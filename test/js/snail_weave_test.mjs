import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const url=s=>`data:text/javascript;base64,${Buffer.from(s).toString('base64')}`
const room=await readFile(new URL('../../assets/js/workshop/wedging_room.js',import.meta.url),'utf8')
const stands=await readFile(new URL('../../assets/js/workshop/regarding_stands.js',import.meta.url),'utf8')
const source=(await readFile(new URL('../../assets/js/workshop/snail_body.js',import.meta.url),'utf8')).replace("'./wedging_room.js'",JSON.stringify(url(room))).replace("'./regarding_stands.js'",JSON.stringify(url(stands)))
const {renderBody,bodyFrame}=await import(url(source))
const {state,model}=JSON.parse(await readFile(new URL('../fixtures/snail_weave_contract.json',import.meta.url),'utf8'))
class Node{constructor(tag,doc){this.tag=tag;this.ownerDocument=doc;this.children=[];this.dataset={};this.attrs={}}replaceChildren(){this.children=[]}append(n){this.children.push(n)}setAttribute(k,v){this.attrs[k]=String(v)}}
const doc={createElementNS:(_,tag)=>new Node(tag,doc)}
test('one canonical material and world registration survive flat, oblique, plan, section, within and ceiling projection',()=>{
 const before=JSON.stringify({state,model}),material=state.body.material[0].id
 for(const view of ['flat','external','plan','section','within','ceiling']){
  const svg=new Node('svg',doc);renderBody(svg,model,view)
  assert.equal(svg.dataset.view,view)
  assert.ok(svg.children.every(n=>!Object.values(n.attrs).some(v=>/NaN|Infinity/.test(v))))
  assert.ok(svg.children.filter(n=>n.attrs['data-material']).every(n=>n.attrs['data-material']===material))
  if(view==='flat'){assert.ok(svg.children.some(n=>n.attrs['data-stage']==='monitor'));assert.ok(!svg.children.some(n=>n.attrs['data-stage']==='loading-deck'))}
  assert.equal(JSON.stringify({state,model}),before)
 }
 assert.deepEqual(bodyFrame(model,'ceiling').forward,[0,1,0])
 assert.deepEqual(bodyFrame(model,'within').eye,model.within_eye.map((v,i)=>(v+(i===1?2:0))*.72))
})
test('reference addresses, relay matrices, sight tests and conflicts are taken from the Elixir apparatus',()=>{
 assert.equal(model.reference_arc.version,'snail-radial-arc-v1');assert.equal(model.reference_arc.purchases.length,6)
 assert.ok(model.reference_arc.samples.every((s,i,ss)=>i===0||s.address>ss[i-1].address))
 const turn=state.turns[0],id=turn.material
 for(const reg of model.projection_relay.registrations){
  assert.equal(reg.material,id);assert.equal(reg.turn,turn.id)
  const p=[...reg.from_point,1],out=reg.matrix.slice(0,3).map(row=>row.reduce((sum,n,i)=>sum+n*p[i],0))
  assert.ok(out.every((v,i)=>Math.abs(v-reg.to_point[i])<1e-9))
 }
 assert.equal(new Set(model.tags.map(t=>t.id)).size,1)
 assert.ok(model.tags.find(t=>t.stage==='encounter').status.includes('pending'))
 assert.deepEqual(model.sight_tests.toward_receiver,[]);assert.deepEqual(model.sight_tests.upward_to_ceiling,[])
 assert.equal(model.clearances.source_lead_conflict.point[2],1.45)
 assert.ok(model.clearances.long_run_sweep_margin>0)
 assert.equal(state.footings.length,0)
})
