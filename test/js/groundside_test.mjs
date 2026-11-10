import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const f=JSON.parse(await readFile(new URL('../fixtures/workshop_groundside_contract.json',import.meta.url),'utf8'))
test('lower-only field keeps SIX registration and ray-plane intersections use the actual U aperture rather than an enlarged Crossing',()=>{
 assert.deepEqual(f.model.entities.central.dimensions,[6,6,6]);assert.deepEqual(f.model.entities.central.frame.origin,[12,0,-3]);assert.deepEqual(f.model.rail.start,[0,0,0])
 assert.deepEqual(f.source,f.model.projection.source.outline)
 assert.ok(f.strip.every(p=>p[1]===-3));assert.equal(Math.max(...f.strip.map(p=>p[0]))-Math.min(...f.strip.map(p=>p[0])),2*f.model.entities.central.dimensions[0])
 assert.ok(f.first_experiment.every(p=>p[1]===6));assert.ok(f.window.every(p=>p[2]===6));assert.ok(f.aperture.every(p=>p[2]===0))
 for(let i=0;i<f.window.length;i++){
  const q=f.window[i],t=(0-f.eye[2])/(q[2]-f.eye[2]),hit=f.eye.map((v,j)=>v+t*(q[j]-v))
  hit.forEach((v,j)=>assert.ok(Math.abs(v-f.aperture[i][j])<1e-10))
 }
 assert.deepEqual(f.tokens.map(t=>t.index),[1,2,3,4,5,6,7,8,9]);assert.equal(f.tokens.map(t=>t.text).join(''),'HEAD LAST')
 assert.ok(f.tokens.at(-1).world[2]>f.tokens[0].world[2]);assert.ok(f.tokens.every(t=>t.world[1]>3&&t.author==='Constitutioning Human'))
})
