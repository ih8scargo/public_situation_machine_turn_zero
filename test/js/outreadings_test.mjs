import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const read=p=>readFile(new URL(p,import.meta.url),'utf8'),uri=s=>`data:text/javascript;base64,${Buffer.from(s).toString('base64')}`
const apparatus=uri(await read('../../assets/js/workshop/apparatus.js'))
const projection=uri((await read('../../assets/js/workshop/projection.js')).replace('./apparatus.js',apparatus))
const {outreadings,targetReading}=await import(uri((await read('../../assets/js/workshop/outreadings.js')).replace('./projection.js',projection)))
const {model,registry}=JSON.parse(await read('../fixtures/workshop_inspection_contract.json'))
test('all letters and planar apparatus read original registrations with explicit provisional display frames',()=>{
 const before=JSON.stringify({model,registry}),records=outreadings(model,registry)
 for(const s of model.steeling.stations){const r=records.get(`letter:${s.index}`);assert.deepEqual(r.coordinates,s.point);assert.deepEqual(r.bearing.inherited_U_reference,[0,0,1]);assert.match(r.classification,/REGISTERED.*PROVISIONAL/)}
 for(const item of registry.items){const r=records.get('line:'+item.id);assert.deepEqual(r.coordinates,item.points);assert.deepEqual(r.relations,item.relations);assert.deepEqual(r.provenance,item.provenance)}
 assert.equal(JSON.stringify({model,registry}),before)
})
test('thin edges expose actual measured bearings and acquired marker witnesses retain original Footing provenance',()=>{
 const records=outreadings(model,registry),edge=records.get('line:central-edge-0-1')
 assert.equal(Math.hypot(...edge.bearing),1)
 const r=records.get('line:footing-1-source')
 assert.deepEqual(r.provenance,model.rehearsal.footings[0]);assert.match(r.display_hypothesis,/provisional/)
 assert.equal(targetReading('letter:13','station'),'letter:13');assert.equal(targetReading('plane:flat-monitor','flat-monitor'),'line:flat-monitor')
})
