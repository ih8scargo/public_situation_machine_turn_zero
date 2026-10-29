import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source = await readFile(new URL('../../assets/js/puffing_compression.js', import.meta.url), 'utf8')
const {compressionDepth, PuffingCompression} = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
test('compression remains bounded and does not turn a reverse pull into a squeeze', () => {
  assert.equal(compressionDepth(100, 62), 0)
  assert.equal(compressionDepth(100, 119), .5)
  assert.equal(compressionDepth(100, 200), 1)
})
test('pointer cancellation restores temporary pose; native activation requests domain labor only', () => {
  const events = new Map(), requests = [], values = new Map()
  const button = {disabled:false, style:{setProperty:(k,v)=>values.set(k,v)},setPointerCapture(){},addEventListener:(n,f)=>events.set(n,f),removeEventListener:n=>events.delete(n)}
  const hook = {el:{dataset:{puffed:'false',ready:'true'},querySelector:()=>button},pushEvent:(...args)=>requests.push(args)}
  PuffingCompression.mounted.call(hook)
  events.get('pointerdown')({clientY:20,pointerId:1,button:0})
  events.get('pointermove')({clientY:58})
  assert.equal(values.get('--compression'), '1')
  events.get('pointercancel')()
  assert.equal(values.get('--compression'), '0')
  assert.deepEqual(requests, [])
  events.get('click')()
  assert.deepEqual(requests, [['puff',{}]])
  hook.el.dataset.puffed='true'
  PuffingCompression.updated.call(hook)
  assert.equal(button.disabled,true)
  events.get('click')()
  assert.equal(requests.length,1)
  PuffingCompression.destroyed.call(hook)
  assert.equal(events.size,0)
})
