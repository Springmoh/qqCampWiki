// Screenshots for the wiki's user guide, from the throwaway server that
// shoot.sh starts (never the camp's own): node capture.mjs <projectRoot>
//   <stationPageToken> <outDir> [systemHealth.json with the console account]
// Phones are 390 x 844 CSS px at 2x; laptops 1280 x 800 at 1x. Each part is
// its own step: one that fails is reported and the rest still run.
//
// @author Springmoh
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';

const [root, stationPage, out, health] = process.argv.slice(2);
const require = createRequire(path.join(root, 'tools/tutorialVideo/package.json'));
const puppeteer = require('puppeteer-core');
fs.mkdirSync(out, { recursive: true });

const PLAYER = 'http://127.0.0.1:19000';
const ADMIN = 'http://127.0.0.1:19443';
const STATION = 'http://127.0.0.1:19800';
const GM = 'http://127.0.0.1:19600';
const EVENT = 'http://127.0.0.1:19900';
const admin = JSON.parse(fs.readFileSync(health || path.join(root, 'devConfig/systemHealth.json'), 'utf8')).admin;

const IPHONE_UA = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1';
const PHONE = { width: 390, height: 844, deviceScaleFactor: 2, isMobile: true, hasTouch: true };
const LAPTOP = { width: 1280, height: 800, deviceScaleFactor: 1 };

const browser = await puppeteer.launch({
  protocolTimeout: 60000,
  executablePath: '/usr/bin/google-chrome',
  headless: 'new',
  args: ['--force-prefers-reduced-motion', '--lang=zh-CN'],
});
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
let failed = 0;

/** @brief One PNG of the page as it is now. @author Springmoh */
async function shot(page, name, wait = 900) {
  await sleep(wait);
  await page.screenshot({ path: `${out}/${name}.png` });
  console.log('shot', name);
}

/** @brief Run one part; a failure is logged, never fatal. @author Springmoh */
async function step(name, fn) {
  try {
    await fn();
  } catch (err) {
    failed += 1;
    console.error(`step ${name} failed: ${err.message}`);
  }
}

/** @brief A fresh, cookie-less window (its own browser context) of the given size. @author Springmoh */
async function device(size, ua) {
  const context = await browser.createBrowserContext();
  const page = await context.newPage();
  if (ua) await page.setUserAgent(ua);
  await page.setViewport(size);
  page.on('dialog', (d) => d.accept());
  return page;
}

/** @brief Sign in through a page's own form, then wait for the next page. @author Springmoh */
async function signIn(page, origin, user, password) {
  await page.goto(`${origin}/`, { waitUntil: 'networkidle0' });
  await page.type('#username', user);
  await page.type('#password', password);
  await Promise.all([page.waitForNavigation({ waitUntil: 'networkidle0' }), page.click('#submit')]);
}

/** @brief Click the first element matching `selector` whose text contains `text`. @author Springmoh */
async function clickText(page, selector, text) {
  const ok = await page.$$eval(selector, (all, want) => {
    const hit = all.find((el) => el.textContent.includes(want));
    if (hit) hit.click();
    return Boolean(hit);
  }, text);
  if (!ok) throw new Error(`no ${selector} with "${text}"`);
}

// --- player: the danger sequence screens ----------------------------------------
await step('player danger', async () => {
  const p = await device(PHONE, IPHONE_UA);
  await signIn(p, PLAYER, 'nicholas', 'camp1234');
  await p.waitForSelector('#popout .popout__card', { timeout: 15000 });
  await shot(p, 'p-danger', 1500);
});
await step('player locked', async () => {
  const p = await device(PHONE, IPHONE_UA);
  await signIn(p, PLAYER, 'weiming', 'camp1234');
  await shot(p, 'p-locked', 1800);
});
await step('player queue', async () => {
  const p = await device(PHONE, IPHONE_UA);
  await signIn(p, PLAYER, '旋风队', 'camp1234');
  await shot(p, 'p-queue', 1800);
});
await step('player hall', async () => {
  const p = await device(PHONE, IPHONE_UA);
  await signIn(p, PLAYER, '小狮子', 'camp1234');
  await shot(p, 'p-hall-wait', 1800);
});

