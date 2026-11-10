import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const read=p=>readFile(new URL(p,import.meta.url),'utf8'),uri=s=>`data:text/javascript;base64,${Buffer.from(s).toString('base64')}`
const apparatus=uri(await read('../../assets/js/workshop/apparatus.js'))
const projection=uri((await read('../../assets/js/workshop/projection.js')).replace('./apparatus.js',apparatus))
const instrument=uri((await read('../../assets/js/workshop/inspection.js')).replace('./projection.js',projection))
const {pose,letterBodies,presentation,clip3,MONITOR}=await import(instrument)
const {model,state,registry,instrument:expected}=JSON.parse(await read('../fixtures/workshop_inspection_contract.json'))
const params=state.parameters
const approx=(a,b)=>a.forEach((v,i)=>assert.ok(Math.abs(v-b[i])<1e-9,`${v} != ${b[i]}`))
test('Elixir and JavaScript instrument positions and monitor-normal measurements agree',()=>{
 const f=pose(model,registry,params);approx(f.eye,expected.eye);assert.equal(f.monitor_distance,expected.monitor_distance)
 for(const orbit of [-180,-90,0,90,180])for(const elevation of [-89,0,89]) {
  const f=pose(model,registry,{...params,orbit,elevation});assert.ok([...f.eye,...f.forward,...f.right,...f.up].every(Number.isFinite))
 }
})
test('five primary FROMs retain actual curved coordinates while projected course changes',()=>{
 const before=JSON.stringify(model),signatures=[]
 for(const stand of [3,8,13,18,23]) {
  const p={...params,stand,from:model.steeling.stations[stand-1].point,target:`letter:${stand}`,mode:'along_forward'}
  const image=presentation(model,registry,p)
  assert.ok(image.faces.length>0)
  signatures.push(JSON.stringify(image.lines.filter(l=>l.id.startsWith('steeling-')).map(l=>l.screen)))
 }
 assert.equal(new Set(signatures).size,5);assert.equal(JSON.stringify(model),before)
})
test('extruded black bodies and FROM-face white edges belong to fixed station geometry',()=>{
 const bodies=letterBodies(model),before=JSON.stringify(bodies)
 assert.equal(new Set(bodies.map(b=>b.station)).size,25)
 for(const b of bodies)for(const p of b.points){const center=model.steeling.stations[b.station-1].point;assert.ok(Math.abs(p[0]-center[0])<=.19);assert.ok(Math.abs(p[1]-center[1])<=.251);assert.ok(Math.abs(p[2]-center[2])<=.041)}
 const visible=[]
 for(const orbit of [-90,0,90,175]) {const image=presentation(model,registry,{...params,orbit,distance:.65});visible.push(JSON.stringify(image.faces.find(b=>b.station===13)?.screen));assert.ok(image.faces.flatMap(f=>f.screen.flat()).every(Number.isFinite))}
 assert.ok(new Set(visible).size>1);assert.equal(JSON.stringify(letterBodies(model)),before)
 assert.ok(bodies.some(b=>b.boundary.length));assert.ok(bodies.some(b=>!b.front))
})
test('monitor is a separate registered projector intersection, responds to bearing and calibration, keeps 4:3 reference',()=>{
 const a=presentation(model,registry,params,true)
 const b=presentation(model,registry,{...params,turn:12},true)
 const other=structuredClone(registry);other.parameters.opening=15
 const c=presentation(model,other,params,true)
 const signature=image=>JSON.stringify(image.faces.slice(-30).map(f=>f.screen))
 assert.notEqual(signature(a),signature(b));assert.notEqual(signature(a),signature(c))
 assert.notEqual(signature(a),signature(presentation(model,registry,params,false)))
 assert.equal(MONITOR.width/MONITOR.height,4/3);assert.deepEqual(MONITOR.center,[15,3,-2])
 assert.ok(a.faces.flatMap(f=>f.screen.flat()).every(Number.isFinite))
 for(const face of a.faces)for(const [x,y]of face.screen){assert.ok(x>=-1e-8&&x<=960+1e-8);assert.ok(y>=-1e-8&&y<=720+1e-8)}
})
test('near clipping preserves crossing fragments and rejects behind-eye geometry before division',()=>{
 assert.deepEqual(clip3([[0,0,-1],[1,0,-2]],false,p=>p[2]),[])
 const segment=clip3([[0,0,-1],[1,0,1]],false,p=>p[2]);approx(segment[0],[.515,0,.03])
 const polygon=clip3([[-1,-1,-1],[1,-1,1],[1,1,1],[-1,1,-1]],true,p=>p[2]);assert.ok(polygon.length>=3);assert.ok(polygon.every(p=>p[2]>=.029999))
})
test('normal approach and explicit THROUGH use actual eye motion and retain FROM',()=>{
 const p={...params,mode:'monitor',monitor_xy:[15,3],monitor_side:-1,monitor_offset:2}
 const a=pose(model,registry,p),b=pose(model,registry,{...p,monitor_offset:.08}),c=pose(model,registry,{...p,through:true,monitor_offset:-.2})
 assert.ok(a.monitor_distance>b.monitor_distance);assert.ok(a.monitor_signed*c.monitor_signed<0);assert.notDeepEqual(a.eye,b.eye);assert.deepEqual(p.from,params.from)
 const near={...p,monitor_offset:.08};assert.deepEqual(presentation(model,registry,p,true).faces.map(f=>f.screen),presentation(model,registry,near,true).faces.map(f=>f.screen))
})
