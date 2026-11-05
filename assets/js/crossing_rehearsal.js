import {assemblePanels, panelInventory, rectangle, dollStock} from './panel_assembly.js'
const add=(a,b)=>a.map((v,i)=>v+b[i]),scale=(a,s)=>a.map(v=>v*s),dot=(a,b)=>a.reduce((n,v,i)=>n+v*b[i],0)
const sub=(a,b)=>a.map((v,i)=>v-b[i]),cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]],unit=a=>scale(a,1/(Math.hypot(...a)||1)),rad=a=>a*Math.PI/180
export function hinge(p,angle){const a=rad(angle);return [p[0],p[1]*Math.cos(a)-p[2]*Math.sin(a),p[1]*Math.sin(a)+p[2]*Math.cos(a)]}
export function pairedGeometry(pull,reference){
 const q=Math.max(0,Math.min(1,pull)),cabinet=45*(1-q),doll=45*q,pin=reference?.head_purchase||[0,0,0]
 return {pull:q,cabinet,doll,pin,toes:hinge([0,-2.4,0],doll),body:hinge([0,-1.35,0],doll),innerNormal:hinge([0,0,1],cabinet),dollNormal:hinge([0,0,1],doll),relative:Math.abs(cabinet-doll),aligned:Math.abs(cabinet)<1e-9,
   planes:{monitor:reference?.monitor||{origin:pin,normal:[0,0,1]},inner:{origin:pin,normal:hinge([0,0,1],cabinet)},cabinet:{origin:pin,normal:hinge([0,0,1],cabinet)},doll:{origin:pin,normal:hinge([0,0,1],doll)},seam:{origin:pin,normal:[1,0,0]},ground:reference?.ground||{origin:[0,-2.5,0],normal:[0,1,0]},far:{origin:[0,0,3],normal:[0,0,1]}}}
}
export const convergingPoint=(point,human)=>add(human,scale(sub(point,human),.86))
export function indexedCourse(){
 const words=['THE','PUBLIC','SITUATION','MACHINE'];let index=0
 return words.flatMap(word=>[...word].map((letter,j)=>{const i=index++;let start=null,end=null;if(i<3){start=[-1.4+i,0,0];end=[-.4+i,0,0]}else if(i<9){start=[1.6,0,i-3];end=[1.6,0,i-2]}return {index:i+1,letter,word,wordIndex:j+1,tile:[i%5-2,2-Math.floor(i/5),6],start,end}}))
}
// Interpolate the domain-supplied inscription; no camera or receipt writes.
export function inscriptionPose(resolution,purchase){
 const p=Math.max(0,Math.min(resolution.letters.length,Number(purchase)||0)),letterIndex=Math.max(0,Math.ceil(p)-1),letter=resolution.letters[letterIndex]
 const local=p-letterIndex,scaled=local*(letter.samples.length-1),i=Math.min(letter.samples.length-2,Math.floor(scaled)),f=scaled-i
 const point=letter.samples[i].point.map((v,axis)=>v+(letter.samples[i+1].point[axis]-v)*f)
 const relations=resolution.relations.filter(r=>letter.relations.includes(r.id))
 const twist=Math.abs(p-resolution.twist.purchase)<1e-8,end=p===resolution.letters.length
 const reading=end?resolution.end_bearing:twist?'N in SITUATION · twist purchase; physical twist unresolved':relations.map(r=>r.bearing).filter(Boolean).join(' / ')
 return {purchase:p,letter,point,relations,twist,end,reading}
}
export function passage(stick=null){
 if(stick?.curve?.samples)return stick.curve.samples.map(p=>[...p])
 if(stick){const tip=stick.tip,dir=stick.direction;return Array.from({length:65},(_,i)=>{const t=i/64,u=1-t;return add(scale([.8,0,0],3*u*u*t),add(scale(sub(tip,scale(dir,.8)),3*u*t*t),scale(tip,t*t*t)))})}
 return Array.from({length:65},(_,i)=>{const a=i*Math.PI/128;return [1.6*Math.sin(a),0,1.6*(1-Math.cos(a))]})
}
export function offeredPath(){return Array.from({length:33},(_,i)=>{const t=i/32,u=1-t;return add(scale([0,0,-2],u*u*u),add(scale([0,0,-.8],3*u*u*t),scale([-.65,0,0],3*u*t*t)))})}
export function sweep(points,half=.16){return points.map((p,i)=>{const direction=unit(sub(points[Math.min(i+1,points.length-1)],points[Math.max(0,i-1)])),up=[0,1,0],right=unit(cross(up,direction));return {center:p,direction,corners:[[-1,-1],[1,-1],[1,1],[-1,1]].map(([x,y])=>add(p,add(scale(right,x*half),scale(up,y*half))))}})}
export function sectionPolygon(points,plane){const result=[];for(let i=0;i<points.length;i++){const a=points[i],b=points[(i+1)%points.length],da=dot(sub(a,plane.origin),plane.normal),db=dot(sub(b,plane.origin),plane.normal);if(Math.abs(da)<1e-8)result.push(a);if(da*db<0)result.push(add(a,scale(sub(b,a),da/(da-db))))}return result.filter((p,i)=>!result.slice(0,i).some(q=>Math.hypot(...sub(p,q))<1e-7))}
export function projectCrossing(p,yaw=-30,elevation=15,zoom=1,centerZ=1.5){const a=rad(yaw),b=rad(elevation),x=p[0],y=p[1]+.7,z=p[2]-centerZ,xx=x*Math.cos(a)+z*Math.sin(a),zz=-x*Math.sin(a)+z*Math.cos(a),yy=y*Math.cos(b)-zz*Math.sin(b),depth=y*Math.sin(b)+zz*Math.cos(b),k=64/(64+depth);return {point:[550+xx*95*k*zoom,530-yy*95*k*zoom],depth}}
// Located Regards transform the view only; all source points retain their standing.
export function locatedRegard(kind,pin=[0,0,0],yaw=0){
 const origin=add(pin,kind==='cab'?[-1.2,0,0]:[-1.1,.9,-1.1])
 const forward=kind==='cab'?[1,0,0]:unit(sub(add(pin,[1.6,0,1.6]),origin))
 const a=rad(yaw),direction=[forward[0]*Math.cos(a)+forward[2]*Math.sin(a),forward[1],-forward[0]*Math.sin(a)+forward[2]*Math.cos(a)]
 const right=unit(cross(direction,[0,1,0])),up=unit(cross(right,direction))
 return {kind,origin,direction,right,up,purchase:[...pin]}
}
export function projectLocated(p,frame){
 const relative=sub(p,frame.origin),depth=dot(relative,frame.direction)
 return {point:[550+520*dot(relative,frame.right)/Math.max(.08,depth),500-520*dot(relative,frame.up)/Math.max(.08,depth)],depth}
}
export function locatedPath(points,view,closed=false,near=.08){
 const intersection=(a,b)=>{const da=view(a).depth,db=view(b).depth;return add(a,scale(sub(b,a),(near-da)/(db-da)))}
 const draw=list=>list.map((p,i)=>`${i?'L':'M'}${view(p).point.join(',')}`).join(' ')
 if(closed){let clipped=[];for(let i=0;i<points.length;i++){const a=points[(i+points.length-1)%points.length],b=points[i],insideA=view(a).depth>=near,insideB=view(b).depth>=near;if(insideA!==insideB)clipped.push(intersection(a,b));if(insideB)clipped.push(b)}return clipped.length>2?draw(clipped)+' Z':''}
 const parts=[];for(let i=1;i<points.length;i++){let a=points[i-1],b=points[i],insideA=view(a).depth>=near,insideB=view(b).depth>=near;if(!insideA&&!insideB)continue;if(!insideA)a=intersection(a,b);else if(!insideB)b=intersection(a,b);parts.push(draw([a,b]))}return parts.join(' ')
}
const circle=(center,r,angle=0)=>Array.from({length:65},(_,i)=>add(center,hinge([r*Math.cos(i*Math.PI/32),r*Math.sin(i*Math.PI/32),0],angle)))
const box=(min,max)=>{const v=Array.from({length:8},(_,i)=>[i&1?max[0]:min[0],i&2?max[1]:min[1],i&4?max[2]:min[2]]);return v.flatMap((p,i)=>[1,2,4].filter(b=>(i&b)===0).map(b=>[p,v[i|b]]))}
export const CrossingRehearsal={
 mounted(){
  this.svg=this.el.querySelector('#crossing-scene');this.pull=0;this.feed=0;this.yaw=-30;this.elevation=15;this.slice='all';this.regard='inspection';this.locatedYaw=0;this.replayFeed=null;this.inscriptionPurchase=0;this.assemblyView='existing';this.panelCabinet=45;this.panelDoll=0;this.read=()=>{this.model=JSON.parse(this.el.dataset.model);if(!this.drag&&!this.saving){this.pull=this.model.pull;this.feed=this.model.feed}this.draw()}
  this.commit=(action,value)=>{if(this.saving||this.el.dataset.ready!=='true')return;this.saving=true;this.pushEvent('crossing-rehearsal',{action,value,revision:this.model.revision},()=>{this.saving=false;this.read()})}
  this.input=e=>{if(e.target.id==='panel-view')this.assemblyView=e.target.value;if(e.target.id==='panel-cabinet')this.panelCabinet=Number(e.target.value);if(e.target.id==='panel-doll')this.panelDoll=Number(e.target.value);if(e.target.id==='crossing-inscription')this.inscriptionPurchase=Number(e.target.value);if(e.target.id==='crossing-pull')this.pull=Number(e.target.value);if(e.target.id==='crossing-feed'){if(this.model.received)this.replayFeed=Number(e.target.value);else this.feed=Number(e.target.value)};if(e.target.id==='crossing-yaw'){if(this.regard==='inspection')this.yaw=Number(e.target.value);else this.locatedYaw=Number(e.target.value)};if(e.target.id==='crossing-slice'){this.regard='inspection';this.slice=e.target.value};this.draw()}
  this.change=e=>{if(e.target.id==='crossing-pull')this.commit('pull',this.pull);if(e.target.id==='crossing-feed'&&!this.model.received)this.commit('feed',this.feed)}
  this.down=e=>{if(e.target.closest('#crossing-wheel')&&e.button===0){e.preventDefault();this.drag={id:e.pointerId,y:e.clientY,start:this.pull};e.target.setPointerCapture(e.pointerId)}}
  this.move=e=>{if(this.drag?.id===e.pointerId){this.pull=Math.max(0,Math.min(1,this.drag.start+(e.clientY-this.drag.y)/160));this.draw()}}
  this.up=e=>{if(this.drag?.id===e.pointerId){this.drag=null;this.commit('pull',this.pull)}}
  this.key=e=>{if(e.target.id==='crossing-wheel'&&['ArrowUp','ArrowDown','Home','End'].includes(e.key)){e.preventDefault();this.pull=e.key==='Home'?0:e.key==='End'?1:Math.max(0,Math.min(1,this.pull+(e.key==='ArrowDown'?.1:-.1)));this.draw();this.commit('pull',this.pull)}}
  this.click=e=>{const id=e.target.closest('button')?.id;if(id==='panel-reset'){this.panelCabinet=45;this.panelDoll=0}if(id==='panel-match'){this.panelCabinet=45*(1-this.pull);this.panelDoll=45*this.pull}if(id==='crossing-replay')this.replayFeed=0;if(id==='crossing-present')this.replayFeed=null;if(id==='crossing-receive')this.commit('receive',1);if(id==='crossing-cab'||id==='crossing-alongside'){this.regard=id==='crossing-cab'?'cab':'alongside';this.locatedYaw=0;this.slice='all'}if(id==='crossing-inspection')this.regard='inspection';for(const [name,yaw,elevation] of [['front',0,0],['oblique',-30,15],['ground',0,-75],['side',90,0]])if(id==='crossing-'+name){this.regard='inspection';this.yaw=yaw;this.elevation=elevation}if(id==='crossing-find-seam'){this.regard='inspection';this.slice='seam';this.yaw=90;this.elevation=0}this.draw()}
  for(const [name,fn] of [['input',this.input],['change',this.change],['pointerdown',this.down],['pointermove',this.move],['pointerup',this.up],['pointercancel',this.up],['keydown',this.key],['click',this.click]])this.el.addEventListener(name,fn)
  this.read()
 },
 draw(){
  if(!this.model)return
  const ns='http://www.w3.org/2000/svg',g=pairedGeometry(this.pull,this.model.operating_reference),frame=this.regard==='inspection'?null:locatedRegard(this.regard,g.pin,this.locatedYaw),view=p=>frame?projectLocated(p,frame):projectCrossing(p,this.yaw,this.elevation,1,1.5),P=p=>view(p).point,shapes=[],labels=[],plane=frame?null:g.planes[this.slice]
  const path=(id,points,klass,closed=false)=>{shapes.push({id,points,klass,closed,depth:points.reduce((n,p)=>n+view(p).depth,0)/points.length})}
  const label=(id,p,text)=>labels.push({id,p,text})
  const rect=rectangle
  path('actual-monitor-plane',rect(2.5,2.5,0),'monitor',true);label('monitor-label',[-2.5,2.7,0],'MONITOR · Z=0')
  const cab=rect(2.15,2.15,0).map(p=>hinge(p,g.cabinet));path('projected-cabinet-face',cab,'cabinet',true)
  // The outward cabinet extent belongs to the appliance, not a measured CH distance.
  const reference=this.model.operating_reference,front=rect(2.5,2.5,reference.cabinet_front_z)
  path('cabinet-outward-front',front,'cabinet',true)
  for(let i=0;i<4;i++){path(`converging-cabinet-${i}`,[front[i],cab[i]],'convergence');path(`cabinet-side-${i}`,[front[i],front[(i+1)%4],cab[(i+1)%4],cab[i]],'cabinet-side',true)}
  path('cabinet-outward-extent',[[2.7,-2.5,reference.cabinet_front_z],[2.7,-2.5,0]],'convergence')
  label('cabinet-extent-label',[2.7,-2.8,-1.5],'OUTWARD EXTENT · 3')
  const innerCenter=hinge([0,-.5,0],g.cabinet);path('inner-aperture',circle(innerCenter,.55,g.cabinet),'inner');label('inner-label',add(innerCenter,[-.6,.7,0]),'INNER APERTURE')
  path('cabinet-aperture',circle([0,0,0],.9,g.cabinet),'cab-aperture')
  path('square-tab',rect(.2,.2,0).map(p=>add(hinge(p,g.cabinet),hinge([0,-1.2,0],g.cabinet))),'tab',true)
  path('square-tab-hole',circle(hinge([0,-1.2,0],g.cabinet),.08,g.cabinet),'tab-hole')
  const dollPanel=dollStock().map(p=>hinge(p,g.doll));path('doll-side-aperture',dollPanel,'doll',true)
  path('doll-head-pin',circle(g.pin,.12),'pin');path('doll-body',[g.pin,g.body,g.toes],'doll-body');label('doll-label',add(g.toes,[.45,-.1,0]),'EXISTING DOLL · TOES')
  path('doll-wedge',[[0,0,0],[0,-2.4,0],g.toes],'wedge',true)
  path('looking-through-glass',[[0,-.24,-.24],[0,.24,-.24],[0,.24,.24],[0,-.24,.24]],'glass',true)
  path('pinned-head-seam',[[-.8,0,0],[.8,0,0]],'seam');label('seam-label',[0,.42,0],'SEAM · pinned head [0,0,0]')
  path('doll-toe-arc',Array.from({length:33},(_,i)=>hinge([0,-2.4,0],45*i/32)),'arc')
  box([-2.5,-2.5,0],[2.5,2.5,6]).forEach((p,i)=>path(`framework-${i}`,p,'framework'))
  path('here-approaching-square',reference.here_square,'here-square',true)
  label('here-label',[0,-2.8,-1.5],'HERE · GROUND SQUARE / COMPUTERING LOCALITY')
  path('ground-monitor-reference',[[0,-2.5,-3],[0,-2.5,0],[0,0,0]],'human-ground')
  label('human-reference-label',[-2.5,-2.9,-3],'CH PLACE · RUGGING DISTINCT FROM SL')
  label('reference-right-angle',[0,-2.25,0],'GROUND / MONITOR · 90°')
  path('next-approaching-square',rect(.6,.6,0).map(p=>add(p,[1.6,1.5,6])),'next-square',true);label('next-label',[1.6,2.3,6],'THIS NEXT APPROACHING LANDINGING · ACROSS')
  for(const item of indexedCourse()){
   if(item.start&&!this.model.inscription_resolution){path(`indexed-extent-${item.index}`,[item.start,item.end],item.word==='THE'?'the-course':'public-course');label(`indexed-letter-${item.index}`,add(scale(add(item.start,item.end),.5),[0,.22,0]),`${item.index} ${item.letter}`)}
   const [x,y,z]=item.tile;path(`letter-tile-${item.index}`,rect(.42,.42,0).map(p=>add(p,[x,y,z])),'letter-tile',true);label(`tile-label-${item.index}`,[x,y,z],`${item.index} ${item.letter}`)
  }
  const resolution=this.model.inscription_resolution
  if(resolution){
   for(const letter of resolution.letters){
    path(letter.id+'-course',letter.samples.map(s=>s.point),'resolution-course')
    const middle=letter.samples[Math.floor(letter.samples.length/2)]
    label(letter.id+'-label',add(middle.point,scale(sub(middle.edges[1],middle.point),2)),letter.letter)
    if(letter.relations.includes('public-situation-face'))for(let i=1;i<letter.samples.length;i++){
     const a=letter.samples[i-1],b=letter.samples[i]
     path(letter.id+'-face-'+i,[a.edges[0],a.edges[1],b.edges[1],b.edges[0]],'resolution-face',true)
    }
   }
   const n=resolution.letters.find(l=>l.id===resolution.twist.letter_id).samples.at(-1).point
   path('inscription-n-twist',circle(n,.12),'resolution-twist',true)
   label('inscription-n-label',add(n,[0,.3,0]),'N · TWIST PURCHASE')
   const pose=inscriptionPose(resolution,this.inscriptionPurchase)
   path('inscription-purchase',circle(pose.point,.07),'resolution-purchase',true)
   this.el.dataset.inscriptionPurchase=String(pose.purchase)
   const range=this.el.querySelector('#crossing-inscription'),status=this.el.querySelector('#crossing-inscription-status')
   range.value=pose.purchase;status.textContent=`${pose.letter.word} · ${pose.reading}`
  }
  const replaying=this.model.received&&this.replayFeed!==null,displayFeed=replaying?this.replayFeed:this.feed
  const curve=passage(this.model.stick),full=[...offeredPath(),...curve.slice(1)],count=Math.max(2,Math.round(displayFeed*(full.length-1))+1),shown=full.slice(0,count)
  // An inspection envelope discloses the entrance and curvature even before feed.
  // It does not furnish a new road, BY-WAY-OF or consequential passage.
  const envelope=sweep(curve.filter((_,i)=>i%4===0||i===curve.length-1),.55)
  for(let i=1;i<envelope.length;i++)for(let side=0;side<4;side++)path(`entrance-wall-${i}-${side}`,[envelope[i-1].corners[side],envelope[i-1].corners[(side+1)%4],envelope[i].corners[(side+1)%4],envelope[i].corners[side]],'entrance-wall',true)
  path('entrance-mouth',envelope[0].corners,'glass',true)
  label('entrance-label',[0,.72,0],'ENTRANCE · XT 3 TOWARD XT 6')
  label('extent-label',add(curve.at(-1),[0,.72,0]),'CURVED EXTENT · REGISTRATION FOR REVIEW')
  if(replaying)path('appointed-stick-retained',full,'retained-stick')
  if(displayFeed>0){path('pretending-stick-passage',replaying?shown:this.model.received?full:shown,'stick');if(displayFeed>.34){const swept=sweep(this.model.received&&!replaying?curve:curve.slice(0,Math.max(2,Math.round((displayFeed-.34)/.66*(curve.length-1))+1)));for(let i=1;i<swept.length;i++)for(let side=0;side<4;side++)path(`cubical-passage-${i}-${side}`,[swept[i-1].corners[side],swept[i-1].corners[(side+1)%4],swept[i].corners[(side+1)%4],swept[i].corners[side]],'passage-face',true)}
   const tip=(this.model.received&&!replaying?curve:shown).at(-1);const tangent=sweep(this.model.received&&!replaying?curve:shown).at(-1).direction,right=unit(cross([0,1,0],tangent));box([-.23,-.23,-.23],[.23,.23,.23]).forEach((p,i)=>path(`nozzle-cubical-${i}`,p.map(v=>add(tip,add(scale(right,v[0]),add([0,v[1],0],scale(tangent,v[2]))))),'nozzle'));label('nozzle-label',add(tip,[0,-.45,0]),'NOZZLE · MOUNTING-ABLE CUBICAL')}
  const target=this.model.stick?.tip||curve.at(-1),cob=this.model.stick?.cob_center||add(target,[0,.32,0]);path('receiving-cob',circle(cob,.3),'cob',true);path('cob-shoulder',[add(cob,[-.4,0,0]),add(cob,[0,.45,0]),add(cob,[.4,0,0])],'cob');for(const side of [-1,1])path(`cob-grasp-${side}`,[add(cob,[side*.3,0,0]),add(target,[side*(this.model.received?.10:.30),0,0])],'cob-grasp');label('cob-label',add(cob,[.6,.45,0]),this.model.received?'COB RETAINS POINTING-ABLE THING':'COB · RECEIVING LOCALITY')
  path('offered-craft-seat',[[-.45,-.35,-.35],[.45,-.35,-.35],[.45,-.35,.35],[-.45,-.35,.35]].map(p=>add(cob,p)),'offered-seat',true)
  label('offered-craft-label',add(cob,[0,-.62,0]),'CRAFT / SEAT · OFFERED REFERENCE')
  const assembly=assemblePanels(reference,this.panelCabinet,this.panelDoll)
  if(this.assemblyView==='panels'){shapes.length=0;labels.length=0}
  if(this.assemblyView!=='existing'){
   for(const panel of assembly.panels){path('assembled-'+panel.id,panel.points,'assembly-'+(panel.id==='doll'?'doll':'panel'),true);label('assembled-'+panel.id+'-label',scale(panel.points.reduce((a,p)=>add(a,p),[0,0,0]),1/panel.points.length),panel.id.toUpperCase())}
   path('assembled-hinge',assembly.hinge,'assembly-hinge');label('assembled-hinge-label',[0,.35,0],'HEAD AXIS · TRIAL HINGE')
   path('assembled-inner-aperture',circle(assembly.innerCenter,.55,assembly.cabinet),'inner')
   path('assembled-cabinet-aperture',circle([0,0,0],.9,assembly.cabinet),'cab-aperture')
  }
  const observations=assembly.observations
  this.el.querySelector('#panel-observations').textContent=`Cabinet fold: ${assembly.cabinet.toFixed(1)}° / Doll fold: ${assembly.doll.toFixed(1)}°\nPanel plane angle: ${observations.planeAngle.toFixed(2)}° · ${observations.coincident?'COPLANAR':'distinct planes'}\nCabinet aligned with monitor: ${observations.monitorAligned}\nDoll top edge / cabinet interior axis: fixed at Y=0 / Z=0\nInner aperture center to head: ${observations.apertureCenterOffset.toFixed(2)}\nInner aperture wholly inside cabinet opening: ${observations.innerWithinCabinet}\nAssumed Glass/nozzle margin per side: ${observations.glassNozzleMargin.toFixed(2)}\nSix planar panels; no side enclosure inferred. Rigid linkage and swept clearance remain unproved.`
  this.el.querySelector('#panel-inventory').textContent=panelInventory.map(p=>`${p.name} · ${p.size} · ${p.source}`).join('\n')
  this.el.querySelector('#panel-cabinet').value=this.panelCabinet
  this.el.querySelector('#panel-doll').value=this.panelDoll
  this.el.dataset.panelAssembly=JSON.stringify(assembly)
  this.svg.replaceChildren()
  const node=(tag,attrs,text)=>{const n=document.createElementNS(ns,tag);for(const [k,v]of Object.entries(attrs))n.setAttribute(k,v);if(text)n.textContent=text;this.svg.append(n);return n}
  for(const shape of shapes.sort((a,b)=>b.depth-a.depth)){
   const d=frame?locatedPath(shape.points,view,shape.closed):shape.points.map((p,i)=>`${i?'L':'M'}${P(p).join(',')}`).join(' ')+(shape.closed?' Z':'')
   if(d)node('path',{id:shape.id,d,class:`crossing-${shape.klass}`,opacity:plane?.28:1,'data-world-points':JSON.stringify(shape.points)})
   if(plane&&shape.points.length>=3){const section=sectionPolygon(shape.points,plane);if(section.length>1)node('path',{id:shape.id+'-section',d:section.map((p,i)=>`${i?'L':'M'}${P(p).join(',')}`).join(' ')+(section.length>2?' Z':''),class:'crossing-section'})}
  }
  for(const item of labels){if(frame&&view(item.p).depth<.08)continue;const [x,y]=P(item.p);node('text',{id:item.id,x,y,class:'crossing-label','text-anchor':'middle'},item.text)}
  const get=id=>this.el.querySelector('#'+id);get('crossing-pull').value=this.pull;get('crossing-feed').value=displayFeed;get('crossing-yaw').value=frame?this.locatedYaw:this.yaw;get('crossing-slice').value=this.slice
  get('crossing-feed').disabled=!this.model.received&&this.pull<1;get('crossing-receive').disabled=this.pull<1||this.feed<1||this.model.received||this.saving
  get('crossing-replay').hidden=!this.model.received;get('crossing-present').hidden=!replaying;get('crossing-feed-label').textContent=this.model.received?'Re-enact the appointmenting journey · COB retains the received stick':'Offer Pretendinging Stick THROUGH the pinned-head aperture';this.el.dataset.replay=replaying?String(displayFeed):'present';
  get('crossing-status').textContent=this.model.received?(replaying?'RE-ENACTING · the recorded appointmenting stands. Dashed course: retained instrument.':'RECEIVED · COB retains the stick. Re-enact its journey freely; appointmenting remains recorded.'):this.pull<1?'Steering pull: cabinet DOWN, Doll UP; head remains pinned.':'Monitor alignment reached. Inspect the SEAM, then furnish the curved passage.'
  get('crossing-coordinates').textContent=`Slice: ${this.slice}\nCabinet ${g.cabinet.toFixed(2)}° / Doll ${g.doll.toFixed(2)}°\nRelative angle ${g.relative.toFixed(2)}°\nTC: ordinary operating locality; no measured CH distance\nGround / monitor: 90°\nCabinet outward extent: 3\nPin: [0, 0, 0] (invariant)\nToes: [${g.toes.map(v=>v.toFixed(3)).join(', ')}]\nInner normal: [${g.innerNormal.map(v=>v.toFixed(3)).join(', ')}]\nMonitor aligned: ${g.aligned}\nTHE → PUBLIC: corner [1.6,0,0], 90°\n${this.model.stick&&!this.model.stick.curve?'Existing held course retained; corner coupling unresolved':'Arc tangent axes meet that corner'}\nCraft seating: UNRESOLVED`
  get('crossing-regard-status').textContent=this.regard==='cab'?'FROM WITHIN THE CAB · toward the wall THROUGH the Doll-head Glass':this.regard==='alongside'?'ALONGSIDE WITH THE DOLL · over the traversaling seat toward the offered craft':'EXTERNAL INSPECTION · transverse sections';for(const kind of ['cab','alongside','inspection'])get('crossing-'+kind).setAttribute('aria-pressed',String(this.regard===kind));this.el.dataset.regard=this.regard;this.el.dataset.frame=JSON.stringify(frame);
  get('crossing-doll-duty').textContent=`${this.model.doll.name}: non-agentive; retains ${this.model.doll.duties.join(' and ')}. No second Human.`
  this.el.dataset.geometry=JSON.stringify(g);this.el.dataset.received=String(this.model.received);this.el.dataset.slice=this.slice;this.el.dataset.stick=JSON.stringify(this.model.stick);get('crossing-wheel').style.transform=`translateY(${this.pull*12}px) rotate(${this.pull*35}deg)`
 },
 updated(){this.read()},
 destroyed(){for(const [name,fn]of [['input',this.input],['change',this.change],['pointerdown',this.down],['pointermove',this.move],['pointerup',this.up],['pointercancel',this.up],['keydown',this.key],['click',this.click]])this.el.removeEventListener(name,fn)}
}