// --- station laptop ---------------------------------------------------------------
await step('station', async () => {
  const s = await device(LAPTOP);
  await s.goto(`${STATION}/s/${stationPage}`, { waitUntil: 'networkidle0' });
  await shot(s, 's-station', 1500);
  await clickText(s, '#inside button', '');
  await s.waitForSelector('#quiz-pick-input', { visible: true, timeout: 5000 });
  await s.type('#quiz-pick-input', 'L20793');
  await shot(s, 's-quiz-pick', 400);
  await s.click('#quiz-pick-submit');
  await s.waitForSelector('#quiz-input', { visible: true, timeout: 8000 });
  await s.type('#quiz-input', '200');
  await shot(s, 's-quiz', 400);
  await s.click('#quiz-submit');
  await s.waitForSelector('#quiz-result', { visible: true, timeout: 8000 });
  await shot(s, 's-quiz-wrong', 1200);
});

// --- game master ------------------------------------------------------------------
await step('game master', async () => {
  const g = await device(PHONE, IPHONE_UA);
  await g.goto(`${GM}/`, { waitUntil: 'networkidle0' });
  await shot(g, 'gm-login', 700);
  await signIn(g, GM, 'gm-ali', 'gm123456');
  await shot(g, 'gm-overview', 1500);
  await g.click('.gm-picker');
  await g.waitForSelector('#gm-pick-popout', { visible: true, timeout: 5000 });
  await shot(g, 'gm-pick', 800);
  await g.keyboard.press('Escape');
  await sleep(400);
  await g.evaluate(() => document.querySelector('#gm-pick-popout .popout__close, #gm-pick-popout button.secondary')?.click());
  await sleep(400);
  await g.click('.gm-station__qr');
  await g.waitForSelector('#gm-qr-popout', { visible: true, timeout: 5000 });
  await shot(g, 'gm-qr', 1000);
  await g.goto(`${GM}/wallet`, { waitUntil: 'networkidle0' });
  await shot(g, 'gm-wallet', 1200);
});

// --- event team -------------------------------------------------------------------
await step('event team', async () => {
  const e = await device(LAPTOP);
  await e.goto(`${EVENT}/`, { waitUntil: 'networkidle0' });
  await shot(e, 'et-main', 1500);
  await e.click('#namelist-open');
  await shot(e, 'et-namelist', 1200);
  await e.keyboard.press('Escape');
  await sleep(400);
  await e.goto(`${EVENT}/`, { waitUntil: 'networkidle0' });
  await e.click('#danger-open');
  await e.waitForSelector('#mode-popout', { visible: true, timeout: 5000 });
  await shot(e, 'et-mode', 800);
  await e.click('#mode-manual');
  await e.waitForSelector('#danger-popout', { visible: true, timeout: 5000 });
  await shot(e, 'et-danger', 800);
});
await step('event team check-in', async () => {
  const c = await device(PHONE);
  await c.goto(`${EVENT}/checkin`, { waitUntil: 'networkidle0' });
  await shot(c, 'et-checkin', 1200);
  await c.click('#todo button');
  await c.waitForSelector('#confirm', { visible: true, timeout: 5000 });
  await shot(c, 'et-confirm', 800);
  await c.click('#confirm-yes');
  await sleep(1500);
});
await step('player hall running', async () => {
  // the team the check-in page just started (the first in its list)
  const p = await device(PHONE, IPHONE_UA);
  await signIn(p, PLAYER, '小狮子', 'camp1234');
  await shot(p, 'p-hall', 1800);
});

// --- console ----------------------------------------------------------------------
await step('console', async () => {
  const a = await device(LAPTOP);
  await signIn(a, ADMIN, admin.admin_user, admin.admin_password);
  await shot(a, 'c-dashboard', 1500);
  for (const [path, name] of [['/players', 'c-players'], ['/checkpoints', 'c-checkpoints'],
                              ['/managers', 'c-managers'], ['/notifications', 'c-notifications'],
                              ['/eventteam', 'c-eventteam']]) {
    await a.goto(`${ADMIN}${path}`, { waitUntil: 'networkidle0' });
    await shot(a, name, 1500);
  }
  await a.goto(`${ADMIN}/players`, { waitUntil: 'networkidle0' });
  await a.click('[data-opens]');
  await shot(a, 'c-log', 1000);
});

await browser.close();
console.log(failed ? `${failed} step(s) failed` : 'all steps done');
