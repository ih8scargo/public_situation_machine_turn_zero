import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8')
const {project,ruggingGeometry,galleryWall}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const config={pivot:[0,-1.2,1.2],radius:1.15,floor_y:-1.2,ceiling_y:1.2,near:0,far:2.4,ground_start:[0,-1.2,-3.2],field_available:true,seating_available:true}
test('one Human Landinging remains the pivot across Regarding without changing world points',()=>{
  const before=JSON.stringify(config),fixed=project(config.pivot,0,config.pivot)
  for(const angle of [-160,-90,0,35,90,160])assert.deepEqual(project(config.pivot,angle,config.pivot),fixed)
  assert.equal(JSON.stringify(config),before)
})
test('determinate Ground line exposes misalignment and joins the one seated Field Floor exactly',()=>{
  const angled=ruggingGeometry(config,{roll:1,yaw:12,seat:1})
  assert.ok(angled.tip[0]>0);assert.equal(angled.seat,0);assert.equal(angled.available,false)
  const seated=ruggingGeometry(config,{roll:1,yaw:0,seat:1})
  assert.equal(seated.angle,90);assert.deepEqual(seated.tip,[0,-1.2,0])
  for(const p of seated.floor)assert.ok(Math.abs(p[1]-config.floor_y)<1e-10)
  assert.deepEqual(seated.ground[2],seated.floor[1]);assert.deepEqual(seated.ground[3],seated.floor[0])
  assert.equal(seated.floor[2][2],config.far)
  assert.equal(seated.floor[0][0],-config.radius)
})
test('growth and 90-degree hinge share one mesh and require the inherited aperture',()=>{
  for(const seat of [0,.25,.5,.75,1]){
    const g=ruggingGeometry(config,{roll:1,yaw:0,seat})
    assert.equal(g.angle,seat*90)
    assert.ok(g.floor[0][1]>=config.floor_y-1e-9)
    assert.ok(g.floor[1][0]<=config.radius)
  }
  assert.equal(ruggingGeometry({...config,seating_available:false},{roll:1,yaw:0,seat:1}).seat,0)
  assert.equal(ruggingGeometry(config,{roll:.5,yaw:0,seat:1}).seat,0)
})
test('COB reveals a complementary Gallery Wall above the same Floor, never a second Floor',()=>{
  const before=JSON.stringify(config)
  const half=galleryWall(config,.5),full=galleryWall(config,1)
  assert.notDeepEqual(half.at(-1),full.at(-1))
  for(const pair of full){
    assert.equal(pair[0][1],config.floor_y);assert.equal(pair[1][1],config.ceiling_y)
    assert.ok(Math.abs(Math.hypot(pair[0][0],pair[0][2]-config.pivot[2])-config.radius)<1e-10)
  }
  assert.equal(JSON.stringify(config),before)
})
