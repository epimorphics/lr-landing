import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import type { Locator, Page, Request } from '@playwright/test'

// What the specs need from a query console, whichever implementation is under
// test. See qonsole-page.ts for how one is chosen.

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

export interface QonsolePage {
  readonly page: Page

  /** Glob for the request that runs a query, for error-path tests to intercept */
  readonly queryRequest: string

  goto (search?: string): Promise<void>
  rejectCookies (): Promise<void>

  /** The control that loads the named example query */
  example (name: string): Locator
  loadExample (name: string): Promise<void>
  loadExampleWithKeyboard (name: string): Promise<void>

  prefix (name: string): Locator
  readonly runButton: Locator
  /** Where the skip link should move focus to */
  readonly endpointSelector: Locator
  /** The control showing the endpoint URL queries are sent to */
  readonly endpointInput: Locator
  /** "N results in 0 min 0.123 s" line shown after a query completes */
  readonly summary: Locator
  readonly results: Locator
  readonly resultsTable: Locator
  readonly spinner: Locator

  editorText (): Promise<string>
  setQuery (text: string): Promise<void>
  focusEditor (): Promise<void>
  editorHasFocus (): Promise<boolean>

  selectFormat (format: ResultFormat): Promise<void>

  /** Run the current query and wait for it to finish, successfully or not */
  run (): Promise<void>
}

/** Example query text as the editor shows it (the config uses \r line endings) */
export function normaliseQuery (query: string): string {
  return query.replace(/\r\n?/g, '\n')
}

/** Click run, then wait for the query request to end and the spinner to go */
export async function runAndWait (qonsole: QonsolePage, queryPath: string) {
  const { page } = qonsole
  const isQuery = (request: Request) => new URL(request.url()).pathname.endsWith(queryPath)
  const finished = page.waitForEvent('requestfinished', isQuery)
  const failed = page.waitForEvent('requestfailed', isQuery)
  // Only one of these will fire; stop the other rejecting unobserved on timeout
  finished.catch(() => undefined)
  failed.catch(() => undefined)

  await qonsole.runButton.click()
  await Promise.race([finished, failed])
  await qonsole.spinner.waitFor({ state: 'hidden' })
}
