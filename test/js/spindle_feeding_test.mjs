import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const src=await readFile(new URL('../../assets/js/spindle_feeding.js',import.meta.url),'utf8')
const {SpindleFeeding}=await import(`data:text/javascript;base64,${Buffer.from(src).toString('base64')}`)
function fixture(){
  const listeners=new Map(),events=[]
  const button={setPointerCapture(){},addEventListener:(n,f)=>listeners.set(n,f),removeEventListener:(n,f)=>{assert.equal(listeners.get(n),f);listeners.delete(n)}}
  const live={textContent:''},ghost={style:{}}
  const square={getBoundingClientRect:()=>({left:10,right:30,top:100,bottom:120})}
  globalThis.document={querySelector:()=>({getBoundingClientRect:()=>({left:10,right:30,top:40,bottom:60})})}
  const h={...SpindleFeeding,el:{dataset:{disabled:'false',extent:'0',limit:'6'},getBoundingClientRect:()=>({left:0,top:0}),querySelector:s=>({'#feed-stick':button,'.feed-live':live,'.feed-ghost':ghost,'#square-for-regarding':square}[s])},pushEvent:(name,payload,reply)=>{events.push({name,payload});reply?.(name==='start-feed'?{accepted:true,token:'feed-token',extent:0}:name==='feed'?{accepted:true,extent:payload.extent}:{accepted:true})}}
  h.mounted()
  return {h,events,listeners,move:(x,y)=>listeners.get('pointermove')({clientX:x,clientY:y,pointerId:1}),down:()=>listeners.get('pointerdown')({button:0,pointerId:1,preventDefault(){}}),key:k=>listeners.get('keydown')({key:k,preventDefault(){}})}
}
test('actual pointer must cross Regarding square then center square before finite feed can occur',()=>{
  const f=fixture();f.down();f.move(20,50);f.move(20,-200)
  assert.equal(f.events.some(e=>e.name==='feed'),false)
  f.move(20,110);f.move(20,50);f.move(20,1)
  assert.deepEqual(f.events.filter(e=>e.name==='feed-through').map(e=>e.payload.square),['regarding-square','center-square'])
  assert.deepEqual(f.events.filter(e=>e.name==='feed').map(e=>e.payload.extent),[1,2])
  f.move(20,1)
  assert.deepEqual(f.events.filter(e=>e.name==='feed').map(e=>e.payload.extent),[1,2])
  f.move(20,-1000)
  assert.equal(f.events.filter(e=>e.name==='feed').at(-1).payload.extent,6)
})
test('keyboard accommodation does not silently perform the two purchases and cannot exceed the rehearsal limit',()=>{
  const f=fixture();f.key(' ');f.key('ArrowUp');assert.equal(f.events.some(e=>e.name==='feed'),false)
  f.key('c');f.key('ArrowUp');assert.equal(f.events.some(e=>e.name==='feed'),false)
  f.key('r');f.key('c');for(let i=0;i<10;i++)f.key('ArrowUp')
  assert.deepEqual(f.events.filter(e=>e.name==='feed').map(e=>e.payload.extent),[1,2,3,4,5,6])
})
test('cancellation preserves only performed extent and the hook cleans up every listener',()=>{
  const f=fixture();f.key(' ');f.key('r');f.key('c');f.key('ArrowUp');f.key('Escape')
  assert.equal(f.events.at(-1).name,'cancel-feed')
  f.h.destroyed();assert.equal(f.listeners.size,0)
})
test('disconnection discards transient feeding and reconnect releases abandoned purchase state',()=>{
  const f=fixture();f.key(' ');f.h.disconnected();assert.equal(f.h.gesture,null)
  f.h.reconnected();assert.equal(f.events.at(-1).name,'abandon-purchase')
})
