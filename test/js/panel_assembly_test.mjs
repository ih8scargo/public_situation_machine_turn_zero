import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/panel_assembly.js',import.meta.url),'utf8')
const {assemblePanels,panelInventory}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const reference={cabinet_front_z:-3,here_square:[[-2.5,-2.5,-3],[2.5,-2.5,-3],[2.5,-2.5,0],[-2.5,-2.5,0]]}
const near=(a,b)=>a.forEach((v,i)=>assert.ok(Math.abs(v-b[i])<1e-9))
test('literal planar stock retains dimensions and its hinge purchase',()=>{
 for(const a of [-90,-45,0,22.5,45,90]){
  const m=assemblePanels(reference,a,90-a),face=m.panels.find(p=>p.id==='cabinet').points,front=m.panels.find(p=>p.id==='front').points
  assert.equal(m.panels.length,6)
  near(face[0].map((v,i)=>v-face[1][i]),[-4.3,0,0])
  assert.deepEqual(m.hinge,[[-.4,0,0],[.4,0,0]])
  const doll=m.panels.find(p=>p.id==='doll').points
  near(doll[0],m.hinge[0]);near(doll[1],m.hinge[1])
  assert.ok(Math.abs(Math.hypot(...doll[2].map((v,i)=>v-doll[1][i]))-2.4)<1e-9)
 }
 assert.equal(panelInventory.length,6)
})
test('observations expose coincidence, offset apertures and hypothetical clearance independently',()=>{
 assert.equal(assemblePanels(reference,22.5,22.5).observations.coincident,true)
 assert.equal(assemblePanels(reference,0,45).observations.monitorAligned,true)
 assert.ok(Math.abs(assemblePanels(reference,0,45).observations.planeAngle-45)<1e-9)
 const o=assemblePanels(reference,45,0).observations
 assert.equal(o.apertureCenterOffset,.5);assert.equal(o.innerWithinCabinet,false)
 assert.ok(Math.abs(o.glassNozzleMargin-.01)<1e-9)
 assert.equal(assemblePanels(reference,-90,90).observations.coincident,true)
})
test('assembly leaves retained reference data untouched and handles invalid angles',()=>{
 const before=JSON.stringify(reference)
 const m=assemblePanels(reference,NaN,Infinity)
 m.panels.find(p=>p.id==='ground').points[0][0]=99
 assert.equal(JSON.stringify(reference),before)
 assert.equal(m.cabinet,0);assert.equal(m.doll,0)
})
