import assert from 'node:assert/strict'
import test from 'node:test'
import {compose, poses} from '../../assets/js/workshop/coming_aboard_composition.js'

const distance = (a, b) => Math.hypot(...a.map((value, index) => value - b[index]))
const near = (a, b) => assert.ok(Math.abs(a - b) < 1e-12)

test('release moves the hold independently and leaves the original XT TO XT reference', () => {
  const held = compose(poses.held)
  const loose = compose(poses.loosened)
  assert.notDeepEqual(held.hold, loose.hold)
  for (const member of ['line', 'reference', 'diagonal', 'flap', 'retained']) {
    assert.deepEqual(held[member], loose[member])
  }
})

test('the line curves continuously UP into six marks without sliding its root', () => {
  const original = compose(poses.loosened).line
  let height = 0
  for (const progress of [.25, .5, .75, 1]) {
    const {line} = compose([1, progress, 0])
    assert.equal(line.length - 1, 6)
    assert.deepEqual(line[0], original[0])
    assert.ok(line.at(-1)[2] > height)
    height = line.at(-1)[2]
    line.slice(1).forEach((point, index) => near(distance(line[index], point), 1 / 6))
  }
})

test('diagonal fold is rigid, carries the same source and keeps the retained triangle fixed', () => {
  const original = compose(poses.curved)
  for (const progress of [.25, .5, .75, 1]) {
    const stock = compose([1, 1, progress])
    assert.deepEqual(stock.diagonal, original.diagonal)
    assert.deepEqual(stock.retained, original.retained)
    assert.deepEqual(stock.reference, original.reference)
    assert.deepEqual(stock.line, original.line)
    near(distance(stock.flap[0], stock.flap[1]), distance(original.flap[0], original.flap[1]))
    near(distance(stock.flap[1], stock.flap[2]), distance(original.flap[1], original.flap[2]))
    assert.ok(stock.flap[1][2] < 0)
  }
  const folded = compose(poses.folded)
  near(folded.flap[1][0], folded.flap[1][1])
  near(folded.flap[1][2], -Math.SQRT1_2)
})
