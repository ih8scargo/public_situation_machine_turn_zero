import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8')
const {applianceView,cutawayFaces,convexHull,traversalPose,traversalStep,framedRing}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
// Phoenix-produced witness exercises the actual JSON → browser geometry boundary.
const course=JSON.parse(await readFile(new URL('../../docs/visual-witnesses/appliance-cutaway-nav/shared-course.json',import.meta.url)))
const stick={cob_center:course.origin.point,tip:course.origin.point.map((v,i)=>v-(i===1?.32:0)),length:2.6}
test('Phoenix course carries reversible distance-based poses and banked local up without camera dependence',()=>{
 const before=JSON.stringify(course),poses=[]
 for(let i=0;i<=20;i++){
  const d=course.length*i/20,p=traversalPose(course,d,stick);poses.push(p)
  assert.ok(Math.abs(Math.hypot(...p.up)-1)<1e-10)
  assert.ok(Math.abs(Math.hypot(...p.direction)-1)<1e-10)
  for(const yaw of [0,90,-90,180])for(const elevation of [-70,0,70])assert.ok(applianceView(p.center,yaw,elevation).point.every(Number.isFinite))
 }
 for(let i=20;i>=0;i--)assert.deepEqual(traversalPose(course,course.length*i/20,stick),poses[i])
 assert.equal(JSON.stringify(course),before)
 assert.deepEqual(poses[0].center,course.origin.point);assert.deepEqual(poses.at(-1).center,course.destination.point)
 const pointed=traversalPose(course,course.length*10/20,stick,[3,1,0])
 assert.deepEqual(pointed.center,poses[10].center);assert.deepEqual(pointed.direction,poses[10].direction);assert.notDeepEqual(pointed.pointDirection,poses[10].pointDirection)
})
test('world-space crossing changes approach faces without changing inward extent or furnishing twelve containers',()=>{
 const small=cutawayFaces(1.8),large=cutawayFaces(4)
 assert.deepEqual(small.filter(f=>f.id.startsWith('interior-')),large.filter(f=>f.id.startsWith('interior-')))
 assert.notDeepEqual(small.find(f=>f.id==='approaching-left'),large.find(f=>f.id==='approaching-left'))
 assert.ok(small.find(f=>f.id==='approaching-left').points.some(p=>p[2]===-2));assert.ok(small.find(f=>f.id==='approaching-left').points.some(p=>p[2]===0))
 for(const yaw of [0,90,180,-90]){const hull=convexHull(large.flatMap(f=>f.points).map(p=>applianceView(p,yaw).point));assert.ok(hull.length>=4);assert.ok(hull.flat().every(Number.isFinite))}
})
test('distance remains fixed when track length grows; bounded movement stops at appointed stations',()=>{
 const d=course.length*.45,p=traversalPose(course,d,stick),extended={...course,length:course.length+1,samples:[...course.samples,{...course.samples.at(-1),point:[0,-.85,12.2],distance:course.length+1}],stations:[course.length,course.length+1]}
 assert.deepEqual(traversalPose(extended,d,stick),p)
 assert.equal(traversalStep(extended,course.length-.02,1,.05),course.length)
 assert.ok(traversalStep(extended,course.length,1,.05)>course.length)
 assert.equal(traversalStep(extended,course.length+.02,-1,.05),course.length)
 assert.equal(traversalStep(course,d,0,.05),d)
})
test('cross-section follows actual banked frame rather than rebuilding world-up rings',()=>{
 const p=traversalPose(course,course.length*.65,stick),ring=framedRing(p.center,[.25,.25,0],'xy',p)
 assert.equal(ring.length,65)
 for(const point of ring){const offset=point.map((v,i)=>v-p.center[i]);assert.ok(Math.abs(Math.hypot(...offset)-.25)<1e-8)}
})
