import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const read=path=>readFile(new URL(path,import.meta.url),'utf8')
const uri=source=>`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`
const apparatusURI=uri(await read('../../assets/js/workshop/apparatus.js'))
const projectionURI=uri((await read('../../assets/js/workshop/projection.js')).replace('./apparatus.js',apparatusURI))
const rendererURI=uri((await read('../../assets/js/workshop/renderer.js')).replace('./projection.js',projectionURI))
const {camera,project,primitives,material,cobPoint}=await import(projectionURI)
const {render}=await import(rendererURI)
const regardingURI=uri(await read('../../assets/js/workshop/regarding.js'))
const {WorkshopRenderer}=await import(uri((await read('../../assets/js/workshop/hook.js')).replace('./renderer.js',rendererURI).replace('./regarding.js',regardingURI)))
const model=JSON.parse(await read('../fixtures/workshop_initial.json'))
class Element {
  constructor(tag,document){this.tag=tag;this.ownerDocument=document;this.attributes={};this.children=[];this.dataset={};this.style={removeProperty(key){delete this[key]}};this.listeners=new Map()}
  setAttribute(k,v){this.attributes[k]=v}
  append(node){this.children.push(node)}
  replaceChildren(){this.children=[]}
  addEventListener(name,handler){this.listeners.set(name,handler)}
  removeEventListener(name,handler){assert.equal(this.listeners.get(name),handler);this.listeners.delete(name)}
  querySelector(){return this.svg}
}
const document={
  createElementNS:(_,tag)=>new Element(tag,document),
  defaultView:{ResizeObserver:class {observe(){} disconnect(){}}},
}
const svg=()=>new Element('svg',document)

test('canonical Phoenix fixture supplies every vertex, edge and inspection surface without hidden geometry',()=>{
  const items=primitives(model)
  assert.equal(items.length,1+19+4*(12+6)+6+25+11+25*12+5)
  assert.equal(items.filter(p=>p.kind==='edge').length,48)
  assert.equal(items.filter(p=>p.kind==='surface').length,24)
  assert.equal(new Set(items.map(p=>p.id)).size,items.length)
  for(const region of Object.values(model.entities))for(let axis=0;axis<3;axis++)assert.equal(Math.max(...region.vertices.map(p=>p[axis]))-Math.min(...region.vertices.map(p=>p[axis])),6)
})
test('opposed structural frames and viewport changes preserve registered coordinates, identity and relationships',()=>{
  const before=JSON.stringify(model),front=camera('front'),reverse=camera('reverse')
  assert.equal(front.forward[0],-reverse.forward[0]);assert.equal(front.forward[2],-reverse.forward[2])
  for(const view of ['front','reverse','plan','lower','transverse','departure','reciprocal'])for(const [width,height] of [[1100,700],[390,300],[2200,1400]]) {
    for(const item of primitives(model))for(const p of item.points)assert.ok(project(p,camera(view),width,height).point.every(Number.isFinite))
    const scene=svg();render(scene,model,view,'lower')
    assert.equal(scene.children.filter(n=>n.tag==='path').length,134+25*12+5)
  }
  assert.equal(JSON.stringify(model),before)
})
test('renderer shows rear edges THROUGH foreground surfaces in either direction with no opaque planar draw',()=>{
  for(const view of ['front','reverse','plan','lower','transverse','departure','reciprocal']) {
    const scene=svg();render(scene,model,view,'ch')
    const paths=scene.children.filter(n=>n.tag==='path')
    assert.ok(paths.every(p=>p.attributes.fill==='none'))
    assert.ok(paths.every(p=>!('mask' in p.attributes)&&!('clip-path' in p.attributes)&&!('opacity' in p.attributes)))
    for(const item of primitives(model)) {
      const actual=paths.find(p=>p.attributes.id===`gw-${item.id}`)
      assert.ok(actual,`${view}: ${item.id} remains drawn`)
      assert.deepEqual(JSON.parse(actual.attributes['data-world-points']),item.points)
    }
    // Both z faces and their edges survive, independent of which face is in front.
    assert.ok(paths.find(p=>p.attributes.id==='gw-tc-surface-z-min'))
    assert.ok(paths.find(p=>p.attributes.id==='gw-tc-surface-z-max'))
    assert.equal(scene.dataset.structuralPaths,String(primitives(model).length))
  }
})
test('hook mounts only local listeners and removes every listener and server event handle on teardown',()=>{
  const host=new Element('div',document);host.svg=svg();host.dataset={model:JSON.stringify(model),regard:'front',selected:'ch'}
  const viewport={scrollWidth:400,clientWidth:400,scrollHeight:400,clientHeight:400,
    scrollLeft:0,scrollTop:0,scrollTo(x,y){this.scrollLeft=x;this.scrollTop=y}}
  const controls=new Map()
  host.querySelector=selector=>{
    if(selector==='#gw-scene') return host.svg
    if(selector==='#gw-regarding-viewport') return viewport
    if(['#gw-pretend-regarding','#gw-axis-witness'].includes(selector)) return null
    if(!controls.has(selector)) controls.set(selector,new Element('button',document))
    return controls.get(selector)
  }
  const events=new Map(),pushed=[]
  const hook={...WorkshopRenderer,el:host,pushEvent:(name,payload)=>pushed.push({name,payload}),handleEvent:(name,fn)=>{events.set(name,fn);return name},removeHandleEvent:ref=>events.delete(ref)}
  hook.mounted()
  assert.equal(host.listeners.size,2);assert.equal(events.size,1)
  hook.updated();assert.equal(pushed.length,0)
  host.listeners.get('click')({target:{closest:()=>({dataset:{entity:'tc'}})}})
  assert.deepEqual(pushed,[{name:'select',payload:{id:'tc'}}])
  hook.destroyed();assert.equal(host.listeners.size,0);assert.equal(events.size,0)
})

