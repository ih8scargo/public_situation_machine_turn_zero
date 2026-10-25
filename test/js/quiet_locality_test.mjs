import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/quiet_locality.js',import.meta.url),'utf8')
const {advanceMotion,elbowPoint,tensionFor,QuietLocality,boundedScale,tackCount,regardDirection,sheetPlacement}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const simulate=(state,input,seconds)=>{for(let i=0;i<seconds*60;i++)state=advanceMotion(state,input,1/60);return state}

test('holding gathers bounded pace, release coasts, and backward decelerates before reversing',()=>{
  const start={position:1,velocity:0,across:0}
  const paced=simulate(start,{along:1},.6)
  assert.ok(paced.velocity>0&&paced.velocity<=1.5)
  const release=advanceMotion(paced,{},1/60)
  assert.ok(release.position>paced.position&&release.velocity>0&&release.velocity<paced.velocity)
  const initiallyBack=advanceMotion(paced,{along:-1},1/60)
  assert.ok(initiallyBack.velocity>0&&initiallyBack.velocity<paced.velocity)
  const reversed=simulate(initiallyBack,{along:-1},1)
  assert.ok(reversed.velocity<0)
  const settled=simulate(paced,{},3)
  assert.equal(settled.velocity,0)
})
test('ACROSS is restrained and returns to the principal course; NAV bounds do not create more passage',()=>{
  const start={position:2,velocity:0,across:0}
  const across=simulate(start,{across:100},1)
  assert.ok(across.across>0&&across.across<=.65)
  assert.equal(across.position,2)
  assert.ok(simulate(across,{},2).across<.001)
  const bounded=simulate({position:5.9,velocity:1.5,across:0},{along:1},10)
  assert.equal(bounded.position,6)
  assert.equal(bounded.velocity,0)
})
test('one elbow has monotonic course and a single curvature sign, with no S reversal',()=>{
  const points=Array.from({length:21},(_,i)=>elbowPoint(i/20))
  for(let i=1;i<points.length;i++){assert.ok(points[i].x>=points[i-1].x);assert.ok(points[i].y<=points[i-1].y)}
  const crosses=[]
  for(let i=1;i<points.length-1;i++){
    const a={x:points[i].x-points[i-1].x,y:points[i].y-points[i-1].y}
    const b={x:points[i+1].x-points[i].x,y:points[i+1].y-points[i].y}
    crosses.push(a.x*b.y-a.y*b.x)
  }
  assert.ok(crosses.every(v=>v<0))
})
test('one corner cannot produce square Readingmenting; two distinct corners can',()=>{
  assert.equal(tensionFor([0,0],1),.55)
  assert.equal(tensionFor([0,3],1),1)
  assert.equal(tensionFor([0,3],-10),0)
})

class Node {
  constructor(dataset={}){this.dataset=dataset;this.attrs={};this.nodes=new Map();this.events=new Map();this.children=[];this.hidden=false;this.classes=new Set();this.classList={toggle:(name,active)=>active?this.classes.add(name):this.classes.delete(name)};this.style={setProperty:(key,value)=>{this.style[key]=value}}}
  setAttribute(key,value){this.attrs[key]=String(value)}
  append(node){this.children.push(node)}
  replaceChildren(){this.children=[]}
  querySelector(key){return this.nodes.get(key)}
  querySelectorAll(key){return this.nodes.get(key)||[]}
  addEventListener(name,fn){this.events.set(name,fn)}
  removeEventListener(name){this.events.delete(name)}
  closest(key){return this.matches?.get(key)||null}
  getScreenCTM(){return {inverse:()=>({})}}
  setPointerCapture(){}
  getBoundingClientRect(){return {x:500,y:150,width:24,height:24}}
  emit(type,extra={}){this.events.get(type)?.({type,target:this,button:0,pointerId:1,preventDefault(){},...extra})}
}
function sheet(){
  const node=new Node(),corners=Array.from({length:4},(_,i)=>new Node({corner:String(i)}))
  for(const selector of ['h2','.quiet-sheet-text','.quiet-sheet-cloth path'])node.nodes.set(selector,new Node())
  node.nodes.set('[data-corner]',corners)
  corners.forEach((corner,i)=>{
    node.nodes.set(`[data-corner="${i}"]`,corner)
    corner.matches=new Map([['[data-corner]',corner],['[data-sheet]',node]])
  })
  return node
}
let now=0,frame
function fixture({tunnel=false,sheets=[]}={}){
  now=0;frame=null
  globalThis.performance={now:()=>now}
  globalThis.requestAnimationFrame=fn=>{frame=fn;return 1}
  globalThis.cancelAnimationFrame=()=>{frame=null}
  globalThis.DOMPoint=class{constructor(x,y){this.x=x;this.y=y}matrixTransform(){return this}}
  globalThis.window=new Node()
  globalThis.document=new Node()
  document.createElementNS=()=>new Node()
  document.createElement=()=>new Node()
  const scene={tunnel,entered:!tunnel,wheel:0,reset:0,calibrated:false,sheets,provenance:[],from:'ONE-APPROACH',bearing:{from:'ZEROETH',toward:'ONE'},courseLength:6,context:{materials:[],relations:[],revisions:[]}}
  const root=new Node({scene:JSON.stringify(scene)})
  const svg=new Node();root.nodes.set('svg',svg)
  const parts={}
  for(const name of ['tacks','sheet-attachments','provenance','sheets','sheet-template','roundabout','room','tunnel','appointment','nav','gesture-hint','motion-reading','bobbing','pointing-tool','points','inner-aperture','context','bearing-regard','bearing-inscription','regard-purchase']){
    parts[name]=new Node();root.nodes.set(`[data-part="${name}"]`,parts[name])
  }
  parts['sheet-template'].content={firstElementChild:{cloneNode:sheet}}
  parts.points.nodes.set('circle',Array.from({length:4},()=>new Node()))
  parts.context.nodes.set('.quiet-context-leaf',new Node())
  const emitted=[]
  const hook={...QuietLocality,el:root,pushEvent:(name,payload,callback)=>{emitted.push({name,payload});callback?.({accepted:true})}}
  hook.mounted()
  const frames=n=>{for(let i=0;i<n;i++){now+=1000/60;const fn=frame;frame=null;fn(now)}}
  return {root,parts,hook,emitted,frames}
}
function target(key,dataset){const node=new Node(dataset);node.matches=new Map([[key,node]]);return node}

