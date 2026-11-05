import type { Locator, Page } from '@playwright/test'
import { runAndWait } from './qonsole-common'
import type { QonsolePage, ResultFormat } from './qonsole-common'

// The qonsole_rails engine mounted at /qonsole: CodeMirror 5, Bootstrap
// dropdowns, queries proxied through the engine's controller.

const QUERY_PATH = '/qonsole/query'

export class EngineQonsolePage implements QonsolePage {
  readonly page: Page
  readonly queryRequest = `**${QUERY_PATH}`

  constructor (page: Page) {
    this.page = page
  }

  async goto (search = '') {
    await this.page.goto(`/qonsole${search}`)
    await this.page.locator('.CodeMirror').waitFor()
  }

  async rejectCookies () {
    const reject = this.page.getByRole('button', { name: 'Reject additional cookies' })
    if (await reject.isVisible()) await reject.click()
  }

  example (name: string): Locator {
    return this.page.getByRole('button', { name, exact: true })
  }

  async loadExample (name: string) {
    await this.example(name).click()
  }

  async loadExampleWithKeyboard (name: string) {
    await this.example(name).focus()
    await this.page.keyboard.press('Enter')
  }

  prefix (name: string): Locator {
    return this.page.getByRole('checkbox', { name, exact: true })
  }

  get runButton (): Locator {
    return this.page.getByRole('button', { name: 'perform query' })
  }

  get endpointSelector (): Locator {
    return this.page.getByRole('button', { name: /Select endpoint/ })
  }

  get endpointInput (): Locator {
    return this.page.getByRole('textbox', { name: 'SPARQL endpoint' })
  }

  get summary (): Locator {
    return this.page.getByText(/\d+ results? in \d+ min/)
  }

  get results (): Locator {
    return this.page.locator('#results')
  }

  get resultsTable (): Locator {
    return this.results.getByRole('grid').or(this.results.getByRole('table'))
  }

  get spinner (): Locator {
    return this.page.getByAltText('waiting for server action to complete')
  }

  async editorText (): Promise<string> {
    return this.page.evaluate(() => {
      const el = document.querySelector('.CodeMirror') as (Element & { CodeMirror: { getValue (): string } }) | null
      return el?.CodeMirror.getValue() ?? ''
    })
  }

  async setQuery (text: string) {
    await this.page.evaluate((value) => {
      const el = document.querySelector('.CodeMirror') as (Element & { CodeMirror: { setValue (v: string): void } }) | null
      el?.CodeMirror.setValue(value)
    }, text)
  }

  async focusEditor () {
    await this.page.locator('.CodeMirror textarea').focus()
  }

  async editorHasFocus (): Promise<boolean> {
    return this.page.evaluate(() => !!document.activeElement?.closest('.CodeMirror'))
  }

  async selectFormat (format: ResultFormat) {
    await this.page.getByRole('button', { name: /^Results/ }).click()
    await this.page.getByRole('menuitem', { name: format, exact: true }).click()
  }

  async run () {
    await runAndWait(this, QUERY_PATH)
  }
}
