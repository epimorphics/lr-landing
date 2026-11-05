import { test, expect, SMALL_QUERY } from './support/qonsole-page'
import type { QonsolePage } from './support/qonsole-page'

// Screenshot baselines of the SPARQL query console (#247), taken from the
// qonsole_rails engine. They are the visual target for theming the web
// component that replaces it (#224): expect these to fail after the swap, and
// review the diffs in the HTML report before updating the baselines with
// `yarn test:e2e --update-snapshots`.
//
// Chromium only (see playwright.config.ts): one set of baselines is enough to
// compare designs.

const DESKTOP = { width: 1280, height: 900 }
const MOBILE = { width: 375, height: 800 }

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
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.selectFormat('table')
    await qonsole.run()
    await expect(qonsole.resultsTable).toBeVisible()

    await expectMainToMatch(qonsole, 'desktop-table-results.png')
  })

  test('with an error at desktop width', async ({ page, qonsole }) => {
    await page.setViewportSize(DESKTOP)
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
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.selectFormat('table')
    await qonsole.run()
    await expect(qonsole.resultsTable).toBeVisible()

    await expectMainToMatch(qonsole, 'mobile-table-results.png')
  })
})
