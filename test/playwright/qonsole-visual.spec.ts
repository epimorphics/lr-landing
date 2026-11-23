import { test, expect, SMALL_QUERY } from './support/qonsole-page'
import type { QonsolePage } from './support/qonsole-page'

// Screenshot baselines of the SPARQL query console (#247): the web component
// (#224) with the HMLR theme in app/assets/stylesheets/qonsole-component.css.
// When the appearance changes on purpose, review the diffs in the HTML report
// before updating the baselines with `yarn test:e2e --update-snapshots`.
//
// Query responses are stubbed, so the baselines don't depend on the dataset
// or on which environment's endpoint the page uses.
//
// Chromium only (see playwright.config.ts): one set of baselines is enough to
// compare designs.

const DESKTOP = { width: 1280, height: 900 }
const MOBILE = { width: 375, height: 800 }

/** SMALL_QUERY's results as the endpoint returns them for the table format */
const TABLE_RESULTS = [
  '?s\t?p\t?o',
  '<http://landregistry.data.gov.uk/def/common/>\t<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>\t<http://www.w3.org/2002/07/owl#Ontology>',
  '<http://landregistry.data.gov.uk/def/common/>\t<http://www.w3.org/2000/01/rdf-schema#label>\t"Common definitions for Land Registry Linked Data"@en',
  '<http://landregistry.data.gov.uk/def/common/postcode>\t<http://www.w3.org/2000/01/rdf-schema#label>\t"postcode"@en',
].join('\n')

/** A parse error as Fuseki reports it */
const PARSE_ERROR = [
  'Error 400: Parse error: ',
  'SELECT * WHERE { ?s ?p }',
  'Encountered " "}" "} "" at line 1, column 23.',
].join('\n')

async function stubQuery (qonsole: QonsolePage, status: number, contentType: string, body: string) {
  await qonsole.page.route(qonsole.queryRequest, (route) => route.fulfill({ status, contentType, body }))
}

async function expectMainToMatch (qonsole: QonsolePage, name: string) {
  // Keep hover styles out of the baselines
  await qonsole.page.mouse.move(0, 0)
  await qonsole.page.evaluate(() => document.fonts.ready)
  await expect(qonsole.page.locator('main')).toHaveScreenshot(name, {
    mask: [qonsole.summary],
    maxDiffPixelRatio: 0.01,
  })
}

test.beforeEach(async ({ qonsole }) => {
  await qonsole.goto()
  await qonsole.rejectCookies()
})

test.describe('Appearance', () => {
  test('on load at desktop width', async ({ page, qonsole }) => {
    await page.setViewportSize(DESKTOP)
    await expectMainToMatch(qonsole, 'desktop-on-load.png')
  })

  test('with table results at desktop width', async ({ page, qonsole }) => {
    await page.setViewportSize(DESKTOP)
    await stubQuery(qonsole, 200, 'text/tab-separated-values', TABLE_RESULTS)
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.selectFormat('table')
    await qonsole.run()
    await expect(qonsole.resultsTable).toBeVisible()

    await expectMainToMatch(qonsole, 'desktop-table-results.png')
  })

  test('with an error at desktop width', async ({ page, qonsole }) => {
    await page.setViewportSize(DESKTOP)
    await stubQuery(qonsole, 400, 'text/plain', PARSE_ERROR)
    await qonsole.setQuery('SELECT * WHERE { ?s ?p }')
    await qonsole.run()

    await expectMainToMatch(qonsole, 'desktop-error.png')
  })

  test('on load at mobile width', async ({ page, qonsole }) => {
    await page.setViewportSize(MOBILE)
    await expectMainToMatch(qonsole, 'mobile-on-load.png')
  })

  test('with table results at mobile width', async ({ page, qonsole }) => {
    await page.setViewportSize(MOBILE)
    await stubQuery(qonsole, 200, 'text/tab-separated-values', TABLE_RESULTS)
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.selectFormat('table')
    await qonsole.run()
    await expect(qonsole.resultsTable).toBeVisible()

    await expectMainToMatch(qonsole, 'mobile-table-results.png')
  })
})
