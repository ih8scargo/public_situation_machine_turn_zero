import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8')
const {drawerRail,drawerMechanism,project,suspensionStep}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const extent={rail:{height:3.25,depth:5.2,inward:1.5,x_slots:[3.8,4.1,4.4]},travel:1.4}
test('furnished course begins at bottom, distinguishes 90 from completed 180 and returns around monitor',()=>{
  assert.deepEqual(drawerRail(extent,1,0),[4.1,-3.25,0])
  const half=drawerRail(extent,1,.5),end=drawerRail(extent,1,1)
  assert.ok(Math.abs(half[1])<1e-10);assert.equal(half[2],5.2)
  assert.ok(end[0]<half[0]&&half[0]<4.1);assert.equal(end[1],3.25);assert.ok(Math.abs(end[2])<1e-10)
  let last=drawerRail(extent,1,0)
  for(let i=1;i<=100;i++){
    const next=drawerRail(extent,1,i/100)
    assert.ok(Math.hypot(...next.map((v,k)=>v-last[k]))<.17)
    last=next
  }
})
test('one bounded progress governs distinct CH PUSH and COB rail courses deterministically',()=>{
  const before=JSON.stringify(extent)
  for(const slot of [0,1,2])for(let i=0;i<=100;i++){
    const progress=i/100,m=drawerMechanism(extent,slot,slot,progress)
    assert.equal(m.progress,progress);assert.equal(m.angle,progress*180)
    assert.deepEqual(m.cob,drawerRail(extent,slot,progress))
    assert.equal(m.ch[2],extent.rail.depth*progress)
    assert.deepEqual(m,drawerMechanism(extent,slot,slot,progress))
    for(const bearing of [-160,-45,0,35,90,160])for(const p of [m.ch,m.cob])assert.ok(project(p,bearing).every(Number.isFinite))
  }
  assert.equal(JSON.stringify(extent),before)
  assert.equal(drawerMechanism(extent,1,1,2).progress,1)
  assert.equal(drawerMechanism(extent,1,1,-1).progress,0)
})
test('tab responds perceptibly to turning and still damps deterministically',()=>{
  const initial={x:0,z:0,vx:0,vz:0}
  const a=suspensionStep(initial,4,8,.05)
  assert.deepEqual(a,suspensionStep(initial,4,8,.05))
  assert.ok(Math.abs(a.x)>.002)
  let settled=a;for(let i=0;i<2000;i++)settled=suspensionStep(settled,0,0,1/120)
  assert.ok(Math.abs(settled.x)+Math.abs(settled.z)<.00001)
})
