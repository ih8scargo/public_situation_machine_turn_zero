import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source = await readFile(new URL('../../assets/js/pulling_ring.js', import.meta.url), 'utf8')
const {PullingRing} = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)

function fixture({defer = false, accept = true} = {}) {
  const listeners = new Map(), events = [], captures = new Set()
  const ring = {style: {}, addEventListener: (name, f) => listeners.set(name, f), removeEventListener: (name, f) => {assert.equal(listeners.get(name), f); listeners.delete(name)}, setPointerCapture: id => captures.add(id), hasPointerCapture: id => captures.has(id), releasePointerCapture: id => captures.delete(id)}
  const live = {textContent: ''}
  let purchaseReply
  const hook = {...PullingRing, el: {dataset: {disabled: 'false'}, querySelector: selector => selector === '#pulling-ring' ? ring : live}, pushEvent: (name, payload, reply) => {
    events.push({name, payload})
    if (name === 'take-purchase') { if (defer) purchaseReply = reply; else reply({accepted: accept, token: 'temporary-token'}) }
    else reply?.({accepted: true})
  }}
  hook.mounted()
  const pointer = (name, x, y, extra = {}) => listeners.get(name)({clientX: x, clientY: y, button: 0, pointerId: 1, preventDefault() {}, ...extra})
  const key = (name, extra = {}) => listeners.get('keydown')({key: name, preventDefault() {}, ...extra})
  return {hook, ring, live, events, listeners, pointer, key, reply: () => purchaseReply({accepted: accept, token: 'temporary-token'})}
}

test('real pointer purchase, displacement and release emit lifecycle only, never coordinates', () => {
  const f = fixture()
  f.pointer('pointermove', 80, 90)
  assert.deepEqual(f.events, [])
  f.pointer('pointerdown', 100, 100)
  f.pointer('pointermove', 140, 130)
  assert.equal(f.ring.style.transform, 'translate(40px, 30px)')
  f.pointer('pointerup', 145, 135)
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase', 'pull', 'release-pull'])
  assert.deepEqual(f.events.slice(0,2).map(e => e.payload), [{}, {token: 'temporary-token'}])
  assert.equal(f.events[2].payload.measurements.dx,45)
  assert.equal(f.events[2].payload.measurements.dy,35)
  assert.ok(f.events[2].payload.measurements.duration_ms>=0)
  assert.equal('clientX' in f.events[2].payload,false)
  assert.equal(f.ring.style.transform, '')
})

test('a click without pulling cancels rather than opening', () => {
  const f = fixture()
  f.pointer('pointerdown', 100, 100)
  f.pointer('pointerup', 100, 100)
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase', 'cancel-pull'])
})

test('pulling back to the purchase locality cannot stand the Toy Box UP', () => {
  const f = fixture()
  f.pointer('pointerdown', 100, 100)
  f.pointer('pointermove', 150, 100)
  f.pointer('pointerup', 100, 100)
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase', 'pull', 'cancel-pull'])
})

test('any nonzero stopping displacement counts; no semantic distance threshold is invented', () => {
  const f = fixture()
  f.pointer('pointerdown', 100, 100)
  f.pointer('pointerup', 100.01, 100)
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase', 'pull', 'release-pull'])
})

test('pointer cancellation relinquishes without durable consequence', () => {
  const f = fixture()
  f.pointer('pointerdown', 100, 100)
  f.pointer('pointermove', 190, 100)
  f.pointer('pointercancel', 190, 100)
  assert.equal(f.events.at(-1).name, 'cancel-pull')
  assert.equal(f.hook.gesture, null)
})

test('keyboard use also requires purchase, movement and a separate relinquishing', () => {
  const f = fixture()
  f.key(' '); f.key(' ', {repeat: true})
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase'])
  f.key('ArrowRight'); f.key('ArrowDown'); f.key(' ')
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase', 'pull', 'release-pull'])
})

test('keyboard click alone and Escape cannot substitute for a completed pull', () => {
  const f = fixture()
  f.key(' '); f.key(' ')
  assert.equal(f.events.at(-1).name, 'cancel-pull')
  f.key(' '); f.key('ArrowRight'); f.key('Escape')
  assert.equal(f.events.at(-1).name, 'cancel-pull')
})

test('quick release waits for the purchase acknowledgment, preserving lifecycle order', () => {
  const f = fixture({defer: true})
  f.pointer('pointerdown', 10, 10)
  f.pointer('pointermove', 40, 10)
  f.pointer('pointerup', 50, 10)
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase'])
  f.reply()
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase', 'pull', 'release-pull'])
})

test('cancel before acknowledgment remains cancelled', () => {
  const f = fixture({defer: true})
  f.pointer('pointerdown', 10, 10)
  f.pointer('pointermove', 40, 10)
  f.pointer('pointercancel', 40, 10)
  f.reply()
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase', 'cancel-pull'])
})

test('unrelated pointers and secondary buttons cannot complete another purchase', () => {
  const f = fixture()
  f.pointer('pointerdown', 10, 10, {button: 2})
  assert.deepEqual(f.events, [])
  f.pointer('pointerdown', 10, 10)
  f.pointer('pointermove', 90, 90, {pointerId: 2})
  f.pointer('pointerup', 90, 90, {pointerId: 2})
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase'])
})

test('unavailable ring and rejected purchase emit no pulling consequence', () => {
  const f = fixture({accept: false})
  f.pointer('pointerdown', 10, 10)
  f.pointer('pointerup', 90, 90)
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase'])
  f.hook.el.dataset.disabled = 'true'
  f.pointer('pointerdown', 10, 10)
  assert.equal(f.events.length, 1)
})

test('hook removes every interaction listener on destruction', () => {
  const f = fixture()
  f.hook.destroyed()
  assert.equal(f.listeners.size, 0)
})

test('ignored hook synchronizes ring availability after UUID initialization and stale-save patches', () => {
  const f = fixture()
  assert.equal(f.ring.disabled, false)
  f.hook.el.dataset.disabled = 'true'; f.hook.updated()
  assert.equal(f.ring.disabled, true)
  f.hook.el.dataset.disabled = 'false'; f.hook.updated()
  assert.equal(f.ring.disabled, false)
})

test('a disconnected purchase cannot complete from a late acknowledgment', () => {
  const f = fixture({defer: true})
  f.pointer('pointerdown', 10, 10)
  f.pointer('pointermove', 50, 10)
  f.hook.disconnected()
  f.reply()
  assert.deepEqual(f.events.map(e => e.name), ['take-purchase', 'cancel-pull'])
  f.hook.reconnected()
  assert.equal(f.events.at(-1).name, 'abandon-purchase')
})

test('duration witnesses actual relinquishing rather than a delayed purchase acknowledgment', () => {
  const descriptor=Object.getOwnPropertyDescriptor(globalThis,'performance')
  let now=100
  Object.defineProperty(globalThis,'performance',{configurable:true,value:{now:()=>now}})
  try {
    const f=fixture({defer:true})
    f.pointer('pointerdown',10,10)
    now=300;f.pointer('pointerup',40,10)
    now=900;f.reply()
    assert.equal(f.events.at(-1).payload.measurements.duration_ms,200)
  } finally { Object.defineProperty(globalThis,'performance',descriptor) }
})
