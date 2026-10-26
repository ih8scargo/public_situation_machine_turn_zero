import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source = await readFile(new URL('../../assets/js/pretend_pointing.js', import.meta.url), 'utf8')
const {PretendPointing} = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)

test('pretend trace stays bounded, supports keyboard, emits no consequential event and cleans up', () => {
  const listeners = new Map()
  const mark = {style: {}}
  const hook = {...PretendPointing, el: {
    querySelector: () => mark,
    getBoundingClientRect: () => ({left: 10, top: 20, width: 200, height: 100}),
    addEventListener: (name, handler) => listeners.set(name, handler),
    removeEventListener: (name, handler) => {assert.equal(listeners.get(name), handler); listeners.delete(name)}
  }, pushEvent: () => assert.fail('pointer motion must never emit a standing event')}
  hook.mounted()
  listeners.get('pointermove')({clientX: 110, clientY: 70})
  assert.deepEqual(mark.style, {left: '50%', top: '50%'})
  let prevented = false
  listeners.get('keydown')({key: 'ArrowRight', preventDefault: () => {prevented = true}})
  assert.equal(prevented, true)
  assert.equal(mark.style.left, '53%')
  listeners.get('pointerdown')({clientX: -100, clientY: 2000})
  assert.deepEqual(mark.style, {left: '0%', top: '100%'})
  hook.destroyed()
  assert.equal(listeners.size, 0)
})
