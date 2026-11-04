import { test, expect, normaliseQuery, qonsoleConfig, QUERY_REQUEST, SMALL_QUERY } from './support/qonsole-page'
import type { QonsolePage } from './support/qonsole-page'

// Regression suite for the SPARQL query console (#247), written against the
// qonsole_rails engine before it is replaced by the web component (#224).
// Assertions describe what a user sees, not how the page is built; see
// support/qonsole-page.ts for the parts that depend on the implementation.
//
// Queries run against the live dataset, so point E2E_BASE_URL at a deployed
// environment. The queries used are small enough for the dev hosts.

const { queries: examples, prefixes, endpoints } = qonsoleConfig

/** A query that matches nothing in the dataset */
const EMPTY_QUERY = 'SELECT * WHERE { <http://example.com/no-such-resource> ?p ?o }'

const DESCRIBE_QUERY = 'DESCRIBE <http://landregistry.data.gov.uk/def/common/>'

async function expectErrorShown (qonsole: QonsolePage) {
  await expect(qonsole.results).not.toHaveText(/^\s*(Query results)?\s*$/)
  await expect(qonsole.resultsTable).toHaveCount(0)
  await expect(qonsole.runButton).toBeEnabled()
}

test.beforeEach(async ({ qonsole }) => {
  await qonsole.goto()
})

// ── Page ──────────────────────────────────────────────────────────────────────

test.describe('Page', () => {
  test('has a page heading and a heading for each section', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 1 })).toHaveText('SPARQL Query Editor')
    for (const name of ['Example queries', 'Prefixes', 'Query results']) {
      await expect(page.getByRole('heading', { level: 2, name })).toBeVisible()
    }
  })

  test('offers each configured example query', async ({ qonsole }) => {
    for (const { name } of examples) {
      await expect(qonsole.example(name)).toBeVisible()
    }
  })

  test('offers each configured prefix, all selected', async ({ qonsole }) => {
    for (const name of Object.keys(prefixes)) {
      await expect(qonsole.prefix(name)).toBeChecked()
    }
  })

  test('opens with the first example and all prefix declarations in the editor', async ({ qonsole }) => {
    await expect.poll(() => qonsole.editorText()).toContain(normaliseQuery(examples[0].query).trim())

    const text = await qonsole.editorText()
    for (const [name, uri] of Object.entries(prefixes)) {
      expect(text).toContain(`prefix ${name}: <${uri}>`)
    }
  })

  test('shows the default endpoint', async ({ qonsole }) => {
    await expect(qonsole.endpointInput).toHaveValue(endpoints['default'])
  })
})

// ── Example queries ───────────────────────────────────────────────────────────

test.describe('Example queries', () => {
  for (const { name, query } of examples) {
    test(`"${name}" loads into the editor and returns results`, async ({ qonsole }) => {
      await qonsole.example(name).click()
      await expect.poll(() => qonsole.editorText()).toContain(normaliseQuery(query).trim())

      await qonsole.run()

      await expect(qonsole.summary).toHaveText(/^[1-9]\d* results? in/)
      expect(await qonsole.resultsTable.getByRole('row').count()).toBeGreaterThan(1)
    })
  }
})

// ── Result formats ────────────────────────────────────────────────────────────

test.describe('Result formats', () => {
  test.beforeEach(async ({ qonsole }) => {
    await qonsole.setQuery(SMALL_QUERY)
  })

  test('table shows a column per variable and a row per result', async ({ qonsole }) => {
    await qonsole.selectFormat('table')
    await qonsole.run()

    await expect(qonsole.summary).toHaveText(/^3 results in/)
    await expect(qonsole.resultsTable.getByRole('columnheader')).toHaveText(['s', 'p', 'o'])
    // Header row plus three result rows
    await expect(qonsole.resultsTable.getByRole('row')).toHaveCount(4)
  })

  test('plain text shows the SPARQL text table', async ({ qonsole }) => {
    await qonsole.selectFormat('plain text')
    await qonsole.run()

    await expect(qonsole.resultsTable).toHaveCount(0)
    await expect(qonsole.results).toContainText(/\|\s*s\s*\|\s*p\s*\|\s*o\s*\|/)
  })

  test('JSON shows SPARQL JSON results', async ({ qonsole }) => {
    await qonsole.selectFormat('JSON')
    await qonsole.run()

    await expect(qonsole.resultsTable).toHaveCount(0)
    await expect(qonsole.results).toContainText('"bindings"')
  })

  test('XML shows SPARQL XML results', async ({ qonsole }) => {
    await qonsole.selectFormat('XML')
    await qonsole.run()

    await expect(qonsole.resultsTable).toHaveCount(0)
    await expect(qonsole.results).toContainText('<sparql')
  })

  test('DESCRIBE results are shown as text', async ({ qonsole }) => {
    await qonsole.setQuery(DESCRIBE_QUERY)
    await qonsole.selectFormat('plain text')
    await qonsole.run()

    await expect(qonsole.results).toContainText('Common definitions for Land Registry Linked Data')
  })

  test('DESCRIBE results are shown as text even when table is selected', async ({ qonsole }) => {
    // Known defect in qonsole_rails: it asks the endpoint for a table, which
    // fails with a server error. The web component switches to text (#224);
    // remove this marker when this test starts passing.
    test.fail()

    await qonsole.setQuery(DESCRIBE_QUERY)
    await qonsole.selectFormat('table')
    await qonsole.run()

    await expect(qonsole.resultsTable).toHaveCount(0)
    await expect(qonsole.results).toContainText('Common definitions for Land Registry Linked Data')
  })

  test('a query with no matches reports zero results', async ({ qonsole }) => {
    await qonsole.setQuery(EMPTY_QUERY)
    await qonsole.run()

    await expect(qonsole.summary).toHaveText(/^0 results in/)
  })
})