test('yaw pivot and station selection retain registered points and separate U and N in every inspection',()=>{
  const before=JSON.stringify(model)
  for(const yaw of [-180,-90,-35,0,47,90,180])for(const view of ['front','reverse','plan','lower','transverse','departure','reciprocal']) {
    const scene=svg();render(scene,model,view,'central',yaw,18)
    assert.ok(scene.children.find(n=>n.attributes.id==='gw-steeling-letter-13'))
    assert.ok(scene.children.find(n=>n.attributes.id==='gw-steeling-letter-18'))
    assert.equal(scene.children.filter(n=>n.tag==='path').length,134+25*12+5)
    assert.ok(scene.children.filter(n=>n.tag==='path').every(n=>n.attributes.fill==='none'&&!/NaN|Infinity/.test(n.attributes.d)))
  }
  assert.equal(JSON.stringify(model),before)
  for(const kind of ['front','plan'])assert.notDeepEqual(project([15,3,0],camera(kind,0)).point,project([15,3,0],camera(kind,70)).point)
})
test('schema-1 geometry still renders all 92 original structural paths without a fabricated lettering course',async()=>{
  const old=JSON.parse(await read('../fixtures/workshop_milestone_one.json')),scene=svg(),before=JSON.stringify(old)
  render(scene,old,'reverse','ch')
  assert.equal(scene.children.filter(n=>n.tag==='path').length,92)
  assert.equal(JSON.stringify(old),before)
})

