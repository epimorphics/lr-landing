import { AxeBuilder } from '@axe-core/playwright'
import { test, expect, SMALL_QUERY } from './support/qonsole-page'
import type { QonsolePage } from './support/qonsole-page'

// Accessibility scans of the SPARQL query console (#247). The header and
// footer come from lr_common_styles, so only <main> is scanned.
//
// The qonsole_rails engine had known violations (an unlabelled CodeMirror 5
// textarea, low-contrast DataTables paging links); the web component that
// replaced it (#224) has none, so any violation fails.

const WCAG_TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa']

async function expectNoViolations (qonsole: QonsolePage) {
  const { violations } = await new AxeBuilder({ page: qonsole.page })
    .include('main')
    .withTags(WCAG_TAGS)
    .analyze()

  // As "rule: html" lines, so a failure says what is wrong and where
  expect(violations.flatMap(({ id, nodes }) => nodes.map(({ html }) => `${id}: ${html}`))).toEqual([])
}

test.beforeEach(async ({ qonsole }) => {
  await qonsole.goto()
})

test.describe('Accessibility', () => {
  test('page on load has no violations', async ({ qonsole }) => {
    await expectNoViolations(qonsole)
  })

  test('table results have no violations', async ({ qonsole }) => {
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.selectFormat('table')
    await qonsole.run()
    await expect(qonsole.resultsTable).toBeVisible()

    await expectNoViolations(qonsole)
  })

  test('text results have no violations', async ({ qonsole }) => {
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.selectFormat('plain text')
    await qonsole.run()
    await expect(qonsole.summary).toBeVisible()

    await expectNoViolations(qonsole)
  })

  test('error message has no violations', async ({ page, qonsole }) => {
    await page.route(qonsole.queryRequest, (route) => route.fulfill({ status: 500, body: 'Internal Server Error' }))
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.run()

    await expectNoViolations(qonsole)
  })
})
