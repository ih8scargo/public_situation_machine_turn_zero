import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8')
const {dioramaMechanism,floorWall,project}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const reference={min:[-1.2,-1.2,0],max:[1.2,1.2,2.4]}
const sub=(a,b)=>a.map((v,i)=>v-b[i])
test('Human PUSH goes behind monitor; coupled COB PULL travels inward toward YT',()=>{
  let previous=dioramaMechanism(0)
  for(let i=1;i<=100;i++){
    const next=dioramaMechanism(i/100)
    assert.ok(next.human[2]>previous.human[2]);assert.ok(next.cob[0]<previous.cob[0])
    assert.deepEqual(next,dioramaMechanism(i/100));previous=next
  }
  assert.equal(dioramaMechanism(-1).amount,0);assert.equal(dioramaMechanism(2).amount,1)
})
test('one inherited wedge keeps shared seam, dimensions and 90 degrees through curved opening and Regarding',()=>{
  const before=JSON.stringify(reference)
  for(let i=0;i<=100;i++){
    const {floor,wall}=floorWall(reference,i/100)
    assert.deepEqual(floor[3],wall[0]);assert.deepEqual(floor[2],wall[1])
    const depth=sub(floor[0],floor[3]),height=sub(wall[3],wall[0])
    assert.ok(Math.abs(depth.reduce((sum,v,k)=>sum+v*height[k],0))<1e-10)
    assert.ok(Math.abs(Math.hypot(...depth)-2.4)<1e-10)
    for(const bearing of [-150,-35,0,70,160])for(const p of [...floor,...wall])assert.ok(project(p,bearing).every(Number.isFinite))
  }
  assert.equal(JSON.stringify(reference),before)
  assert.deepEqual(floorWall(reference,0),floorWall(reference,0))
  assert.notDeepEqual(floorWall(reference,.5),floorWall(reference,1))
})
