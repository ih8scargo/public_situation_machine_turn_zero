import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const url=s=>`data:text/javascript;base64,${Buffer.from(s).toString('base64')}`
const dep=await readFile(new URL('../../assets/js/workshop/wedging_room.js',import.meta.url),'utf8')
const stands=await readFile(new URL('../../assets/js/workshop/regarding_stands.js',import.meta.url),'utf8')
const code=(await readFile(new URL('../../assets/js/workshop/snail_body.js',import.meta.url),'utf8')).replace("'./wedging_room.js'",JSON.stringify(url(dep))).replace("'./regarding_stands.js'",JSON.stringify(url(stands)))
const {renderBody,bodyFrame}=await import(url(code))
const {state,base,emergence}=JSON.parse(await readFile(new URL('../fixtures/snail_emergence_contract.json',import.meta.url),'utf8'))
class Node{constructor(tag,doc){this.tag=tag;this.ownerDocument=doc;this.children=[];this.dataset={};this.attrs={}}replaceChildren(){this.children=[]}append(n){this.children.push(n)}setAttribute(k,v){this.attrs[k]=String(v)}}
const doc={createElementNS:(_,tag)=>new Node(tag,doc)},model={...base,emergence}
test('Contraption, fixed-eye Volume and Groundward source use one mesh, one inherited item and finite projections',()=>{
 const before=JSON.stringify({state,model}),id=state.body.material[0].id
 for(const view of ['contraption','volume','groundward','flat']){
  const svg=new Node('svg',doc);renderBody(svg,model,view)
  assert.equal(svg.dataset.view,view)
  assert.ok(svg.children.every(n=>!Object.values(n.attrs).some(v=>/NaN|Infinity/.test(v))))
  assert.ok(svg.children.filter(n=>n.attrs['data-material']).every(n=>n.attrs['data-material']===id))
  if(view==='volume')assert.ok(svg.children.some(n=>n.tag==='text'&&n.attrs['data-host-surface']?.startsWith('corkscrew-ribbon-')))
  if(view==='groundward')assert.ok(svg.children.some(n=>n.attrs['data-body-object']==='Unvanishing Line source registration'))
  assert.equal(JSON.stringify({state,model}),before)
 }
})
test('quarter-turn changes only camera bearing; glyphs are registered to existing surfaces and source standing is fixed',()=>{
 const flat={...model,emergence:{...emergence,regard:{...emergence.regard,quarter_turn:0}}}
 const standing = ({fixed,fold,line,crossing}) => JSON.stringify({fixed,fold,line,crossing})
 const before = standing(model)
 for (const presentation of [flat,model]) {
  renderBody(new Node('svg',doc),presentation,'volume')
  assert.equal(standing(presentation),before)
 }
 const f0=bodyFrame(flat,'volume'),f1=bodyFrame(model,'volume')
 assert.ok(Math.abs(f0.forward.reduce((sum,n,i)=>sum+n*f1.forward[i],0))<1e-10)
 assert.deepEqual(f0.eye,f1.eye)
 assert.deepEqual(emergence.registration.fixed_seat,[0,0,0])
 assert.equal(emergence.fresh.local_fashioning_extent,0)
 assert.equal(emergence.fresh.inherited_material_ids.length,1)
 assert.equal(emergence.fresh.accretion_limit,null)
 for(const glyph of emergence.wall_test.marks){assert.ok(base.surfaces.some(s=>s.id===glyph.host));assert.equal(glyph.quad.length,4)}
 assert.ok(emergence.wall_test.early_wall_probe.obstructions.length>0)
 assert.ok(!emergence.presentation.lines.some(l=>l.id==='bellows-UP-reading'))
})
test('FROM WITHIN consumes the same fixed-eye quarter turn at 0, 45 and 90; ordinary monitor has one center line and right-side staged material',async()=>{
 const {near_monitor}=JSON.parse(await readFile(new URL('../fixtures/snail_emergence_contract.json',import.meta.url),'utf8'))
 const m={...model,near_monitor},cameras=[],scenes=[]
 const before=JSON.stringify(m)
 for(const angle of [0,45,90]){
  const changed={...m,emergence:{...emergence,regard:{...emergence.regard,quarter_turn:angle}}}
  const f=bodyFrame(changed,'within');cameras.push(f.forward)
  assert.deepEqual(f.eye,bodyFrame(changed,'volume').eye)
  const svg=new Node('svg',doc);renderBody(svg,changed,'within')
  scenes.push(JSON.stringify(svg.children.map(n=>n.attrs.points).filter(Boolean)))
 }
 assert.equal(new Set(cameras.map(JSON.stringify)).size,3)
 assert.equal(new Set(scenes).size,3)
 const svg=new Node('svg',doc);renderBody(svg,m,'flat')
 assert.equal(svg.children.filter(n=>n.tag==='line').length,1)
 assert.ok(!svg.children.some(n=>n.attrs['data-body-object']?.includes('diagonal')))
 assert.ok(svg.children.filter(n=>n.attrs['data-material']).every(n=>Number(n.attrs.x)>500))
 renderBody(svg,{...m,near_monitor:{...near_monitor,flat:{...near_monitor.flat,material:null}}},'flat')
 assert.ok(!svg.children.some(n=>n.attrs['data-material']))
 assert.equal(JSON.stringify(m),before)
})
