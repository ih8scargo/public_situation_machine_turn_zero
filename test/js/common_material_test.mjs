import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const code=await readFile(new URL('../../assets/js/workshop/common_material.js',import.meta.url),'utf8')
const {projection,renderCommonMaterial,selectRegarding,CommonMaterial}=await import(`data:text/javascript;base64,${Buffer.from(code).toString('base64')}`)
const model=JSON.parse(await readFile(new URL('../fixtures/common_material_contract.json',import.meta.url),'utf8'))
const state=JSON.parse(await readFile(new URL('../../docs/visual-witnesses/snail-weave/two-woven-turns.json',import.meta.url),'utf8')).state
class Node {
 constructor(tag,doc){this.tag=tag;this.ownerDocument=doc;this.children=[];this.attrs={};this.dataset={};this.hidden=false}
 replaceChildren(){this.children=[]}
 append(n){this.children.push(n)}
 setAttribute(k,v){this.attrs[k]=String(v)}
}
const doc={createElementNS:(_,tag)=>new Node(tag,doc)}
const makeRoot=()=>{
 const nodes=Object.fromEntries(['tunneling-scene','flat-scene','tunneling-card','flat-card','view-status'].map(id=>[`#cm-${id}`,new Node('div',doc)]))
 const buttons=['both','tunneling','flat'].map(mode=>{const n=new Node('button',doc);n.dataset.cmMode=mode;return n})
 return {dataset:{model:JSON.stringify(model)},querySelector:id=>nodes[id],querySelectorAll:()=>buttons,
  addEventListener(){},removeEventListener(){},nodes,buttons}
}

test('actual Elixir contract projects the same source points in distinct views with finite geometry',()=>{
 const before=JSON.stringify(model),all=[]
 for(const view of ['tunneling','flat']){
  const svg=new Node('svg',doc)
  renderCommonMaterial(svg,model,view)
  assert.ok(svg.children.every(n=>!Object.values(n.attrs).some(v=>/NaN|Infinity/.test(v))))
  const material=svg.children.filter(n=>n.attrs['data-material'])
  assert.ok(material.length>0)
  assert.ok(material.every(n=>n.attrs['data-material']===model.source.material.id))
  for(const node of material){
   const source=model.samples.find(s=>String(s.index)===node.attrs['data-source-index'])
   assert.deepEqual(JSON.parse(node.attrs['data-world']),source.point)
   if(node.tag==='circle'){
    const span=svg.children.find(n=>n.attrs['data-reference']===model.mapping.id).attrs.points
      .split(' ').map(p=>p.split(',').map(Number))
    const [a,b]=span,p=[Number(node.attrs.cx),Number(node.attrs.cy)]
    // A sample of a straight world extent must lie on its projected extent,
    // rather than a decorative offset masquerading as the registered point.
    assert.ok(Math.abs((p[0]-a[0])*(b[1]-a[1])-(p[1]-a[1])*(b[0]-a[0]))<1e-7)
   }
  }
  all.push(material.map(n=>[n.attrs['data-source-index'],n.attrs['data-material'],n.attrs['data-world']]))
 }
 assert.deepEqual(all[0],all[1])
 assert.equal(JSON.stringify(model),before)
 const at=model.diagonal.midpoint
 assert.deepEqual(projection(model,'flat')(at),[at[0],-at[1]])
 const screen=projection(model,'tunneling')(at)
 assert.ok(screen.every(n=>Math.abs(n)<1e-12))
})

test('paired/flat/tunneling switching and hook updates preserve canonical source, HERE, NEXT and Footings',()=>{
 const root=makeRoot(),before=JSON.stringify({state,model}),context={el:root}
 CommonMaterial.mounted.call(context)
 for(const mode of ['flat','tunneling','both','flat','both']){
  selectRegarding(root,mode)
  assert.equal(root.nodes['#cm-flat-card'].hidden,mode==='tunneling')
  assert.equal(root.nodes['#cm-tunneling-card'].hidden,mode==='flat')
  assert.equal(root.buttons.filter(b=>b.attrs['aria-pressed']==='true').length,1)
  context.mode=mode
  CommonMaterial.updated.call(context)
  assert.equal(root.dataset.mode,mode)
  assert.equal(root.nodes['#cm-flat-scene'].dataset.material,model.source.material.id)
  assert.equal(root.nodes['#cm-tunneling-scene'].dataset.material,model.source.material.id)
  assert.equal(JSON.stringify({state,model}),before)
 }
 const count=state.body.material.length
 assert.equal(new Set(model.samples.map(s=>s.material)).size,1)
 assert.equal(state.body.material.length,count)
 const mode=root.dataset.mode
 selectRegarding(root,'acquire')
 assert.equal(root.dataset.mode,mode)
 CommonMaterial.destroyed.call(context)
})

test('empty source draws reference geometry without fabricated material; mapping is anchored, not collapsed',()=>{
 const empty={...model,source:null,samples:[]},svg=new Node('svg',doc)
 renderCommonMaterial(svg,empty,'tunneling')
 assert.equal(svg.children.filter(n=>n.attrs['data-material']).length,0)
 const [a,b]=model.mapping.endpoints
 assert.notDeepEqual(a,b)
 const midpoint=a.map((x,i)=>(x+b[i])/2)
 assert.deepEqual(midpoint,model.diagonal.midpoint)
 assert.equal(model.mapping.physical_transform,null)
 assert.equal(model.registration.upper_check.status,'UNREGISTERED')
})
