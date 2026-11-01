const radians = n => n * Math.PI / 180
const add = (a,b) => a.map((v,i)=>v+b[i])
const scale = (a,s) => a.map(v=>v*s)
const cross = (a,b) => [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
const unit = a => Math.hypot(...a)>1e-12?scale(a,1/Math.hypot(...a)):[0,0,1]
const rightOf = direction => unit(cross(Math.abs(direction[1])>.95?[0,0,1]:[0,1,0],direction))

export function project(point, pivot=0, center=[0,0,0]) {
  const [px,y,pz]=point, a=radians(pivot),x=px-center[0],z=pz-center[2]
  const xx=center[0]+x*Math.cos(a)+z*Math.sin(a), zz=center[2]-x*Math.sin(a)+z*Math.cos(a)
  const perspective=12/(12+zz)
  return [400+xx*55*perspective,260-y*55*perspective]
}
export function furnishedStick(yaw,pitch,extension,length=2.6) {
  const y=radians(yaw),p=radians(pitch)
  const direction=[Math.sin(y)*Math.cos(p),Math.sin(p),Math.cos(y)*Math.cos(p)]
  return {origin:[0,0,0],direction,tip:scale(direction,length*extension),extension,yaw,pitch,length}
}
export function ringPoints(center,radii,plane='xy',direction=[0,0,1]) {
  const right=rightOf(direction), up=unit(cross(direction,right))
  return Array.from({length:65},(_,i)=>{
    const a=i*Math.PI/32, local=plane==='xy'?[radii[0]*Math.cos(a),radii[1]*Math.sin(a),0]:plane==='xz'?[radii[0]*Math.cos(a),0,radii[2]*Math.sin(a)]:[0,radii[1]*Math.cos(a),radii[2]*Math.sin(a)]
    return add(center,add(scale(right,local[0]),add(scale(up,local[1]),scale(direction,local[2]))))
  })
}
export function wireframeEdges(min,max) {
  const vertices=Array.from({length:8},(_,i)=>[i&1?max[0]:min[0],i&2?max[1]:min[1],i&4?max[2]:min[2]])
  return vertices.flatMap((p,i)=>[1,2,4].filter(bit=>(i&bit)===0).map(bit=>[p,vertices[i|bit]]))
}
export function responseOffset(dx,dy,limit=.65) {
  const size=Math.hypot(dx,dy), amount=size>limit?limit/size:1
  return [dx*amount,dy*amount,0]
}

export function settleOffset(current, target, dt) {
  const response = 1 - Math.exp(-10 * Math.min(.05, dt))
  return current.map((v,i)=>v+(target[i]-v)*response)
}

export function suspensionStep(state, velocity, acceleration, dt, length=.9) {
  const next={...state}, steps=Math.max(1,Math.ceil(Math.min(.05,dt)*120)), h=Math.min(.05,dt)/steps
  const forceX=Math.max(-5,Math.min(5,-acceleration*.16-velocity*.3))
  const forceZ=Math.max(-3,Math.min(3,velocity*velocity*.04))
  for(let i=0;i<steps;i++){
    next.vx+=(forceX-9.81/length*next.x-4*next.vx)*h
    next.vz+=(forceZ-9.81/length*next.z-4*next.vz)*h
    next.x=Math.max(-.28,Math.min(.28,next.x+next.vx*h))
    next.z=Math.max(-.2,Math.min(.2,next.z+next.vz*h))
  }
  return next
}
export function suspendedTab(purchase,state,displacement=[0,0,0]){
  const x=state.x,z=state.z,l=purchase.length
  return add(purchase.anchor,add([x,-Math.sqrt(Math.max(.01,l*l-x*x-z*z)),z],displacement))
}
// Historical four-point articulation: open purchase contracts around the held tool.
export function graspPoints(center,direction,held=false){
  const right=rightOf(direction),up=unit(cross(direction,right)),amount=typeof held==='number'?held:held?1:0,spread=.32*(1-amount)+.134*amount
  return [[-1,-1],[1,-1],[1,1],[-1,1]].map(([x,y])=>add(center,add(scale(right,x*spread),scale(up,y*spread*.65))))
}
export function drawerRail(extent,slot,progress) {
  const p=Math.max(0,Math.min(1,progress)),a=p*Math.PI,r=extent.rail
  return [r.x_slots[slot]-r.inward*(1-Math.cos(a))/2,-r.height*Math.cos(a),r.depth*Math.sin(a)]
}
export function drawerMechanism(extent,chSlot,cobSlot,progress) {
  const p=Math.max(0,Math.min(1,progress))
  return {progress:p,angle:180*p,ch:[-2.8,[-1.1,0,1.1][chSlot],extent.rail.depth*p],
    cob:drawerRail(extent,cobSlot,p),displacement:[0,0,extent.travel*p]}
}
export function ruggingGeometry(config,state) {
  const roll=Math.max(0,Math.min(1,state.roll)),yaw=Math.max(-24,Math.min(24,state.yaw))
  const aligned=Math.abs(yaw)<.001,available=config.field_available&&config.seating_available&&roll===1&&aligned
  const seat=available?Math.max(0,Math.min(1,state.seat)):0,a=seat*Math.PI/2
  const start=config.ground_start,distance=(config.near-start[2])*roll
  const tip=[start[0]+distance*Math.tan(radians(yaw)),config.floor_y,start[2]+distance]
  const h=.16+(config.radius-.16)*seat,length=.32+(config.far-config.near-.32)*seat
  const hinge=[0,-.16+(config.floor_y+.16)*seat,config.near+(state.drawerOffset||0)*(1-seat)]
  const floor=[[-h,0],[h,0],[h,length],[-h,length]].map(([x,d])=>[x,hinge[1]+d*Math.cos(a),hinge[2]+d*Math.sin(a)])
  const ground=[[-.45,0],[.45,0],[h,1],[-h,1]].map(([x,t])=>[start[0]+(tip[0]-start[0])*t+x,config.floor_y,start[2]+distance*t])
  return {roll,yaw,seat,aligned,available,tip,ground,floor,hinge,angle:seat*90}
}
export function galleryWall(config,progress) {
  const count=Math.max(0,Math.min(1,progress)),span=Math.PI*count
  return Array.from({length:25},(_,i)=>{
    const a=span*i/24
    const p=[config.pivot[0]+config.radius*Math.cos(a),config.floor_y,config.pivot[2]+config.radius*Math.sin(a)]
    return [p,[p[0],config.ceiling_y,p[2]]]
  })
}
// One reserved envelope for all accomplished stages and bearings, never event-dependent auto-fit.
export function reservedEnvelope() {
  const points=['xy','xz','yz'].flatMap(plane=>ringPoints([0,0,1.6],[6.2,5.2,6.4],plane))
  points.push(...wireframeEdges([-3.2,-3.9,-3.2],[3.2,4.2,5.2]).flat())
  let minX=Infinity,maxX=-Infinity,minY=Infinity,maxY=-Infinity
  for(let angle=-180;angle<=180;angle+=5)for(const point of points){
    const [x,y]=project(point,angle,[0,-1.2,1.2])
    minX=Math.min(minX,x);maxX=Math.max(maxX,x);minY=Math.min(minY,y);maxY=Math.max(maxY,y)
  }
  const size=Math.max(maxX-minX,maxY-minY)+220,cx=(minX+maxX)/2,cy=(minY+maxY)/2
  return [cx-size/2,cy-size/2,size,size]
}
const reserved=reservedEnvelope()
export function projectRegarding(point,bearing=0,elevation=0,center=[0,-1.2,1.2],through=null) {
  if(through){
    const forward=unit(through.direction),right=rightOf(forward),up=unit(cross(forward,right))
    const relative=point.map((v,i)=>v-through.origin[i]),dot=a=>a.reduce((sum,v,i)=>sum+v*relative[i],0)
    const depth=dot(forward),perspective=12/Math.max(2,12+depth)
    return [400+dot(right)*55*perspective,260-dot(up)*55*perspective]
  }
  const a=radians(bearing),b=radians(elevation),x=point[0]-center[0],z=point[2]-center[2],y=point[1]-center[1]
  const xx=x*Math.cos(a)+z*Math.sin(a),zz=-x*Math.sin(a)+z*Math.cos(a)
  const yy=y*Math.cos(b)-zz*Math.sin(b),depth=y*Math.sin(b)+zz*Math.cos(b)+center[2]
  return [400+(xx+center[0])*55*12/(12+depth),260-(yy+center[1])*55*12/(12+depth)]
}
export function tunnelPose(course,progress,stick,target=null) {
  const p=Math.max(0,Math.min(1,progress)),scaled=p*(course.samples.length-1),i=Math.min(course.samples.length-2,Math.floor(scaled)),f=scaled-i
  const a=course.samples[i],b=course.samples[i+1],mix=(u,v)=>u.map((n,k)=>n+(v[k]-n)*f)
  const center=mix(a.point,b.point),tip=add(center,[0,-.32,0])
  const direction=target?unit(target.map((v,k)=>v-tip[k])):unit(mix(a.tangent,b.tangent))
  return {progress:p,center,tip,direction,origin:add(tip,scale(direction,-stick.length))}
}
export function skateStep(progress,direction,dt) {
  return Math.max(0,Math.min(1,progress+direction*Math.max(0,Math.min(dt,.05))*.16))
}
export function earlyEnvelope(){
  const points=['xy','xz','yz'].flatMap(plane=>ringPoints([0,0,1.2],[4.5,3.5,4.8],plane))
  let minX=Infinity,maxX=-Infinity,minY=Infinity,maxY=-Infinity
  for(const elevation of [-28,0,28])for(let angle=-180;angle<=180;angle+=6)for(const point of points){
    const [x,y]=projectRegarding(point,angle,elevation)
    minX=Math.min(minX,x);maxX=Math.max(maxX,x);minY=Math.min(minY,y);maxY=Math.max(maxY,y)
  }
  const size=Math.max(maxX-minX,maxY-minY)+100
  return [(minX+maxX-size)/2,(minY+maxY-size)/2,size,size]
}
const earlyReserved=earlyEnvelope()
const clamp=(n,a,b)=>Math.max(a,Math.min(b,n))
const zeroSwing=()=>({x:0,z:0,vx:0,vz:0})
// Experimental cutaway: world-space faces, one fixed orbit, no event-dependent fitting.
export function applianceView(point,bearing=0,elevation=0,through=null){
  const center=through?.origin||[0,0,5.5],r=point.map((v,i)=>v-center[i])
  let x,y,depth
  if(through){const f=unit(through.direction),right=through.up?unit(cross(through.up,f)):rightOf(f),up=unit(cross(f,right));x=dot(r,right);y=dot(r,up);depth=dot(r,f)}
  else {const a=radians(bearing),b=radians(elevation);x=r[0]*Math.cos(a)+r[2]*Math.sin(a);const z=-r[0]*Math.sin(a)+r[2]*Math.cos(a);y=r[1]*Math.cos(b)-z*Math.sin(b);depth=r[1]*Math.sin(b)+z*Math.cos(b)}
  const focal=through?.local?1.1:through?8:24,k=through?.local?560/Math.max(.18,depth):50*focal/Math.max(2,focal+depth)
  return {point:[550+x*k,550-y*k],depth}
}
const dot=(a,b)=>a.reduce((n,v,i)=>n+v*b[i],0)
export function cutawayFaces(half=3.2,floor=-1.2,config=null){
  const outerHalf=config?.appliance_extent.max[0]??4.8,front=config?.crossing.z??-2,width=config?.approach.mouth_half??3.6,near=config?.approach.depth?config.crossing.z+config.approach.depth:0,ceiling=config?.diorama_extent.max[1]??3.6,rear=config?.diorama_extent.max[2]??13.2,lipFloor=config?.approach.floor_y??-1.2
  const rect=(x,y,z)=>[[-x,-y,z],[x,-y,z],[x,y,z],[-x,y,z]],outer=rect(outerHalf,outerHalf,front),opening=rect(half,half,front),mouth=[[-width,lipFloor,near],[width,lipFloor,near],[width,ceiling,near],[-width,ceiling,near]]
  const faces=[]
  for(let i=0;i<4;i++){const j=(i+1)%4;faces.push({id:`appliance-face-${i}`,points:[outer[i],outer[j],opening[j],opening[i]],kind:'front'});faces.push({id:['approaching-floor','approaching-right','approaching-ceiling','approaching-left'][i],points:[opening[i],opening[j],mouth[j],mouth[i]],kind:'approach'})}
  faces.push({id:'interior-floor',kind:'floor',points:[mouth[0],mouth[1],[width,floor,near+1.2],[width,floor,rear],[-width,floor,rear],[-width,floor,near+1.2]]},
    {id:'interior-left',kind:'wall',points:[mouth[0],[-width,floor,near+1.2],[-width,floor,rear],[-width,ceiling,rear],mouth[3]]},
    {id:'interior-right',kind:'wall',points:[mouth[1],[width,floor,near+1.2],[width,floor,rear],[width,ceiling,rear],mouth[2]]},
    {id:'interior-back',kind:'wall',points:[[-width,floor,rear],[width,floor,rear],[width,ceiling,rear],[-width,ceiling,rear]]},
    {id:'interior-ceiling',kind:'wall',points:[mouth[3],mouth[2],[width,ceiling,rear],[-width,ceiling,rear]]})
  return faces
}
export function convexHull(points){
 const sorted=[...points].sort((a,b)=>a[0]-b[0]||a[1]-b[1]),turn=(a,b,c)=>(b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0]),half=list=>{const h=[];for(const p of list){while(h.length>1&&turn(h.at(-2),h.at(-1),p)<=0)h.pop();h.push(p)}return h.slice(0,-1)}
 return [...half(sorted),...half([...sorted].reverse())]
}
export function traversalPose(course,distance,stick,target=null){
 const d=Math.abs(distance-course.length)<1e-10?course.length:clamp(distance,0,course.length),samples=course.samples;let lo=0,hi=samples.length-1
 while(hi-lo>1){const mid=(lo+hi)>>1;if(samples[mid].distance<=d)lo=mid;else hi=mid}
 const a=samples[lo],b=samples[hi],f=(d-a.distance)/Math.max(1e-12,b.distance-a.distance),mix=(u,v)=>f<=0?[...u]:f>=1?[...v]:u.map((n,k)=>n+(v[k]-n)*f)
 const center=mix(a.point,b.point),direction=unit(mix(a.tangent,b.tangent)),up=unit(mix(a.up,b.up)),right=unit(cross(up,direction))
 // Transport the original grasp offset in the course frame; distance zero preserves its source locality.
 const first=samples[0],firstRight=unit(cross(first.up,first.tangent)),offset=stick.tip.map((v,k)=>v-stick.cob_center[k])
 const tip=add(center,add(scale(right,dot(offset,firstRight)),add(scale(up,dot(offset,first.up)),scale(direction,dot(offset,first.tangent)))))
 const pointDirection=target?unit(target.map((v,k)=>v-tip[k])):direction
 return {center,tip,direction,pointDirection,up,right,origin:add(tip,scale(pointDirection,-stick.length)),distance:d,bank:a.bank+(b.bank-a.bank)*f}
}
export function traversalStep(course,distance,direction,dt){
 const candidate=clamp(distance+direction*Math.min(.05,Math.max(0,dt))*2,0,course.length)
 const stations=[0,...course.stations],crossed=stations.filter(s=>direction>0?s>distance+1e-8&&s<=candidate:s<distance-1e-8&&s>=candidate)
 return crossed.length?(direction>0?Math.min(...crossed):Math.max(...crossed)):candidate
}
export function framedRing(center,radii,plane,pose){
 return Array.from({length:65},(_,i)=>{const a=i*Math.PI/32,c=Math.cos(a),s=Math.sin(a),local=plane==='xy'?[radii[0]*c,radii[1]*s,0]:plane==='xz'?[radii[0]*c,0,radii[2]*s]:[0,radii[1]*c,radii[2]*s];return add(center,add(scale(pose.right,local[0]),add(scale(pose.up,local[1]),scale(pose.direction,local[2]))))})
}

