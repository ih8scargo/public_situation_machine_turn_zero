import assert from 'node:assert/strict'
import {spawn} from 'node:child_process'
import {mkdir, mkdtemp, readFile, rm, writeFile} from 'node:fs/promises'
import {tmpdir} from 'node:os'
import {join} from 'node:path'
import {once} from 'node:events'
const profileDirectory = await mkdtemp(join(tmpdir(), 'layering-zero-chromium-'))
const witnessDirectory = process.env.WITNESS_DIR
const url = new URL('/experiments/architecture', process.env.TEST_BASE_URL || 'http://localhost:4001')
const browser = spawn(process.env.CHROMIUM_PATH || 'chromium', [
  '--headless', '--no-sandbox', '--disable-dev-shm-usage', '--remote-debugging-port=0',
  `--user-data-dir=${profileDirectory}`, 'about:blank'
], {stdio:'ignore'})
const exited = once(browser, 'exit')
exited.catch(() => {})
const delay = ms => new Promise(resolve => setTimeout(resolve, ms))
try {
  let targets
  for (let i = 0; i < 50 && !targets; i++) {
    try {
      const [port] = (await readFile(join(profileDirectory, 'DevToolsActivePort'), 'utf8')).split('\n')
      targets = await fetch(`http://127.0.0.1:${port}/json/list`).then(r => r.json())
    } catch {
      await delay(100)
    }
  }
  assert.ok(targets, 'Chromium DevTools started')
  const socket = new WebSocket(targets.find(target => target.type === 'page').webSocketDebuggerUrl)
  await once(socket, 'open')
  let seq = 0
  const calls = new Map(), errors = []
  socket.onmessage = ({data}) => {
    const response = JSON.parse(data)
    if (response.method === 'Runtime.exceptionThrown') errors.push(response.params.exceptionDetails)
    calls.get(response.id)?.(response)
  }
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = ++seq
    calls.set(id, response => {
      calls.delete(id)
      response.error ? reject(response.error) : resolve(response.result)
    })
    socket.send(JSON.stringify({id, method, params}))
  })
  const evaluate = async expression => {
    const result = await send('Runtime.evaluate', {expression, returnByValue: true})
    assert.equal(result.exceptionDetails, undefined, JSON.stringify(result.exceptionDetails))
    return result.result.value
  }
  await send('Runtime.enable')
  await send('Emulation.setDeviceMetricsOverride', {width: 1400, height: 1050, deviceScaleFactor: 1, mobile: false})
  await send('Page.navigate', {url: url.href})
  const ready = 'document.querySelector("#lzero-bulb")?.getAttribute("aria-pressed") === "true" && location.search.includes("id=")'
  for (let i = 0; i < 100 && !await evaluate(ready); i++) await delay(200)
  assert.ok(await evaluate(ready), 'LiveView hook mounted and composition ID assigned')
  const read = expr => evaluate(`(() => { const r = document.querySelector("#layering-zero"), q = s => r.querySelector(s); return ${expr} })()`)
  const press = id => read(`q("#lzero-${id}").click()`)
  const change = (id, value) => evaluate(`(() => {
    const node = document.querySelector("#lzero-${id}"); node.value = ${JSON.stringify(value)};
    node.dispatchEvent(new Event("input", {bubbles:true}));
  })()`)
  const count = id => read(`r.querySelectorAll('#lzero-scene [data-source="${id}"]').length`)
  const shot = async name => {
    if (!witnessDirectory) return
    await mkdir(witnessDirectory, {recursive: true})
    const image = await send('Page.captureScreenshot', {format:'png'})
    await writeFile(join(witnessDirectory, `layering-zero-${name}.png`), Buffer.from(image.data, 'base64'))
  }
  const standing = await read('r.dataset.standingDigest')
  const profile = await read('q(\'#lzero-wayfinding [data-source="snail:coil"]\').getAttribute("points")')
  assert.equal(await read(`[...r.querySelectorAll("#lzero-source option")].filter(o => /^gallery-door:[1-8]$/.test(o.value)).length`), 8)
  const door = 'gallery-door:1'
  const doorPoints = await read(`q('#lzero-scene [data-source="${door}"]').getAttribute("points")`)
  await change('pose', 'wheel')
  assert.equal(await read('r.dataset.pose'), 'upright')
  assert.notEqual(await read(`q('#lzero-scene [data-source="${door}"]').getAttribute("points")`), doorPoints)
  await change('pose', 'gallery')
  assert.equal(await read(`q('#lzero-scene [data-source="${door}"]').getAttribute("points")`), doorPoints)
  await change('source', 'gallery-door:2')
  await change('slice', 'compare')
  assert.ok(await count('gallery-door:2:positive'))
  assert.ok(await count('gallery-door:2:negative'))
  assert.ok(await count('gallery-door:2:passage'))
  await change('office', 'ft')
  assert.ok(await count('gallery-door:2:ft'))
  assert.ok(await count('gallery-door:2:ft-hold'))
  await change('office', 'tf')
  assert.ok(await count('gallery-door:2:tf'))
  await change('office', 'course')
  await change('slice', 'source')
  assert.equal(await count('gallery-door:2:positive'), 0)
  assert.equal(await read('r.dataset.selected'), 'gallery-door:2')
  await shot('bulb')
  await change('source', 'transverse:bar')
  await press('flat')
  assert.ok(await count('transverse:bar'))
  assert.ok(await count('monitor:intersection'))
  await shot('flat')
  await press('diorama')
  assert.ok(await count('cb:monitor'))
  await press('wall')
  assert.equal(await count('cb:monitor'), 0)
  await press('wall')
  for (const side of ['upper', 'lower']) {
    await press(side)
    assert.equal(await read(`r.querySelectorAll('#lzero-scene [data-source$=":${side}"]').length`), 0)
    await press(side)
    assert.ok(await read(`r.querySelectorAll('#lzero-scene [data-source$=":${side}"]').length`))
  }
  const oldBar = await read('q(\'#lzero-scene [data-source="transverse:bar"]\').getAttribute("points")')
  await change('anchor', 'table')
  await change('orbit', '70')
  assert.notEqual(await read('q(\'#lzero-scene [data-source="transverse:bar"]\').getAttribute("points")'), oldBar)
  await change('anchor', 'seat')
  await change('orbit', '32')
  await shot('diorama')
  await press('coil')
  for (const specimen of ['first', 'stacked', 'alongside']) {
    await change('specimen', specimen)
    assert.ok(await count('footing:first'))
    assert.equal(await count('footing:opening'), 2)
    assert.equal(await read('q(\'#lzero-wayfinding [data-source="snail:coil"]\').getAttribute("points")'), profile)
  }
  await shot('coil')
  assert.equal(await read('r.dataset.selected'), 'transverse:bar')
  assert.equal(await read('r.dataset.standingDigest'), standing)
  assert.ok(await read('!r.innerText.includes("STAND TOWARD THIS ONE BUTTONING")'))
  await send('Emulation.setDeviceMetricsOverride', {width: 390, height: 844, deviceScaleFactor: 1, mobile: true})
  assert.ok(await evaluate('document.querySelector("#layering-zero").getBoundingClientRect().right <= document.documentElement.clientWidth + 1'))
  assert.deepEqual(errors, [])
  socket.close()
  console.log('PASS Chromium appliance: eight addresses, all views, monitor toggle, anchor/orbit, all Footing specimens and invariant wayfinding, selection, standing, mobile.')
} finally {
  browser.kill()
  await exited.catch(() => {})
  await rm(profileDirectory, {recursive: true, force: true})
}
