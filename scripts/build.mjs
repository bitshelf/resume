import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { chromium } from 'playwright';
import { PDFDocument } from 'pdf-lib';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const output = resolve(root, 'output/html');
await mkdir(output, { recursive: true });

// Export a standalone HTML with the same local fonts and original QR code.
let html = await readFile(resolve(root, 'resume.html'), 'utf8');
for (const [path, type] of [
  ['fonts/NotoSansSC.ttf', 'font/ttf'],
  ['fonts/SourceSans3-Regular.otf', 'font/otf'],
  ['fonts/SourceSans3-Bold.otf', 'font/otf'],
  ['assets/qrcode.png', 'image/png'],
]) {
  const bytes = await readFile(resolve(root, path));
  html = html.replaceAll(path, `data:${type};base64,${bytes.toString('base64')}`);
}
const htmlPath = resolve(output, 'resume.html');
await writeFile(htmlPath, html);

const browser = await chromium.launch({
  ...(process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : {}),
});
try {
  const page = await browser.newPage({ viewport: { width: 1100, height: 1300 }, deviceScaleFactor: 1.5 });
  const failures = [];
  page.on('pageerror', error => failures.push(error.message));
  page.on('requestfailed', request => failures.push(request.url()));
  await page.goto(pathToFileURL(htmlPath).href, { waitUntil: 'load' });
  await page.evaluate(async () => {
    await document.fonts.ready;
    await Promise.all([...document.images].map(img => img.decode()));
  });
  if (failures.length) throw new Error(`Page failed to load: ${failures.join(', ')}`);
  await page.emulateMedia({ media: 'print' });
  const pdf = await page.pdf({ format: 'A4', preferCSSPageSize: true, printBackground: true, displayHeaderFooter: false });
  const document = await PDFDocument.load(pdf);
  if (document.getPageCount() !== 1) throw new Error(`Expected one page, got ${document.getPageCount()}`);
  await writeFile(resolve(output, 'resume.pdf'), pdf);
  await page.locator('.resume').screenshot({ path: resolve(output, 'preview-1.png') });
  await page.emulateMedia({ media: 'screen' });
  await page.setViewportSize({ width: 390, height: 844 });
  const overflows = await page.evaluate(() => document.documentElement.scrollWidth > innerWidth);
  if (overflows) throw new Error('Mobile layout overflows horizontally');
  await page.screenshot({ path: resolve(output, 'preview-mobile.png'), fullPage: true });
  console.log('Built standalone HTML, single-page A4 PDF, print and mobile previews in output/html/');
} finally {
  await browser.close();
}
