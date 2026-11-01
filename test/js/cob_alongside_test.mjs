import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8')
const {treadmillStep,treadmillSettings,companionPose,companionWheels,shoulderFrame,applianceView}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const {course,stick}=JSON.parse(await readFile(new URL('../../docs/visual-witnesses/cob-alongside/course-contract.json',import.meta.url)))
const start={distance:0,velocity:0,reverse:false,attached:false}
const advance=(state,command,seconds)=>{let s={...state};for(let i=0;i<seconds*120;i++)s=treadmillStep(s,course,command,1/120);return s}
test('commanded purchase integrates distinct velocity, release coasts down and braking stops faster',()=>{
 const gentle=advance(start,'gentle',1),strong=advance(start,'strong',1)
 assert.ok(strong.velocity>gentle.velocity);assert.ok(strong.distance>gentle.distance)
 const coast=advance(strong,'rest',.5),brake=advance(strong,'brake',.5)
 assert.ok(coast.velocity<strong.velocity);assert.ok(coast.velocity>brake.velocity)
 assert.ok(coast.distance>strong.distance)
 assert.equal(advance(gentle,'brake',1).velocity,0)
 assert.equal(advance(gentle,'rest',3).velocity,0)
 assert.ok(advance(start,'strong',5).velocity<=treadmillSettings.maxSpeed)
})
test('same input yields identical reversible current-turn mechanics with finite station stops',()=>{
 assert.deepEqual(advance(start,'working',2),advance(start,'working',2))
 const forward=advance(start,'strong',2),reverse=advance({...forward,velocity:0,reverse:true},'strong',1)
 assert.ok(reverse.distance<forward.distance);assert.ok(reverse.velocity<0)
 const arrived=advance({distance:course.length-.01,velocity:2},'strong',1)
 assert.equal(arrived.distance,course.length);assert.equal(arrived.velocity,0)
 const attached=advance({...forward,attached:true},'strong',2)
 assert.equal(attached.velocity,0);assert.ok(attached.distance<forward.distance+forward.velocity/4+.001)
})
test('four wheels retain tack contacts, local course heading, bank and deterministic roll',()=>{
 for(const fraction of [0,.2,.5,.65,.9,1])for(const lateral of [-1,0,1]){
  const wheels=companionWheels(course,course.length*fraction,stick,lateral)
  assert.equal(new Set(wheels.map(w=>w.id)).size,4)
  for(const w of wheels){assert.ok(Math.abs(Math.hypot(...w.center.map((v,i)=>v-w.contact[i]))-.1)<1e-8);assert.equal(w.angle,course.length*fraction/.1);assert.ok(w.contact.every(Number.isFinite))}
 }
 const p=companionPose(course,course.length*.5,stick),shifted=companionPose(course,course.length*.5,stick,1)
 assert.ok(Math.abs(Math.hypot(...p.center.map((v,i)=>v-shifted.center[i]))-.18)<1e-8)
 assert.deepEqual(p.direction,shifted.direction)
})
test('shoulder camera is UP OVER and behind the same companion, and view changes never mutate course or pose',()=>{
 const before=JSON.stringify(course),p=companionPose(course,course.length*.65,stick),original=JSON.stringify(p),frame=shoulderFrame(p),offset=frame.origin.map((v,i)=>v-p.center[i]),dot=(a,b)=>a.reduce((n,v,i)=>n+v*b[i],0)
 assert.ok(dot(offset,p.up)>.6);assert.ok(dot(offset,p.direction)<-1.3)
 assert.ok(applianceView(p.center,0,0,frame).point.every(Number.isFinite))
 for(const yaw of [0,90,180])applianceView(p.center,yaw)
 assert.equal(JSON.stringify(p),original);assert.equal(JSON.stringify(course),before)
})

test('local camera clips behind-eye lines and faces rather than clamping them into the field',async()=>{
 const {localCameraPath}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
 const view=p=>({point:[p[0]/Math.max(.18,p[2]),p[1]/Math.max(.18,p[2])],depth:p[2]})
 assert.equal(localCameraPath([[0,0,-2],[1,1,-1]],view),'')
 assert.equal(localCameraPath([[0,0,-2],[1,0,-1],[1,1,-1]],view,true),'')
 const line=localCameraPath([[0,0,-1],[1,0,1]],view)
 assert.ok(line.startsWith('M'));assert.ok(line.includes('L'));assert.ok(!/NaN|Infinity/.test(line))
 const face=localCameraPath([[-1,-1,-1],[1,-1,1],[1,1,1],[-1,1,-1]],view,true)
 assert.ok(face.endsWith(' Z'));assert.ok(!/NaN|Infinity/.test(face))
})
