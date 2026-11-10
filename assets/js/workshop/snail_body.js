import {inspectionFrame} from './regarding_stands.js'
import {frame,project,clipPolygon} from './wedging_room.js'
const NS='http://www.w3.org/2000/svg'
const sub=(a,b)=>a.map((v,i)=>v-b[i]), add=(a,b)=>a.map((v,i)=>v+b[i]), scale=(a,n)=>a.map(v=>v*n)
const dot=(a,b)=>a.reduce((s,v,i)=>s+v*b[i],0),cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
const unit=a=>scale(a,1/(Math.hypot(...a)||1)),display=p=>[p[0]*.72,(p[1]+2)*.72,p[2]*.72]
export function bodyFrame(model,view){
 const f=frame(view==='reverse'?'external':view,0,0,0,view==='reverse'?-130:35,1.3)
 if(view==='external'||view==='reverse'){const angle=(view==='reverse'?-130:35)*Math.PI/180;f.eye=[4.3*Math.sin(angle),2.8,4.3*Math.cos(angle)];f.forward=unit(sub([0,.5,0],f.eye));f.right=unit(cross(f.forward,[0,1,0]));f.up=unit(cross(f.right,f.forward))}
 if(model.projection_relay&&(view==='external'||view==='reverse')){f.eye=[7,5,9];f.forward=unit(sub([0,.8,1.6],f.eye));f.right=unit(cross(f.forward,[0,1,0]));f.up=unit(cross(f.right,f.forward));f.zoom=1.5}
 if(model.projection_relay&&model.interface?.mode==='across'&&view==='external'){const r=model.interface.radial||[1,0,0],t=[-r[2],0,r[0]];f.eye=[-7*r[0]-9*t[0],5,-7*r[2]-9*t[2]];f.forward=unit(sub([0,.8,1.6],f.eye));f.right=unit(cross(f.forward,[0,1,0]));f.up=unit(cross(f.right,f.forward))}
 if(view==='within'||view==='ceiling'){
  f.eye=display(model.within_eye);f.forward=view==='ceiling'?[0,1,0]:unit(sub(display(model.within_toward),f.eye))
  // Radial direction is a stable camera-up reference, including a downward look.
  const q=model.fold.quarter*Math.PI/2,up=[Math.cos(q),0,Math.sin(q)]
  f.right=unit(cross(f.forward,up));f.up=unit(cross(f.right,f.forward))
 }
 if(model.emergence&&['contraption','volume','within','groundward'].includes(view)){
  const e=model.emergence
  if(view==='contraption'){f.eye=[2,2,3];f.forward=unit(sub(display([0,-.9,0]),f.eye));f.right=unit(cross(f.forward,[0,1,0]));f.up=unit(cross(f.right,f.forward));f.zoom=1.35}
  if(view==='volume'||view==='within'){const angle=e.regard.quarter_turn*Math.PI/180;f.eye=display(e.registration.revised_eye);f.forward=[0,-Math.sin(angle),Math.cos(angle)];const r=e.regard.reading_right;f.right=unit(sub(r,scale(f.forward,dot(r,f.forward))));f.up=unit(cross(f.right,f.forward));f.zoom=.45+.75*e.regard.quarter_turn/90}
  if(view==='groundward'){const a=e.registration.revised_aperture,n=unit(sub([0,0,0],a));f.eye=display(sub(a,scale(n,.12)));f.forward=n;f.right=[0,0,1];f.up=unit(cross(f.right,f.forward));f.zoom=.8}
 }
 return f
}
export function renderBody(svg,model,view,showInstrument=true,options={}){
 const source=model
 const emergenceView=model.emergence&&['contraption','volume','within','groundward'].includes(view)
 if(emergenceView)model={...model,...model.emergence.presentation}
 if(view==='flat'&&model.near_monitor&&!options.inspection){renderMonitor(svg,model);return}
 svg.replaceChildren()
 const base=bodyFrame(model,view)
 const worldEye=[base.eye[0]/.72,base.eye[1]/.72-2,base.eye[2]/.72]
 const inspection=options.inspection&&inspectionFrame({...base,eye:worldEye},model,view,options.inspection)
 const f=inspection?{...inspection,eye:inspection.eye===worldEye?base.eye:display(inspection.eye)}:base
 const perspective=inspection?!f.orthographic:!['section','plan','flat'].includes(view)
 const camera=p=>{const v=sub(display(p),f.eye);return[dot(v,f.right),dot(v,f.up),dot(v,f.forward)]}
 const inspected=p=>{
  if(!f.orthographic)return project(display(p),{...f,view:'inspection'})
  const relative=sub(p,f.target)
  return {point:[f.screen[0]+dot(relative,f.right)*f.pixels[0],f.screen[1]-dot(relative,f.up)*f.pixels[1]],depth:dot(relative,f.forward)}
 }
 const projection=p=>inspection?inspected(p):model.projection_relay&&view==='flat'?{point:[500+(p[0]+.55)*850,325-(p[1]+.65)*850],depth:-p[2]}:model.projection_relay&&view==='plan'?{point:[500+p[0]*100,150+p[2]*70],depth:-p[1]}:model.projection_relay&&view==='section'?{point:[230+p[2]*100,160-p[1]*150],depth:p[0]}:view==='section'?{point:[500+p[0]*165,175-p[1]*154],depth:p[2]}:view==='plan'?{point:[500+p[0]*165,325+p[2]*165],depth:-p[1]}:project(display(p),f)
 const human=model.near_monitor&&['volume','within'].includes(view)
 const external=model.near_monitor&&view==='contraption'
 const filteredSurfaces=human?model.surfaces.filter(s=>['corkscrew','janusite-wall','monitor'].includes(s.kind)):external?model.surfaces.filter(s=>['corkscrew','janusite-wall','registration','table','standing-landinging'].includes(s.kind)||(options.focus==='tc'&&s.kind==='down-under-computer')):model.surfaces.slice()
 const filteredLines=human?model.lines.filter(s=>s.id==='seat-to-spiral-continuation'):external?model.lines.filter(s=>['Seat-fixed-HERE-datum','Human-UPON-Seat-eye','inaugural-45-degree-bearing','seat-to-spiral-continuation','acquired-Landinging-registration'].includes(s.id)):model.lines.slice()
 if(external)filteredLines.push(...model.emergence.diagonals.flat.map(d=>({...d,color:'#c4b5fd',kind:'flat-diagonal'})))
 if(inspection&&view==='flat'){
  filteredLines.push({id:'ordinary-monitor-center-line',points:model.near_monitor.flat.center_line,color:'#d4e4df',kind:'monitor-center'})
 }
 const stand=options.inspection?.stand
 if(stand&&view!=='flat'){
  // Furnished registration witnesses supplement the selected view's own material.
  const {presentation}=source.emergence
  const witnesses={
   seat:['Seat-fixed-HERE-datum','Human-UPON-Seat-eye','inaugural-45-degree-bearing'],
   eye:['Human-UPON-Seat-eye','Seat-fixed-HERE-datum'],
   aperture:['inaugural-aperture-45','inaugural-45-degree-bearing'],
   pittoning:['pittoning-surface','radial-interface-fold','tunnel-mouth'],
   'arch-first':['zeroeth-first-arch-XT-TOWARD-YT','diagonal-brace-to-Quilling-Needle'],
   'arch-second':['zeroeth-second-arch-UP-OVER-ACROSS'],
   'mouth-near':['tunnel-mouth','pittoning-surface','YT-inbound-centerline'],
   'mouth-far':['tunnel-opening','YT-inbound-centerline'],
   monitor:['ordinary-flat-monitor']
  }
  const selected=witnesses[stand.id]||[]
  const sources=[source,presentation]
  for(const layer of sources){
   for(const line of layer.lines){
    if(selected.includes(line.id)&&!filteredLines.some(s=>s.id===line.id))filteredLines.push(line)
   }
   for(const surface of layer.surfaces){
    const related=selected.includes(surface.id)||(stand.id==='table'&&surface.kind==='table')
    if(related&&!filteredSurfaces.some(s=>s.id===surface.id))filteredSurfaces.push(surface)
   }
  }
 }
 const shapes=[...filteredSurfaces.map(s=>({...s,closed:true})),...filteredLines.map(s=>({...s,closed:false}))]
 const visible=s=>showInstrument||!(/^(side-AROUND|projection-ray|cabinet-side-aperture|corner-fold)/.test(s.id))
 shapes.sort((a,b)=>b.points.reduce((sum,p)=>sum+projection(p).depth/b.points.length,0)-a.points.reduce((sum,p)=>sum+projection(p).depth/a.points.length,0))
 const seen=new Set()
 const node=(tag,attrs)=>{const n=svg.ownerDocument.createElementNS(NS,tag);for(const[k,v]of Object.entries(attrs))n.setAttribute(k,String(v));svg.append(n);return n}
 for(const s of shapes.filter(visible).filter(s=>view!=='flat'||s.id==='ordinary-flat-monitor'||s.kind==='flat-diagonal'||s.kind==='monitor-center')){
  if(view==='section'&&s.kind==='cabinet'&&!s.id.endsWith('-0')&&!s.id.endsWith('-4'))continue
  const toScreen=ps=>ps.map(([x,y,z])=>[500+600*f.zoom*x/z,325-600*f.zoom*y/z])
  const segments=[]
  if(!perspective)segments.push(s.points.map(p=>projection(p).point))
  else if(s.closed)segments.push(toScreen(clipPolygon(s.points.map(camera))))
  else for(let i=1;i<s.points.length;i++){
   let a=camera(s.points[i-1]),b=camera(s.points[i]);if(a[2]<.04&&b[2]<.04)continue
   if(a[2]<.04||b[2]<.04){const q=add(a,scale(sub(b,a),(.04-a[2])/(b[2]-a[2])));if(a[2]<.04)a=q;else b=q}
   segments.push(toScreen([a,b]))
  }
  for(const points of segments){
   if(points.length<2)continue
   const first=!seen.has(s.kind);seen.add(s.kind)
   const el=node(s.closed?'polygon':'polyline',{points:points.map(p=>p.join(',')).join(' '),stroke:human?'#3c777a':s.color,fill:s.closed?(human?'#143a43':s.color+'18'):'none','stroke-width':s.closed?(s.kind==='table'||s.kind==='corkscrew'?.4:1):3,'data-body-object':s.id,'data-world':JSON.stringify(s.points),tabindex:first?0:-1,role:'img','aria-label':s.id,class:'sb-object'})
   const title=svg.ownerDocument.createElementNS(NS,'title');title.textContent=s.id+' · experimental registered points '+JSON.stringify(s.points);el.append(title)
  }
 }
 for(const tag of model.tags||[]){
  if(view==='flat'&&(tag.stage!=='monitor'||inspection))continue
  const p=projection(tag.point);if(!['flat','section','plan'].includes(view)&&p.depth<.04)continue
  const attrs={'data-material':tag.id,'data-stage':tag.stage,'data-body-object':tag.id+' / '+tag.stage,'data-world':JSON.stringify(tag.point),tabindex:0,role:'img','aria-label':tag.stage+' · '+tag.id}
  const c=node('circle',{...attrs,cx:p.point[0],cy:p.point[1],r:6,fill:'#fbbf24',stroke:'#fff'})
  const caption=node('text',{...attrs,x:p.point[0]+9,y:p.point[1]-8+(tag.stage==='encounter'?18:0),fill:'#fff','font-size':view==='flat'?22:12});caption.textContent=view==='flat'?tag.text.slice(0,80):tag.stage+(tag.status?.includes('pending')?' (pending)':'')
 }
 if(inspection&&view==='flat'&&model.near_monitor.flat.material){
  const {material,staging_point:point}=model.near_monitor.flat
  const {point:[cx,cy]}=projection(point)
  node('circle',{cx,cy,r:5,fill:'#fbbf24','data-material':material.id,'data-stage':'monitor','data-world':JSON.stringify(point),'data-body-object':'Monitor-stage material'})
 }
 if(inspection?.target&&options.inspection.stand){
  const {point:[cx,cy]}=projection(inspection.target)
  node('circle',{cx,cy,r:6,fill:'none',stroke:'#fbbf24','stroke-width':2,'data-stand-point':options.inspection.stand.id})
 }
 if(emergenceView){
  const e=model.emergence
  for(const mark of e.wall_test.marks){
   const corners=mark.quad.map(projection)
   if(corners.some(p=>p.depth<.04))continue
   const [a,b,,d]=corners.map(p=>p.point),du=sub(b,a),dv=sub(d,a)
   if(Math.abs(du[0]*dv[1]-du[1]*dv[0])<.05)continue
   const visible=view==='groundward'?mark.groundward_obstructions.length===0:mark.visible
   if(!visible){node('polygon',{points:corners.map(p=>p.point.join(',')).join(' '),fill:'none',stroke:'#fb7185','stroke-dasharray':'3 3','data-material':mark.material,'data-host-surface':mark.host,'data-world':JSON.stringify(mark.quad),'data-body-object':'occluded surface registration','data-visible':false});continue}
   const glyph=node('text',{x:0,y:.85,'font-size':1,textLength:1,lengthAdjust:'spacingAndGlyphs',fill:mark.visible?'#fff':'#fb7185',transform:`matrix(${du[0]} ${du[1]} ${dv[0]} ${dv[1]} ${a[0]} ${a[1]})`,'data-material':mark.material,'data-host-surface':mark.host,'data-world':JSON.stringify(mark.quad),'data-body-object':'JANUSITE wall / '+mark.index,'data-visible':mark.visible,tabindex:0})
   glyph.textContent=mark.letter
  }
  if(view==='groundward'&&e.wall_test.material){const ps=e.wall_test.source_line.map(projection);node('polyline',{points:ps.map(p=>p.point.join(',')).join(' '),stroke:'#fbbf24','stroke-width':4,fill:'none','data-material':e.wall_test.material.id,'data-world':JSON.stringify(e.wall_test.source_line),'data-body-object':'Unvanishing Line source registration'});const source=node('text',{x:20,y:82,fill:'#fbbf24','font-size':13});source.textContent='Line-like source of '+e.wall_test.sample+' · same authored material'}
  if(view==='contraption'&&!model.near_monitor)for(const [name,point,dx,dy] of [['Fixed Seat / HERE',e.registration.fixed_seat,12,20],['Seated eye',e.registration.revised_eye,-100,-16],['COB FROM Seat · common eye level',e.registration.COB_eye,12,-6],['Groundward aperture · 45°',e.registration.revised_aperture,-100,20]]){const p=projection(point);if(p.depth<.04)continue;const label=node('text',{x:p.point[0]+dx,y:p.point[1]+dy,fill:'#e2e8f0','font-size':13,'data-world':JSON.stringify(point),'data-body-object':name,tabindex:0});label.textContent=name}
  if(model.near_monitor&&!inspection)orientation(svg,model,view,projection,node,options.focus||'seat')
  const label=node('text',{x:20,y:58,fill:'#fbbf24','font-size':13});label.textContent=['volume','within'].includes(view)?'Human Regarding pivots; body and fixed Seat retain standing':view==='groundward'?'Unvanishing Line source registration; no optical motor claimed':'Seat / aperture / eye-line registrations; acquired source remains inspectable'
  svg.dataset.seat=JSON.stringify(e.registration.fixed_seat);svg.dataset.eye=JSON.stringify(e.registration.revised_eye)
 }
 if(view==='ceiling')for(const noticing of model.noticings||[]){
  const p=projection(noticing.point);if(p.depth<.04)continue
  const label=node('text',{x:p.point[0]+12,y:p.point[1]-8,fill:noticing.color,'font-size':16,'data-body-object':noticing.object,'data-world':JSON.stringify(noticing.point),tabindex:0});label.textContent=noticing.text
 }
 const title=node('text',{x:20,y:30,fill:'#dbeafe','font-size':18});title.textContent=inspection?view.toUpperCase()+' · AROUND ABOUT '+options.inspection.bearing+'°':emergenceView?`${view.toUpperCase()} · Regarding ${model.emergence.regard.quarter_turn}° / radial fold ${model.fold.degrees}° · fixed Seat`:`${view.toUpperCase()} · ${model.fold.degrees}° wedging · fixed standing`
 svg.dataset.camera=JSON.stringify({eye:f.eye,forward:f.forward,right:f.right,up:f.up});
 if(inspection)svg.dataset.inspection='active';else delete svg.dataset.inspection;svg.dataset.view=view;svg.dataset.fixed=JSON.stringify(model.fixed);svg.dataset.normal=JSON.stringify(model.fold.normal)
 return inspection||{...base,eye:worldEye}
}
export const SnailBody={
 mounted(){
  this.pinned=false
  this.draw=()=>renderBody(this.el.querySelector('svg'),JSON.parse(this.el.dataset.model),this.el.dataset.view,this.el.dataset.instrument==='true')
  this.outreading=this.el.querySelector('[data-outreading]')
  this.read=e=>{if(this.pinned)return;const n=e.target.closest('[data-body-object]');if(n)this.outreading.textContent=n.getAttribute('data-body-object')+' · world points '+n.getAttribute('data-world')+' · experimental body registration'}
  this.pin=e=>{this.read(e);if(e.target.closest('[data-body-object]')){this.pinned=!this.pinned;this.outreading.dataset.pinned=String(this.pinned)}}
  this.key=e=>{if(e.key==='Escape'){this.pinned=false;this.outreading.dataset.pinned='false'}if(e.key==='Enter'||e.key===' ')this.pin(e)}
  this.el.addEventListener('mouseover',this.read);this.el.addEventListener('focusin',this.read);this.el.addEventListener('click',this.pin);this.el.addEventListener('keydown',this.key)
  this.ref=this.handleEvent('snail-body-export',({json})=>{const url=URL.createObjectURL(new Blob([json],{type:'application/json'})),a=document.createElement('a');a.href=url;a.download='snail-body-quilling.json';a.click();URL.revokeObjectURL(url)})
  this.draw()
 },updated(){this.draw()},destroyed(){this.el.removeEventListener('mouseover',this.read);this.el.removeEventListener('focusin',this.read);this.el.removeEventListener('click',this.pin);this.el.removeEventListener('keydown',this.key);this.removeHandleEvent(this.ref)}
}

