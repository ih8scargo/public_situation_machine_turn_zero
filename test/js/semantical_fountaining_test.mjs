import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/semantical_fountaining.js',import.meta.url),'utf8')
const {sampleCourse}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const course=Object.freeze({length:100,samples:Object.freeze([
  Object.freeze({distance:0,x:0,y:0,face_angle:88,text_angle:0,relation:'sc-source'}),
  Object.freeze({distance:30,x:30,y:0,face_angle:88,text_angle:0,relation:'sc-initial'}),
  Object.freeze({distance:70,x:40,y:-30,face_angle:0,text_angle:-45,relation:'sc-pivot'}),
  Object.freeze({distance:100,x:60,y:-50,face_angle:0,text_angle:-45,relation:'sc-toward'})])})
test('the same sample resolves edge to face using only supplied local semantic geometry',()=>{
  assert.equal(sampleCourse(course,0).face_angle,88)
  assert.equal(sampleCourse(course,.5).face_angle,44)
  assert.equal(sampleCourse(course,.5).relation,'sc-pivot')
  assert.equal(sampleCourse(course,1).face_angle,0)
  assert.equal(sampleCourse(course,1).relation,'sc-toward')
  assert.deepEqual(sampleCourse(course,-1),sampleCourse(course,0))
  assert.deepEqual(sampleCourse(course,2),sampleCourse(course,1))
})
test('sampling does not write character identity, semantic standing or course coordinates',()=>{
  const before=JSON.stringify(course)
  for(let i=0;i<=100;i++)sampleCourse(course,i/100)
  assert.equal(JSON.stringify(course),before)
})
