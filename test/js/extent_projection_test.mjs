import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/extent_projection.js',import.meta.url),'utf8')
const {pointAlong,segmentStyle}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
test('a material purchase follows the supplied 3D bend without changing or replacing its course',()=>{
  const points=Object.freeze([Object.freeze([-2,-1,1]),Object.freeze([-1,0,1]),Object.freeze([-1,2,1])])
  assert.deepEqual(pointAlong(points,0),[-2,-1,1])
  assert.deepEqual(pointAlong(points,.25),[-1.5,-.5,1])
  assert.deepEqual(pointAlong(points,.75),[-1,1,1])
  assert.deepEqual(pointAlong(points,1),[-1,2,1])
  assert.deepEqual(pointAlong(points,-1),[-2,-1,1])
})
test('projection segments retain genuine depth and remain finite at a zero-length embedding',()=>{
  const depth=segmentStyle([0,0,0],[0,0,2])
  assert.equal(depth.width,'60px')
  assert.ok(depth.transform.includes('rotateY(-90deg)'))
  assert.ok(!segmentStyle([0,0,0],[0,0,0]).transform.includes('NaN'))
})
