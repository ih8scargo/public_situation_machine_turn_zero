import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/workshop/wedging_room.js',import.meta.url),'utf8')
const {frame,project,renderRoom,clipPolygon}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const {room,state}=JSON.parse(await readFile(new URL('../fixtures/wedging_round_two_contract.json',import.meta.url),'utf8'))
class Node{constructor(tag,doc){this.tag=tag;this.ownerDocument=doc;this.children=[];this.dataset={};this.attrs={}}replaceChildren(){this.children=[]}append(n){this.children.push(n)}setAttribute(k,v){this.attrs[k]=String(v)}}
const doc={createElementNS:(_,tag)=>new Node(tag,doc)}
test('within, plan, section and rotated external inspect the exact shared centerlines and meshes without changing standing',()=>{
 const original=JSON.stringify({room,state})
 for(const view of ['within','plan','section','external']){
  const svg=new Node('svg',doc);renderRoom(svg,room,frame(view,0,0,18,35,1),0)
  assert.equal(svg.dataset.view,view)
  assert.ok(svg.children.length>100)
  assert.ok(svg.children.every(n=>!Object.values(n.attrs).some(v=>/NaN|Infinity/.test(v))))
  assert.ok(svg.children.some(n=>n.attrs.class==='wgr-centerline'&&n.attrs.points.length>0))
 }
 assert.equal(JSON.stringify({room,state}),original)
 const p=room.pairs[0].up_over.centerline[48]
 assert.notDeepEqual(project(p,frame('external',0,0,18,0)).point,project(p,frame('external',0,0,18,90)).point)
 assert.deepEqual(frame('within').eye,[0,.65,0])
})
test('all indexed surface faces resolve to finite shared ring vertices, both courses return HERE, and existing foundation is inherited',()=>{
 for(const pair of [...room.pairs,room.proposal])for(const name of ['up_over','ordinary']){
  const c=pair[name],vertices=c.rings.flat()
  assert.equal(c.rings.length,97);assert.equal(c.faces.length,96*12)
  for(const face of c.faces)for(const i of face){assert.ok(i>=0&&i<vertices.length);assert.ok(vertices[i].every(Number.isFinite))}
  assert.deepEqual(c.entrance,c.return);assert.ok(c.length>3)
 }
 assert.equal(state.footings.length,2);assert.equal(state.founding.first_footing,state.footings[0].id)
 assert.equal(room.pairs[0].curvature_measurements.local_elbow_max_difference,0)
 assert.ok(room.pairs[0].curvature_measurements.whole_course_max_difference>0)
})
test('perspective clips behind-eye polygons before division rather than faking a backdrop',()=>{
 assert.deepEqual(clipPolygon([[-1,0,-2],[1,0,-2],[0,1,-1]]),[])
 const p=clipPolygon([[-1,-1,-1],[1,-1,1],[1,1,1],[-1,1,-1]])
 assert.ok(p.length>=3);assert.ok(p.every(v=>v[2]>=.039999999))
})
