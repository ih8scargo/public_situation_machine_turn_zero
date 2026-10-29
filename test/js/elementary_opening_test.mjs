import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8')
const {project,furnishedStick,ringPoints,wireframeEdges,responseOffset,settleOffset,suspensionStep,suspendedTab,graspPoints}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
test('one plane is projected front and back without supplying a second scene',()=>{
  const point=[1,1,0],before=[...point]
  assert.notDeepEqual(project(point,0),project(point,160))
  assert.deepEqual(point,before)
  assert.deepEqual(project([0,0,0],130),[400,260])
  assert.notDeepEqual(project([0,0,2],55),project([0,0,0],55))
})
test('wireframe has exactly twelve edges and ring points keep genuine depth',()=>{
  const min=[-1,-1,0],max=[1,1,2]
  assert.equal(wireframeEdges(min,max).length,12)
  const points=ringPoints([0,0,1],[2,1,3],'xz')
  assert.ok(points.some(p=>p[2]>3))
  assert.ok(points.some(p=>p[2]<0))
})
test('through stick preserves Human bearing at every partial extent and pivot',()=>{
  const partial=furnishedStick(38,-17,.5),full=furnishedStick(38,-17,1)
  assert.deepEqual(partial.direction,full.direction)
  full.tip.forEach((n,i)=>assert.ok(Math.abs(n-2*partial.tip[i])<1e-10))
  const before=JSON.stringify(full)
  for(const angle of [-160,-45,0,90,160])project(full.tip,angle)
  assert.equal(JSON.stringify(full),before)
  assert.ok(full.tip[2]>0)
})
test('responsive bobbining is bounded and settles without authoring geometry',()=>{
  const target=responseOffset(100,100)
  assert.ok(Math.hypot(...target)<=.6500001)
  assert.deepEqual(responseOffset(0,0),[0,0,0])
  const next=settleOffset([0,0,0],target,.016)
  assert.ok(next[0]>0&&next[0]<target[0])
  const targetBefore=[...target]
  settleOffset(next,target,.02)
  assert.deepEqual(target,targetBefore)
})
test('projection remains finite across vertical-axis bearings without clipping world geometry',()=>{
  for(let angle=-160;angle<=160;angle+=5)for(const plane of ['xy','xz','yz']){
    for(const point of ringPoints([0,0,1.6],[3.7,2.8,3.2],plane)){
      const [x,y]=project(point,angle)
      assert.ok(Number.isFinite(x)&&Number.isFinite(y))
    }
  }
})

test('vertical-axis Regarding leaves height direction upright and reveals actual depth',()=>{
  assert.deepEqual(project([0,1,0],0),project([0,1,0],90))
  assert.notEqual(project([0,0,2],0)[0],project([0,0,2],90)[0])
})
test('suspended purchase responds repeatably to angular motion and settles under gravity',()=>{
  const initial={x:0,z:0,vx:0,vz:0},a=suspensionStep(initial,4,8,.02),b=suspensionStep(initial,4,8,.02)
  assert.deepEqual(a,b);assert.notEqual(a.z,0);assert.deepEqual(initial,{x:0,z:0,vx:0,vz:0})
  let settled=a;for(let i=0;i<1200;i++)settled=suspensionStep(settled,0,0,1/120)
  assert.ok(Math.abs(settled.x)+Math.abs(settled.z)<.0001)
  const purchase={anchor:[0,0,0],length:.9},point=suspendedTab(purchase,a)
  assert.ok(Math.abs(Math.hypot(...point)-.9)<1e-9)
  assert.deepEqual(purchase.anchor,[0,0,0])
})
test('historical four-point purchase contracts around chosen direction without changing it',()=>{
  const direction=furnishedStick(31,-13,1).direction,before=[...direction]
  const open=graspPoints([0,0,0],direction,false),held=graspPoints([0,0,0],direction,true)
  assert.equal(held.length,4)
  assert.ok(Math.hypot(...held[0])<Math.hypot(...open[0]))
  assert.deepEqual(direction,before)
})