// Bounded companion mechanics: all state below is operational, never a new Human FROM.
export const treadmillSettings=Object.freeze({gentle:.45,working:.9,strong:1.5,brake:1.8,coast:.28,maxSpeed:2.4,dwell:.12})
export function treadmillStep(state,course,command,dt,settings=treadmillSettings){
 const h=Math.max(0,Math.min(dt,.1)),v=state.velocity||0,sign=Math.sign(v),drive=state.reverse?-1:1
 let acceleration=0,next=v,distance=state.distance
 if(state.attached){next=v*Math.exp(-4*h);distance+=v*(1-Math.exp(-4*h))/4;if(Math.abs(next)<.035)next=0}
 else {
  if(command==='brake'||command==='rest')acceleration=-sign*(command==='brake'?settings.brake:settings.coast)
  else acceleration=drive*(settings[command]||0)
  next=clamp(v+acceleration*h,-settings.maxSpeed,settings.maxSpeed)
  if((command==='brake'||command==='rest')&&sign&&Math.sign(next)!==sign){const t=Math.abs(v/acceleration);distance+=v*t+.5*acceleration*t*t;next=0}
  else distance+=(v+next)*.5*h
 }
 distance=clamp(distance,0,course.length)
 const crossed=[0,...course.stations].filter(s=>next>=0?s>state.distance+1e-9&&s<=distance:s<state.distance-1e-9&&s>=distance)
 if(crossed.length){distance=next>=0?Math.min(...crossed):Math.max(...crossed);next=0}
 if(distance===0&&next<0||distance===course.length&&next>0)next=0
 return {...state,distance,velocity:next}
}
export function companionPose(course,distance,stick,lateral=0,target=null){
 const p=traversalPose(course,distance,stick,target),lane=clamp(lateral,-1,1)*.18,offset=scale(p.right,lane)
 return {...p,center:add(p.center,offset),tip:add(p.tip,offset),origin:add(p.origin,offset),lateral:lane}
}
export function companionWheels(course,distance,stick,lateral=0){
 return [-1,1].flatMap(axle=>[-1,1].map(side=>{
  const p=companionPose(course,clamp(distance+axle*.22,0,course.length),stick,lateral),contact=add(p.center,add(scale(p.right,side*.22),scale(p.up,-.30)))
  return {id:`cob-wheel-${axle===-1?'rear':'front'}-${side===-1?'left':'right'}`,contact,center:add(contact,scale(p.up,.10)),right:p.right,up:p.up,direction:p.direction,angle:distance/.10,radius:.10}
 }))
}
export function shoulderFrame(pose){
 const up=pose.up,forward=pose.direction
 return {origin:add(pose.center,add(scale(forward,-1.35),scale(up,.65))),direction:unit(add(forward,scale(up,-.14))),up,local:true}
}

// Clip the local view at its actual near plane; behind-eye material cannot stretch across the tunnel.
export function localCameraPath(points,view,closed=false,near=.18){
 const interpolate=(a,b)=>{const da=view(a).depth,db=view(b).depth,t=(near-da)/(db-da);return a.map((v,k)=>v+(b[k]-v)*t)}
 const draw=list=>list.map((p,i)=>`${i?'L':'M'}${view(p).point.map(v=>v.toFixed(3)).join(',')}`).join(' ')
 if(closed){let clipped=[];for(let i=0;i<points.length;i++){const a=points[(i+points.length-1)%points.length],b=points[i],insideA=view(a).depth>=near,insideB=view(b).depth>=near;if(insideA!==insideB)clipped.push(interpolate(a,b));if(insideB)clipped.push(b)}return clipped.length?draw(clipped)+' Z':''}
 const parts=[]
 for(let i=1;i<points.length;i++){let a=points[i-1],b=points[i],insideA=view(a).depth>=near,insideB=view(b).depth>=near;if(!insideA&&!insideB)continue;if(!insideA)a=interpolate(a,b);else if(!insideB)b=interpolate(a,b);parts.push(draw([a,b]))}
 return parts.join(' ')
}

export function retainedInstrumentPoints(stick,pose=null){
 if(!stick.curve?.samples)return pose?[pose.origin,pose.tip]:[stick.origin,stick.tip]
 if(!pose)return stick.curve.samples
 const sourceRight=rightOf(stick.direction),sourceUp=unit(cross(stick.direction,sourceRight)),direction=pose.pointDirection||pose.direction,right=rightOf(direction),up=unit(cross(direction,right))
 return stick.curve.samples.map(p=>{const relative=p.map((v,i)=>v-stick.tip[i]);return add(pose.tip,add(scale(right,dot(relative,sourceRight)),add(scale(up,dot(relative,sourceUp)),scale(direction,dot(relative,stick.direction)))))})
}

export function inauguralElbow(stick){
 const right=rightOf(stick.direction),radius=.55
 return Array.from({length:9},(_,i)=>{const a=i*Math.PI/16;return {point:add(stick.tip,add(scale(right,radius*(1-Math.cos(a))),scale(stick.direction,radius*Math.sin(a)))),tangent:unit(add(scale(right,Math.sin(a)),scale(stick.direction,Math.cos(a))))}})
}