// ── Prefixes ──────────────────────────────────────────────────────────────────

test.describe('Prefixes', () => {
  test('unselecting a prefix removes its declaration and selecting it restores it', async ({ qonsole }) => {
    const declaration = `prefix owl: <${prefixes['owl']}>`

    await qonsole.prefix('owl').uncheck()
    await expect.poll(() => qonsole.editorText()).not.toContain(declaration)

    await qonsole.prefix('owl').check()
    await expect.poll(() => qonsole.editorText()).toContain(declaration)
  })
})

// ── Links from other applications ─────────────────────────────────────────────

test.describe('Links from other applications', () => {
  const query = 'SELECT ?p WHERE { ?s ?p ?o } LIMIT 1'

  test('?q= loads the query (Price Paid Data "show SPARQL" link)', async ({ qonsole }) => {
    await qonsole.goto(`?q=${encodeURIComponent(query)}`)
    await expect.poll(() => qonsole.editorText()).toContain(query)
  })

  test('?query= loads the query', async ({ qonsole }) => {
    await qonsole.goto(`?query=${encodeURIComponent(query)}`)
    await expect.poll(() => qonsole.editorText()).toContain(query)
  })

  test('?query=_localstore loads the query UKHPI saved in session storage', async ({ page, qonsole }) => {
    await page.evaluate((value) => sessionStorage.setItem('qonsole.query', value), query)
    await qonsole.goto('?query=_localstore')

    await expect.poll(() => qonsole.editorText()).toContain(query)
    expect(await qonsole.editorText()).not.toContain('_localstore')
  })
})

// ── Errors and loading ────────────────────────────────────────────────────────

test.describe('Errors and loading', () => {
  test.beforeEach(async ({ qonsole }) => {
    await qonsole.setQuery(SMALL_QUERY)
  })

  test('shows a loading indicator while the query runs', async ({ page, qonsole }) => {
    await page.route(QUERY_REQUEST, async (route) => {
      await new Promise((resolve) => setTimeout(resolve, 1500))
      await route.continue()
    })

    await qonsole.runButton.click()
    await expect(qonsole.spinner).toBeVisible()
    await expect(qonsole.spinner).toBeHidden({ timeout: 15_000 })
    await expect(qonsole.summary).toBeVisible()
  })

  test('shows an error when the query service fails', async ({ page, qonsole }) => {
    await page.route(QUERY_REQUEST, (route) => route.fulfill({ status: 500, body: 'Internal Server Error' }))
    await qonsole.run()
    await expectErrorShown(qonsole)
  })

  test('shows an error when the query service is unavailable', async ({ page, qonsole }) => {
    await page.route(QUERY_REQUEST, (route) => route.fulfill({ status: 502, body: '' }))
    await qonsole.run()
    await expectErrorShown(qonsole)
  })

  test('shows an error when the network request fails', async ({ page, qonsole }) => {
    await page.route(QUERY_REQUEST, (route) => route.abort('failed'))
    await qonsole.run()
    await expectErrorShown(qonsole)
  })

  test('shows an error for an invalid query', async ({ qonsole }) => {
    await qonsole.setQuery('SELECT * WHERE { ?s ?p }')
    await qonsole.run()
    await expectErrorShown(qonsole)
  })
})

// ── Keyboard ──────────────────────────────────────────────────────────────────

test.describe('Keyboard', () => {
  test('Escape leaves the editor', async ({ page, qonsole }) => {
    await qonsole.focusEditor()
    await page.keyboard.press('Escape')
    expect(await qonsole.editorHasFocus()).toBe(false)
  })

  test('Shift+Tab leaves the editor', async ({ page, qonsole }) => {
    await qonsole.focusEditor()
    await page.keyboard.press('Shift+Tab')
    expect(await qonsole.editorHasFocus()).toBe(false)
  })

  test('Tab stays in the editor for indentation', async ({ page, qonsole }) => {
    await qonsole.focusEditor()
    await page.keyboard.press('Tab')
    expect(await qonsole.editorHasFocus()).toBe(true)
  })

  test('skip link moves focus past the editor to endpoint selection', async ({ page, qonsole }) => {
    await page.getByRole('button', { name: /Skip SPARQL editor/ }).click()
    await expect(qonsole.endpointSelector).toBeFocused()
  })

  test('an example can be loaded and run without a mouse', async ({ page, qonsole }) => {
    const { name, query } = examples[1]

    await qonsole.example(name).focus()
    await page.keyboard.press('Enter')
    await expect.poll(() => qonsole.editorText()).toContain(normaliseQuery(query).trim())

    await qonsole.runButton.focus()
    await page.keyboard.press('Enter')
    await expect(qonsole.summary).toHaveText(/^[1-9]\d* results? in/)
  })
})
