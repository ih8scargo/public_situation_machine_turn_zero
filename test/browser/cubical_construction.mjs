import assert from 'node:assert/strict'
import {mkdir, writeFile} from 'node:fs/promises'

const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright')
const out = process.env.WITNESS_DIR || 'docs/visual-witnesses/cubical-construction'
await mkdir(out, {recursive: true})
const browser = await chromium.launch({executablePath: process.env.CHROMIUM_PATH, args: ['--no-sandbox']})
try {
  const page = await browser.newPage({viewport: {width: 1440, height: 1100}})
  const errors = []
  page.on('pageerror', error => errors.push(error.message))
  await page.goto('http://127.0.0.1:4001/workshop/string-ribbon')
  await page.waitForSelector('.phx-connected')
  const panel = page.locator('#cubical-construction')
  const hash = await panel.getAttribute('data-source-hash')
  const reference = await page.locator('#cc-gauge-reference').getAttribute('data-world')
  const approach = await page.locator('#cc-object-ground-approach').getAttribute('data-world')
  const click = async id => {
    const before = await panel.getAttribute('data-revision')
    await page.locator(id).click()
    await page.waitForFunction(revision => document.querySelector('#cubical-construction').dataset.revision !== revision, before)
  }
  const select = async id => {
    await page.selectOption('#cc-component', id)
    await page.waitForSelector(`#cc-inscription[data-component="${id}"]`)
  }
  const snapshot = async name => panel.screenshot({path: `${out}/${name}.png`})
  await select('stage-door')
  await snapshot('01-near-xt-flat')
  for (const facet of ['tunneling', 'reciprocal', 'return', 'flat']) {
    await click(`#cc-facet-${facet}`)
    await page.waitForSelector(`#cubical-construction[data-facet="${facet}"]`)
    assert.equal(await panel.getAttribute('data-source-hash'), hash)
    assert.equal(await page.locator('#cc-object-ground-approach').getAttribute('data-world'), approach)
    assert.equal(await panel.getAttribute('data-index'), '0')
    if (facet === 'tunneling') {
      await select('first-bisection')
      await snapshot('02-bisection-two-footings')
      await select('cubical-right')
      await snapshot('03-standing-staging')
    }
    if (facet === 'reciprocal') await snapshot('04-reciprocal')
    if (facet === 'return') {
      await click('#cc-compare-FOUR')
      await page.waitForSelector('#cc-gauge-reading[data-candidate="gauge-4-x"]')
      assert.equal(await page.locator('#cc-gauge-reference').getAttribute('data-world'), reference)
      assert.match(await page.locator('#cc-gauge-reading').innerText(), /0\.5/)
      await select('gauge-four')
      await snapshot('05-return-four')
    }
  }
  await click('#cc-orbit-forward')
  assert.equal(await panel.getAttribute('data-yaw'), '15')
  assert.equal(await panel.getAttribute('data-source-hash'), hash)
  await click('#cc-materials')
  assert.equal(await page.locator('#cc-object-cubical-right').count(), 0)
  await click('#cc-materials')
  assert.equal(await page.locator('#cc-object-cubical-right').count(), 1)
  assert.notEqual(await page.locator('#cc-object-cubical-left').getAttribute('data-material'), await page.locator('#cc-object-cubical-right').getAttribute('data-material'))
  assert.equal(await page.locator('#cc-object-footing-two').getAttribute('data-status'), 'prospective')
  assert.match(await page.locator('#cc-landing-status').innerText(), /next cursor: nil/)
  for (const id of ['janusite-inheritance', 'here-wedging-study', 'geometry-exploration', 'paired-motor']) assert.equal(await page.locator(`#${id}`).count(), 1)
  await click('#cc-facet-tunneling')
  await page.setViewportSize({width: 390, height: 844})
  assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth))
  await snapshot('06-mobile')
  assert.deepEqual(errors, [])
  await writeFile(`${out}/verification.json`, JSON.stringify({sourceHash: hash, facets: 4, sourceInvariant: true, fixedReferenceInvariant: true, footings: ['candidate', 'prospective'], actualTwoOrigin: null, nextCursor: null, index: 0, gauge: 'matched-source comparison; no interpolation law', pageErrors: errors, mobileOverflow: false}, null, 2))
  console.log('PASS CUBICAL source invariance, bisection, LEFT/RIGHT identity, inscriptions, FOUR comparison and mobile.')
} finally {
  await browser.close()
}
