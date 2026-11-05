import { existsSync, readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import type { Locator, Page } from '@playwright/test'
import { qonsoleConfig, runAndWait } from './qonsole-common'
import type { QonsolePage, ResultFormat } from './qonsole-common'

// The <epi-qonsole> web component from @epimorphics/qonsole (#224), before it
// is installed in this app.
//
// The real /qonsole page is fetched from E2E_BASE_URL and the engine's markup
// inside <main> is swapped for <epi-qonsole>, configured from
// config/qonsole.json. The page keeps the HMLR header, footer and styles, the
// component is themed by app/assets/stylesheets/qonsole-component.css, and it
// sends queries straight to the endpoint on the same origin.
//
// QONSOLE_COMPONENT_JS points at the built bundle; by default a checkout of
// epimorphics/qonsole next to this repo, built with `yarn build`.

const COMPONENT_JS = resolve(
  process.env['QONSOLE_COMPONENT_JS'] ?? '../qonsole/packages/qonsole-wc/dist/qonsole.js',
)

/** The app's theme for the component, injected as the app will include it */
const THEME_CSS = readFileSync(resolve('app/assets/stylesheets/qonsole-component.css'), 'utf8')

/** Path the harness serves the bundle from; never reaches the server */
const COMPONENT_JS_PATH = '/__qonsole-component/qonsole.js'

const QUERY_PATH = new URL(qonsoleConfig.endpoints['default'], 'http://host').pathname

function escapeAttribute (value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

function componentMarkup (): string {
  const { endpoints, prefixes, queries } = qonsoleConfig
  const attribute = (name: string, value: unknown) => `${name}="${escapeAttribute(JSON.stringify(value))}"`

  return `
    <h1 class="heading-large">SPARQL Query Editor</h1>
    <epi-qonsole
      ${attribute('endpoints', endpoints)}
      ${attribute('prefixes', prefixes)}
      ${attribute('queries', queries)}
      allow-queries-from-u-r-l="true"
    ></epi-qonsole>
  `
}

/** The deployed /qonsole page with the engine replaced by the component */
function harness (html: string): string {
  const main = /(<main\b[^>]*>)[\s\S]*?(<\/main>)/
  if (!main.test(html)) throw new Error('No <main> element in the /qonsole page')

  return html
    .replace(main, (_, open: string, close: string) => `${open}${componentMarkup()}${close}`)
    .replace('</head>', `<style>${THEME_CSS}</style><script type="module" src="${COMPONENT_JS_PATH}"></script></head>`)
}

export class ComponentQonsolePage implements QonsolePage {
  readonly page: Page
  readonly queryRequest = `**${QUERY_PATH}`
  private routed = false

  constructor (page: Page) {
    this.page = page
  }

  private async routeHarness () {
    if (this.routed) return
    this.routed = true

    if (!existsSync(COMPONENT_JS)) {
      throw new Error(`Web component bundle not found at ${COMPONENT_JS}; build epimorphics/qonsole or set QONSOLE_COMPONENT_JS`)
    }
    const bundle = readFileSync(COMPONENT_JS)

    await this.page.route(`**${COMPONENT_JS_PATH}`, (route) => route.fulfill({
      body: bundle,
      contentType: 'text/javascript',
    }))

    await this.page.route(
      (url) => url.pathname.replace(/\/$/, '').endsWith('/qonsole'),
      async (route) => {
        if (route.request().resourceType() !== 'document') return route.fallback()
        const response = await route.fetch()
        await route.fulfill({ response, body: harness(await response.text()) })
      },
    )
  }

  private get host (): Locator {
    return this.page.locator('epi-qonsole')
  }

  /** The query editor, as opposed to the read-only editor showing text results */
  private get editor (): Locator {
    return this.host.locator('.qonsole__section .cm-editor')
  }

  async goto (search = '') {
    await this.routeHarness()
    await this.page.goto(`/qonsole${search}`)
    await this.editor.waitFor()
  }

  async rejectCookies () {
    const reject = this.page.getByRole('button', { name: 'Reject additional cookies' })
    if (await reject.isVisible()) await reject.click()
  }

  /** The examples dropdown, if it offers this example; options are never "visible" */
  example (name: string): Locator {
    return this.host.getByLabel('Example queries')
      .filter({ has: this.page.getByRole('option', { name, exact: true }) })
  }

  async loadExample (name: string) {
    await this.host.getByLabel('Example queries').selectOption({ label: name })
  }

  async loadExampleWithKeyboard (name: string) {
    const select = this.host.getByLabel('Example queries')
    const options = await select.getByRole('option').allTextContents()
    const target = options.findIndex((option) => option.trim() === name)
    const current = await select.evaluate((el: HTMLSelectElement) => el.selectedIndex)

    await select.focus()
    const key = target > current ? 'ArrowDown' : 'ArrowUp'
    for (let i = 0; i < Math.abs(target - current); i++) {
      await this.page.keyboard.press(key)
    }
  }

  prefix (name: string): Locator {
    return this.host.getByRole('checkbox', { name, exact: true })
  }

  get runButton (): Locator {
    return this.host.getByRole('button', { name: 'perform query' })
  }

  get endpointSelector (): Locator {
    return this.host.getByLabel('SPARQL endpoint')
  }

  get endpointInput (): Locator {
    return this.host.getByLabel('SPARQL endpoint')
  }

  get summary (): Locator {
    return this.host.getByText(/\d+ results? in \d+ min/)
  }

  get results (): Locator {
    return this.host.locator('.results-pane')
  }

  get resultsTable (): Locator {
    return this.results.getByRole('table')
  }

  get spinner (): Locator {
    return this.host.getByText('Running query…')
  }

  async editorText (): Promise<string> {
    return this.host.evaluate((el) => (el as HTMLElement & { currentQueryText (): string }).currentQueryText())
  }

  async setQuery (text: string) {
    await this.host.evaluate(
      (el, value) => (el as HTMLElement & { setCurrentQueryText (v: string): void }).setCurrentQueryText(value),
      text,
    )
  }

  async focusEditor () {
    await this.editor.locator('.cm-content').focus()
  }

  async editorHasFocus (): Promise<boolean> {
    return this.host.evaluate((el) => !!el.shadowRoot?.activeElement?.closest('.qonsole__section .cm-editor'))
  }

  async selectFormat (format: ResultFormat) {
    await this.host.getByLabel('Results format').selectOption({ label: format })
  }

  async run () {
    await runAndWait(this, QUERY_PATH)
  }
}
