import {primitives} from './projection.js'
// Independent instrument pose. No mutation of the architecture or constitutional cameras.
export const add=(a,b)=>a.map((v,i)=>v+b[i])
const sub=(a,b)=>a.map((v,i)=>v-b[i]),mul=(a,n)=>a.map(v=>v*n)
const dot=(a,b)=>a.reduce((s,v,i)=>s+v*b[i],0),cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
const unit=a=>{const n=Math.hypot(...a);return n>1e-10?mul(a,1/n):[0,0,1]}
const rad=x=>x*Math.PI/180
export const OPTICS={field_gain:1.5,near:.03,letter_height:.5,letter_depth:.08}
export const MONITOR={center:[15,3,-2],normal:[0,0,1],width:2.4,height:1.8}
export function locality(model,registry,id) {
 const [kind,key]=id.split(':')
 if(kind==='letter') {const s=model.steeling.stations.find(s=>s.index===Number(key));if(s)return {id,label:`${s.letter}${s.index}`,point:s.point,radius:.32,normal:[0,0,-1],frame:{origin:s.point,basis:[[1,0,0],[0,1,0],[0,0,1]]},note:'Provisional display frame inherited from U13; original station position',source:s}}
 if(kind==='region') {const e=model.entities[key];if(e)return {id,label:e.name,point:add(e.frame.origin,[3,3,3]),radius:5.2,normal:[0,0,-1],frame:e.frame,source:e}}
 if(kind==='plane') {const item=registry.items.find(i=>i.id===key);if(item){const point=item.points.reduce((s,p)=>add(s,mul(p,1/item.points.length)),[0,0,0]);let normal=item.frame.bearing;if(key.includes('-surface-')){const e=model.entities[key.split('-surface-')[0]];if(e&&dot(normal,sub(point,add(e.frame.origin,[3,3,3])))<0)normal=mul(normal,-1)}return {id,label:item.label,point,radius:.08,normal:unit(normal),frame:item.frame,source:item}}}
 return locality(model,registry,'letter:13')
}
export function pose(model,registry,p) {
 const target=locality(model,registry,p.target),o=rad(p.orbit),e=rad(p.elevation)
 const outward=[Math.sin(o)*Math.cos(e),Math.sin(e),-Math.cos(o)*Math.cos(e)]
 // Region approach stops outside its bounding sphere; ordinary surface approach stops 0.08 away.
 const distance=p.through?p.distance:Math.max(p.distance,target.radius+.08)
 let eye=add(target.point,mul(outward,distance))
 if(p.target.startsWith('plane:')&&!p.through&&['orbit','surface_along'].includes(p.mode)){const correction=Math.max(0,.08-dot(sub(eye,target.point),target.normal));eye=add(eye,mul(target.normal,correction))}
 let forward=unit(sub(target.point,eye))
 if(p.mode.startsWith('along')) {
  eye=add(p.from,[0,0,-distance])
  const index=model.steeling.stations.findIndex(s=>s.index===p.stand),sign=p.mode==='along_forward'?1:-1
  const adjacent=model.steeling.stations[Math.max(0,Math.min(24,index+sign))].point
  const tangent=unit(sub(adjacent,p.from));forward=unit(sub(add(p.from,mul(tangent,4)),eye))
 }
 if(p.mode==='monitor') {
  eye=[15+(p.monitor_xy[0]-15)*p.monitor_offset/p.monitor_start,3+(p.monitor_xy[1]-3)*p.monitor_offset/p.monitor_start,-2+p.monitor_side*p.monitor_offset]
  forward=unit(sub(MONITOR.center,eye))
 }
 if(p.mode==='surface_along'){const n=target.normal;forward=unit(cross(n,Math.abs(n[1])>.9?[0,0,1]:[0,1,0]))}
 const t=rad(p.turn);forward=unit([forward[0]*Math.cos(t)+forward[2]*Math.sin(t),forward[1],-forward[0]*Math.sin(t)+forward[2]*Math.cos(t)])
 const right=unit(cross(forward,Math.abs(forward[1])>.999?[0,0,1]:[0,1,0])),up=unit(cross(right,forward))
 return {eye,forward,right,up,target,distance,monitor_signed:eye[2]+2,monitor_distance:Math.abs(eye[2]+2)}
}
export function cameraPoint(point,f){const v=sub(point,f.eye);return [dot(v,f.right),dot(v,f.up),dot(v,f.forward)]}
// Half-space clipping happens before either perspective division.
export function clip3(points,closed,coordinate,minimum=.03) {
 if(!points.length)return []
 const clipSegment=(a,b)=>{const da=coordinate(a)-minimum,db=coordinate(b)-minimum;if(da<0&&db<0)return [];if(da>=0&&db>=0)return [a,b];const q=add(a,mul(sub(b,a),da/(da-db)));return da>=0?[a,q]:[q,b]}
 if(!closed)return clipSegment(points[0],points[1])
 const result=[];for(let i=0;i<points.length;i++){const a=points[i],b=points[(i+1)%points.length],part=clipSegment(a,b);if(part.length){if(coordinate(a)>=minimum)result.push(a);if((coordinate(a)<minimum)!==(coordinate(b)<minimum))result.push(part[coordinate(a)>=minimum?1:0])}}
 return result
}
const font={T:['11111','00100','00100','00100','00100','00100','00100'],H:['11011','11011','11011','11111','11011','11011','11011'],E:['11111','11000','11000','11110','11000','11000','11111'],P:['11110','11011','11011','11110','11000','11000','11000'],U:['11011','11011','11011','11011','11011','11011','01110'],B:['11110','11011','11011','11110','11011','11011','11110'],L:['11000','11000','11000','11000','11000','11000','11111'],I:['11111','00100','00100','00100','00100','00100','11111'],C:['01111','11000','11000','11000','11000','11000','01111'],S:['01111','11000','11000','01110','00011','00011','11110'],A:['01110','11011','11011','11111','11011','11011','11011'],O:['01110','11011','11011','11011','11011','11011','01110'],N:['11011','11111','11111','11111','11011','11011','11011'],M:['10001','11011','11111','11111','11011','11011','11011']}
// 0.5-high extruded display lettering, fixed at the actual station. Not new CUBICAL reservations.
export function letterBodies(model) {
 const result=[],cell=.5/7,d=.08
 for(const s of model.steeling.stations){const bitmap=font[s.letter],occupied=(x,y)=>bitmap[y]?.[x]==='1'
 for(let y=0;y<7;y++)for(let x=0;x<5;x++)if(occupied(x,y)){
 const a=(x-2.5)*cell,b=(2.5-y)*cell
 const v=[[a,b,-d/2],[a+cell,b,-d/2],[a+cell,b+cell,-d/2],[a,b+cell,-d/2],[a,b,d/2],[a+cell,b,d/2],[a+cell,b+cell,d/2],[a,b+cell,d/2]].map(p=>add(s.point,p))
 const boundary=[];if(!occupied(x,y+1))boundary.push([v[0],v[1]]);if(!occupied(x+1,y))boundary.push([v[1],v[2]]);if(!occupied(x,y-1))boundary.push([v[2],v[3]]);if(!occupied(x-1,y))boundary.push([v[3],v[0]])
 result.push({station:s.index,points:[v[0],v[1],v[2],v[3]],boundary,front:true})
 result.push({station:s.index,points:[v[4],v[7],v[6],v[5]],boundary:[],front:false})
 for(const [dx,dy,indexes] of [[0,1,[0,4,5,1]],[1,0,[1,5,6,2]],[0,-1,[2,6,7,3]],[-1,0,[3,7,4,0]]])if(!occupied(x+dx,y+dy))result.push({station:s.index,points:indexes.map(i=>v[i]),boundary:[],front:false})
 }}return result
}
export function sourceScene(model,registry) {
 const lines=[]
 for(const item of primitives(model,'both'))for(let i=1;i<item.points.length;i++)lines.push({id:item.id,points:[item.points[i-1],item.points[i]],color:({edge:'#7795a0','trial-cage':'#245785',bunting:'#a34b22','receiving-region':'#08776e'})[item.kind]||'#a7b7be',target:item.station?`letter:${item.station}`:item.kind==='surface'?`plane:${item.id}`:item.entity?`region:${item.entity}`:null})
 for(const item of registry.items.filter(i=>!i.id.includes('-surface-'))){for(let i=1;i<item.points.length;i++)lines.push({id:item.id,points:[item.points[i-1],item.points[i]],color:item.material_status==='STANDING FOR STAGING'?'#08776e':'#ba5423',target:`plane:${item.id}`});if(item.closed)lines.push({id:item.id,points:[item.points.at(-1),item.points[0]],color:'#08776e',target:`plane:${item.id}`})}
 return {lines,faces:letterBodies(model)}
}
export function presentation(model,registry,p,monitor=false) {
 const f=pose(model,registry,monitor&&p.mode==='monitor'?{...p,mode:p.feed_mode}:p),scene=sourceScene(model,registry),beta=rad(registry.parameters.opening),sn=Math.sin(beta),cs=Math.cos(beta),origin=registry.projection_thing.origin
 const coordinate=world=>cameraPoint(world,f)
 const relay=c=>{const u=c[0]/c[2]*OPTICS.field_gain,v=c[1]/c[2]*OPTICS.field_gain;return [u,sn+v*cs,-cs+v*sn]}
 const map=c=>{
 if(!monitor)return [550+600*c[0]/c[2],350-600*c[1]/c[2]]
 const d=relay(c),t=(-2-origin[2])/d[2]
 const hit=add(origin,mul(d,t));return [(hit[0]-13.8)/2.4*960,(3.9-hit[1])/1.8*720]
 }
 const transform=(points,closed)=>{
  let clipped=clip3(points.map(coordinate),closed,p=>p[2],OPTICS.near);if(!clipped.length)return []
  if(monitor)clipped=clip3(clipped,closed,c=>cs*c[2]-sn*c[1]*OPTICS.field_gain,.001)
  let screen=clipped.map(map)
  if(monitor)for(const coord of [q=>q[0],q=>960-q[0],q=>q[1],q=>720-q[1]]){screen=clip3(screen,closed,coord,0);if(!screen.length)break}
  return screen
 }
 if(!monitor&&p.mode==='monitor') {
  const display=presentation(model,registry,p,true)
  const world=points=>points.map(([x,y])=>[13.8+x/960*2.4,3.9-y/720*1.8,-2])
  return {frame:f,faces:display.faces.map(face=>({...face,points:world(face.screen),boundary:face.boundary.map(edge=>world(display.transform(edge,false))).filter(edge=>edge.length===2),screen:transform(world(face.screen),true)})).filter(face=>face.screen.length>=3),lines:display.lines.map(line=>({...line,screen:transform(world(line.screen),false)})).filter(line=>line.screen.length>=2),transform}
 }
 const faces=scene.faces.map(face=>({...face,depth:face.points.reduce((sum,v)=>sum+coordinate(v)[2]/face.points.length,0),screen:transform(face.points,true)})).filter(f=>f.screen.length>=3).sort((a,b)=>b.depth-a.depth)
 return {frame:f,faces,lines:scene.lines.map(line=>({...line,screen:transform(line.points,false)})).filter(l=>l.screen.length>=2),transform}
}
