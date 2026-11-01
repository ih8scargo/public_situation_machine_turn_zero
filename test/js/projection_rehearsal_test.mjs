import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8')
const {tunnelPose,skateStep,projectRegarding,ringPoints,graspPoints}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const course={samples:Array.from({length:97},(_,i)=>{const a=i*Math.PI/96;return {point:[1-Math.cos(a),0,2+Math.sin(a)],tangent:[Math.sin(a),0,Math.cos(a)]}})}
const stick={length:2}
test('forward/reverse and pause return along exactly the same sampled course without changing it',()=>{
 const before=JSON.stringify(course)
 const poses=Array.from({length:21},(_,i)=>tunnelPose(course,i/20,stick))
 for(let i=20;i>=0;i--)assert.deepEqual(tunnelPose(course,i/20,stick),poses[i])
 assert.equal(JSON.stringify(course),before)
 assert.equal(skateStep(.5,0,.05),.5)
 assert.ok(skateStep(.5,1,.05)>.5);assert.ok(skateStep(.5,-1,.05)<.5)
 assert.equal(skateStep(1,1,.05),1);assert.equal(skateStep(0,-1,.05),0)
})
test('pointing changes the tool presentation toward a selected target while retaining pose location and course',()=>{
 const rest=tunnelPose(course,.5,stick),pointed=tunnelPose(course,.5,stick,[0,1,0])
 assert.deepEqual(rest.center,pointed.center)
 assert.notDeepEqual(rest.direction,pointed.direction)
 assert.ok(Math.abs(Math.hypot(...pointed.tip.map((v,i)=>v-pointed.origin[i]))-2)<1e-10)
 for(const angle of [0,45,90,180])for(const elevation of [-28,0,28])assert.ok(projectRegarding(pointed.center,angle,elevation).every(Number.isFinite))
})
test('THROUGH COB uses the actual located participant and its pointing direction, not a free-flying camera',()=>{
 const pose=tunnelPose(course,.4,stick),target=pose.center.map((v,i)=>v+pose.direction[i]*2)
 const [x,y]=projectRegarding(target,0,0,[0,-1.2,1.2],{origin:pose.center,direction:pose.direction})
 assert.ok(Math.abs(x-400)<1e-8&&Math.abs(y-260)<1e-8)
})

test('a vertical target at the paused bend keeps tube rings and four-point grasp finite',()=>{
 const pose=tunnelPose(course,.5,stick,course.samples[48].point)
 assert.ok(pose.direction[1]>.99)
 for(const point of [...ringPoints(pose.center,[.22,.22,0],'xy',pose.direction),...graspPoints(pose.tip,pose.direction,true)])assert.ok(point.every(Number.isFinite))
 assert.equal(graspPoints(pose.tip,pose.direction,true).length,4)
})
