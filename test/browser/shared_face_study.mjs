import assert from 'node:assert/strict'
import {mkdir} from 'node:fs/promises'

const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright')
const output = process.env.WITNESS_DIR || 'docs/visual-witnesses/three-footing-study'
await mkdir(output, {recursive: true})
const browser = await chromium.launch({executablePath: process.env.CHROMIUM_PATH, args: ['--no-sandbox']})

try {
  const page = await browser.newPage({viewport: {width: 1440, height: 1000}})
  const errors = []
  page.on('pageerror', error => errors.push(error.message))
  await page.goto((process.env.WORKSHOP_URL || 'http://127.0.0.1:4001') + '/workshop/string-ribbon')
  await page.waitForSelector('.phx-connected')
  const surface = page.locator('#geometry-exploration')
  const study = page.locator('#ge-shared-face-study')
  const world = id => page.locator('#ge-scene-' + id).getAttribute('data-world')
  const invariantIds = ['diagonal-A', 'diagonal-B', 'HERE', 'NEXT', 'table', 'inner-aperture']
  const before = await Promise.all(invariantIds.map(world))
  await page.locator('#ge-experiment-9').click()
  await study.waitFor()
  assert.equal(await study.getAttribute('data-capacity'), 'mechanism_unproved')
  assert.equal(await surface.getAttribute('data-coils'), '0')
  assert.equal(await surface.getAttribute('data-index'), '0')

  for (const pair of ['blue-yellow', 'yellow-third']) {
    const join = page.locator('#ge-shared-join-' + pair)
    for (const key of ['face', 'point']) assert.equal(await join.getAttribute('data-' + key + '-match'), 'true')
    for (const key of ['tangent', 'boundary']) assert.equal(await join.getAttribute('data-' + key + '-match'), 'false')
  }
  assert.deepEqual(await Promise.all(invariantIds.map(world)), before)
  assert.equal(await page.locator('#ge-shared-oblique-third').getAttribute('data-bearing'), '[[0,0,6],[3,3,9]]')
  await study.screenshot({path: output + '/01-shared-faces.png'})
  await page.locator('#ge-view-half').click()
  await page.locator('#ge-half-scene').waitFor()
  assert.deepEqual(await Promise.all(invariantIds.map(world)), before)
  await page.setViewportSize({width: 390, height: 844})
  assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth))
  await study.screenshot({path: output + '/02-mobile.png'})
  assert.deepEqual(errors, [])
  console.log('PASS shared faces, angular and boundary gaps, parent limit, protected state, half projection and mobile')
} finally {
  await browser.close()
}
