import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const dataURL=s=>`data:text/javascript;base64,${Buffer.from(s).toString('base64')}`
const dependency=await readFile(new URL('../../assets/js/workshop/wedging_room.js',import.meta.url),'utf8')
const stands=await readFile(new URL('../../assets/js/workshop/regarding_stands.js',import.meta.url),'utf8')
const source=(await readFile(new URL('../../assets/js/workshop/snail_body.js',import.meta.url),'utf8')).replace("'./wedging_room.js'",JSON.stringify(dataURL(dependency))).replace("'./regarding_stands.js'",JSON.stringify(dataURL(stands)))
const {renderBody,bodyFrame}=await import(dataURL(source))
const {models,state}=JSON.parse(await readFile(new URL('../fixtures/snail_body_contract.json',import.meta.url),'utf8'))
class Node{constructor(tag,doc){this.tag=tag;this.ownerDocument=doc;this.children=[];this.dataset={};this.attrs={}}replaceChildren(){this.children=[]}append(n){this.children.push(n)}setAttribute(k,v){this.attrs[k]=String(v)}}
const doc={createElementNS:(_,tag)=>new Node(tag,doc)}
const length=ps=>ps.slice(1).reduce((sum,p,i)=>sum+Math.hypot(...p.map((v,j)=>v-ps[i][j])),0)
test('all fold angles render finite common geometry in five views, including downward FROM WITHIN',()=>{
 const before=JSON.stringify({models,state})
 for(const model of models)for(const mode of ['external','reverse','plan','section','within']){
  const svg=new Node('svg',doc);renderBody(svg,model,mode)
  assert.equal(svg.dataset.view,mode);assert.ok(svg.children.length>5)
  assert.ok(svg.children.every(n=>!Object.values(n.attrs).some(v=>/NaN|Infinity/.test(v))))
  assert.deepEqual(JSON.parse(svg.dataset.fixed),models[0].fixed)
 }
 assert.deepEqual(bodyFrame(models[2],'within').forward.map(n=>Math.round(n)),[0,-1,0])
 assert.equal(JSON.stringify({models,state}),before)
})
test('hidden side instrument retains world registration; gathered and outstanding line are separately furnished',()=>{
 const model=models[2],before=JSON.stringify(model),svg=new Node('svg',doc)
 renderBody(svg,model,'external',true)
 assert.ok(svg.children.some(n=>n.attrs['data-body-object']==='side-AROUND-THE-CORNER'))
 assert.ok(svg.children.some(n=>n.attrs['data-body-object']==='gathered-YT-winding'))
 renderBody(svg,model,'external',false)
 assert.ok(!svg.children.some(n=>n.attrs['data-body-object']==='side-AROUND-THE-CORNER'))
 assert.equal(JSON.stringify(model),before)
 assert.equal(state.withdrawn,state.gathered+state.outstanding)
 assert.ok(Math.abs(length(model.line.visible)-state.outstanding/1000)<1e-9)
 assert.ok(svg.children.some(n=>n.attrs['data-body-object']==='ordinary-flat-monitor'))
})