test('both presentation bearings match the Phoenix-produced contract and retain source Footing identity',async()=>{
  const contract=JSON.parse(await read('../fixtures/workshop_projection_contract.json')),m=contract.model,before=JSON.stringify(m)
  const actual=material(m).map(({vertical,oblique})=>({vertical,oblique}))
  assert.deepEqual(actual,contract.expected_material)
  assert.equal(actual.length,5)
  for(const pair of actual){assert.equal(pair.vertical.footing_id,pair.oblique.footing_id);assert.deepEqual(pair.vertical.source,pair.oblique.source);assert.notDeepEqual(pair.vertical.point,pair.oblique.point)}
  for(const mode of ['vertical','oblique','both'])for(const view of ['front','departure','reciprocal','transverse'])for(const yaw of [-180,0,53,180]) {
    const scene=svg();render(scene,m,view,'central',yaw,13,mode,3)
    const paths=scene.children.filter(n=>n.tag==='path')
    assert.ok(paths.every(n=>n.attributes.fill==='none'&&!/NaN|Infinity/.test(n.attributes.d)))
    for(let i=1;i<=5;i++) {
      assert.ok(paths.some(n=>n.attributes.id===`gw-footing-${i}-source`))
      for(const kind of ['vertical','oblique'])assert.equal(paths.some(n=>n.attributes.id===`gw-footing-${i}-${kind}`),mode==='both'||mode===kind)
    }
  }
  assert.equal(JSON.stringify(m),before)
})
test('COB reference position and all registered staging geometry are invariant under Regarding changes',async()=>{
  const {model:m}=JSON.parse(await read('../fixtures/workshop_projection_contract.json')),before=JSON.stringify(m),point=cobPoint(m)
  for(const mode of ['vertical','oblique','both']) {
    const items=primitives(m,mode)
    assert.ok(items.some(n=>n.id==='crossing-reference-course'))
    assert.ok(items.some(n=>n.id==='crossing-six-extent-height'))
    assert.equal(items.filter(n=>n.kind==='edge').length,48)
    if(mode!=='both')assert.ok(!items.some(n=>n.bearing&&n.bearing!==mode))
  }
  assert.equal(JSON.stringify(m),before)
  const moved=structuredClone(m);moved.rehearsal.progress=.7
  assert.notDeepEqual(cobPoint(moved),point)
  assert.deepEqual(moved.rehearsal.footings,m.rehearsal.footings)
  assert.equal(cobPoint(moved)[1],3)
})

test('calibration registry projects in Tunneling, Diorama and oblique views without changing its measured points or provenance',async()=>{
  const {model,state,registry}=JSON.parse(await read('../fixtures/workshop_calibration_contract.json')),before=JSON.stringify({model,state,registry})
  for(const view of ['tunneling','diorama','reciprocal'])for(const yaw of [-180,0,45,180]) {
    const scene=svg();render(scene,model,view,'central',yaw,13,'both',1,registry,'u-aperture')
    const paths=scene.children.filter(n=>n.tag==='path')
    assert.ok(paths.every(n=>n.attributes.fill==='none'&&!/NaN|Infinity/.test(n.attributes.d)))
    for(const id of ['u-aperture','bobbining-enclosure','flat-aperture','doll-toes','SIX-upstage','camera-zero','camera-one','camera-two','projection-thing','monitor-prospective']) {
      const path=paths.find(n=>n.attributes.id===`gw-cal-${id}`)
      assert.ok(path,id)
      assert.deepEqual(JSON.parse(path.attributes['data-world-points']),registry.items.find(i=>i.id===id).points)
    }
    assert.ok(!paths.some(n=>n.attributes.id==='gw-cal-camera-three'))
    assert.equal(paths.filter(n=>n.attributes.class.includes('gw-edge ')).length,48)
  }
  assert.equal(JSON.stringify({model,state,registry}),before)
})

test('U13 trial carries both Ground lines through separate cage corners to the receiving region', () => {
  const items = primitives(model)
  const find = id => items.find(item => item.id === id).points
  const xt = find('xt-toward-xt')
  const yt = find('yt-returns-toward-xt')
  assert.deepEqual(xt[0], [15, -6, -2])
  assert.deepEqual(yt[0], xt[0])
  assert.deepEqual(xt[1], [14.5, 3.5, 0.5])
  assert.deepEqual(yt[1], [15.5, 3.5, 0.5])
  assert.equal(xt[2][1], 6)
  assert.deepEqual(find('u13-re-step-region').slice(0, 2), [xt[2], yt[2]])
  assert.equal(items.filter(item => item.kind === 'trial-cage').length, 12)
  assert.equal(items.filter(item => item.kind === 'inherited-cage').length, 24 * 12)
})