export const ElementaryOpening={
  mounted(){
    this.svg=this.el.querySelector('svg');this.host=this.el.closest('main');this.nodes=new Map()
    this.motion={progress:0,play:0,target:null,through:false,elevation:0,leaf:0};
    this.carpet={roll:0,yaw:12,seat:0};this.zoom=1;this.navDistance=0;this.crossingHalf=3.2;this.signIndex=-1;this.signReverse=false;this.showTraces=false;
    this.offline=false;this.opening=0;this.detent=false;this.preview={ch:1,cob:1};this.mode="flat";this.bearings={flat:0,diorama:35}
    this.regard={scope:'opening-page',bearing:0,axis:'vertical'}
    this.swing=zeroSwing();this.offset=[0,0,0];this.target=[0,0,0];this.velocity=0;this.acceleration=0
    this.draft=furnishedStick(0,0,0);this.reduced=matchMedia('(prefers-reduced-motion: reduce)')
    this.drive={velocity:0,reverse:false,lateral:0,attached:false};this.purchase='rest';this.cobRegarding=false;this.handoffHeld=false;this.settings={...treadmillSettings}
    this.endPurchase=()=>{this.purchase='rest';this.purchasePointer=null;this.purchaseSince=0;if(this.model?.refurbished)this.draw()}
    this.driveLoop=()=>{
      if(this.driveFrame)return
      let last=performance.now(),accumulator=0
      const step=now=>{
        this.driveFrame=null;if(this.gone||this.offline)return
        accumulator+=Math.min(.1,(now-last)/1000);last=now
        const state=this.model.traversal,course=state?.course
        if(course&&state.appointed&&(!this.model.inaugural||this.model.inaugural.across)){
          const command=this.purchase!=='rest'&&now-this.purchaseSince>=this.settings.dwell*1000?this.purchase:'rest'
          while(accumulator>=1/120){const wasMoving=Math.abs(this.drive.velocity)>0;this.drive=treadmillStep({...this.drive,distance:this.navDistance},course,command,1/120,this.settings);this.navDistance=this.drive.distance;if(this.model.inaugural?.across&&!this.model.inaugural.detent&&wasMoving&&Math.abs(this.navDistance-course.base_length)<1e-7&&this.drive.velocity===0){this.purchase='rest';this.purchasePointer=null;this.inauguralOperate('detent',{distance:this.navDistance})}accumulator-=1/120}
          this.motion.progress=this.navDistance/course.length;this.draw()
        }
        if(this.purchase!=='rest'||Math.abs(this.drive.velocity)>.00001)this.driveFrame=requestAnimationFrame(step)
      }
      this.driveFrame=requestAnimationFrame(step)
    }
    this.purchaseDown=e=>{
      const region=e.target.closest('[data-treadmill-purchase]');if(!region||region.disabled||e.button!==0)return
      e.preventDefault();region.focus({preventScroll:true});this.motion.play=0;this.purchase=region.dataset.treadmillPurchase;this.purchasePointer=e.pointerId;this.purchaseSince=performance.now();this.driveLoop();this.draw()
    }
    this.purchaseMove=e=>{if(this.purchasePointer===e.pointerId){const region=document.elementFromPoint(e.clientX,e.clientY)?.closest('[data-treadmill-purchase]');if(!region||region.dataset.treadmillPurchase!==this.purchase)this.endPurchase()}}
    this.purchaseUp=e=>{if(this.purchasePointer===e.pointerId)this.endPurchase()}
    this.purchaseFocusOut=e=>{if(e.target.closest('[data-treadmill-purchase]'))this.endPurchase()}
    this.pointerExit=()=>this.endPurchase()
    this.el.addEventListener('focusout',this.purchaseFocusOut);document.addEventListener('mouseleave',this.pointerExit)
    this.lostFocus=()=>this.endPurchase()
    this.hidden=()=>{if(document.hidden)this.endPurchase()}
    this.purchaseKey=e=>{
      const region=e.target.closest('[data-treadmill-purchase]');if(!region||region.disabled||![' ','Enter'].includes(e.key))return
      e.preventDefault();if(e.type==='keydown'&&!e.repeat){this.motion.play=0;this.purchase=region.dataset.treadmillPurchase;this.purchaseSince=performance.now();this.driveLoop();this.draw()}else if(e.type==='keyup')this.endPurchase()
    }
    this.el.addEventListener('pointerdown',this.purchaseDown);document.addEventListener('pointermove',this.purchaseMove);document.addEventListener('pointerup',this.purchaseUp);document.addEventListener('pointercancel',this.purchaseUp);window.addEventListener('blur',this.lostFocus);document.addEventListener('visibilitychange',this.hidden);this.el.addEventListener('keydown',this.purchaseKey);this.el.addEventListener('keyup',this.purchaseKey)

    this.read=()=>{this.model=JSON.parse(this.el.dataset.model);
      if(this.model.inaugural&&!this.inauguralBearingSet){this.regard.bearing=45;this.bearings.flat=45;this.inauguralBearingSet=true}
      const state=this.model.diorama?.mechanical
      if(state){this.mechanical=state;if(!this.pushing&&!this.saving){this.opening=state.progress;this.detent=state.detent}}
if(this.model.accomplished){this.handoffHeld=true;this.offset=[0,0,0];this.target=[0,0,0]}this.draw()}
    this.pivotCenter=()=>this.model.rugging?.pivot||[0,-1.2,1.2]
    this.carpetChange=(key)=>{
      const before={...this.carpet},g=ruggingGeometry(this.model.rugging,this.carpet)
      if(key==='ArrowLeft'||key==='ArrowRight'){this.carpet.yaw=clamp(this.carpet.yaw+(key==='ArrowLeft'?-2:2),-24,24);this.carpet.seat=0}
      if(key==='ArrowUp'||key==='ArrowDown'){this.carpet.roll=clamp(Math.round((this.carpet.roll+(key==='ArrowUp'?.1:-.1))*10)/10,0,1);this.carpet.seat=0}
      if(key==='End'){this.carpet.roll=1;this.carpet.seat=0}
      if(key==='Home'){this.carpet.roll=0;this.carpet.seat=0}
      if(key==='Escape')this.carpet={roll:0,yaw:12,seat:0}
      if(key==='PageUp'&&g.available)this.carpet.seat=clamp(Math.round((this.carpet.seat+.25)*100)/100,0,1)
      if(key==='PageDown')this.carpet.seat=clamp(this.carpet.seat-.25,0,1)
      if((key==='Enter'||key===' ')&&g.available)this.carpet.seat=this.carpet.seat===1?0:1
      if(JSON.stringify(before)!==JSON.stringify(this.carpet))this.draw()
    }
    this.pose=()=>{
      const body=this.model.projection_body,target=body.targets.find(t=>t.id===this.motion.target)?.target
      if(this.model.refurbished&&this.model.traversal)return companionPose(this.model.traversal.course,this.navDistance,this.model.stick,this.drive.lateral,target)
      return body.tunnel?tunnelPose(body.tunnel,this.motion.progress,this.model.stick,target):null
    }
    this.chooseTarget=id=>{this.inspectedResolution=id||null;if(this.model.accomplished)this.motion.target=id||null;this.el.querySelector('#resolution-target').value=id||'';this.draw()}
    this.skate=direction=>{
      if(!this.model.accomplished||(this.model.refurbished&&!this.model.traversal?.appointed)||(this.model.inaugural&&!this.model.inaugural.across))return
      if(this.model.refurbished){this.drive.velocity=direction*1;this.drive.attached=false;this.purchase='rest';this.driveLoop();return}
      this.motion.play=direction
      if(this.skateFrame)return
      let last=performance.now()
      const step=now=>{
        this.skateFrame=null;if(this.gone||!this.motion.play)return
        if(this.model.refurbished){const c=this.model.traversal.course;this.navDistance=traversalStep(c,this.navDistance,this.motion.play,(now-last)/1000);this.motion.progress=this.navDistance/c.length;if([0,...c.stations].some(s=>Math.abs(s-this.navDistance)<1e-8))this.motion.play=0}
        else this.motion.progress=skateStep(this.motion.progress,this.motion.play,(now-last)/1000);last=now
        if(this.motion.progress===0||this.motion.progress===1)this.motion.play=0
        this.draw()
        if(this.motion.play)this.skateFrame=requestAnimationFrame(step)
      }
      this.skateFrame=requestAnimationFrame(step)
    }
    this.earlyChange=e=>{
      if(e.target.id==='cob-handoff-depth'&&!this.model.accomplished&&this.handoffHeld){this.feed={handoff:true};this.draft=furnishedStick(0,0,Number(e.target.value)/100,2.6);this.draw()}
      if(e.target.id==='cob-lateral-steering'){this.drive.lateral=Number(e.target.value);this.draw()}
      if(e.target.id==='treadmill-strength'){const factor=Number(e.target.value);this.settings={...treadmillSettings,gentle:.45*factor,working:.9*factor,strong:1.5*factor};this.draw()}
if(e.target.id==='resolution-target')this.chooseTarget(e.target.value);if(e.target.id==='crossing-width'){this.crossingHalf=Number(e.target.value);this.draw()}}
    this.el.addEventListener('change',this.earlyChange);this.el.addEventListener('input',this.earlyChange)
    this.inauguralOperate=(action,extra={})=>{if(this.inauguralSaving||!this.model.inaugural||this.offline)return;this.inauguralSaving=true;this.pushEvent('inaugural',{action,...extra,revision:this.model.inaugural.revision},()=>{this.inauguralSaving=false;this.read()})}
    this.navOperate=action=>{if(this.navSaving||!this.model.traversal||this.offline)return;this.navSaving=true;this.pushEvent('traversal-rehearsal',{action,revision:this.model.traversal.revision},()=>{this.navSaving=false;this.read()})}
    this.guide=this.host.querySelector('#ordinary-operation-details')
    this.guideSent=this.guide.open
    this.guideToggle=()=>{
      const open=this.guide.open
      if(open!==this.guideSent){this.guideSent=open;this.pushEvent('ordinary-guide',{open})}
    }
    this.guide.addEventListener('toggle',this.guideToggle)

    this.operate=params=>{
      if(this.offline||this.saving||this.el.dataset.ready!=='true')return
      this.saving=true
      this.pushEvent('diorama-operation',{...params,revision:this.mechanical.revision},reply=>{
        if(this.gone)return
        this.saving=false
        // The patched server model wins on acceptance, rejection and concurrent recovery.
        this.read()
        if(!reply.accepted){this.opening=this.mechanical.progress;this.detent=this.mechanical.detent;this.draw()}
      })
    }
    this.flick=()=>{
      this.bearings[this.mode]=this.regard.bearing
      this.mode=this.mode==='flat'?'diorama':'flat';this.regard.bearing=this.bearings[this.mode];this.draw()
    }
    this.compose=side=>this.operate({action:'compose',side,slot:this.preview[side]})
    this.coupled=()=>this.model.diorama?.extent&&this.mechanical?.ch_slot!==null&&this.mechanical?.cob_slot!==null
    this.setTravel=value=>{if(!this.detent&&!this.saving&&this.coupled()){this.opening=value>=.998?1:value<=.002?0:value;this.draw()}}
    this.turn=(delta,dt=.04)=>{
      const velocity=radians(delta)/Math.max(.016,dt)
      this.acceleration=clamp((velocity-this.velocity)/Math.max(.016,dt),-40,40);this.velocity=clamp(velocity,-10,10)
      this.regard.bearing+=delta
      if(this.reduced.matches){this.swing=zeroSwing();this.velocity=0;this.acceleration=0}
      else this.animate()
      this.draw()
    }
    this.beginPull=event=>{
      if(this.model.wireframe||this.el.dataset.ready!=='true'||this.pull)return
      this.pull={id:event.pointerId,x:event.clientX||0,y:event.clientY||0,dx:0,dy:0,token:null,ended:false}
      const gesture=this.pull
      this.pushEvent('take-purchase',{},reply=>{
        if(this.gone)return
        if(!reply.accepted){this.pull=null;this.draw();return}
        gesture.token=reply.token
        if(gesture.ended)this.finishPull(gesture.cancelled)
      })
    }
    this.finishPull=cancelled=>{
      const g=this.pull;if(!g)return
      g.ended=true;g.cancelled=cancelled
      if(!g.token)return
      const moved=g.dx!==0||g.dy!==0
      if(cancelled||!moved){this.pushEvent('cancel-pull',{token:g.token});this.pull=null;this.draw();return}
      this.pushEvent('pull',{token:g.token},reply=>{
        if(this.gone)return
        if(reply.accepted)this.pushEvent('release-pull',{token:g.token,measurements:{dx:g.dx,dy:g.dy}},()=>{if(!this.gone){this.pull=null;this.draw()}})
      })
    }
    this.finishFeed=()=>{
      const g=this.feed;if(!g)return
      this.feed=null
      if(this.draft.extension<1){this.draft=furnishedStick(0,0,0);this.draw();return}
      const d=this.draft
      this.pushEvent('stage-feed',{yaw:d.yaw,pitch:d.pitch,length:d.length,extension:1},reply=>{
        if(!this.gone&&reply.accepted)this.pushEvent('cob-up-over',{})
      })
    }
    this.down=e=>{
      if(e.button!==undefined&&e.button!==0)return
      if(e.target.closest('#carpet-purchase')){
        e.preventDefault();this.unrolling={id:e.pointerId,x:e.clientX,y:e.clientY,start:{...this.carpet},align:e.shiftKey}
        this.svg.setPointerCapture(e.pointerId);return
      }
      if(e.target.closest('#cob-skate-purchase')&&this.model.accomplished){
        e.preventDefault();this.skating={id:e.pointerId,x:e.clientX,start:this.motion.progress};this.drive.velocity=0;this.motion.play=0;this.svg.setPointerCapture(e.pointerId);return
      }
      const compose=e.target.closest('[data-compose]')
      if(compose){e.preventDefault();this.composing={id:e.pointerId,side:compose.dataset.compose};this.svg.setPointerCapture(e.pointerId);return}
      if(e.target.closest('#human-push-handle')&&this.coupled()&&!this.detent&&!this.saving){
        e.preventDefault();this.pushing={id:e.pointerId,y:e.clientY,start:this.opening}
        e.target.setPointerCapture(e.pointerId);return
      }
      const handle=e.target.closest('[data-turn-handle]')
      if(handle){e.preventDefault();this.turning={id:e.pointerId,x:e.clientX,time:performance.now()};handle.setPointerCapture(e.pointerId);return}
      if(e.target.closest('#pulling-ring,#tab-purchase-hit')&&!this.model.wireframe){e.preventDefault();this.beginPull(e);e.target.closest('#pulling-ring,#tab-purchase-hit').setPointerCapture(e.pointerId);return}
      if(e.target.closest('#feed-purchase')&&!this.model.accomplished){
        if(this.model.refurbished&&!this.handoffHeld)return;
        e.preventDefault();this.feed={id:e.pointerId,x:e.clientX,y:e.clientY};this.svg.setPointerCapture(e.pointerId)
      }
    }
    this.move=e=>{
      if(this.skating?.id===e.pointerId){if(this.model.refurbished&&(!this.model.traversal?.appointed||(this.model.inaugural&&!this.model.inaugural.across)))return;this.motion.progress=clamp(this.skating.start+(e.clientX-this.skating.x)/Math.max(150,this.svg.getBoundingClientRect().width*.5),0,1);if(this.model.refurbished)this.navDistance=this.motion.progress*this.model.traversal.course.length;this.draw();return}
      if(this.unrolling?.id===e.pointerId){
        const g=this.unrolling,travel=Math.max(90,this.svg.getBoundingClientRect().height*.25)
        if(g.align)this.carpet.yaw=clamp(Math.round((g.start.yaw+(e.clientX-g.x)/4)/2)*2,-24,24)
        else this.carpet.roll=clamp(g.start.roll+(g.y-e.clientY)/travel,0,1)
        if(this.carpet.roll>.998)this.carpet.roll=1
        this.carpet.seat=0;this.draw();return
      }
      if(this.composing?.id===e.pointerId){
        const side=this.composing.side,centers=[0,1,2].map(slot=>side==='ch'?[-2.8,[-1.1,0,1.1][slot],0]:drawerRail(this.model.diorama.extent,slot,0))
        const screen=centers.map(p=>project(p,this.regard.bearing,this.pivotCenter()))
        const local=new DOMPoint(e.clientX,e.clientY).matrixTransform(this.svg.getScreenCTM().inverse())
        const px=local.x,py=local.y
        this.preview[side]=screen.map(p=>Math.hypot(p[0]-px,p[1]-py)).reduce((best,d,i,all)=>d<all[best]?i:best,0)
        this.draw();return
      }
      if(this.pushing?.id===e.pointerId){
        const travel=Math.max(80,this.svg.getBoundingClientRect().height*.3)
        this.setTravel(clamp(this.pushing.start+(this.pushing.y-e.clientY)/travel,0,1));return
      }
      if(this.turning?.id===e.pointerId){const now=performance.now();this.turn((e.clientX-this.turning.x)*.65,(now-this.turning.time)/1000);this.turning.x=e.clientX;this.turning.time=now;return}
      if(this.pull?.id===e.pointerId&&!this.pull.ended){this.pull.dx=e.clientX-this.pull.x;this.pull.dy=e.clientY-this.pull.y;this.draw();return}
      if(this.feed?.id===e.pointerId){
        const dx=e.clientX-this.feed.x,dy=e.clientY-this.feed.y,extent=Math.hypot(dx,dy)
        this.draft=furnishedStick(clamp(dx*.35,-60,60),clamp(-dy*.15,-45,45),clamp(extent/100,0,1),clamp(1+extent/160,1,3));this.draw();return
      }
      if(this.model.janusite&&!this.feed){
        const r=this.svg.getBoundingClientRect()
        this.target=responseOffset((e.clientX-r.left-r.width/2)/300,-(e.clientY-r.top-r.height/2)/300,.35)
        if(this.reduced.matches){this.offset=this.target;this.draw()}else this.animate()
      }
    }
    this.up=e=>{
      if(this.skating?.id===e.pointerId){this.skating=null;return}
      if(this.unrolling?.id===e.pointerId){this.unrolling=null;this.draw();return}
      if(this.composing?.id===e.pointerId){const side=this.composing.side;this.composing=null;this.compose(side);return}
      if(this.pushing?.id===e.pointerId){this.pushing=null;this.operate({action:'travel',progress:this.opening});return}
      if(this.turning?.id===e.pointerId){this.turning=null;this.velocity=0;this.acceleration=0;this.animate();return}
      if(this.pull?.id===e.pointerId){this.finishPull(false);return}
      if(this.feed?.id===e.pointerId)this.finishFeed()
    }
    this.cancel=e=>{
      if(this.skating?.id===e.pointerId){this.motion.progress=this.skating.start;this.skating=null}
      if(this.unrolling?.id===e.pointerId){this.carpet=this.unrolling.start;this.unrolling=null}
      if(this.composing?.id===e.pointerId)this.composing=null
      if(this.pushing?.id===e.pointerId){this.opening=this.pushing.start;this.pushing=null}
      if(this.turning?.id===e.pointerId){this.turning=null;this.velocity=0;this.acceleration=0}
      if(this.pull?.id===e.pointerId)this.finishPull(true)
      if(this.feed?.id===e.pointerId){this.feed=null;this.draft=furnishedStick(0,0,0)}
      this.draw()
    }
    this.key=e=>{
      if(e.target.closest('#cob-skate-purchase')&&['ArrowRight','ArrowLeft','ArrowUp','ArrowDown','Home','End',' '].includes(e.key)){
        e.preventDefault();this.motion.play=0;this.drive.velocity=0
        if(this.model.refurbished&&(!this.model.traversal?.appointed||(this.model.inaugural&&!this.model.inaugural.across)))return
        this.motion.progress=e.key==='Home'?0:e.key==='End'?1:e.key===' '?this.motion.progress:clamp(Math.round((this.motion.progress+(['ArrowRight','ArrowUp'].includes(e.key)?.05:-.05))*100)/100,0,1)
        if(this.model.refurbished)this.navDistance=this.motion.progress*this.model.traversal.course.length
        this.draw();return
      }
      const resolution=e.target.closest('[data-resolution-id]')
      if(resolution&&['Enter',' '].includes(e.key)){e.preventDefault();this.chooseTarget(resolution.dataset.resolutionId);return}
      const surface=e.target.closest('[data-xt-locality]')
      if(surface&&['Enter',' '].includes(e.key)){
        e.preventDefault();if(!e.repeat)this.pushEvent('inspect',{relation:surface.dataset.heldRelation});return
      }
      if(e.target.closest('#carpet-purchase')&&['ArrowUp','ArrowDown','ArrowLeft','ArrowRight','Home','End','PageUp','PageDown','Enter',' ','Escape'].includes(e.key)){
        e.preventDefault();if(!e.repeat||e.key.startsWith('Arrow'))this.carpetChange(e.key);return
      }
      if(e.target.closest('#rugging-seat')&&['Enter',' '].includes(e.key)){
        e.preventDefault();if(!e.repeat)this.carpetChange('Enter');return
      }
      const composition=e.target.closest('[data-compose]')
      if(composition){
        const side=composition.dataset.compose
        if(['ArrowUp','ArrowRight','ArrowDown','ArrowLeft'].includes(e.key)){
          e.preventDefault();this.preview[side]=clamp(this.preview[side]+(['ArrowUp','ArrowRight'].includes(e.key)?1:-1),0,2);this.draw();return
        }
        if(['Enter',' '].includes(e.key)){e.preventDefault();if(!e.repeat)this.compose(side);return}
      }
      if(e.target.closest('#second-puffing-squeeze,#pointing-flick,#detent-release')&&['Enter',' '].includes(e.key)){
        e.preventDefault();if(!e.repeat)this.activate(e.target);return
      }
      if(e.target.closest('#human-push-handle')&&this.coupled()){
        if(['ArrowUp','ArrowRight','ArrowDown','ArrowLeft','Home','End'].includes(e.key)){
          e.preventDefault();if(this.detent||this.saving)return
          this.setTravel(e.key==='Home'?0:e.key==='End'?1:this.opening+(['ArrowUp','ArrowRight'].includes(e.key)?.05:-.05))
          this.operate({action:'travel',progress:this.opening});return
        }
      }
      const turning=e.target.closest('[data-turn-handle]')
      if(turning&&['Home','End'].includes(e.key)){e.preventDefault();this.turn((e.key==='Home'?0:90)-this.regard.bearing);this.velocity=0;this.acceleration=0;return}
      if(turning&&['ArrowLeft','ArrowRight'].includes(e.key)){e.preventDefault();this.turn(e.key==='ArrowRight'?12:-12);this.velocity=0;this.acceleration=0;return}
      if(e.target.closest('#pulling-ring,#tab-purchase-hit')&&!this.model.wireframe){
        if(['Enter',' '].includes(e.key)){e.preventDefault();if(e.repeat)return;if(this.pull)this.finishPull(false);else this.beginPull({})}
        else if(this.pull&&e.key.startsWith('Arrow')){e.preventDefault();this.pull.dx+=e.key==='ArrowRight'?12:e.key==='ArrowLeft'?-12:0;this.pull.dy+=e.key==='ArrowDown'?12:e.key==='ArrowUp'?-12:0;this.draw()}
        else if(e.key==='Escape')this.finishPull(true)
      }
      if(e.target.closest('#feed-purchase')&&!this.model.accomplished){
        if(this.model.refurbished&&!this.handoffHeld)return;
        if(['Enter',' '].includes(e.key)){e.preventDefault();if(e.repeat)return;if(this.feed)this.finishFeed();else this.feed={keyboard:true}}
        else if(this.feed&&['ArrowLeft','ArrowRight','ArrowUp','ArrowDown','PageUp','PageDown'].includes(e.key)){
          e.preventDefault();const d=this.draft
          this.draft=furnishedStick(clamp(d.yaw+(e.key==='ArrowRight'?6:e.key==='ArrowLeft'?-6:0),-60,60),clamp(d.pitch+(e.key==='ArrowUp'?6:e.key==='ArrowDown'?-6:0),-45,45),clamp(d.extension+(e.key==='PageUp'?.25:e.key==='PageDown'?-.25:0),0,1),d.length);this.draw()
        }else if(e.key==='Escape'){this.feed=null;this.draft=furnishedStick(0,0,0);this.draw()}
      }
    }
    this.activate=target=>{
      if(this.offline)return
      if(this.model.refurbished){
        if(target.closest('#inaugural-first-puff'))this.pushEvent('puff',{})
        if(target.closest('#inaugural-second-puff'))this.inauguralOperate('puff-across')
        if(target.closest('#inaugural-third-puff'))this.inauguralOperate('puff-over-across')
        if(target.closest('#inspect-inaugural-reference')){this.inspectReference=!this.inspectReference;this.draw()}
        if(target.closest('#inspect-cabinet-seat')){this.inspectSeat=!this.inspectSeat;this.draw()}
        if(target.closest('#take-hold-cob')){this.handoffHeld=true;this.draw()}
        if(target.closest('#complete-cob-handoff'))this.finishFeed()
        if(target.closest('#take-cob-regarding')){this.cobRegarding=true;this.motion.through=false;this.draw()}
        if(target.closest('#release-cob-regarding')){this.cobRegarding=false;this.draw()}
        if(target.closest('#cob-immediate-stop')){this.endPurchase();this.drive.velocity=0;this.motion.play=0;this.draw()}
        if(target.closest('#cob-reverse-drive')){this.drive.reverse=!this.drive.reverse;this.draw()}
        if(target.closest('#grasp-stopping-sheet')){this.drive.attached=true;this.motion.play=0;this.endPurchase();this.signIndex=1;this.signReverse=false;this.driveLoop();this.draw()}
        if(target.closest('#release-stopping-sheet')){this.drive.attached=false;this.draw()}
        for(const [id,yaw,elevation] of [['regard-front',0,0],['regard-left',90,0],['regard-right',-90,0],['regard-back',180,0],['regard-groundward',0,-70],['regard-upside',180,70]])if(target.closest('#'+id)){this.cobRegarding=false;this.motion.through=false;this.motion.elevation=elevation;this.mode=yaw===0&&elevation===0?'flat':'diorama';this.turn(yaw-this.regard.bearing);return}
        if(target.closest('#pointing-flick-cab'))this.flick()
        if(target.closest('#appoint-traversal-course'))this.navOperate('appoint')
        if(target.closest('#appoint-road-continuation'))this.navOperate('appoint-continuation')
        if(target.closest('#issue-janusite'))this.navOperate('issue')
        if(target.closest('#toggle-top-down')){const box=this.el.querySelector('#top-down-outreading');box.hidden=!box.hidden;this.mapDismissed=box.hidden;target.setAttribute('aria-expanded',String(!box.hidden))}
        if(target.closest('#inspect-course-sign')){this.signIndex=(this.signIndex+1)%4;this.signReverse=false;this.draw()}
        if(target.closest('#reverse-course-sign')){if(this.signIndex<0)this.signIndex=0;this.signReverse=!this.signReverse;this.draw()}
        if(target.closest('#toggle-resolution-traces')){this.showTraces=!this.showTraces;this.draw()}
      }
      if(target.closest('#early-puffing-squeeze'))this.pushEvent('puff',{})
      if(target.closest('#regard-groundward')){this.motion.through=false;this.motion.elevation=0;this.turn(-this.regard.bearing)}
      if(target.closest('#regard-upside')){this.motion.through=false;this.motion.elevation=0;this.turn(180-this.regard.bearing)}
      if(target.closest('#regard-through-cob')&&this.model.accomplished){this.cobRegarding=false;this.motion.through=!this.motion.through;this.draw()}
      if(target.closest('#human-quarter-rehearsal')){this.motion.leaf=(this.motion.leaf+.25)%1.25;this.draw()}
      if(target.closest('#reset-cob-rehearsal')){this.endPurchase();this.drive.velocity=0;this.drive.attached=false;this.navDistance=0;this.motion.progress=0;this.motion.play=0;this.motion.target=null;this.inspectedResolution=null;this.el.querySelector('#resolution-target').value='';this.draw()}
      if(target.closest('#skate-forward'))this.skate(1)
      if(target.closest('#skate-reverse'))this.skate(-1)
      if(target.closest('#skate-pause')){this.endPurchase();this.drive.velocity=0;this.motion.play=0;this.draw()}
      if(target.closest('#regarding-zoom-in')){this.zoom=Math.min(3,this.zoom*1.5);this.draw()}
      if(target.closest('#regarding-zoom-out')){this.zoom=Math.max(1,this.zoom/1.5);this.draw()}
      if(target.closest('#regarding-zoom-reset')){this.zoom=1;this.draw()}
      if(target.closest('#second-puffing-squeeze'))this.pushEvent('second-puff',{})
      if(target.closest('#pointing-flick'))this.flick()
      if(target.closest('#rugging-seat'))this.carpetChange('Enter')
      if(target.closest('#detent-release')&&!this.saving)this.operate({action:'release'})
    }
    this.click=e=>{
      const sign=e.target.closest('[data-course-sign]');if(sign){this.signIndex=this.model.traversal.course.signs.findIndex(s=>s.id===sign.dataset.courseSign);this.signReverse=false;this.draw();return}
      const resolution=e.target.closest('[data-resolution-id]')
      if(resolution){this.chooseTarget(resolution.dataset.resolutionId);return}
      this.activate(e.target)
      const relation=e.target.closest('svg [data-held-relation]')?.dataset.heldRelation
      if(relation&&!e.target.closest('[data-turn-handle],[data-compose],#human-push-handle,#pulling-ring,#tab-purchase-hit,#feed-purchase,#second-puffing-squeeze,#pointing-flick,#detent-release,#carpet-purchase,#rugging-seat,#cob-skate-purchase,#early-puffing-squeeze'))this.pushEvent('inspect',{relation})
    }
    this.svg.addEventListener('pointerdown',this.down);this.svg.addEventListener('pointermove',this.move);this.svg.addEventListener('pointerup',this.up);this.svg.addEventListener('pointercancel',this.cancel);this.svg.addEventListener('keydown',this.key);this.el.addEventListener('click',this.click)
    this.read()
  },
  animate(){
    if(this.frame||this.reduced.matches)return
    let last=performance.now()
    const step=now=>{
      this.frame=null;if(this.gone)return
      const dt=Math.min(.05,(now-last)/1000);last=now
      this.swing=suspensionStep(this.swing,this.velocity,this.acceleration,dt,this.model.purchase.length)
      this.offset=settleOffset(this.offset,this.target,dt)
      this.acceleration*=.7
      if(!this.turning)this.velocity*=.7
      this.draw()
      const energy=Math.abs(this.swing.x)+Math.abs(this.swing.z)+Math.abs(this.swing.vx)+Math.abs(this.swing.vz)+Math.hypot(...this.offset.map((v,i)=>v-this.target[i]))
      if(energy>.001||this.turning)this.frame=requestAnimationFrame(step)
    }
    this.frame=requestAnimationFrame(step)
  },
  draw(){
    if(!this.model?.sheet)return
    const refurbished=this.model.refurbished,early=this.model.early,bodyModel=this.model.projection_body,pose=early&&this.model.accomplished?this.pose():null
    const through=refurbished&&this.cobRegarding&&pose?shoulderFrame(pose):early&&this.motion.through&&pose?{origin:pose.center,direction:pose.pointDirection||pose.direction,up:pose.up}:null
    const pivotCenter=this.pivotCenter(),P=point=>refurbished?applianceView(point,this.regard.bearing,this.motion.elevation,through).point:early?projectRegarding(point,this.regard.bearing,this.motion.elevation,pivotCenter,through):project(point,this.regard.bearing,pivotCenter)
    const [rx,ry,rw,rh]=refurbished?[0,0,1100,1100]:early?earlyReserved:reserved,z=this.zoom
    this.svg.setAttribute('viewBox',`${rx+rw*(1-1/z)/2} ${ry+rh*(1-1/z)/2} ${rw/z} ${rh/z}`)
    this.el.dataset.reservedEnvelope=JSON.stringify(early?earlyReserved:reserved);this.el.dataset.zoom=String(z)
    const used=new Set(),ns='http://www.w3.org/2000/svg',pivot=this.regard.bearing
    const path=(id,points,klass,relation,closed=false)=>{
      used.add(id);let node=this.nodes.get(id)
      if(!node){
        node=document.createElementNS(ns,'path');node.id=id
        const anchor=this.nodes.get('purchase-anchor')
        if(/^(xt-|inner-spindle)/.test(id)&&anchor)this.svg.insertBefore(node,anchor);else this.svg.append(node)
        this.nodes.set(id,node)
      }
      const drawer=/^(wireframe-|janusite-|rounded-cob|cob-grasp-|square-aperture|receiving-cylinder|cylinder-rail-|pretending-stick|pointing-flick)/.test(id)
      const offset=!early&&drawer&&this.model.diorama?.extent?[0,0,this.model.diorama.extent.travel*this.opening]:[0,0,0]
      if(refurbished){node.dataset.cameraVisible=String(!through?.local||points.some(p=>applianceView(p,this.regard.bearing,this.motion.elevation,through).depth>-.85));node.dataset.depth=String(points.reduce((n,p)=>n+applianceView(p,this.regard.bearing,this.motion.elevation,through).depth,0)/points.length);node.dataset.worldPoints=JSON.stringify(points)}
      const drawing=through?.local?localCameraPath(points,p=>applianceView(p,this.regard.bearing,this.motion.elevation,through),closed):points.map((p,i)=>`${i?'L':'M'}${P(add(p,offset)).map(n=>n.toFixed(3)).join(',')}`).join(' ')+(closed?' Z':'')
      if(through?.local)node.dataset.cameraVisible=String(!!drawing)
      node.setAttribute('d',drawing);node.setAttribute('class',klass)
      if(relation)node.dataset.heldRelation=relation
      return node
    }
    const square=(id,c,h,klass,relation)=>{
      const operable=/^(compose-(ch|cob)|human-push-handle|second-puffing-squeeze|pointing-flick|detent-release|carpet-purchase|rugging-seat|cob-skate-purchase|early-puffing-squeeze)$/.test(id)
      const a=radians(pivot),right=operable?[Math.cos(a),0,Math.sin(a)]:[1,0,0]
      if(operable){
        const z=-c[0]*Math.sin(a)+c[2]*Math.cos(a),pixelsPerUnit=this.svg.getBoundingClientRect().width/this.svg.viewBox.baseVal.width*55*12/(12+z)
        h=Math.max(h,14/pixelsPerUnit)
      }
      return path(id,[[-1,-1],[1,-1],[1,1],[-1,1]].map(([x,y])=>add(c,add(scale(right,x*h),[0,y*h,0]))),klass,relation,true)
    }
    const mobile=this.svg.getBoundingClientRect().width<600
    const label=(id,point,value,klass='drawer-notice')=>{
      used.add(id);let node=this.nodes.get(id)
      if(!node){
        node=document.createElementNS(ns,'text');node.id=id
        const anchor=this.nodes.get('purchase-anchor')
        if(id.startsWith('xt-axle-')&&anchor)this.svg.insertBefore(node,anchor);else this.svg.append(node)
        this.nodes.set(id,node)
      }
      if(refurbished){const view=applianceView(point,this.regard.bearing,this.motion.elevation,through);node.dataset.cameraVisible=String(!through?.local||view.depth>.18);node.dataset.depth=String(view.depth-.01)}
      const [x,y]=P(point);node.setAttribute('x',x);node.setAttribute('y',y)
      node.setAttribute('class',klass);node.setAttribute('text-anchor','middle')
      node.style.fontSize=`${clamp(12*this.svg.viewBox.baseVal.width/Math.max(300,this.svg.getBoundingClientRect().width),9,22)}px`
      node.textContent=value;return node
    }
    const button=(node,name)=>{node.setAttribute('role','button');node.setAttribute('tabindex','0');node.setAttribute('aria-label',name);return node}
    const surfaceNotice=(id,quad,lines)=>{
      const panel=path(`${id}-surface`,quad,'official-surface',null,true)
      panel.dataset.source='PROVISIONAL official Noticing-Menting'
      const p0=P(quad[3]),p1=P(quad[2]),p2=P(quad[0])
      lines.forEach((line,i)=>{
        const node=label(`${id}-${i}`,[0,0,0],line,'official-lettering')
        node.setAttribute('x','6');node.setAttribute('y',String(13+i*13));node.setAttribute('text-anchor','start')
        node.style.fontSize='10px';node.setAttribute('transform',`matrix(${(p1[0]-p0[0])/160} ${(p1[1]-p0[1])/160} ${(p2[0]-p0[0])/46} ${(p2[1]-p0[1])/46} ${p0[0]} ${p0[1]})`)
        node.dataset.editorialStatus='PROVISIONAL';node.dataset.surface=`${id}-surface`
      })
    }
    const surfaces=this.model.inscription_surfaces||[]
    if(surfaces.length){
      path('xt-ground-ancestry',[[0,-1.2,0],[0,0,0]],'xt-axle','human-standing')
      path('xt-axle',[[-3.2,0,0],[3.2,0,0]],'xt-axle','opening-accomplished')
      for(const x of [-1.2,1.2])path(`inner-spindle-end-${x}`,ringPoints([x,0,0],[.12,.12,0],'xy',[1,0,0]),'inner-spindle','opening-accomplished')
      for(const y of [-.12,.12])path(`inner-spindle-rail-${y}`,[[-1.2,y,0],[1.2,y,0]],'inner-spindle','opening-accomplished')
      for(const surface of surfaces){
        surfaceNotice(surface.id,surface.surface,[surface.title,'ALONG THROUGH XT','FROM HERE NOW'])
        const node=this.nodes.get(`${surface.id}-surface`)
        node.setAttribute('class',`xt-locality-surface${this.model.inspected_relation===surface.relation?' xt-locality-selected':''}`)
        node.dataset.source=surface.event;node.dataset.frame=surface.frame;node.dataset.xtLocality=surface.id;node.dataset.heldRelation=surface.relation;node.dataset.provenance=surface.provenance
        node.setAttribute('role','button');node.setAttribute('tabindex','0');node.setAttribute('aria-label',`${surface.title}. Inspect retained XT-axle locality.`)
        for(let i=0;i<3;i++)this.nodes.get(`${surface.id}-${i}`).dataset.editorialStatus='retained event inscription'
      }
    }
    const selected=surfaces.find(surface=>surface.relation===this.model.inspected_relation)
    const reading=this.el.querySelector('#xt-surface-reading')
    const readingKey=selected?selected.id+':'+this.mode:''
    if(this.readingKey!==readingKey){
      this.readingKey=readingKey
      reading.replaceChildren();reading.hidden=!selected||this.mode!=='flat'
      if(selected){
        reading.dataset.locality=selected.id;reading.dataset.provenance=selected.provenance
        const title=document.createElement('strong'),inscription=document.createElement('p'),ancestry=document.createElement('small')
        title.textContent=selected.title;inscription.textContent=selected.inscription
        ancestry.textContent=`${selected.id} · ${selected.provenance} · ALONG THROUGH XT · UP FROM OUT OF THE GROUND FROM HERE`
        reading.append(title,inscription,ancestry)
      }
    }
    const s=this.model.sheet,side=Math.cos(radians(pivot))>=0?'front':'back'
    if(!refurbished)path('planar-sheet',[[-s.half_width,-s.half_height,0],[s.half_width,-s.half_height,0],[s.half_width,s.half_height,0],[-s.half_width,s.half_height,0]],`opening-sheet sheet-${side}`,null,true)
    const rug=this.model.rugging,drawerOffset=this.model.diorama?.extent?this.model.diorama.extent.travel*this.opening:0,carpet=ruggingGeometry(rug,{...this.carpet,drawerOffset})
    this.el.dataset.carpetRoll=String(carpet.roll);this.el.dataset.carpetYaw=String(carpet.yaw);this.el.dataset.carpetSeat=String(carpet.seat)
    const humanCircle=rug.field_available?ringPoints(rug.pivot,[rug.radius,0,rug.radius],'xz'):ringPoints(this.model.circle.center,[this.model.circle.radius,this.model.circle.radius,0])
    const circle=path('opening-circle',humanCircle,'opening-circle human-landinging-reference','opening-circle-available')
    circle.style.pointerEvents=rug.field_available?'none':'auto';circle.dataset.pivotReference='human-standing';circle.dataset.responsibility=rug.responsibility
    this.el.dataset.pivotCenter=JSON.stringify(pivotCenter)
    if(!early){
    const stand=rug.ground_start
    path('rugging-dispensationaling-stand',[[stand[0]-.6,stand[1]-.1,stand[2]-.12],[stand[0]+.6,stand[1]-.1,stand[2]-.12],[stand[0]+.6,stand[1]+.12,stand[2]+.12],[stand[0]-.6,stand[1]+.12,stand[2]+.12]],'rugging-stand',null,true)
    path('carpet-line',[rug.ground_start,carpet.tip],'carpet-line')
    if(!early&&carpet.roll>0)path('pretending-carpet',carpet.ground,'pretending-carpet',null,true)
    const unroll=button(square('carpet-purchase',carpet.roll>0?carpet.tip:rug.ground_start,.18,'carpet-purchase'),'Pretend to unroll Magic Carpet FROM HERE. Drag up; Shift-drag aligns. Arrows up/down unroll; left/right align. Page Up seats in quarters.')
    unroll.setAttribute('aria-describedby','carpet-local-reading');unroll.setAttribute('aria-label',unroll.getAttribute('aria-label')+` Bearing ${carpet.yaw} degrees; ${Math.round(carpet.roll*100)} percent; seating ${carpet.angle} degrees.`)
    label('carpet-local-reading',add(rug.ground_start,[0,-.55,0]),carpet.seat===1?'ALONG THROUGH · seated':carpet.available?'Aligned · seat square':`Unroll · align ${carpet.yaw}°`)
    if(rug.field_available&&carpet.roll===1){
      path('field-bearing',[[0,rug.floor_y,rug.near],[0,rug.floor_y,rug.far]],'field-bearing')
      if(carpet.available){
        const floor=path('field-rugging',carpet.floor,'field-rugging','aperture-available',true)
        floor.dataset.hingeDegrees=String(carpet.angle);floor.dataset.apertureReference=rug.aperture_reference
        floor.dataset.material='substrationing';floor.dataset.status='reversible seating rehearsal'
        path('aperture-rugging-join',[[0,-.16,drawerOffset],carpet.hinge],'rugging-join')
        button(square('rugging-seat',[-1.65,rug.floor_y,rug.near],.16,'rugging-seat'),'Seat or return the Human square surface through 90 degrees; no RE-STEP')
      }
      if(carpet.seat===1){
        surfaceNotice('rugging-notice',[[-.85,rug.floor_y,.25],[.85,rug.floor_y,.25],[.85,rug.floor_y,1.1],[-.85,rug.floor_y,1.1]],['OFFICIAL · PROVISIONAL','GROUND FLOOR RUGGING','FROM HERE NOW'])
      }
    }
    if(rug.gallery_available&&carpet.seat===1&&this.opening>0){
      const wall=galleryWall(rug,this.opening),bottom=wall.map(pair=>pair[0]),top=wall.map(pair=>pair[1])
      path('gallery-wall',[...bottom,...top.toReversed()],'gallery-wall','drawer-extent-standing',true)
      path('gallery-ground-course',bottom,'gallery-course');path('gallery-ceiling-course',top,'gallery-course')
      wall.filter((_,i)=>i%4===0).forEach((pair,i)=>path(`gallery-upright-${i}`,pair,'gallery-upright'))
      const z=rug.far
      path('yt-transverse-region',[[-.75,rug.floor_y,z],[.75,rug.floor_y,z],[.75,rug.ceiling_y,z],[-.75,rug.ceiling_y,z]],'yt-transverse-region',null,true)
      surfaceNotice('yt-notice',[[-.7,.1,z],[.7,.1,z],[.7,.85,z],[-.7,.85,z]],['TOWARD YT · OVER ACROSS','APPROACHING LANDINGING','STITCHING STAND · RESERVED'])
      if(this.opening>=.5){
        surfaceNotice('gallery-notice',[[.05,-.45,rug.pivot[2]+rug.radius],[1.1,-.45,rug.pivot[2]+.35],[1.1,.4,rug.pivot[2]+.35],[.05,.4,rug.pivot[2]+rug.radius]],['OFFICIAL · PROVISIONAL','REGARDING FROM HERE NOW','Weddinging · notice only'])
      }
    }
    }
    const purchase=this.model.purchase
    path('purchase-anchor',ringPoints(purchase.anchor,[purchase.anchor_radius,purchase.anchor_radius,0]),'purchase-anchor')
    const displacement=this.pull?[this.pull.dx/65*Math.cos(radians(pivot)),-this.pull.dy/65,this.pull.dx/65*Math.sin(radians(pivot))]:[0,0,0],tab=suspendedTab(purchase,this.swing,displacement)
    path('hanging-string',[purchase.anchor,[tab[0],tab[1]+purchase.tab_half,tab[2]]],'hanging-string')
    const outer=square('pulling-ring',tab,purchase.tab_half,'square-pull-tab'),inner=square('pull-tab-hollow',tab,purchase.hollow_half,'pull-tab-hollow')
    outer.setAttribute('tabindex',this.model.wireframe?'-1':'0');outer.setAttribute('role','button');outer.setAttribute('aria-label','Grasp hollow square pull tab. Enter, arrow, Enter.');outer.dataset.worldCenter=JSON.stringify(tab)
    outer.setAttribute('d',outer.getAttribute('d')+' '+inner.getAttribute('d'));outer.setAttribute('fill-rule','evenodd');inner.style.pointerEvents='none'
    const tabHit=square('tab-purchase-hit',tab,.38,'tab-purchase-hit');tabHit.setAttribute('aria-hidden','true')
    // This local course carries the four Regarding purchases, not XT/YT standing.
    const course=Array.from({length:49},(_,i)=>{const a=-Math.PI*.7+i*Math.PI*1.4/48;return [Math.sin(a)*1.8,-3.25,Math.cos(a)*.65]})
    path('turning-course',course,'turning-course')
    for(let i=0;i<4;i++){
      const index=[6,18,30,42][i],center=course[index],handle=square(`turn-handle-${i}`,center,.2,'turn-handle')
      handle.dataset.turnHandle=String(i);handle.setAttribute('tabindex','0');handle.setAttribute('role','button');handle.setAttribute('aria-label',`Turning handle ${i+1}. Drag or use left and right arrows. Home: flat; End: edge-on.`)
    }
    if(early&&!this.model.wireframe)label('early-pull-invitation',[0,-1.6,0],'PULL · take the hollow square')
    if(early&&this.model.janusite&&!this.model.accomplished)label('early-feed-invitation',[-1.7,-.55,0],'Feed THROUGH · release FOR COB')
    if(early&&this.model.wireframe){
      if(!refurbished)path('machine-floor',bodyModel.floor,'projection-floor','opening-accomplished',true)
      label('body-ground-reading',refurbished?[-2.7,this.model.cutaway.floor_y+.1,5]:[-1.5,-1.7,1.2],'GROUND / FLOOR')
      for(const extent of bodyModel.extents.filter(e=>e.family==='square'&&(!refurbished||this.showTraces))){
        const node=path(extent.id,extent.points,`resolution-square${(this.motion.target||this.inspectedResolution)===extent.id?' resolution-selected':''}`,null,true)
        node.dataset.resolutionId=extent.id;node.setAttribute('role','button');node.setAttribute('tabindex','0');node.setAttribute('aria-label',`${extent.id}. Provisional resolutioning section, inspect and point.`)
      }
      const selected=bodyModel.extents.find(e=>e.id===(this.motion.target||this.inspectedResolution))
      if(selected){
        const paired=bodyModel.extents.find(e=>e.id===selected.pair)
        path('paired-correspondence',[selected.target,paired.target],'paired-correspondence')
      }
      if(this.motion.leaf>0&&this.model.aperture){
        const leaf=ruggingGeometry(rug,{roll:1,yaw:0,seat:this.motion.leaf})
        path('human-quarter-leaf',leaf.floor,'quarter-leaf','aperture-available',true)
      }
      if(!this.model.janusite){
        button(square('early-puffing-squeeze',[-2.1,1.6,0],.3,'second-bellows'),'Squeeze Bellowing Thing: first PUFFING THROUGH aperture')
        label('early-puff-invitation',[-2.1,2.15,0],'PUFF THROUGH')
      }
    }
    if(early&&bodyModel.tunnel&&!refurbished){
      const course=bodyModel.tunnel
      path('rehearsal-tunnel-centerline',course.samples.map(s=>s.point),'tunnel-centerline')
      for(let i=0;i<course.samples.length;i+=8){
        const sample=course.samples[i]
        path(`rehearsal-tunnel-ring-${i}`,ringPoints(sample.point,[course.tube_radius,course.tube_radius,0],'xy',sample.tangent),'tunnel-section')
      }
      for(const j of [0,16,32,48]){
        const rail=course.samples.map(sample=>ringPoints(sample.point,[course.tube_radius,course.tube_radius,0],'xy',sample.tangent)[j])
        path(`rehearsal-tunnel-pipe-${j}`,rail,'tunnel-pipe')
      }
      const entrance=path('rehearsal-tunnel-entrance',ringPoints(course.entrance,[.24,.24,0],'xy',course.samples[0].tangent),'tunnel-entrance')
      entrance.dataset.courseId=course.id
      label('tunnel-entrance-reading',add(course.entrance,[0,-.55,0]),'INLET')
      label('tunnel-continuation-reading',add(course.continuation,[0,-.9,0]),'CONTINUE')
      for(const marker of course.markers){
        const place=tunnelPose(course,marker.progress,this.model.stick),node=label(marker.id,add(place.center,[0,.32,0]),marker.text.match(/^TEST ([A-Z])/)[1],'rehearsal-lettering')
        const a=P(place.center),b=P(add(place.center,place.direction)),angle=Math.atan2(b[1]-a[1],b[0]-a[0])*180/Math.PI
        node.setAttribute('transform',`rotate(${angle} ${node.getAttribute('x')} ${node.getAttribute('y')})`)
        node.setAttribute('aria-label',marker.text+'; engineering rehearsal only');node.dataset.courseId=course.id;node.dataset.progress=marker.progress;node.dataset.status=marker.status
      }
      const skate=square('cob-skate-purchase',add(pose.center,[0,.65,0]),.17,'cob-skate-purchase')
      skate.setAttribute('role','slider');skate.setAttribute('tabindex','0');skate.setAttribute('aria-valuemin','0');skate.setAttribute('aria-valuemax','100');skate.setAttribute('aria-valuenow',Math.round(this.motion.progress*100));skate.setAttribute('aria-label','Skate COB ALONG THROUGH: drag horizontally, arrows forward/reverse, Home returns to entrance')
      if(this.motion.target){
        const target=bodyModel.targets.find(t=>t.id===this.motion.target)?.target
        if(target)path('through-by-cob-pointing-ray',[pose.tip,target],'through-by-cob-pointing-ray')
      }
      label('early-cob-locality',add(pose.center,[0,1.1,0]),`COB ${Math.round(this.motion.progress*100)}%`)
      this.el.dataset.skateProgress=String(this.motion.progress);this.el.dataset.cobPosition=JSON.stringify(pose.center);this.el.dataset.cobDirection=JSON.stringify(pose.direction)
    }
    if(refurbished)this.drawAlongside()
    if(refurbished)this.drawAppliance({path,label,square,button,P,pose,used,ns,through})
    if(this.model.inaugural)this.drawInaugural({path,label,P})
    if(early){
      for(const id of ['regard-through-cob','reset-cob-rehearsal','skate-forward','skate-reverse','skate-pause'])this.el.querySelector(`#${id}`).disabled=!this.model.accomplished||(refurbished&&id.startsWith('skate-')&&(!this.model.traversal?.appointed||(this.model.inaugural&&!this.model.inaugural.across)))
      this.el.querySelector('#human-quarter-rehearsal').disabled=!this.model.aperture||(!!this.model.inaugural&&!this.model.inaugural.across)
      const target=this.el.querySelector('#resolution-target');target.disabled=!this.model.accomplished||(!!this.model.inaugural&&!this.model.inaugural.over_across)
      const selected=bodyModel.extents.find(e=>e.id===(this.motion.target||this.inspectedResolution))
      const reading=this.el.querySelector('#projection-reading'),key=selected?.id||this.motion.target||''
      reading.hidden=!key
      if(this.resolutionReading!==key){
        this.resolutionReading=key;reading.replaceChildren()
        if(key){
          const title=document.createElement('strong'),detail=document.createElement('p')
          title.textContent=key
          detail.textContent=selected?`${selected.family} / ${selected.plane}; pair ${selected.pair}; source ${selected.source}; ${selected.furnished?'furnished reference':'reserved'}; no accomplished CH inscription. PROVISIONAL interpretation.`:'Rehearsal target in the same Projectioning body; appointment and Human FROM remain retained.'
          reading.append(title,detail);reading.dataset.resolutionId=key
        }
      }

      this.el.dataset.elevation=String(this.motion.elevation);this.el.dataset.throughCob=String(this.motion.through)
    }
    if(this.model.accomplished&&!early){
      const extent=this.model.diorama.extent
      if(!extent){
        const bellows=button(square('second-puffing-squeeze',[-2.1,1.6,0],.32,'second-bellows'),'Squeeze Bellowing Thing again: second PUFFING AROUND ABOUT')
        bellows.dataset.furnishes='second-puffing'
        for(const dy of [-.12,0,.12])path(`second-bellows-rib-${dy}`,[[-2.28,1.6+dy,0],[-1.92,1.6+dy,0]],'bellows-rib')
        label('second-puff-notice',[-1.9,2.2,0],'PUFF AROUND ABOUT')
        label('purchase-unavailable',[-2.1,.8,0],'Purchases not yet available')
      }else{
        for(const plane of ['xy','xz','yz'])path(`drawer-extent-${plane}`,ringPoints(extent.center,extent.radii,plane),'drawer-extent','drawer-extent-standing')
        label('extent-outreading',[-1.3,4.15,1.6],mobile?'AROUND ABOUT':'AROUND ABOUT · extent furnished')
        const state=this.mechanical,slot=state.cob_slot??this.preview.cob,rail=extent.rail
        const samples=Array.from({length:97},(_,i)=>drawerRail(extent,slot,i/96))
        path('drawer-rail',samples,'drawer-rail','drawer-extent-standing')
        path('drawer-rail-companion',samples.map(p=>add(p,[.12,0,0])),'drawer-rail companion')
        if(!mobile||this.opening>.25&&this.opening<.75)label('rail-quarter-outreading',add(drawerRail(extent,slot,.5),[-.6,0,0]),mobile?'90° · continue':'90° · course continues')
        if(!this.detent)label('rail-return-outreading',add(drawerRail(extent,slot,1),[-.8,.38,0]),'180° · return')
        for(const side of ['ch','cob']){
          if(state[`${side}_slot`]===null&&this.opening===0){
            const candidate=side==='ch'?[-2.8,[-1.1,0,1.1][this.preview.ch],0]:drawerRail(extent,this.preview.cob,0)
            const node=button(square(`compose-${side}`,candidate,.28,`compose-purchase compose-${side}`),`Compose ${side==='ch'?'yellow CH PUSH':'green COB PULL'} purchase. Arrows explore lawful mounting slots; Enter accomplishes purchase.`)
            node.dataset.compose=side
            label(`compose-${side}-notice`,add(candidate,[side==='ch'?.6:-.9,.65,0]),`${side.toUpperCase()} available · Enter`)
          }
        }
        const mechanism=drawerMechanism(extent,state.ch_slot??this.preview.ch,slot,this.opening)
        if(state.ch_slot!==null){
          const human=square('human-push-handle',mechanism.ch,.28,'diorama-human-handle')
          human.setAttribute('tabindex','0');human.setAttribute('role','slider');human.setAttribute('aria-orientation','vertical')
          human.setAttribute('aria-label','CH PUSH BACK. Drag upward or arrows to open; Home returns, End completes rail.')
          human.setAttribute('aria-valuemin','0');human.setAttribute('aria-valuemax','100');human.setAttribute('aria-valuenow',String(Math.round(this.opening*100)))
          human.setAttribute('aria-disabled',String(this.detent||!this.coupled()||this.saving))
          if(!this.detent)label('ch-purchase-notice',add(mechanism.ch,[-.1,-.7,0]),this.coupled()?(mobile?'PUSH':'CH PUSH BACK'):'CH accomplished')
        }
        if(state.cob_slot!==null){
          const cooperative=square('cob-pull-handle',mechanism.cob,.28,'diorama-cob-handle')
          cooperative.dataset.progress=String(this.opening);cooperative.dataset.returnDegrees=String(mechanism.angle)
          path('cob-cooperative-purchase',[add(this.model.stick.tip,mechanism.displacement),mechanism.cob],'diorama-coupling')
          if(!this.detent)label('cob-purchase-notice',add(mechanism.cob,[-.9,-.55,0]),this.coupled()?(mobile?'PULL':'COB PULL'):'COB accomplished')
        }
        if(this.detent){
          const end=drawerRail(extent,slot,1)
          const pageContact=[this.model.sheet.half_width,this.model.sheet.half_height,0]
          path('detent-page-hold',[end,pageContact,add(this.model.diorama.reference.max,[0,0,extent.travel])],'detent-hold')
          path('detent-cup',ringPoints(pageContact,[.28,.14,0]),'detent-cup')
          button(square('detent-release',add(end,[-.8,-.3,0]),.22,'detent-release'),'Deliberately release seated LOCK; furnished extent remains')
          label('lock-outreading',add(end,[-.6,.9,0]),mobile?'LOCK · 180°':'LOCK · held · release below')
          label('release-outreading',add(end,[-1,-.9,0]),'Release')
        }
        this.el.dataset.dioramaOpening=String(this.opening);this.el.dataset.detent=String(this.detent)
        label('coupled-outreading',[0,-3.9,0],this.detent?'LOCK holds · Regarding remains free':this.coupled()?'Coupled · one drawer progress':'Compose both purchases')
      }
    }
    if(this.model.wireframe&&(!refurbished||this.showTraces))wireframeEdges(this.model.wireframe.min,this.model.wireframe.max).forEach((edge,i)=>path(`wireframe-${i}`,edge,'opening-wire','opening-accomplished'))
    const cob=this.model.cob
    if(this.model.janusite){
      const extent=this.model.janusite
      for(const plane of (refurbished&&(!this.showTraces||(this.model.inaugural&&!this.model.inaugural.over_across))?[]:['xy','xz','yz'])){
        const id=`resolution-circle-${plane}`,node=path(`janusite-${plane}`,ringPoints(extent.center,extent.radii,plane),`janusite-extent${early&&this.motion.target===id?' resolution-selected':''}`,'janusite-extent-standing')
        if(early){node.dataset.resolutionId=id;node.setAttribute('role','button');node.setAttribute('tabindex','0');node.setAttribute('aria-label',`${id}. Provisional circular resolutioning section.`)}
      }
      const stick=this.model.stick||this.model.locked||this.draft,active=stick.extension>0
      const arrival=active?stick.extension:0,rest=add(cob.center,this.offset),goal=active?add(stick.tip,[0,.32,0]):rest
      const center=pose?pose.center:add(add(scale(rest,1-arrival),scale(goal,arrival)),this.model.accomplished?scale(this.offset,.1):[0,0,0]),direction=pose?pose.direction:active?stick.direction:[0,0,1]
      const body=path('rounded-cob',refurbished&&pose?framedRing(center,cob.radii,'xy',pose):ringPoints(center,cob.radii,'xy',direction),'rounded-cob','cob-standing',true)
      body.dataset.orientation=JSON.stringify(direction)
      if(refurbished)this.drawCompanion({path,label,center,direction,pose,arrival,stick})
      for(const plane of ['xz','yz'])path(`rounded-cob-${plane}`,refurbished&&pose?framedRing(center,cob.radii,plane,pose):ringPoints(center,cob.radii,plane,direction),'cob-meridian','cob-standing')
      const contactCenter=pose?pose.tip:active?add(scale(center,1-arrival),scale(stick.tip,arrival)):center
      const contacts=refurbished&&pose?[[-1,-1],[1,-1],[1,1],[-1,1]].map(([x,y])=>add(contactCenter,add(scale(pose.right,x*.134),scale(pose.up,y*.134*.65)))):graspPoints(contactCenter,direction,arrival)
      contacts.forEach((contact,i)=>{
        const start=add(center,scale(contact.map((v,k)=>v-center[k]),.7))
        path(`cob-grasp-${i}`,[start,contact],'cob-grasp',this.model.accomplished?'cob-grasp-standing':null)
      })
      square('square-aperture',this.model.aperture.center,this.model.aperture.half_size,'square-aperture','aperture-available')
      if(active){
        const radius=.16,cylinderDirection=refurbished?stick.direction:direction
        path('receiving-cylinder-near',ringPoints(stick.origin,[radius,radius,0],'xy',cylinderDirection),'receiving-cylinder',this.model.accomplished?'receiving-cylinder-standing':null)
        path('receiving-cylinder-far',ringPoints(stick.tip,[radius,radius,0],'xy',cylinderDirection),'receiving-cylinder')
        const nearRing=ringPoints(stick.origin,[radius,radius,0],'xy',cylinderDirection),farRing=ringPoints(stick.tip,[radius,radius,0],'xy',cylinderDirection),near=[0,16,32,48].map(i=>nearRing[i]),far=[0,16,32,48].map(i=>farRing[i])
        near.forEach((p,i)=>path(`cylinder-rail-${i}`,[p,far[i]],'receiving-cylinder'))
        path('pretending-stick',retainedInstrumentPoints(stick,pose),this.model.accomplished?'appointed-stick':'staging-stick',this.model.accomplished?'pointingable-standing':null)
      }
      if(this.model.accomplished&&!refurbished){
        if(early)path('pen-chain-rehearsal',[this.model.purchase.anchor,pose.origin],'pen-chain-rehearsal')
        button(square('pointing-flick',add(stick.origin,[-1.25,.85,0]),.16,'pointing-flick'),'Flick Pointing-able handle: Flat-Page Regarding / Diorama Regarding')
        path('pointing-flick-stem',[stick.origin,add(stick.origin,[-1.25,.85,0])],'flick-stem')
        label('flick-outreading',add(stick.origin,[-1.25,1.45,0]),early||mobile?'Flick':this.mode==='flat'?'Flick → Diorama':'Flick → Flat-Page')
      }
      // A short material purchase is offered AT the aperture, not a remote control.
      if(!this.model.accomplished){
        const feed=path('feed-purchase',[[-.18,-.65,-.45],[0,0,0]],'feed-purchase')
        feed.setAttribute('tabindex','0');feed.setAttribute('role','button');feed.setAttribute('aria-label','Grasp and feed THROUGH aperture. Enter, arrows to aim, Page Up to feed, Enter to release.')
      }
    }else if(cob)square('square-cob',cob.center,cob.half_size,'square-cob','cob-square-standing')
    if(!refurbished)this.svg.insertBefore(this.nodes.get('planar-sheet'),this.svg.firstChild)
    // Earned material and its notices remain behind inherited COB/aperture geometry.
    const background=/^(rugging-dispensationaling-stand|carpet-line|pretending-carpet|field-bearing|field-rugging|aperture-rugging-join|gallery-wall|gallery-ground-course|gallery-ceiling-course|gallery-upright-|yt-transverse-region|rugging-notice-|gallery-notice-|yt-notice-)/
    const anchor=this.nodes.get('carpet-purchase')
    for(const [id,node] of this.nodes)if(used.has(id)&&background.test(id))this.svg.insertBefore(node,anchor)
    if(rug.field_available&&!refurbished)this.svg.append(circle)
    if(refurbished){
      const focused=document.activeElement
      // A convex interior's support surfaces are its backdrop, not averaged-depth occluders.
      // Otherwise a single long Floor would incorrectly conceal the far half of the road.
      const frontFacing=!through&&Math.cos(radians(this.regard.bearing))*Math.cos(radians(this.motion.elevation))>=0
      const layer=n=>n.classList.contains('inaugural-opaque')?1:n.classList.contains('cutaway-front')?(frontFacing?2:0):n.classList.contains('cutaway-face')?0:1
      for(const node of [...this.nodes.values()].filter(n=>used.has(n.id)).sort((a,b)=>layer(a)-layer(b)||Number(b.dataset.depth||0)-Number(a.dataset.depth||0)))this.svg.append(node)
      for(const node of this.nodes.values()){node.setAttribute('clip-path',through?.local?'none':'url(#cutaway-envelope-clip)');node.style.display=node.dataset.cameraVisible==='false'||(through?.local&&node.id==='cob-skate-purchase')?'none':''}
      if(focused&&this.svg.contains(focused)&&document.activeElement!==focused)focused.focus({preventScroll:true})
    }
    for(const [id,node]of this.nodes)if(!used.has(id)){node.remove();this.nodes.delete(id)}
    this.el.dataset.regardingMode=this.mode;this.el.dataset.pivot=String(pivot);this.el.dataset.scope=this.regard.scope;this.el.dataset.side=side
    this.el.querySelector('#regarding-condition').textContent=`${early?'PROVISIONAL 3 SQUARES / 3 CIRCLES · ':''}REGARDING ${this.mode} · ${side} · ${this.model.accomplished?'ACCOMPLISHED STANDING':this.feed||this.pull?'STAGING FOR STANDING':this.model.janusite?'JANUSITE extent':this.model.wireframe?'inherited wireframe':'planar page / suspended purchase'}`
  },
  drawInaugural({path,label,P}){
    const state=this.model.inaugural;if(!state)return
    const get=id=>this.el.querySelector('#'+id)
    get('inaugural-first-puff').disabled=!this.model.wireframe||state.first
    get('inaugural-second-puff').disabled=!state.pointing||state.across
    get('inaugural-third-puff').disabled=!state.detent||state.over_across
    get('inaugural-status').textContent=state.over_across?'THIRD PUFFING · OVER ACROSS possibility retained':state.detent?'THUNK · completed inherited motion at detent; third PUFFING available':state.across?'SECOND PUFFING · ACROSS extent; NAV through inherited course':state.pointing?'Pointing-able Thing retained; second PUFFING available':state.first?'FIRST PUFFING · compact opaque HERE WITHIN':'Introductory cabinet · pre-furnished inaugural approach'
    for(const id of ['regard-groundward','regard-upside'])get(id).disabled=!state.over_across
    get('human-quarter-rehearsal').disabled=!state.across
    get('toggle-resolution-traces').disabled=!state.over_across
    get('top-down-outreading').hidden=!state.across||!!this.mapDismissed
    get('appoint-traversal-course').textContent='Receive inherited NAV course'
    get('appoint-traversal-course').disabled=!state.across||this.model.traversal?.appointed
    if(state.across&&!this.model.traversal?.appointed){get('cob-next-instruction').textContent='The inherited ACROSS course is furnished ahead of navigation. Receive it for NAV; you are not authoring its turns.';get('traversal-status').textContent='Pre-furnished inaugural course · receive for NAV'}
    if(state.pointing&&!state.across)get('cob-next-instruction').textContent='Pointing-able Thing retained. Receive the second PUFFING in the cab; it makes ACROSS extent available. This is inherited furnishing, not a new turn authored by you.'
    const seat=get('cabinet-seat-reading')
    if(this.inspectSeat){seat.hidden=false;seat.textContent=`${state.cabinet_seat.identity} · seated upon Cabinet Seat ALONGSIDE WITH the Cab. Non-agentive; the same Doll retains Semantical In-Stringing-Mentings and stitching letters upon the road. No second Human.`}else seat.hidden=true
    if(this.inspectReference){
      path('monitor-reference-plane',[[-4.8,-4.8,0],[4.8,-4.8,0],[4.8,4.8,0],[-4.8,4.8,0]],'inaugural-reference',null,true)
      for(const extent of state.reference_extents)wireframeEdges(extent.min,extent.max).forEach((edge,i)=>path(`${extent.id}-${i}`,edge,'inaugural-reference'))
      label('monitor-distance-reading',[0,4.6,0],'MONITOR Z=0 · HUMAN GROUND REFERENCE 24 MODEL UNITS','appliance-world-label')
    }
    if(state.pointing){
      const stick=this.model.stick,cube=wireframeEdges([-.23,-.23,-.23],[.23,.23,.23])
      const right=rightOf(stick.direction),up=unit(cross(stick.direction,right))
      cube.forEach((edge,i)=>path(`pointing-regarding-cube-${i}`,edge.map(p=>add(stick.tip,add(scale(right,p[0]),add(scale(up,p[1]),scale(stick.direction,p[2]))))),'regarding-cube'))
      // One continuous elbow sampled as eight segments; two half-turn bearings remain inspectable.
      const elbow=inauguralElbow(stick),points=elbow.map(s=>s.point)
      path('paired-bend-crossing',points,'paired-bend-crossing')
      points.forEach((p,i)=>path(`inaugural-segmentation-${i}`,ringPoints(p,[.14,.14,0],'xy',elbow[i].tangent),'inaugural-segmentation'))
      label('paired-bends-reading',add(points[4],[0,.45,0]),'2 APPROXIMATE BENDS · 8 SEGMENTS','appliance-world-label')
    }
  },
  drawAlongside(){
    const m=this.model,state=m.traversal,ready=!!state?.appointed&&(!m.inaugural||m.inaugural.across),complete=m.accomplished,available=!!m.janusite
    const get=id=>this.el.querySelector('#'+id)
    get('cob-encounter').hidden=!available
    get('take-hold-cob').hidden=this.handoffHeld||complete
    get('appoint-traversal-course').hidden=!complete||ready
    get('cob-handoff-controls').hidden=!this.handoffHeld||complete
    get('complete-cob-handoff').disabled=this.draft.extension<1||complete
    const title=get('cob-next-notice'),detail=get('cob-next-instruction')
    if(!complete){title.textContent=this.handoffHeld?'HAND THIS ONE PRETENDINGING STICK THROUGH':'STAND THIS ONE STEWARDLY CO-CAPTAIN CO-BOBBINING TOWARD APPOINTMENTING THIS ONE POINTING-ABLE THING.';detail.textContent=this.handoffHeld?(this.draft.extension>=1?'COB has reached for the offered stick. Press “Let COB take hold” to complete the handoff.':'Slide the stick forward THROUGH the aperture. Watch COB reach to receive it.'):'Take hold of COB below; then hand the stick through the opening.'}
    else if(!ready){title.textContent='POINTING-ABLE THING · RECEIVED AND RETAINED';detail.textContent='COB has taken hold. Appoint the offered NAV course once in the cab; then take hold of COB’s Regarding.'}
    else {title.textContent=this.cobRegarding?'WITH COB · REGARDING FORWARD':'COB ALONGSIDE · READY FOR NAV';detail.textContent=this.drive.attached?'COB holds the stopping sheet. Inspect its front or reverse, then release the sheet to skate again.':this.cobRegarding?'Press and hold a treadmill region; release to coast. Steer within the tacks. Release COB’s Regarding to watch externally.':'Take hold of COB’s Regarding, or dispatch COB from here. Press and hold a treadmill region; release to coast.'}
    get('mouse-treadmill-panel').hidden=!complete
    get('take-cob-regarding').disabled=!ready;get('take-cob-regarding').hidden=this.cobRegarding
    get('release-cob-regarding').hidden=!this.cobRegarding
    for(const region of this.el.querySelectorAll('[data-treadmill-purchase]')){region.disabled=!ready||this.drive.attached;region.dataset.engaged=String(region.dataset.treadmillPurchase===this.purchase);region.setAttribute('aria-pressed',String(region.dataset.treadmillPurchase===this.purchase))}
    const dwell=this.purchase!=='rest'&&performance.now()-this.purchaseSince<this.settings.dwell*1000
    get('treadmill-response').textContent=`${dwell?'DETENT · engaging':this.purchase.toUpperCase()} · purchase ${this.purchase==='rest'?0:this.purchase==='brake'?-this.settings.brake:(this.settings[this.purchase]||0)*(this.drive.reverse?-1:1)} u/s² · velocity ${this.drive.velocity.toFixed(2)} u/s${this.drive.reverse?' · REVERSE selected':''}`
    get('cob-reverse-drive').setAttribute('aria-pressed',String(this.drive.reverse))
    get('cob-lateral-steering').disabled=!ready
    const sign=state?.course.signs[1],gap=sign?sign.distance-this.navDistance:Infinity,reachable=ready&&Math.abs(gap)<=1.3
    get('grasp-stopping-sheet').disabled=!reachable||this.drive.attached;get('release-stopping-sheet').disabled=!this.drive.attached
    get('stopping-sheet-status').textContent=this.drive.attached?(Math.abs(this.drive.velocity)<.035?'Sheet held · COB at rest. Inspect, release, then engage the treadmill.':'Sheet held · furnished purchase is slowing COB.'):reachable?'BANK notice within reach · take stopping purchase.':sign?`BANK stopping sheet ${gap>0?'approaching':'behind'} · ${Math.abs(gap).toFixed(1)} units away`:'Stopping sheet available on the appointed course.'
    this.el.dataset.purchase=this.purchase;this.el.dataset.navVelocity=String(this.drive.velocity);this.el.dataset.cobRegarding=String(this.cobRegarding);this.el.dataset.stoppingPurchase=String(this.drive.attached);this.el.dataset.handoff=complete?'retained':this.handoffHeld?'reaching':'available'
  },
  drawCompanion({path,label,center,direction,pose,arrival,stick}){
    const frame=pose||{center,direction,right:rightOf(direction),up:unit(cross(direction,rightOf(direction)))},at=(x,y,z)=>add(center,add(scale(frame.right,x),add(scale(frame.up,y),scale(direction,z))))
    path('cob-shoulders',[at(-.38,.12,-.08),at(-.25,.30,-.06),at(.25,.30,-.06),at(.38,.12,-.08)],'cob-shoulders')
    path('cob-head',framedRing(at(0,.32,.02),[.20,.16,.14],'xy',frame),'cob-head',null,true)
    for(const x of [-.075,.075])path(`cob-eye-${x}`,framedRing(at(x,.35,.16),[.025,.035,0],'xy',frame),'cob-eye',null,true)
    if(this.cobRegarding&&(!this.model.inaugural||this.model.inaugural.over_across))path('cob-coupling-ring',framedRing(at(0,.53,-.06),[.24,0,.20],'xz',frame),'cob-coupling-ring')
    if(pose){
      for(const wheel of companionWheels(this.model.traversal.course,this.navDistance,this.model.stick,this.drive.lateral)){
        const wheelFrame={right:wheel.direction,up:wheel.up,direction:wheel.right},node=path(wheel.id,framedRing(add(wheel.center,scale(wheel.right,.045)),[.1,.1,.045],'xy',wheelFrame),'cob-wheel',null,true)
        path(`${wheel.id}-back`,framedRing(add(wheel.center,scale(wheel.right,-.045)),[.1,.1,0],'xy',wheelFrame),'cob-wheel-back',null,true)
        for(const angle of [0,Math.PI/2,Math.PI,Math.PI*1.5]){const edge=add(wheel.center,add(scale(wheel.up,.1*Math.sin(angle)),scale(wheel.direction,.1*Math.cos(angle))));path(`${wheel.id}-tread-${angle}`,[add(edge,scale(wheel.right,-.045)),add(edge,scale(wheel.right,.045))],'cob-wheel-tread')}
        node.dataset.contact=JSON.stringify(wheel.contact);node.dataset.orientation=JSON.stringify(wheel.direction);node.dataset.roll=String(wheel.angle)
        const spoke=add(scale(wheel.up,.09*Math.cos(wheel.angle)),scale(wheel.direction,.09*Math.sin(wheel.angle)))
        path(`${wheel.id}-spoke`,[add(wheel.center,scale(spoke,-1)),add(wheel.center,spoke)],'cob-wheel-spoke')
        path(`${wheel.id}-suspension`,[at(wheel.id.includes('left')?-.22:.22,-.1,wheel.id.includes('rear')?-.18:.18),wheel.center],'cob-wheel-suspension')
      }
      if(this.drive.attached){const sign=this.model.traversal.course.signs[1],local=traversalPose(this.model.traversal.course,sign.distance,this.model.stick);path('cob-stopping-purchase',[at(.3,.1,.1),add(local.center,scale(local.right,.68))],'cob-stopping-purchase')}
    }else {
      for(const axle of [-1,1])for(const side of [-1,1]){const id=`cob-wheel-${axle===-1?'rear':'front'}-${side===-1?'left':'right'}`,p=at(side*.22,-.20,axle*.22);path(id,framedRing(p,[.1,.1,0],'xy',{right:direction,up:frame.up,direction:frame.right}),'cob-wheel',null,true)}
      if(this.handoffHeld){
      const tip=arrival>0?stick.tip:[0,0,.5]
      for(const side of [-1,1])path(`cob-reaching-${side}`,[at(side*.33,.05,.1),add(tip,[side*(.32-.18*arrival),.04,0])],'cob-reaching')
      }
    }
    const state=this.model.traversal
    if(state?.appointed&&(!this.model.inaugural||this.model.inaugural.across)){
      const course=state.course
      for(const side of [-1,1])for(const edge of [-1,1])path(`janusite-tack-${side}-${edge}`,course.samples.map(s=>{const right=unit(cross(s.up,s.tangent));return add(s.point,add(scale(right,side*.22+edge*.20),scale(s.up,-.30)))}),'janusite-tack')
      for(let d=0,index=0;d<=course.length;d+=.5,index++){const p=traversalPose(course,d,this.model.stick);path(`janusite-tie-${index}`,[add(p.center,add(scale(p.right,-.46),scale(p.up,-.30))),add(p.center,add(scale(p.right,.46),scale(p.up,-.30)))],'janusite-tie')}
    }
  },
  drawAppliance({path,label,square,button,P,pose,ns,through}){
    const config=this.model.cutaway,state=this.model.traversal,course=state?.course
    const inaugural=this.model.inaugural,compact=!!inaugural&&!inaugural.across
    const faces=cutawayFaces(this.crossingHalf,config.floor_y,config).filter(f=>!compact||f.kind==='front'||f.kind==='approach')
    if(compact){
      const a=[-1.6,-1.2,0],b=[1.6,2,3.2],corners=Array.from({length:8},(_,i)=>[i&1?b[0]:a[0],i&2?b[1]:a[1],i&4?b[2]:a[2]])
      for(const [name,ids] of [['left',[0,2,6,4]],['right',[1,3,7,5]],['back',[4,5,7,6]],['floor',[0,1,5,4]],['ceiling',[2,3,7,6]]])faces.push({id:'compact-'+name,kind:'compact',points:ids.map(i=>corners[i])})
      const panel=path('compact-aperture-panel',[[-3.6,-1.2,0],[3.6,-1.2,0],[3.6,3.6,0],[-3.6,3.6,0]],'cutaway-face inaugural-opaque',null,true)
      const circle=ringPoints([0,0,0],[inaugural.first?.35:1.15,inaugural.first?.35:1.15,0]);panel.setAttribute('d',panel.getAttribute('d')+' '+circle.map((p,i)=>`${i?'L':'M'}${P(p).join(',')}`).join(' ')+' Z');panel.setAttribute('fill-rule','evenodd')
    }
    // A modeled cutaway removes the near wall's central panel, leaving its perimeter.
    for(const face of faces){
      const node=path(face.id,face.points,`cutaway-face cutaway-${face.kind}${compact?' inaugural-opaque':''}`,null,true)
      node.dataset.frame=face.kind==='front'?'appliance-cubical-frame':'local-diorama-cubical-frame'
      const section=!through?.local&&(face.kind==='wall'||(face.kind==='floor'&&Math.sin(radians(this.motion.elevation))>0))
      if(section){
        const center=scale(face.points.reduce((a,b)=>add(a,b),[0,0,0]),1/face.points.length)
        const inner=face.points.map(p=>add(center,scale(p.map((v,k)=>v-center[k]),.89)))
        node.setAttribute('d',node.getAttribute('d')+' '+inner.map((p,i)=>`${i?'L':'M'}${P(p).join(',')}`).join(' ')+' Z');node.setAttribute('fill-rule','evenodd');node.dataset.sectioned='true'
      }
    }
    let defs=this.svg.querySelector('defs')
    if(!defs){defs=document.createElementNS(ns,'defs');this.svg.prepend(defs);defs.innerHTML='<clipPath id="cutaway-envelope-clip"><path/></clipPath>'}
    const hull=convexHull(faces.flatMap(f=>f.points).map(P))
    defs.querySelector('path').setAttribute('d',hull.map((p,i)=>`${i?'L':'M'}${p.join(',')}`).join(' ')+' Z')
    label('appliance-frame-name',[-3.7,4.35,-2],'A / APPLIANCE','appliance-world-label')
    label('diorama-frame-name',[0,3.15,12.9],'B / LOCAL DIORAMA','appliance-world-label')
    if(this.model.wireframe&&!compact){
      // Floor ribs and longitudinal seams are in the same inward frame as the course.
      for(let z=1.2;z<=13;z+=1.5)path(`floor-rib-${z}`,[[-3.6,config.floor_y,z],[3.6,config.floor_y,z]],'cutaway-floor-rib')
      for(const x of [-3.6,0,3.6])path(`floor-seam-${x}`,[[x,config.floor_y,1.2],[x,config.floor_y,13.2]],'cutaway-floor-rib')
    }
    this.el.dataset.crossingHalf=String(this.crossingHalf)
    this.el.dataset.frameCount='2';this.el.dataset.resolutionCount='6'
    const appoint=this.el.querySelector('#appoint-traversal-course'),continuation=this.el.querySelector('#appoint-road-continuation'),issue=this.el.querySelector('#issue-janusite')
    appoint.disabled=!state||state.appointed;continuation.disabled=!state?.appointed||state.continuation_authorized||state.issues.length>=3;issue.disabled=!state?.continuation_authorized
    this.el.querySelector('#pointing-flick-cab').disabled=!this.model.accomplished
    if(!course){this.el.querySelector('#traversal-status').textContent='PULL → PUFF THROUGH → feed THROUGH and release FOR COB.';return}
    const active=state.appointed&&(!this.model.inaugural||this.model.inaugural.across)
    if(active){
      path('nav-course-centerline',course.samples.map(s=>s.point),'nav-course-centerline')
      for(let i=0;i<course.samples.length;i+=8){const sample=course.samples[i],frame={right:unit(cross(sample.up,sample.tangent)),up:sample.up,direction:sample.tangent};path(`nav-course-ring-${i}`,framedRing(sample.point,[course.tube_radius,course.tube_radius,0],'xy',frame).map(p=>{const height=dot(p.map((v,k)=>v-sample.point[k]),sample.up);return height<-.30?add(p,scale(sample.up,-.30-height)):p}),'nav-course-ring')}
      for(const angle of [0,Math.PI/2,Math.PI,Math.PI*1.5])path(`nav-course-rail-${angle}`,course.samples.map(s=>add(s.point,add(scale(unit(cross(s.up,s.tangent)),course.tube_radius*Math.cos(angle)),scale(s.up,Math.max(-.30,course.tube_radius*Math.sin(angle)))))),'nav-course-rail')
      for(const sign of course.signs){
        const local=traversalPose(course,sign.distance,this.model.stick),center=add(local.center,scale(local.right,.68)),bottom=add(center,scale(local.up,-.2)),top=add(center,scale(local.up,.42))
        path(`${sign.id}-post`,[bottom,top],'course-sign-post')
        const quad=[[-1,-1],[1,-1],[1,1],[-1,1]].map(([x,y])=>add(top,add(scale(local.right,x*.42),scale(local.up,y*.17))))
        const panel=button(path(sign.id,quad,'course-sign-panel',null,true),`Official experimental notice: ${sign.title}. Use cab to inspect either face.`)
        panel.dataset.courseSign=sign.id;panel.dataset.authority=sign.authority
        const short={ 'flick-departure-notice':'1 · FLICK', 'banking-notice':'2 · BANK', 'nav-stepping-notice':'3 · NAV', 'seat-approach-notice':'4 · NEXT' };label(`${sign.id}-title`,top,short[sign.id],'course-sign-title').style.fontSize='10px'
      }
    }
    const destination=course.destination,seat=destination.point
    const futureSeat=config.reserved_seat.point
    path('aperture-future-seat-reserve',ringPoints(futureSeat,[.35,0,.35],'xz'),'future-seat-locality')
    const seatMarker=this.nodes.get('aperture-future-seat-reserve');seatMarker.dataset.source='aperture-available';seatMarker.dataset.facing='inward +Z';seatMarker.dataset.status='reserved future Seat WITH COB; not seated'
    path('future-seat-locality',ringPoints(seat,[.48,0,.48],'xz'),'future-seat-locality')
    label('future-seat-reading',add(seat,[0,.65,0]),'NEXT APPROACHINGING LANDINGING','course-sign-title')
    path('flick-departure-locality',ringPoints(course.origin.point,[.3,.3,0],'xy',this.model.stick.direction),'tunnel-entrance')
    if(pose){
      const skate=square('cob-skate-purchase',add(pose.center,scale(pose.up,.65)),.17,'cob-skate-purchase')
      skate.setAttribute('role','slider');skate.setAttribute('tabindex','0');skate.setAttribute('aria-valuemin','0');skate.setAttribute('aria-valuemax','100');skate.setAttribute('aria-valuenow',Math.round(this.navDistance/course.length*100));skate.setAttribute('aria-label','NAV skate along furnished track: arrows, Home, End; no seating or new turn')
      if(this.motion.target){const target=this.model.projection_body.targets.find(t=>t.id===this.motion.target)?.target;if(target)path('through-by-cob-pointing-ray',[pose.tip,target],'through-by-cob-pointing-ray')}
      this.motion.progress=this.navDistance/course.length
      this.el.dataset.skateProgress=String(this.motion.progress);this.el.dataset.navDistance=String(this.navDistance);this.el.dataset.cobPosition=JSON.stringify(pose.center);this.el.dataset.cobDirection=JSON.stringify(pose.direction);this.el.dataset.cobUp=JSON.stringify(pose.up)
    }
    const atStation=course.stations.some(s=>Math.abs(s-this.navDistance)<1e-7)
    this.el.querySelector('#traversal-status').textContent=!active?'Course proposed. Appoint before NAV.':atStation?'At course endpoint / NEXT approaching landinging. No seating or RE-STEP.':`NAV ${this.navDistance.toFixed(1)} / ${course.length.toFixed(1)} · ${this.motion.play?'skating':'paused'} · same turn`
    this.el.querySelector('#janusite-quantity').textContent=`JANUSITE · base + ${state.issues.length} issued · ${course.samples.length} sections · ${course.length.toFixed(1)} units${state.continuation_authorized?' · return loop appointed':''}`
    const reading=this.el.querySelector('#course-sign-reading'),sign=course.signs[this.signIndex]
    reading.hidden=!sign
    if(sign){reading.replaceChildren();const title=document.createElement('strong'),p=document.createElement('p'),small=document.createElement('small');title.textContent=sign.title+(this.signReverse?' / REVERSE':' / FRONT');p.textContent=this.signReverse?sign.reverse:sign.front;small.textContent=sign.authority;reading.append(title,p,small);reading.dataset.sign=sign.id;reading.dataset.reverse=String(this.signReverse)}
    const map=this.el.querySelector('#course-map'),xy=p=>[120+p[0]*24,240-(p[2]+2)*15],make=(tag,attrs,text)=>{const n=document.createElementNS(ns,tag);for(const [k,v] of Object.entries(attrs))n.setAttribute(k,v);if(text)n.textContent=text;map.append(n);return n}
    map.replaceChildren()
    make('rect',{x:34,y:12,width:172,height:228,fill:'#e9e5d7',stroke:'#aa9979'})
    if(active)for(let index=0;index<=state.issues.length;index++){const samples=course.samples.filter((s,i)=>s.issue===index||course.samples[i+1]?.issue===index);make('path',{id:`map-issued-${index}`,d:samples.map((s,i)=>`${i?'L':'M'}${xy(s.point).join(',')}`).join(' '),fill:'none',stroke:index?'#b77e2d':'#51786f','stroke-width':2})}
    for(const [id,p,text,color] of [['map-reserved-seat',futureSeat,'SEAT RESERVE','#80517d'],['map-flick',course.origin.point,'FLICK','#9b793b'],['map-seat',seat,'NEXT LANDING','#976753']]){const [x,y]=xy(p);make('circle',{id,cx:x,cy:y,r:4,fill:color});make('text',{x:x+7,y:y-5,fill:color,'font-size':9},text)}
    if(pose){const p=xy(pose.center),tip=xy(add(pose.center,scale(pose.direction,.65)));make('circle',{id:'map-cob',cx:p[0],cy:p[1],r:5,fill:'#345b48'});make('path',{id:'map-cob-direction',d:`M${p} L${tip}`,stroke:'#345b48','stroke-width':3});const angle=Math.atan2(tip[1]-p[1],tip[0]-p[0]),wing=sign=>[tip[0]-5*Math.cos(angle)+sign*3*Math.sin(angle),tip[1]-5*Math.sin(angle)-sign*3*Math.cos(angle)];make('path',{id:'map-cob-arrowhead',d:`M${wing(-1)} L${tip} L${wing(1)}`,fill:'none',stroke:'#345b48','stroke-width':2});map.dataset.cobPosition=JSON.stringify(pose.center)}
    map.dataset.courseLength=String(course.length);map.dataset.issuedCount=String(state.issues.length)
  },
  updated(){this.read()},
  disconnected(){this.endPurchase();this.drive.velocity=0;this.motion.play=0;this.offline=true;this.pull=null;this.feed=null;this.turning=null;this.pushing=null;this.composing=null;this.unrolling=null;this.opening=this.mechanical?.progress||0;this.detent=this.mechanical?.detent||false;this.draw()},
  reconnected(){this.offline=false;this.pushEvent('abandon-purchase',{})},
  destroyed(){
    this.gone=true;this.el.removeEventListener('focusout',this.purchaseFocusOut);document.removeEventListener('mouseleave',this.pointerExit);if(this.driveFrame)cancelAnimationFrame(this.driveFrame);this.el.removeEventListener('pointerdown',this.purchaseDown);document.removeEventListener('pointermove',this.purchaseMove);document.removeEventListener('pointerup',this.purchaseUp);document.removeEventListener('pointercancel',this.purchaseUp);window.removeEventListener('blur',this.lostFocus);document.removeEventListener('visibilitychange',this.hidden);this.el.removeEventListener('keydown',this.purchaseKey);this.el.removeEventListener('keyup',this.purchaseKey);if(this.skateFrame)cancelAnimationFrame(this.skateFrame);if(this.frame)cancelAnimationFrame(this.frame)
    for(const [name,fn]of[['pointerdown',this.down],['pointermove',this.move],['pointerup',this.up],['pointercancel',this.cancel],['keydown',this.key]])this.svg.removeEventListener(name,fn)
    this.el.removeEventListener('click',this.click)
    this.el.removeEventListener('change',this.earlyChange);this.el.removeEventListener('input',this.earlyChange)
    this.guide.removeEventListener('toggle',this.guideToggle)
  }
}