// Ordinary composition uses the fixed monitor's local frame, separately from apparatus diagnostics.
export function renderMonitor(svg,model){
 svg.replaceChildren()
 delete svg.dataset.inspection
 const n=(tag,attrs,text)=>{const el=svg.ownerDocument.createElementNS(NS,tag);for(const[k,v]of Object.entries(attrs))el.setAttribute(k,String(v));if(text!==undefined)el.textContent=text;svg.append(el);return el}
 const flat=model.near_monitor.flat
 n('rect',{x:0,y:0,width:1000,height:650,fill:'#101e28'})
 n('line',{x1:500,y1:55,x2:500,y2:600,stroke:'#d4e4df','stroke-width':2,'data-body-object':'ordinary-monitor-center-line','data-world':JSON.stringify(flat.center_line)})
 if(flat.material)n('text',{x:550,y:160,fill:'#fff','font-size':28,'data-material':flat.material.id,'data-stage':'monitor','data-world':JSON.stringify(flat.staging_point)},flat.material.text)
 svg.dataset.camera=JSON.stringify({kind:'fixed monitor-local presentation',plane:flat.plane.points});svg.dataset.view='flat';svg.dataset.seat=JSON.stringify(model.emergence.registration.fixed_seat)
}

function orientation(svg,model,view,projection,node,focus){
 const records=model.near_monitor.orientation,chosen=records.find(r=>r.id===focus)||records[2]
 const ids=view==='contraption'?[...new Set(['seat','eye','aperture',chosen.id])]:[chosen.id]
 for(const [i,id] of ids.entries()){
  const r=records.find(r=>r.id===id),p=projection(r.point),y=124+i*68
  const attrs={'data-body-object':r.name+' · '+r.relation,'data-world':JSON.stringify(r.point),tabindex:0,role:'img'}
  node('rect',{x:20,y:y-24,width:300,height:52,rx:7,fill:'#091c29',stroke:id===focus?'#fbbf24':'#476776'})
  const label=node('text',{...attrs,x:34,y:y-3,fill:'#f5f4e9','font-size':18});label.textContent=r.name
  const pos=node('text',{x:34,y:y+17,fill:'#a7c5d2','font-size':12});pos.textContent='FROM registration ['+r.point.join(', ')+']'
  if(p.depth>=.04&&p.point.every(Number.isFinite)&&p.point[0]>0&&p.point[0]<1000&&p.point[1]>78&&p.point[1]<650){
   node('line',{x1:320,y1:y,x2:p.point[0],y2:p.point[1],stroke:'#fbbf24','stroke-width':1.5})
   node('circle',{...attrs,cx:p.point[0],cy:p.point[1],r:7,fill:'#fbbf24',stroke:'#091c29','stroke-width':3})
  }else{
   const note=node('text',{x:34,y:y+38,fill:'#fbbf24','font-size':12});note.textContent='Outside this bearing · retained at its registration'
  }
 }
 // Small fixed section locator; derived from the same points, never a second world.
 if(['within','volume'].includes(view)){
  node('rect',{x:760,y:442,width:220,height:184,rx:10,fill:'#091c29',stroke:'#476776'})
  const caption=node('text',{x:775,y:467,fill:'#d7e9e5','font-size':14});caption.textContent='HERE · fixed section locator'
  const local=p=>[865+p[0]*65,520-p[1]*50]
  const seat=model.emergence.registration.fixed_seat,eye=model.emergence.registration.revised_eye
   const spiral=model.emergence.presentation.lines.find(l=>l.id==='seat-to-spiral-continuation')
  node('polyline',{points:spiral.points.map(p=>local(p).join(',')).join(' '),fill:'none',stroke:'#5eead4','stroke-width':2,'data-world':JSON.stringify(spiral.points),'data-body-object':'same Seat-to-spiral section locator'})
  node('polyline',{points:model.reference_arc.samples.map(s=>local(s.point).join(',')).join(' '),fill:'none',stroke:'#83aeb6','stroke-width':1.5,'data-body-object':'same inherited spiral in section','data-world':JSON.stringify(model.reference_arc.samples.map(s=>s.point))})
  for(const [name,p]of [['Seat / HERE',seat],['Eye',eye]]){const [x,y]=local(p);node('circle',{cx:x,cy:y,r:4,fill:'#fbbf24'});const text=node('text',{x:x+7,y:y+4,fill:'#fff','font-size':12});text.textContent=name}
  const angle=model.emergence.regard.quarter_turn*Math.PI/180,[x,y]=local(eye)
  node('line',{x1:x,y1:y,x2:x+35*Math.cos(angle),y2:y+35*Math.sin(angle),stroke:'#fff','stroke-width':2})
  const bearing=node('text',{x:775,y:606,fill:'#fbbf24','font-size':13});bearing.textContent=model.emergence.regard.quarter_turn+'° · +Z toward −Y'
 }
}
