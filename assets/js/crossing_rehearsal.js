const add=(a,b)=>a.map((v,i)=>v+b[i]),scale=(a,s)=>a.map(v=>v*s),dot=(a,b)=>a.reduce((n,v,i)=>n+v*b[i],0)
const sub=(a,b)=>a.map((v,i)=>v-b[i]),cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]],unit=a=>scale(a,1/(Math.hypot(...a)||1)),rad=a=>a*Math.PI/180
export function hinge(p,angle){const a=rad(angle);return [p[0],p[1]*Math.cos(a)-p[2]*Math.sin(a),p[1]*Math.sin(a)+p[2]*Math.cos(a)]}
export function pairedGeometry(pull){
 const q=Math.max(0,Math.min(1,pull)),cabinet=45*(1-q),doll=45*q,pin=[0,0,0]
 return {pull:q,cabinet,doll,pin,toes:hinge([0,-2.4,0],doll),body:hinge([0,-1.35,0],doll),innerNormal:hinge([0,0,1],cabinet),dollNormal:hinge([0,0,1],doll),relative:Math.abs(cabinet-doll),aligned:Math.abs(cabinet)<1e-9,
   planes:{monitor:{origin:pin,normal:[0,0,1]},inner:{origin:pin,normal:hinge([0,0,1],cabinet)},cabinet:{origin:pin,normal:hinge([0,0,1],cabinet)},doll:{origin:pin,normal:hinge([0,0,1],doll)},seam:{origin:pin,normal:[1,0,0]},ground:{origin:[0,-2.5,0],normal:[0,1,0]},far:{origin:[0,0,3],normal:[0,0,1]}}}
}
export const convergingPoint=(point,human)=>add(human,scale(sub(point,human),.86))
export function indexedCourse(){
 const words=['THE','PUBLIC','SITUATION','MACHINE'];let index=0
 return words.flatMap(word=>[...word].map((letter,j)=>{const i=index++;let start=null,end=null;if(i<3){start=[-1.4+i,0,0];end=[-.4+i,0,0]}else if(i<9){start=[1.6,0,i-3];end=[1.6,0,i-2]}return {index:i+1,letter,word,wordIndex:j+1,tile:[i%5-2,2-Math.floor(i/5),6],start,end}}))
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
const circle=(center,r,angle=0)=>Array.from({length:65},(_,i)=>add(center,hinge([r*Math.cos(i*Math.PI/32),r*Math.sin(i*Math.PI/32),0],angle)))
const box=(min,max)=>{const v=Array.from({length:8},(_,i)=>[i&1?max[0]:min[0],i&2?max[1]:min[1],i&4?max[2]:min[2]]);return v.flatMap((p,i)=>[1,2,4].filter(b=>(i&b)===0).map(b=>[p,v[i|b]]))}
export const CrossingRehearsal={
 mounted(){
  this.svg=this.el.querySelector('#crossing-scene');this.pull=0;this.feed=0;this.yaw=-30;this.elevation=15;this.slice='all';this.read=()=>{this.model=JSON.parse(this.el.dataset.model);if(!this.drag&&!this.saving){this.pull=this.model.pull;this.feed=this.model.feed}this.draw()}
  this.commit=(action,value)=>{if(this.saving||this.el.dataset.ready!=='true')return;this.saving=true;this.pushEvent('crossing-rehearsal',{action,value,revision:this.model.revision},()=>{this.saving=false;this.read()})}
  this.input=e=>{if(e.target.id==='crossing-pull')this.pull=Number(e.target.value);if(e.target.id==='crossing-feed')this.feed=Number(e.target.value);if(e.target.id==='crossing-yaw')this.yaw=Number(e.target.value);if(e.target.id==='crossing-slice')this.slice=e.target.value;this.draw()}
  this.change=e=>{if(e.target.id==='crossing-pull')this.commit('pull',this.pull);if(e.target.id==='crossing-feed')this.commit('feed',this.feed)}
  this.down=e=>{if(e.target.closest('#crossing-wheel')&&e.button===0){e.preventDefault();this.drag={id:e.pointerId,y:e.clientY,start:this.pull};e.target.setPointerCapture(e.pointerId)}}
  this.move=e=>{if(this.drag?.id===e.pointerId){this.pull=Math.max(0,Math.min(1,this.drag.start+(e.clientY-this.drag.y)/160));this.draw()}}
  this.up=e=>{if(this.drag?.id===e.pointerId){this.drag=null;this.commit('pull',this.pull)}}
  this.key=e=>{if(e.target.id==='crossing-wheel'&&['ArrowUp','ArrowDown','Home','End'].includes(e.key)){e.preventDefault();this.pull=e.key==='Home'?0:e.key==='End'?1:Math.max(0,Math.min(1,this.pull+(e.key==='ArrowDown'?.1:-.1)));this.draw();this.commit('pull',this.pull)}}
  this.click=e=>{const id=e.target.closest('button')?.id;if(id==='crossing-receive')this.commit('receive',1);for(const [name,yaw,elevation] of [['front',0,0],['oblique',-30,15],['ground',0,-75],['side',90,0]])if(id==='crossing-'+name){this.yaw=yaw;this.elevation=elevation}if(id==='crossing-find-seam'){this.slice='seam';this.yaw=90;this.elevation=0}this.draw()}
  for(const [name,fn] of [['input',this.input],['change',this.change],['pointerdown',this.down],['pointermove',this.move],['pointerup',this.up],['pointercancel',this.up],['keydown',this.key],['click',this.click]])this.el.addEventListener(name,fn)
  this.read()
 },
 draw(){
  if(!this.model)return
  const ns='http://www.w3.org/2000/svg',g=pairedGeometry(this.pull),view=p=>projectCrossing(p,this.yaw,this.elevation,this.slice==='ground'?.24:1,this.slice==='ground'?-9:1.5),P=p=>view(p).point,shapes=[],labels=[],plane=g.planes[this.slice]
  const path=(id,points,klass,closed=false)=>{shapes.push({id,points,klass,closed,depth:points.reduce((n,p)=>n+view(p).depth,0)/points.length})}
  const label=(id,p,text)=>labels.push({id,p,text})
  const rect=(x,y,z)=>[[-x,-y,z],[x,-y,z],[x,y,z],[-x,y,z]]
  path('actual-monitor-plane',rect(2.5,2.5,0),'monitor',true);label('monitor-label',[-2.5,2.7,0],'MONITOR · Z=0')
  const cab=rect(2.15,2.15,0).map(p=>hinge(p,g.cabinet));path('projected-cabinet-face',cab,'cabinet',true)
  // Both side courses lie on rays to the same Human point, not arbitrary parallel obliques.
  for(let i=0;i<4;i++){const near=convergingPoint(cab[i],this.model.human);path(`converging-cabinet-${i}`,[near,cab[i]],'convergence');if(i<3)path(`cabinet-side-${i}`,[cab[i],cab[(i+1)%4],convergingPoint(cab[(i+1)%4],this.model.human),near],'cabinet-side',true)}
  const innerCenter=hinge([0,-.5,0],g.cabinet);path('inner-aperture',circle(innerCenter,.55,g.cabinet),'inner');label('inner-label',add(innerCenter,[-.6,.7,0]),'INNER APERTURE')
  path('cabinet-aperture',circle([0,0,0],.9,g.cabinet),'cab-aperture')
  path('square-tab',rect(.2,.2,0).map(p=>add(hinge(p,g.cabinet),hinge([0,-1.2,0],g.cabinet))),'tab',true)
  path('square-tab-hole',circle(hinge([0,-1.2,0],g.cabinet),.08,g.cabinet),'tab-hole')
  const dollPanel=[[-.4,0,0],[.4,0,0],[.4,-2.4,0],[-.4,-2.4,0]].map(p=>hinge(p,g.doll));path('doll-side-aperture',dollPanel,'doll',true)
  path('doll-head-pin',circle(g.pin,.12),'pin');path('doll-body',[g.pin,g.body,g.toes],'doll-body');label('doll-label',add(g.toes,[.45,-.1,0]),'EXISTING DOLL · TOES')
  path('doll-wedge',[[0,0,0],[0,-2.4,0],g.toes],'wedge',true)
  path('looking-through-glass',[[0,-.24,-.24],[0,.24,-.24],[0,.24,.24],[0,-.24,.24]],'glass',true)
  path('pinned-head-seam',[[-.8,0,0],[.8,0,0]],'seam');label('seam-label',[0,.42,0],'SEAM · pinned head [0,0,0]')
  path('doll-toe-arc',Array.from({length:33},(_,i)=>hinge([0,-2.4,0],45*i/32)),'arc')
  box([-2.5,-2.5,0],[2.5,2.5,6]).forEach((p,i)=>path(`framework-${i}`,p,'framework'))
  label('human-reference-label',[0,0,-24],'HUMAN GROUNDWARD · FROM HERE · Z=-24')
  path('human-circular-landinging',circle([0,-2.5,-24],.55,90),'human-ground')
  path('here-approaching-square',rect(.6,.6,0).map(p=>add(p,[-1.5,1.5,0])),'here-square',true);label('here-label',[-1.5,2.3,0],'THIS HERE APPROACHING LANDINGING')
  path('next-approaching-square',rect(.6,.6,0).map(p=>add(p,[1.6,1.5,6])),'next-square',true);label('next-label',[1.6,2.3,6],'THIS NEXT APPROACHING LANDINGING · ACROSS')
  for(const item of indexedCourse()){
   if(item.start){path(`indexed-extent-${item.index}`,[item.start,item.end],item.word==='THE'?'the-course':'public-course');label(`indexed-letter-${item.index}`,add(scale(add(item.start,item.end),.5),[0,.22,0]),`${item.index} ${item.letter}`)}
   const [x,y,z]=item.tile;path(`letter-tile-${item.index}`,rect(.42,.42,0).map(p=>add(p,[x,y,z])),'letter-tile',true);label(`tile-label-${item.index}`,[x,y,z],`${item.index} ${item.letter}`)
  }
  const curve=passage(this.model.stick),full=[...offeredPath(),...curve.slice(1)],count=Math.max(2,Math.round(this.feed*(full.length-1))+1),shown=full.slice(0,count)
  if(this.feed>0||this.model.received){path('pretending-stick-passage',this.model.received?full:shown,'stick');if(this.feed>.34||this.model.received){const swept=sweep(this.model.received?curve:curve.slice(0,Math.max(2,Math.round((this.feed-.34)/.66*(curve.length-1))+1)));for(let i=1;i<swept.length;i++)for(let side=0;side<4;side++)path(`cubical-passage-${i}-${side}`,[swept[i-1].corners[side],swept[i-1].corners[(side+1)%4],swept[i].corners[(side+1)%4],swept[i].corners[side]],'passage-face',true)}
   const tip=(this.model.received?curve:shown).at(-1);const tangent=sweep(this.model.received?curve:shown).at(-1).direction,right=unit(cross([0,1,0],tangent));box([-.23,-.23,-.23],[.23,.23,.23]).forEach((p,i)=>path(`nozzle-cubical-${i}`,p.map(v=>add(tip,add(scale(right,v[0]),add([0,v[1],0],scale(tangent,v[2]))))),'nozzle'));label('nozzle-label',add(tip,[0,-.45,0]),'NOZZLE · MOUNTING-ABLE CUBICAL')}
  const target=this.model.stick?.tip||curve.at(-1),cob=this.model.stick?.cob_center||add(target,[0,.32,0]);path('receiving-cob',circle(cob,.3),'cob',true);path('cob-shoulder',[add(cob,[-.4,0,0]),add(cob,[0,.45,0]),add(cob,[.4,0,0])],'cob');for(const side of [-1,1])path(`cob-grasp-${side}`,[add(cob,[side*.3,0,0]),add(target,[side*(this.model.received?.10:.30),0,0])],'cob-grasp');label('cob-label',add(cob,[.6,.45,0]),this.model.received?'COB RETAINS POINTING-ABLE THING':'COB · RECEIVING LOCALITY')
  this.svg.replaceChildren()
  const node=(tag,attrs,text)=>{const n=document.createElementNS(ns,tag);for(const [k,v]of Object.entries(attrs))n.setAttribute(k,v);if(text)n.textContent=text;this.svg.append(n);return n}
  for(const shape of shapes.sort((a,b)=>b.depth-a.depth)){const d=shape.points.map((p,i)=>`${i?'L':'M'}${P(p).join(',')}`).join(' ')+(shape.closed?' Z':'');node('path',{id:shape.id,d,class:`crossing-${shape.klass}`,opacity:plane?.28:1});if(plane&&shape.points.length>=3){const section=sectionPolygon(shape.points,plane);if(section.length>1)node('path',{id:shape.id+'-section',d:section.map((p,i)=>`${i?'L':'M'}${P(p).join(',')}`).join(' ')+(section.length>2?' Z':''),class:'crossing-section'})}}
  for(const item of labels){const [x,y]=P(item.p);node('text',{id:item.id,x,y,class:'crossing-label','text-anchor':'middle'},item.text)}
  const get=id=>this.el.querySelector('#'+id);get('crossing-pull').value=this.pull;get('crossing-feed').value=this.feed;get('crossing-yaw').value=this.yaw;get('crossing-slice').value=this.slice
  get('crossing-feed').disabled=this.pull<1||this.model.received;get('crossing-receive').disabled=this.pull<1||this.feed<1||this.model.received||this.saving
  get('crossing-status').textContent=this.model.received?'RECEIVED · persistent appointed instrument retained. STOP at reception.':this.pull<1?'Steering pull: cabinet DOWN, Doll UP; head remains pinned.':'Monitor alignment reached. Inspect the SEAM, then furnish the curved passage.'
  get('crossing-coordinates').textContent=`Slice: ${this.slice}\nCabinet ${g.cabinet.toFixed(2)}° / Doll ${g.doll.toFixed(2)}°\nRelative angle ${g.relative.toFixed(2)}°\nHuman: [0, 0, -24] FROM HERE\nPin: [0, 0, 0] (invariant)\nToes: [${g.toes.map(v=>v.toFixed(3)).join(', ')}]\nInner normal: [${g.innerNormal.map(v=>v.toFixed(3)).join(', ')}]\nMonitor aligned: ${g.aligned}\nTHE → PUBLIC: corner [1.6,0,0], 90°\n${this.model.stick&&!this.model.stick.curve?'Existing held course retained; corner coupling unresolved':'Arc tangent axes meet that corner'}\nCraft seating: UNRESOLVED`
  get('crossing-doll-duty').textContent=`${this.model.doll.name}: non-agentive; retains ${this.model.doll.duties.join(' and ')}. No second Human.`
  this.el.dataset.geometry=JSON.stringify(g);this.el.dataset.received=String(this.model.received);this.el.dataset.slice=this.slice;this.el.dataset.stick=JSON.stringify(this.model.stick);get('crossing-wheel').style.transform=`translateY(${this.pull*12}px) rotate(${this.pull*35}deg)`
 },
 updated(){this.read()},
 destroyed(){for(const [name,fn]of [['input',this.input],['change',this.change],['pointerdown',this.down],['pointermove',this.move],['pointerup',this.up],['pointercancel',this.up],['keydown',this.key],['click',this.click]])this.el.removeEventListener(name,fn)}
}
