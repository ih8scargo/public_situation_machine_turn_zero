const ns='http://www.w3.org/2000/svg'
const sub=(a,b)=>a.map((v,i)=>v-b[i]),add=(a,b)=>a.map((v,i)=>v+b[i]),scale=(a,n)=>a.map(v=>v*n)
const dot=(a,b)=>a.reduce((s,v,i)=>s+v*b[i],0),cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
const unit=a=>scale(a,1/(Math.hypot(...a)||1)),rad=n=>n*Math.PI/180
export function frame(view,turn=0,look=0,elevation=18,orbit=35,zoom=1){
 let eye,forward
 if(view==='within'){const angle=rad(turn*90+look);eye=[0,.65,0];forward=unit([Math.sin(angle)*Math.cos(rad(elevation)),Math.sin(rad(elevation)),-Math.cos(angle)*Math.cos(rad(elevation))])}
 else{eye=[6*Math.sin(rad(orbit)),4,6*Math.cos(rad(orbit))];forward=unit(sub([0,1,0],eye))}
 const right=unit(cross(forward,[0,1,0])),up=unit(cross(right,forward))
 return {view,eye,forward,right,up,zoom}
}
const local=(p,f)=>{const v=sub(p,f.eye);return [dot(v,f.right),dot(v,f.up),dot(v,f.forward)]}
export function clipPolygon(points,near=.04){
 const out=[]
 for(let i=0;i<points.length;i++){const a=points[i],b=points[(i+1)%points.length],inside=a[2]>=near,next=b[2]>=near;if(inside)out.push(a);if(inside!==next){const t=(near-a[2])/(b[2]-a[2]);out.push(add(a,scale(sub(b,a),t)))}}
 return out
}
export function project(point,f){
 if(f.view==='plan')return {point:[500+point[0]*105*f.zoom,325+point[2]*105*f.zoom],depth:-point[1]}
 if(f.view==='section')return {point:[500+point[0]*115*f.zoom,520-point[1]*125*f.zoom],depth:point[2]}
 const [x,y,z]=local(point,f)
 return {point:[500+600*f.zoom*x/Math.max(.04,z),325-600*f.zoom*y/Math.max(.04,z)],depth:z}
}
export function renderRoom(svg,room,f,selected){
 svg.replaceChildren();const shapes=[]
 const addShape=(id,points,kind,color,closed=false,fill='none',bay=null)=>shapes.push({id,points,kind,color,closed,fill,bay,depth:points.reduce((s,p)=>s+project(p,f).depth/points.length,0)})
 for(const panel of room.panels)addShape(panel.id,panel.points,'panel',panel.bay===selected?'#fbbf24':panel.appointed?'#c084fc':panel.available?'#48b7ac':'#52677b',true,'#1c354833',panel.bay)
 room.rings.forEach((r,i)=>addShape(`octagon-${i}`,r,'framework','#d9b65e',true))
 if(room.founding)addShape('inaugural-PITTONING',[[-.15,.005,-.15],[.15,.005,-.15],[.15,.005,.15],[-.15,.005,.15]],'pittoning','#fb7185',true,'#fb718533')
 addShape('spiral-framework',room.spiral,'framework','#d9b65e')
 addShape('HERE',room.here,'here','#cbd5e1',true)
 addShape('standinging-landinging',room.landinging,'here','#5eead4')
 addShape('upper-aperture',room.aperture,'here','#cbd5e1')
 addShape('approach',room.approach,'framework','#8c9eac',true)
 addShape('FOUR',room.measurements.four,'measure','#a78bfa')
 addShape('THREE',room.measurements.three,'measure','#f472b6')
 for(const pair of [...room.pairs,...(room.proposal?[room.proposal]:[])]){
  const candidate=pair.status==='candidate'
  for(const name of ['up_over','ordinary']){
   const c=pair[name],vertices=c.rings.flat(),color=name==='up_over'?'#5eead4':'#fbbf24'
   c.faces.forEach((face,i)=>addShape(`${pair.id}-${name}-surface-${i}`,face.map(i=>vertices[i]),'tube',color,true,candidate?'#a78bfa18':name==='up_over'?'#3abcb82b':'#c9a4432b'))
   c.rings.forEach((ring,i)=>{if(i%8===0)addShape(`${pair.id}-${name}-section-${i}`,ring,'tube-ring',color,true)})
   addShape(`${pair.id}-${name}`,c.centerline,'centerline',color)
  }
  for(const p of pair.planes)addShape(`${pair.id}-${p.id}`,p.points,'upon-plane','#f472b6',true,'#ec489933')
  pair.web.forEach((p,i)=>addShape(`${pair.id}-support-${i}`,p,'support','#d8b4fe',true,'#a78bfa33'))
 }
 // One restrained geometric marker, interpreted through the active office, not two agents.
 const center=room.active?.point||[0,.1,0],r=.035
 const bottom=Array.from({length:8},(_,i)=>add(center,[r*Math.cos(i*Math.PI/4),-.025,r*Math.sin(i*Math.PI/4)]))
 const top=bottom.map(p=>add(p,[0,.05,0]))
 addShape('COB-octagon',top,'cob','#e2e8f0',true,'#dbeafe')
 for(let i=0;i<8;i++)addShape(`COB-body-${i}`,[bottom[i],bottom[(i+1)%8],top[(i+1)%8],top[i]],'cob','#9bb4d0',true,'#6c83a4')
 addShape('COB-cap',[add(center,[-.045,.03,0]),add(center,[.045,.03,0]),add(center,[0,.06,0])],'cob','#f8fafc',true,'#f8fafc')
 addShape('COB-square',[add(center,[-.018,-.015,-r]),add(center,[.018,-.015,-r]),add(center,[.018,.015,-r]),add(center,[-.018,.015,-r])],'cob','#0f172a',true)
 addShape('COB-circle',Array.from({length:25},(_,i)=>add(center,[.025*Math.cos(i*Math.PI/12),-.03,.025*Math.sin(i*Math.PI/12)])),'cob','#e2e8f0')
 shapes.sort((a,b)=>b.depth-a.depth)
 const node=(tag,attrs,text)=>{const el=svg.ownerDocument.createElementNS(ns,tag);for(const[k,v]of Object.entries(attrs))el.setAttribute(k,String(v));if(text!==undefined)el.textContent=text;svg.append(el);return el}
 const screen=(points,closed)=>{
  if(f.view==='plan'||f.view==='section')return points.map(p=>project(p,f).point)
  if(closed)return clipPolygon(points.map(p=>local(p,f))).map(([x,y,z])=>[500+600*f.zoom*x/z,325-600*f.zoom*y/z])
  return points.map(p=>project(p,f).point)
 }
 for(const s of shapes){
  if(!s.closed&&f.view==='within'){
   for(let i=1;i<s.points.length;i++){
    let a=local(s.points[i-1],f),b=local(s.points[i],f);if(a[2]<.04&&b[2]<.04)continue
    if(a[2]<.04||b[2]<.04){const q=add(a,scale(sub(b,a),(.04-a[2])/(b[2]-a[2])));if(a[2]<.04)a=q;else b=q}
    const pts=[a,b].map(([x,y,z])=>[500+600*f.zoom*x/z,325-600*f.zoom*y/z])
    node('polyline',{points:pts.map(p=>p.join(',')).join(' '),fill:'none',stroke:s.color,'stroke-width':s.kind==='centerline'?3:1,'data-wg-object':s.id,class:`wgr-${s.kind}`})
   }
  }else{
   const pts=screen(s.points,s.closed);if(pts.length<2)continue
   node(s.closed?'polygon':'polyline',{points:pts.map(p=>p.join(',')).join(' '),fill:s.fill,stroke:s.color,'stroke-width':s.kind==='centerline'?3:s.kind==='tube'?.3:1.2,'data-wg-object':s.id,'data-bay':s.bay??'',class:`wgr-${s.kind}`})
  }
 }
 node('text',{x:20,y:30,fill:'#dbeafe','font-size':17},`${f.view==='within'?'FROM WITHIN Roundabout Gallery':f.view.toUpperCase()} · shared unitless geometry`)
 svg.dataset.view=f.view;svg.dataset.eye=JSON.stringify(f.eye);svg.dataset.activePoint=JSON.stringify(room.active?.point||null)
}
export const WedgingRoom={
 mounted(){
  this.draw=()=>{const room=JSON.parse(this.el.dataset.room),view=JSON.parse(this.el.dataset.view);renderRoom(this.el.querySelector('svg'),room,frame(view.mode,view.turn,view.look,view.elevation,view.orbit,view.zoom),view.selected)}
  this.click=e=>{const bay=e.target.closest('[data-bay]')?.dataset.bay;if(bay)this.pushEvent('select',{bay})}
  this.el.addEventListener('click',this.click)
  this.exportRef=this.handleEvent('wedging-export',({json})=>{const url=URL.createObjectURL(new Blob([json],{type:'application/json'})),a=this.el.ownerDocument.createElement('a');a.href=url;a.download='wedging-round-two.json';this.el.append(a);a.click();a.remove();URL.revokeObjectURL(url)})
  this.draw()
 },updated(){this.draw()},destroyed(){this.el.removeEventListener('click',this.click);this.removeHandleEvent(this.exportRef)}
}
