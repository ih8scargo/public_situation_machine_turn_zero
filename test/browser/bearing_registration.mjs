import assert from 'node:assert/strict'
import {mkdir} from 'node:fs/promises'

const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright')
const output = process.env.WITNESS_DIR || 'docs/visual-witnesses/bearing-registration'
await mkdir(output, {recursive: true})
const browser = await chromium.launch({executablePath: process.env.CHROMIUM_PATH, args: ['--no-sandbox']})

try {
  const page = await browser.newPage({viewport: {width: 1440, height: 1000}})
  const errors = []
  page.on('pageerror', error => errors.push(error.message))
  await page.goto((process.env.WORKSHOP_URL || 'http://127.0.0.1:4001') + '/workshop/string-ribbon')
  await page.waitForSelector('.phx-connected')
  const ids = ['diagonal-A', 'diagonal-B', 'HERE', 'NEXT', 'table', 'inner-aperture']
  const world = () => Promise.all(ids.map(id => page.locator('#ge-scene-' + id).getAttribute('data-world')))
  const before = await world()

  await page.locator('#ge-experiment-10').click()
  const study = page.locator('#ge-bearing-study')
  assert.equal(await study.getAttribute('data-face-match'), 'true')
  for (const [id, match, overlap] of [['face', 'false', 'false'], ['transverse', 'false', 'false'], ['historical', 'true', 'true']]) {
    const trial = study.locator('#ge-bearing-' + id)
    assert.equal(await trial.getAttribute('data-point-match'), match)
    assert.equal(await trial.getAttribute('data-overlap'), overlap)
    assert.equal(await trial.getByRole('img').count(), 5)
    await trial.locator('summary').click()
    assert.equal(await trial.locator('tbody tr:visible').count(), 9)
  }
  assert.equal(await page.locator('#geometry-exploration').getAttribute('data-index'), '0')
  assert.equal(await page.locator('#geometry-exploration').getAttribute('data-coils'), '0')
  assert.deepEqual(await world(), before)
  await study.screenshot({path: output + '/01-registration.png'})

  await page.setViewportSize({width: 390, height: 844})
  assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth))
  await study.locator('#ge-bearing-transverse').screenshot({path: output + '/02-transverse-mobile.png'})
  await page.locator('#ge-experiment-9').click()
  await page.locator('#ge-shared-face-study').waitFor()
  await study.waitFor({state: 'detached'})
  assert.deepEqual(await world(), before)
  assert.deepEqual(errors, [])
  console.log('PASS three comparisons, five views each, hinge tables, protected state and mobile')
} finally {
  await browser.close()
}

