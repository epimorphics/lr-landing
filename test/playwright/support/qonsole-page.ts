import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { test as base } from '@playwright/test'
import type { Locator, Page, Request } from '@playwright/test'

// Page object for the SPARQL query console: the <epi-qonsole> web component
// from @epimorphics/qonsole (#224).
//
// The specs describe behaviour a user can see; everything that depends on how
// the console is built (shadow DOM, editor API, the request it makes) lives
// here.

export interface ExampleQuery {
  name: string
  query: string
}

export interface QonsoleConfig {
  endpoints: Record<string, string>
  prefixes: Record<string, string>
  queries: ExampleQuery[]
}

export const qonsoleConfig: QonsoleConfig = JSON.parse(
  readFileSync(join(process.cwd(), 'config/qonsole.json'), 'utf8'),
)

/** Small query that returns three rows from the live dataset */
export const SMALL_QUERY = 'SELECT * WHERE { ?s ?p ?o } LIMIT 3'

export type ResultFormat = 'table' | 'plain text' | 'JSON' | 'XML'

/** Example query text as the editor shows it (the config uses \r line endings) */
export function normaliseQuery (query: string): string {
  return query.replace(/\r\n?/g, '\n')
}

/**
 * Path of the SPARQL endpoint. Deployed, queries go to it on the same host; a
 * local server sends them to the dev endpoint, which has the same path
 */
const QUERY_PATH = new URL(qonsoleConfig.endpoints['default'], 'http://host').pathname

export class QonsolePage {
  readonly page: Page

  /** Glob for the request that runs a query, for error-path tests to intercept */
  readonly queryRequest = `**${QUERY_PATH}`

  constructor (page: Page) {
    this.page = page
  }

  private get host (): Locator {
    return this.page.locator('epi-qonsole')
  }

  /** The query editor, as opposed to the read-only editor showing text results */
  private get editor (): Locator {
    return this.host.locator('.qonsole__section .cm-editor')
  }

  async goto (search = '') {
    await this.page.goto(`/qonsole${search}`)
    await this.editor.waitFor()
  }

  async rejectCookies () {
    const reject = this.page.getByRole('button', { name: 'Reject additional cookies' })
    if (await reject.isVisible()) await reject.click()
  }

  /**
   * The default endpoint the page gives the component: config/qonsole.json's
   * (checked by test/integration/qonsole_test.rb), or the dev endpoint when
   * the page comes from a local server
   */
  async defaultEndpoint (): Promise<string> {
    const endpoints = JSON.parse(await this.host.getAttribute('endpoints') ?? '{}')
    if (!endpoints['default']) throw new Error('<epi-qonsole> has no default endpoint')
    return endpoints['default']
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

  /** The endpoint dropdown: where the skip link moves focus, and whose value is the URL queries go to */
  get endpointSelector (): Locator {
    return this.host.getByLabel('SPARQL endpoint')
  }

  /** "N results in 0 min 0.123 s" line shown after a query completes */
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

  /** Run the current query and wait for it to finish, successfully or not */
  async run () {
    const isQuery = (request: Request) => new URL(request.url()).pathname.endsWith(QUERY_PATH)
    const finished = this.page.waitForEvent('requestfinished', isQuery)
    const failed = this.page.waitForEvent('requestfailed', isQuery)
    // Only one of these will fire; stop the other rejecting unobserved on timeout
    finished.catch(() => undefined)
    failed.catch(() => undefined)

    await this.runButton.click()
    await Promise.race([finished, failed])
    await this.spinner.waitFor({ state: 'hidden' })
  }
}

export const test = base.extend<{ qonsole: QonsolePage }>({
  qonsole: async ({ page }, use) => {
    await use(new QonsolePage(page))
  },
})

export { expect } from '@playwright/test'
