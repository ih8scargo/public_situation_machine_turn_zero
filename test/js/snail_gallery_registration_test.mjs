import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/workshop/gallery_registration.js',import.meta.url),'utf8')
const {renderGallery,galleryPoint}=await import('data:text/javascript;base64,'+Buffer.from(source).toString('base64'))
const model=JSON.parse(await readFile(new URL('../fixtures/snail_gallery_contract.json',import.meta.url),'utf8'))
class Node{constructor(tag,doc){this.tag=tag;this.ownerDocument=doc;this.children=[];this.attrs={};this.dataset={}}append(n){this.children.push(n)}replaceChildren(){this.children=[]}setAttribute(k,v){this.attrs[k]=String(v)}}
const doc={createElementNS:(_,tag)=>new Node(tag,doc)}
test('paired outreadings retain every wall, HERE, three Landingings and the same material without source mutation',()=>{
 const before=JSON.stringify(model),worlds=[]
 for(const kind of ['plan','section']){
  const svg=new Node('svg',doc);renderGallery(svg,model,kind,'registered-observation-7')
  assert.equal(svg.dataset.view,kind)
  assert.equal(svg.children.filter(n=>n.attrs['data-proposed-table']).length,kind==='plan'?1:0)
  assert.equal(model.provisional.table.nominal_diameter_extents,3)
  assert.equal(model.provisional.table.height,null)
  const walls=svg.children.filter(n=>n.attrs['data-source-wall'])
  assert.equal(walls.length,model.observed.walls.length)
  for(const face of model.observed.walls)assert.deepEqual(JSON.parse(walls.find(n=>n.attrs['data-source-wall']===face.id).attrs['data-world']),face.points)
  assert.ok(svg.children.every(n=>!Object.values(n.attrs).some(s=>/NaN|Infinity|undefined/.test(s))))
  assert.equal(svg.children.filter(n=>n.attrs['data-ghost']).length,4)
  assert.ok(!svg.children.some(n=>n.attrs['data-registration-object']?.startsWith('45-degree Craft')))
  assert.ok(!svg.children.some(n=>n.attrs['data-registration-object']?.startsWith('COB upstanding stand candidate')))
  const markers=svg.children.filter(n=>n.attrs['data-observation-marker'])
  assert.equal(markers.length,25);assert.equal(markers.find(n=>n.attrs['data-observation']==='registered-observation-7').attrs.r,'6')
  worlds.push(markers.map(n=>n.attrs['data-world']))
  assert.ok(svg.children.filter(n=>n.attrs['data-material']).every(n=>n.attrs['data-material']===model.provisional.material_work.material.id))
 }
 assert.deepEqual(worlds[0],worlds[1]);assert.equal(JSON.stringify(model),before)
 assert.notDeepEqual(galleryPoint([1,2,3],'plan'),galleryPoint([1,2,3],'section'))
})
