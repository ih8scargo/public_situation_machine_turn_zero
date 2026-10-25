import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'

const source = await readFile(new URL('../../assets/js/toy_apparatus.js', import.meta.url), 'utf8')
const {RegardingWheel, ToyCraft} = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)

class Element {
  constructor(dataset = {}) { this.dataset = dataset; this.attributes = {}; this.listeners = new Map(); this.nodes = new Map() }
  setAttribute(k, v) { this.attributes[k] = String(v) }
  querySelector(k) { return this.nodes.get(k) }
  addEventListener(k, fn) { this.listeners.set(k, fn) }
  removeEventListener(k) { this.listeners.delete(k) }
  focus() {}
  setPointerCapture() {}
  getScreenCTM() { return {inverse: () => ({})} }
  closest(k) { return this.matches?.get(k) || null }
  emit(type, values = {}) { this.listeners.get(type)?.({type, button: 0, pointerId: 1, preventDefault() {}, target: this, ...values}) }
}
globalThis.DOMPoint = class { constructor(x,y) { this.x=x; this.y=y } matrixTransform() { return this } }

function craft(state = {}) {
  const root = new Element({state: JSON.stringify({open: true, box: true, pointer: true, offered: 'projected-tc', held: null, pointed: null, target: null, x: 315, y: 385, turn: 0, aligned: false, wrapped: false, articulation: 'rest', seated: false, appointed: false, calibrated: false, nav: 0, tunnel: false, ...state})})
  const svg = new Element()
  root.nodes.set('svg', svg)
  const parts = {}
  for (const name of ['workspace','pointer','box-lid','tc','buckle','wrap','held-halo','artifact-label','bobbing','articulation']) {
    parts[name] = new Element()
    svg.nodes.set(`[data-part="${name}"]`, parts[name])
  }
  const turn = new Element({drag: 'turn'})
  parts['held-halo'].nodes.set('[data-drag=turn]', turn)
  const points = Array.from({length: 4}, () => new Element())
  points.forEach((p,i) => parts.articulation.nodes.set(`[data-point-index="${i}"]`, p))
  const events = []
  const hook = {...ToyCraft, el: root, pushEvent: (name, payload) => events.push({name,payload})}
  hook.mounted()
  return {hook, root, svg, parts, points, events, turn}
}

function dragTarget(kind) {
  const node = new Element({drag: kind})
  node.matches = new Map([['[data-drag]', node]])
  return node
}

test('pointing at a target only proposes Point; the artifact stays where it stands', () => {
  const c = craft()
  const target = new Element({point: 'projected-tc'})
  target.matches = new Map([['[data-point]', target]])
  const pose = c.parts.tc.attributes.transform
  c.svg.emit('click', {target})
  assert.deepEqual(c.events, [{name:'point-artifact',payload:{id:'projected-tc'}}])
  assert.equal(c.parts.tc.attributes.transform, pose)
  assert.equal(c.parts.articulation.nodes.size, 4)
  c.hook.destroyed()
  assert.equal(c.svg.listeners.size, 0)
})

test('a real carry gesture renders locally, then submits only a pose even at the receiver', () => {
  const c = craft({held: 'projected-tc', articulation:'grasp'})
  c.svg.emit('pointerdown', {target: dragTarget('carry'), clientX:315, clientY:385})
  c.svg.emit('pointermove', {clientX:642, clientY:390})
  assert.match(c.parts.tc.attributes.transform, /translate\(642 390\)/)
  assert.equal(c.parts.articulation.dataset.articulation, 'square')
  assert.equal(c.events.length, 0)
  c.svg.emit('pointerup')
  assert.deepEqual(c.events, [{name:'craft-pose',payload:{x:642,y:390,turn:0}}])
  assert.equal(c.parts.tc.attributes.display, '')
})

test('turning the held ring is independent of the Human-facing Bobbing extent', () => {
  const c = craft({held:'square-buckle', articulation:'grasp'})
  const body = c.parts.bobbing.attributes.transform
  c.svg.emit('pointerdown', {target:dragTarget('turn'), clientX:415, clientY:385})
  c.svg.emit('pointermove', {clientX:315, clientY:485})
  assert.match(c.parts.buckle.attributes.transform, /rotate\(90\)/)
  assert.match(c.parts.articulation.attributes.transform, /rotate\(90\)/)
  assert.equal(c.parts.bobbing.attributes.transform, body)
  c.svg.emit('pointerup')
  assert.equal(c.events[0].payload.turn, 90)
  assert.equal(c.events[0].name, 'craft-pose')
})

test('keyboard carry/turn work, and unheld material cannot be dragged', () => {
  const held = craft({held:'projected-tc', articulation:'grasp'})
  held.svg.emit('keydown', {target:dragTarget('carry'),key:'ArrowRight'})
  held.svg.emit('keydown', {target:dragTarget('turn'),key:'ArrowRight'})
  assert.equal(held.events[0].payload.x, 330)
  assert.equal(held.events[1].payload.turn, 15)
  const reading = craft({open:false, tunnel:true})
  reading.svg.emit('pointerdown', {target:dragTarget('carry'), clientX:315,clientY:385})
  reading.svg.emit('pointermove',{clientX:600,clientY:380})
  reading.svg.emit('pointerup')
  assert.equal(reading.events.length, 0)
})

test('NAV moves only Bobbing projection and fresh server state restores its four resting points', () => {
  const c = craft({tunnel:true, open:false})
  const before = c.parts.bobbing.attributes.transform
  const next = {...c.hook.state, nav:4, held:null, articulation:'rest'}
  c.root.dataset.state = JSON.stringify(next)
  c.hook.updated()
  assert.notEqual(c.parts.bobbing.attributes.transform, before)
  assert.equal(c.parts.bobbing.dataset.nav, '4')
  assert.equal(c.points.length, 4)
  assert.equal(c.parts.workspace.attributes.display, 'none')
  assert.equal(c.events.length, 0)
})

test('wheel drag and keyboard rotate an actual rotor and submit only Regard angles', () => {
  const root = new Element({angle:'0',disabled:'false'})
  const svg = new Element(), rotor = new Element()
  root.nodes.set('svg',svg)
  root.nodes.set('[data-wheel-rotor]',rotor)
  const events=[]
  const hook={...RegardingWheel,el:root,pushEvent:(name,payload)=>events.push({name,payload})}
  hook.mounted()
  svg.emit('pointerdown',{clientX:100,clientY:0})
  svg.emit('pointermove',{clientX:200,clientY:100})
  svg.emit('pointerup')
  assert.equal(rotor.attributes.transform,'rotate(90 100 100)')
  assert.ok(events.every(e=>e.name==='wheel'))
  assert.equal(events.at(-1).payload.angle,90)
  svg.emit('keydown',{key:'ArrowRight',shiftKey:false})
  assert.equal(events.at(-1).payload.angle,97.5)
  root.dataset.disabled='true'
  const count=events.length
  svg.emit('keydown',{key:'ArrowRight'})
  assert.equal(events.length,count)
  hook.destroyed()
  assert.equal(svg.listeners.size,0)
})
