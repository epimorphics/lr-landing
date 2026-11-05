import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { test as base } from '@playwright/test'
import type { Locator, Page, Request } from '@playwright/test'

// Page object for the SPARQL query console.
//
// The specs describe behaviour a user can see; everything that depends on how
// the console is built (CodeMirror API, dropdown markup, the request it makes)
// lives here, so the same specs can run against the qonsole_rails engine and
// its web component replacement (#224) with only this file changing.

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

/** Path of the request the browser makes to run a query */
const QUERY_PATH = '/qonsole/query'

/** Glob for the query request, for error-path tests to intercept */
export const QUERY_REQUEST = `**${QUERY_PATH}`

/** Small query that returns three rows from the live dataset */
export const SMALL_QUERY = 'SELECT * WHERE { ?s ?p ?o } LIMIT 3'

export type ResultFormat = 'table' | 'plain text' | 'JSON' | 'XML'

export class QonsolePage {
  readonly page: Page

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

  /** "N results in 0 min 0.123 s" line shown after a query completes */
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

/** Example query text as the editor shows it (the config uses \r line endings) */
export function normaliseQuery (query: string): string {
  return query.replace(/\r\n?/g, '\n')
}

export const test = base.extend<{ qonsole: QonsolePage }>({
  qonsole: async ({ page }, use) => {
    await use(new QonsolePage(page))
  },
})

export { expect } from '@playwright/test'
