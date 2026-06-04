const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();

  await page.setViewport({ width: 390, height: 844, deviceScaleFactor: 2 });

  const url = 'https://preview-sandbox--6a1059db497edb3c3384ca87.base44.app?access_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJxem1hc2hhcmExOTk3MDBAZ21haWwuY29tIiwiZXhwIjoxNzg3MjQwMTY1LCJpYXQiOjE3Nzk0NjQxNjV9.i8XVNiGDMGpICRdW7fcvhByUy33M-zyKYhd3W0P8UQw&_preview_token=JGUoB51l1-AFSqthPZ1lg9Yc10HBJza98s7nyFGr5H4';

  console.log('Navigating to app...');
  await page.goto(url, { waitUntil: 'networkidle2', timeout: 60000 });

  // Wait for content to load
  await new Promise(r => setTimeout(r, 5000));

  const outputPath = path.join(__dirname, 'assets', 'main_screen.png');
  await page.screenshot({ path: outputPath, fullPage: false });
  console.log('Screenshot saved to:', outputPath);

  await browser.close();
})();
