import { defineConfig } from '@playwright/test';

// Prefer the system-installed Chrome to avoid Playwright's managed-browser downloads.
// Override via PLAYWRIGHT_EXECUTABLE_PATH if needed.
const use: any = { headless: true };
if (process.env.PLAYWRIGHT_EXECUTABLE_PATH) {
  use.launchOptions = { executablePath: process.env.PLAYWRIGHT_EXECUTABLE_PATH };
} else {
  use.channel = 'chrome';
}

export default defineConfig({
  testDir: __dirname,
  testMatch: ['**/*.spec.ts'],
  timeout: 60_000,
  retries: 0,
  reporter: 'line',
  use,
});
