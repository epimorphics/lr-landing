import { test as base } from '@playwright/test'
import { ComponentQonsolePage } from './qonsole-component'
import { EngineQonsolePage } from './qonsole-engine'
import type { QonsolePage } from './qonsole-common'

// Page object for the SPARQL query console.
//
// The specs describe behaviour a user can see; everything that depends on how
// the console is built (editor API, dropdown markup, the request it makes)
// lives behind the QonsolePage interface, so the same specs run against the
// qonsole_rails engine and its web component replacement (#224).
//
// QONSOLE_IMPL chooses which: `engine` (default, what the app serves today)
// or `component` (see qonsole-component.ts).

const IMPLEMENTATIONS = {
  engine: EngineQonsolePage,
  component: ComponentQonsolePage,
}

export type QonsoleImpl = keyof typeof IMPLEMENTATIONS

function selectedImpl (): QonsoleImpl {
  const impl = process.env['QONSOLE_IMPL'] ?? 'engine'
  if (!(impl in IMPLEMENTATIONS)) {
    throw new Error(`QONSOLE_IMPL must be one of ${Object.keys(IMPLEMENTATIONS).join(', ')}, not "${impl}"`)
  }
  return impl as QonsoleImpl
}

export const QONSOLE_IMPL = selectedImpl()

export const test = base.extend<{ qonsole: QonsolePage }>({
  qonsole: async ({ page }, use) => {
    await use(new IMPLEMENTATIONS[QONSOLE_IMPL](page))
  },
})

export { expect } from '@playwright/test'
export { normaliseQuery, qonsoleConfig, SMALL_QUERY } from './qonsole-common'
export type { ExampleQuery, QonsoleConfig, QonsolePage, ResultFormat } from './qonsole-common'
