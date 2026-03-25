import { defineConfig } from '@playwright/test';

// 优先使用系统安装的 Chrome，避免 Playwright 下载管理浏览器
const use: any = { headless: true };
if (process.env.PLAYWRIGHT_EXECUTABLE_PATH) {
  use.launchOptions = { executablePath: process.env.PLAYWRIGHT_EXECUTABLE_PATH };
} else {
  use.channel = 'chrome';
}

export default defineConfig({
  testDir: __dirname,
  testMatch: ['*.spec.ts'],
  timeout: 60_000,
  retries: 0,
  reporter: 'line',
  use,
});
