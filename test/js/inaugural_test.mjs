import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8')
const {inauguralElbow,furnishedStick}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
test('one continuous eight-segment Crossing inherits the appointed bearing instead of changing it with the view',()=>{
 for(const [yaw,pitch] of [[0,0],[60,45],[-60,-45]]){
  const stick=furnishedStick(yaw,pitch,1),before=JSON.stringify(stick),elbow=inauguralElbow(stick),dot=(a,b)=>a.reduce((n,v,i)=>n+v*b[i],0)
  assert.equal(elbow.length,9);assert.deepEqual(elbow[0].point,stick.tip)
  assert.ok(Math.abs(dot(elbow[0].tangent,stick.direction)-1)<1e-12)
  assert.ok(Math.abs(dot(elbow[4].tangent,stick.direction)-Math.SQRT1_2)<1e-12)
  assert.ok(Math.abs(dot(elbow[8].tangent,stick.direction))<1e-12)
  assert.equal(JSON.stringify(stick),before)
 }
})