test('mounted room makes Bobbing attend actual pointer motion and articulates through draw/turn/release',()=>{
  const f=fixture()
  const before=f.parts.bobbing.attrs.transform
  f.root.emit('pointermove',{clientX:800,clientY:300})
  f.frames(30)
  assert.notEqual(f.parts.bobbing.attrs.transform,before)
  const circle=target('[data-room-target]',{roomTarget:'circle'})
  f.root.emit('pointerdown',{target:circle,clientX:500,clientY:482})
  f.root.emit('pointermove',{clientX:700,clientY:200})
  f.frames(4)
  assert.equal(f.parts['pointing-tool'].attrs.display,'')
  assert.equal(f.parts.points.querySelectorAll('circle').length,4)
  f.root.emit('pointerup')
  assert.ok(f.emitted.some(e=>e.name==='pointer'&&e.payload.op==='draw'))
  assert.ok(f.emitted.some(e=>e.name==='pointer'&&e.payload.op==='turn'))
  assert.ok(f.emitted.some(e=>e.name==='pointer'&&e.payload.op==='release'))
  assert.ok(!f.emitted.some(e=>e.name==='appoint-pointer'))
  f.hook.destroyed()
  assert.equal(f.root.events.size,0)
})
test('mounted hold/release NAV moves Bobbing and lattice through rAF without any consequence request',()=>{
  const f=fixture({tunnel:true})
  const forward=target('[data-nav]',{nav:'forward'})
  f.root.emit('pointerdown',{target:forward,clientX:700,clientY:640})
  f.frames(45)
  const position=f.hook.motion.position
  assert.ok(position>0)
  const tack=f.parts.tacks.children[0].attrs.d
  f.root.emit('pointerup')
  f.frames(5)
  assert.ok(f.hook.motion.position>position)
  assert.notEqual(f.parts.tacks.children[0].attrs.d,tack)
  assert.ok(f.emitted.every(e=>e.name==='nav-motion'))
  f.hook.destroyed()
})
test('taking a sheet through the Inner Aperture resolves it without a Square button, and relinquishes the same material',()=>{
  const material={id:'note',title:'Note',text:'Material remains where it stands.',course:1,
    context:{origin:'ZEROETH',materials:[{id:'inherited-note',title:'Inherited',text:'Recorded context.'}],relations:[],revisions:[]}}
  const f=fixture({tunnel:true,sheets:[material]})
  const record=f.hook.sheetNodes.get('note')
  record.node.matches=new Map([['[data-sheet]',record.node]])
  f.root.emit('pointerdown',{target:record.node,clientX:250,clientY:200})
  f.root.emit('pointerup')
  f.frames(45)
  assert.ok(record.node.classes.has('is-square'))
  assert.equal(f.hook.sheet.id,'note')
  assert.equal(f.parts['inner-aperture'].dataset.material,'note')
  f.hook.look('xt');f.frames(1)
  assert.equal(f.parts.context.hidden,false)
  assert.equal(f.parts.context.querySelector('.quiet-context-leaf').children[1].textContent,'Recorded context.')
  f.hook.look('yt');f.frames(1)
  assert.equal(f.parts.context.hidden,true)
  assert.equal(f.hook.sheet.id,'note')
  f.hook.relinquish();f.frames(1)
  assert.equal(f.hook.sheet.id,null)
  assert.ok(!record.node.classes.has('is-square'))
  assert.equal(f.hook.sheetNodes.get('note').node,record.node)
  assert.equal(record.material.id,'note')
  assert.ok(f.emitted.every(e=>['nav-motion','sheet'].includes(e.name)))
  assert.ok(!f.emitted.some(e=>e.payload.op==='square'||e.payload.op==='catch'))
  f.hook.destroyed()
})
test('loading a separate first-passage fixture rebuilds the scene from its material and resets ephemeral handling',()=>{
  const f=fixture()
  f.hook.pointer.drawn=true
  const next={...f.hook.scene,tunnel:true,entered:false,reset:1,sheets:[{id:'recovered',title:'Recovered sheet',text:'From the ledger.',course:1}]}
  f.root.dataset.scene=JSON.stringify(next)
  f.hook.updated()
  assert.equal(f.hook.sheetNodes.size,1)
  assert.equal(f.hook.sheetNodes.get('recovered').node.querySelector('h2').textContent,'Recovered sheet')
  assert.equal(f.hook.pointer.drawn,false)
  assert.equal(f.parts.room.attrs.display,'none')
  assert.equal(f.parts.tunnel.attrs.display,'')
  f.frames(1)
  f.hook.destroyed()
})
test('sweeping the physical Inner Aperture gives four bearings without four mode buttons',()=>{
  const f=fixture({tunnel:true,sheets:[{id:'note',title:'Note',text:'Readable.',course:1}]})
  f.hook.resolve('note')
  const grip=target('[data-inner-grip], [data-part="regard-purchase"]',{})
  for(const [dx,dy,direction] of [[-100,0,'xt'],[100,0,'yt'],[0,-100,'up'],[0,100,'down']]){
    f.root.emit('pointerdown',{target:grip,clientX:500,clientY:300})
    f.root.emit('pointermove',{clientX:500+dx,clientY:300+dy})
    f.root.emit('pointerup')
    f.frames(1)
    assert.equal(f.hook.regard,direction)
    assert.equal(f.hook.sheet.id,'note')
  }
  assert.equal(regardDirection(4,3),null)
  f.hook.destroyed()
})
test('DOWN recovers the same FROM and UP the same receiving bearing after forward or reverse NAV',()=>{
  const f=fixture({tunnel:true,sheets:[{id:'note',title:'Note',text:'Readable.',course:1}]})
  const bearing=f.parts['bearing-inscription'].textContent
  f.hook.look('down');f.frames(1)
  const fromPosition={...f.hook.provenance[0].text.attrs}
  const fromText=f.hook.provenance[0].text.textContent
  f.hook.motion={position:5,velocity:-1,across:0}
  f.frames(1)
  assert.equal(f.hook.provenance[0].text.textContent,fromText)
  assert.equal(f.hook.provenance[0].text.attrs.x,fromPosition.x)
  assert.equal(f.hook.provenance[0].text.attrs.y,fromPosition.y)
  f.hook.look('up');f.frames(1)
  assert.equal(f.parts['bearing-inscription'].textContent,bearing)
  assert.equal(f.parts['bearing-regard'].dataset.toward,'ONE')
  assert.equal(f.parts['bearing-regard'].style.opacity,'1')
  f.hook.destroyed()
})
test('bidirectional sheet neighborhoods retain the same source and receiving bearing',()=>{
  const material={id:'note',title:'Note',text:'Standing remains.',course:2}
  const f=fixture({tunnel:true,sheets:[material]})
  const bearing=f.parts['bearing-inscription'].textContent
  for(const velocity of [1,-1]){
    f.hook.motion={position:1.8,velocity,across:0}
    f.frames(1)
    assert.equal(f.hook.sheetNodes.get('note').node.hidden,false)
    f.hook.resolve('note')
    assert.equal(f.hook.sheet.id,'note')
    assert.deepEqual(f.hook.sheetNodes.get('note').material,material)
    assert.equal(f.parts['bearing-inscription'].textContent,bearing)
    f.hook.relinquish()
  }
  assert.equal(sheetPlacement(2,5,1).available,false)
  assert.notEqual(tackCount(6,1),tackCount(6,10))
  assert.ok(tackCount(600,100)<=48)
  f.hook.destroyed()
})
test('readable calibration is bounded, shared across fixtures in memory, and does not redefine course geometry',()=>{
  const f=fixture({tunnel:true})
  const course=elbowPoint(.5)
  f.hook.calibrate(100)
  assert.equal(f.hook.scale,1.15)
  f.hook.calibrate(-100)
  assert.equal(f.hook.scale,.85)
  assert.deepEqual(elbowPoint(.5),course)
  assert.equal(boundedScale(NaN),1)
  f.hook.destroyed()
  const next=fixture({tunnel:true})
  assert.equal(next.hook.scale,.85)
  next.hook.destroyed()
})
