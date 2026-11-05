import { AxeBuilder } from '@axe-core/playwright'
import { test, expect, SMALL_QUERY } from './support/qonsole-page'
import type { QonsolePage } from './support/qonsole-page'

// Accessibility scans of the SPARQL query console (#247). The header and
// footer come from lr_common_styles, so only <main> is scanned.
//
// KNOWN_VIOLATIONS lists the problems the qonsole_rails engine has today,
// matched node by node so that a new problem of the same kind still fails.
// The web component replacement (#224) must not add to this list, and should
// let us empty it.

const WCAG_TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa']

// axe-core is only a transitive dependency, so take its result type from AxeBuilder
type Violation = Awaited<ReturnType<AxeBuilder['analyze']>>['violations'][number]

interface KnownViolation {
  rule: string
  reason: string
  matches: (html: string) => boolean
}

const KNOWN_VIOLATIONS: KnownViolation[] = [
  {
    rule: 'label',
    reason: 'CodeMirror 5 editors (query and text results) use an unlabelled hidden textarea',
    matches: (html) => html.startsWith('<textarea'),
  },
  {
    rule: 'color-contrast',
    reason: 'DataTables disabled Previous/Next links are #777 on white (4.47:1)',
    matches: (html) => html.includes('data-dt-idx'),
  },
]

/** Violations not covered by KNOWN_VIOLATIONS, as "rule: html" lines */
function unexpected (violations: Violation[]): string[] {
  return violations.flatMap(({ id, nodes }) => nodes
    .filter(({ html }) => !KNOWN_VIOLATIONS.some((known) => known.rule === id && known.matches(html)))
    .map(({ html }) => `${id}: ${html}`))
}

async function expectNoNewViolations (qonsole: QonsolePage) {
  const { violations } = await new AxeBuilder({ page: qonsole.page })
    .include('main')
    .withTags(WCAG_TAGS)
    .analyze()

  for (const { id, nodes } of violations) {
    test.info().annotations.push({ type: 'axe', description: `${id} (${nodes.length} nodes)` })
  }
  expect(unexpected(violations)).toEqual([])
}

test.beforeEach(async ({ qonsole }) => {
  await qonsole.goto()
})

test.describe('Accessibility', () => {
  test('page on load has no new violations', async ({ qonsole }) => {
    await expectNoNewViolations(qonsole)
  })

  test('table results have no new violations', async ({ qonsole }) => {
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.selectFormat('table')
    await qonsole.run()
    await expect(qonsole.resultsTable).toBeVisible()

    await expectNoNewViolations(qonsole)
  })

  test('text results have no new violations', async ({ qonsole }) => {
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.selectFormat('plain text')
    await qonsole.run()
    await expect(qonsole.summary).toBeVisible()

    await expectNoNewViolations(qonsole)
  })

  test('error message has no new violations', async ({ page, qonsole }) => {
    await page.route(qonsole.queryRequest, (route) => route.fulfill({ status: 500, body: 'Internal Server Error' }))
    await qonsole.setQuery(SMALL_QUERY)
    await qonsole.run()

    await expectNoNewViolations(qonsole)
  })
})
