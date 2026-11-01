import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8')
const {project,drawerRail,reservedEnvelope,ringPoints}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
test('the same complete envelope reserves all bearings and every lawful return course',()=>{
  const box=reservedEnvelope(),[x,y,w,h]=box
  const extent={rail:{height:3.25,depth:5.2,inward:1.5,x_slots:[3.8,4.1,4.4]}}
  for(let angle=-180;angle<=180;angle+=3){
    const points=['xy','xz','yz'].flatMap(plane=>ringPoints([0,0,1.6],[6.2,5.2,6.4],plane))
    for(const slot of [0,1,2])for(let i=0;i<=100;i++)points.push(drawerRail(extent,slot,i/100))
    for(const point of points){
      const [px,py]=project(point,angle,[0,-1.2,1.2])
      assert.ok(px>x&&px<x+w&&py>y&&py<y+h)
    }
  }
  assert.deepEqual(reservedEnvelope(),box)
})
