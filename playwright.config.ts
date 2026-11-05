import { defineConfig, devices } from '@playwright/test'

const rawBaseURL = process.env['E2E_BASE_URL'] ?? 'http://localhost:3000/'
const baseURL = rawBaseURL.endsWith('/') ? rawBaseURL : `${rawBaseURL}/`

export default defineConfig({
  testDir: 'test/playwright',
  outputDir: 'tmp/test-results',
  reporter: [['html', { outputFolder: 'tmp/playwright-report', open: 'never' }]],
  timeout: 60_000,
  workers: 1,

  use: {
    baseURL,
    screenshot: 'only-on-failure',
    ...(process.env['E2E_USERNAME']
      ? {
        httpCredentials: {
          username: process.env['E2E_USERNAME'],
          password: process.env['E2E_PASSWORD'] ?? '',
        },
      }
      : {}),
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // Screenshot baselines are kept for Chromium only
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
      testIgnore: /-visual\.spec\.ts$/,
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
      testIgnore: /-visual\.spec\.ts$/,
    },
  ],

  webServer: process.env['E2E_BASE_URL']
    ? undefined
    : {
      command: 'bin/rails server -p 3000',
      url: 'http://localhost:3000',
      reuseExistingServer: true,
      timeout: 60_000,
    },
})
