import assert from 'node:assert/strict'
import {mkdir} from 'node:fs/promises'
import {compose, poses} from '../../assets/js/workshop/coming_aboard_composition.js'

const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright')
const output = process.env.WITNESS_DIR || '/tmp/psm-coming-aboard'
await mkdir(output, {recursive: true})
const browser = await chromium.launch({executablePath: process.env.CHROMIUM_PATH, args: ['--no-sandbox']})
const url = process.env.COMING_ABOARD_URL || 'http://127.0.0.1:4001/workshop/coming-aboard'

try {
  const page = await browser.newPage({viewport: {width: 1280, height: 900}})
  const errors = []
  page.on('pageerror', error => errors.push(error.message))
  await page.goto(url)
  await page.waitForSelector('.phx-connected')
  const stock = page.locator('#ca-stock')
  const tab = page.getByRole('button', {name: 'Toy Box tab'})
  const settled = pose => page.waitForFunction(
    expected => document.querySelector('#ca-stock').dataset.geometry === expected,
    JSON.stringify(compose(poses[pose])),
  )
  const screenshot = name => page.screenshot({path: output + '/' + name + '.png', fullPage: true})
  await settled('held')
  await screenshot('01-invitation')
  await tab.click()
  await page.getByText('Relinquished without a completed pull.', {exact: false}).waitFor()
  assert.equal(await tab.count(), 1)
  const box = await tab.boundingBox()
  const x = box.x + box.width / 2
  const y = box.y + box.height / 2
  await page.mouse.move(x, y)
  await page.mouse.down()
  await page.mouse.move(x + 70, y + 15, {steps: 8})
  await page.mouse.up()
  await page.waitForSelector('#ca-cob[data-appointed=true][data-confirmed=false]')
  await settled('loosened')
  await screenshot('02-loosened')
  await page.locator('#ca-puff').click()
  await page.locator('#ca-curve').click()
  await settled('curved')
  await screenshot('03-six-marks')
  await page.locator('#ca-fold').click()
  await settled('folded')
  await page.waitForSelector('#ca-tunnel')
  await screenshot('04-tunneling')
  const native = page.locator('#ca-native-reference')
  await page.locator('#ca-composition summary').click()
  assert.ok(await native.evaluate(canvas => canvas.getContext('2d')
    .getImageData(0, 0, canvas.width, canvas.height).data.some(value => value !== 0)))
  await screenshot('04a-native-references')
  await page.locator('#ca-composition summary').click()
  const folded = await stock.getAttribute('data-geometry')
  await page.locator('#ca-flat').click()
  await page.waitForSelector('#coming-aboard[data-pose=folded][data-regarding=flat]')
  assert.equal(await stock.getAttribute('data-geometry'), folded)
  assert.equal(await page.locator('#ca-flat-offices > section').count(), 2)
  assert.equal(await page.locator('#coming-aboard').getAttribute('data-from'), 'HOME FROM HERE')
  assert.equal(await page.locator('#ca-cob').getAttribute('data-confirmed'), 'true')
  await screenshot('05-returned-flat')
  await page.locator('#ca-regard').click()
  await page.waitForSelector('#ca-tunnel')
  assert.equal(await stock.getAttribute('data-geometry'), folded)

  await page.setViewportSize({width: 390, height: 844})
  await page.emulateMedia({reducedMotion: 'reduce'})
  await page.reload()
  await page.waitForSelector('.phx-connected')
  await tab.focus()
  await tab.press('Space')
  await tab.press('ArrowRight')
  await tab.press('Space')
  await settled('loosened')
  await page.locator('#ca-curve').click()
  await settled('curved')
  await page.locator('#ca-fold').click()
  await settled('folded')
  assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth))
  await screenshot('06-mobile-keyboard')
  assert.deepEqual(errors, [])
  console.log('Coming Aboard Chromium walkthrough passed. Witnesses at ' + output)
} finally {
  await browser.close()
}
