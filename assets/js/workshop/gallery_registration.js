const NS='http://www.w3.org/2000/svg'
const add=(a,b)=>a.map((v,i)=>v+b[i])
export function galleryPoint(point,kind,scale=88){
 return kind==='plan'?[300+point[0]*scale,300-point[2]*scale]:[300+point[2]*scale,295-point[1]*scale]
}
export function renderGallery(svg,model,kind,selected=null){
 svg.replaceChildren()
 const observed=model.observed,trial=model.provisional
 const extent=Math.max(2.7,...trial.ghost.points.map(p=>Math.max(Math.abs(p[0]),Math.abs(p[2]))+.4))
 const zoom=kind==='plan'?240/extent:76
 const P=p=>galleryPoint(p,kind,zoom)
 const node=(tag,attrs,text)=>{const el=svg.ownerDocument.createElementNS(NS,tag);for(const[k,v]of Object.entries(attrs))el.setAttribute(k,String(v));if(text!==undefined)el.textContent=text;svg.append(el);return el}
 const shape=(id,points,color,closed=false,extra={})=>node(closed?'polygon':'polyline',{points:points.map(p=>P(p).join(',')).join(' '),fill:closed?color+'18':'none',stroke:color,'stroke-width':1.2,'data-registration-object':id,'data-world':JSON.stringify(points),tabindex:-1,...extra})
 node('rect',{x:0,y:0,width:600,height:600,fill:'#091b28'})
 if(kind==='section')shape('HERE Groundward reference at Y=0 · not a new Ground',[[-0,0,-3.5],[0,0,3.5]],'#567a89',false,{'stroke-dasharray':'3 6'})
 // Retain every source JANUSITE face in both diagnostic outreadings.
 for(const face of observed.walls)shape(face.id,face.points,'#4d9999',true,{'stroke-width':.6,'data-source-wall':face.id})
 for(const face of observed.table.mesh)shape('Prior annulus / '+face.id,face.points,'#687887',true,{'stroke-width':.5})
 if(kind==='plan'){
  const radius=trial.table.comparison_radius
  const rim=Array.from({length:97},(_,i)=>[radius*Math.cos(i*Math.PI/48),0,radius*Math.sin(i*Math.PI/48)])
  shape('PROPOSED THREE-extent RE-SURFACING Table plan rim · height unregistered',rim,'#fbbf24',false,{'stroke-width':3,'data-proposed-table':true,'data-plan':JSON.stringify(rim.map(p=>[p[0],p[2]])),'data-world':'Y unregistered; X/Z plan projection only',tabindex:0})
  node('text',{x:20,y:34,fill:'#fbbf24','font-size':15},'Proposed Table Ø3 extents · HERE side 6')
 }else node('text',{x:20,y:34,fill:'#fbbf24','font-size':14},'Proposed Table height/thickness: UNRESOLVED')
 shape('Gallery study boundary · provisional identity overlay',observed.gallery.boundary,'#c7d0df',true,{'stroke-dasharray':'6 4','stroke-width':2,tabindex:0})
 if(kind==='section'){
  shape('Gallery study upper boundary · not a new furnished shell',observed.gallery.boundary.map(p=>add(p,[0,observed.gallery.height[1],0])),'#728498',true,{'stroke-dasharray':'3 7'})
  for(const point of observed.gallery.boundary)shape('Gallery study vertical reference',[point,add(point,[0,3,0])],'#728498',false,{'stroke-dasharray':'3 7'})
 }
 shape('Feasible center locus · planar boundary only',model.computed.feasible_centers,'#72caac',true,{'stroke-dasharray':'2 5'})
 const course=model.computed.courses.find(c=>c.mode===model.parameters.coupling)
 shape('Trial center course 0–90 degrees · no NAV authority',course.samples.map(s=>s.center),'#9ca5df',false,{'stroke-dasharray':'3 6'})
 shape('THIS HERE APPROACHING LANDINGING · unchanged',observed.here.points,'#f1f5f9',true,{'stroke-width':3,tabindex:0})
 const circle=Array.from({length:65},(_,i)=>[observed.standing.radius*Math.cos(i*Math.PI/32),0,observed.standing.radius*Math.sin(i*Math.PI/32)])
 shape('THIS ONE STANDINGING LANDINGING · circular standing',circle,'#5eead4',false,{'stroke-width':2})
 const cube=trial.ghost.points
 for(let i=0;i<4;i++){
  shape('Movement ghost · invariant six-reference-unit comparison',[cube[i],cube[(i+1)%4]],'#c4b5fd',false,{'stroke-width':3,'stroke-dasharray':'7 4','data-ghost':true})
 }
 shape('HERE TOWARD NEXT · Rooming direction retained',[[0,0,0],observed.next.center],'#f472b6',false,{'stroke-width':3,tabindex:0})
 shape('Snail central axle · fixed',[[0,-2.12,0],[0,.4,0]],'#e2e8f0',false,{'stroke-width':2})
 if(trial.craft.heading)shape('45-degree Craft plan heading · unit direction, not physical Craft length',[trial.craft.seat,add(trial.craft.seat,trial.craft.heading)],'#fbbf24',false,{'stroke-width':3,'stroke-dasharray':'4 4',tabindex:0})
 if(trial.cob.stand_base)shape('COB upstanding stand candidate · same Seat, no avatar',[trial.cob.stand_base,trial.cob.eye],'#fbbf24',false,{'stroke-width':3,tabindex:0})
 for(const [name,point]of [['HERE',[0,0,0]],['NEXT',observed.next.center],['Prior annulus',observed.table.center]]){
  const p=P(point);const label=node('text',{x:p[0]+10,y:p[1]+(name==='HERE'?22:-9),fill:name==='NEXT'?'#f9a8d4':'#e4e9df','font-size':14,'data-registration-object':name,'data-world':JSON.stringify(point),tabindex:0},name)
 }
 for(const mark of trial.material_work.existing_wall_registrations)shape('Same material '+mark.material+' on '+mark.host,mark.quad,'#fbbf24',true,{'data-material':mark.material,'data-host-surface':mark.host})
 if(trial.material_work.material){
  const work=trial.material_work,source=work.existing_wall_registrations[0]
  if(source){const from=source.quad.reduce((out,p)=>out.map((v,i)=>v+p[i]/4),[0,0,0]);shape('Historical work preview on prior annulus face '+work.proposed_host+' · source standing retained',[from,work.proposed_destination],'#fbbf24',false,{'stroke-dasharray':'3 5','data-material':work.material.id,tabindex:0})}
 }
 for(const observation of model.computed.curvature.observations){
  const p=P(observation.point),attrs={'data-observation':observation.id,'data-registration-object':observation.id+' · arc address '+observation.address.toFixed(4),'data-world':JSON.stringify(observation.point)}
  node('circle',{...attrs,cx:p[0],cy:p[1],r:10,fill:'transparent',tabindex:0,'aria-label':observation.id})
  node('circle',{...attrs,cx:p[0],cy:p[1],r:selected===observation.id?6:2.6,'data-observation-marker':true,fill:selected===observation.id?'#fff':'#fbbf24',stroke:'#091b28','stroke-width':1.2})
 }
 svg.dataset.view=kind
 svg.dataset.axle=JSON.stringify(observed.axle.point)
 svg.dataset.here=JSON.stringify(observed.here.points)
 svg.dataset.material=trial.material_work.material?.id||''
}
export const GalleryRegistration={
 mounted(){
  this.selected=null;this.pinned=false
  this.draw=()=>{const model=JSON.parse(this.el.dataset.model);for(const kind of ['plan','section'])renderGallery(this.el.querySelector('#sgr-'+kind),model,kind,this.selected)}
  this.highlight=()=>{for(const marker of this.el.querySelectorAll('[data-observation-marker]')){const on=marker.dataset.observation===this.selected;marker.setAttribute('r',on?6:2.6);marker.setAttribute('fill',on?'#fff':'#fbbf24')}}
  this.read=e=>{
   if(this.pinned)return
   const active=this.el.ownerDocument.activeElement
   if(e.type==='mouseover'&&active?.hasAttribute('data-registration-object')&&this.el.contains(active))return
   const n=e.target.closest('[data-registration-object]');if(!n)return
   const id=n.dataset.observation||null
   this.el.querySelector('[data-outreading]').textContent=n.dataset.registrationObject+' · world '+n.dataset.world+' · registered diagnostic projection, not a new acquisition'
   if(id!==this.selected){this.selected=id;this.highlight()}
  }
  this.pin=e=>{this.read(e);if(e.target.closest('[data-registration-object]'))this.pinned=!this.pinned;this.el.querySelector('[data-outreading]').dataset.pinned=String(this.pinned)}
  this.key=e=>{if(e.key==='Escape'){this.pinned=false;this.selected=null;this.highlight();this.el.querySelector('[data-outreading]').dataset.pinned='false'}if(e.key==='Enter'||e.key===' '){e.preventDefault();this.pin(e)}}
  this.el.addEventListener('mouseover',this.read);this.el.addEventListener('focusin',this.read);this.el.addEventListener('click',this.pin);this.el.addEventListener('keydown',this.key)
  this.draw()
 },
 updated(){this.draw()},
 destroyed(){this.el.removeEventListener('mouseover',this.read);this.el.removeEventListener('focusin',this.read);this.el.removeEventListener('click',this.pin);this.el.removeEventListener('keydown',this.key)}
}
