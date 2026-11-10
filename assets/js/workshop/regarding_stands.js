// All points are in the Snail House frame. Camera offsets are inspection appointments.
const add=(a,b)=>a.map((v,i)=>v+b[i])
const sub=(a,b)=>a.map((v,i)=>v-b[i])
const scale=(a,n)=>a.map(v=>v*n)
const unit=a=>scale(a,1/Math.hypot(...a))
const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
const mid=(a,b)=>scale(add(a,b),.5)
const center=ps=>scale(ps.reduce(add,[0,0,0]),1/ps.length)
const rad=a=>a*Math.PI/180

export function regardingStands(model){
 const {fixed_seat:seat,revised_eye:eye,revised_aperture:aperture}=model.emergence.registration
 const {far_mouth:far,near_mouth:near}=model.crossing.yt_through.probe
 const line=id=>model.lines.find(s=>s.id===id).points
 const surface=id=>model.surfaces.find(s=>s.id===id).points
 const first=line('zeroeth-first-arch-XT-TOWARD-YT')
 const second=line('zeroeth-second-arch-UP-OVER-ACROSS')
 const table=model.surfaces.filter(s=>s.kind==='table').flatMap(s=>s.points)
 const pitton=surface('pittoning-surface')
 const mouth=line('tunnel-mouth')
 const plane=model.near_monitor.flat.plane.points
 const span=ps=>Math.max(...ps.map(p=>Math.hypot(...sub(p,ps[0]))))
 const make=(id,name,point,from,size,source)=>({id,name,point,from,size,source})
 return [
  make('seat','Traversaling Seat',seat,add(eye,sub(seat,aperture)),Math.hypot(...sub(eye,seat)),'Fixed HERE datum, seated eye and 45° aperture relation.'),
  make('eye','Seated eye',eye,seat,Math.hypot(...sub(eye,seat)),'Revised eye registration above the fixed Seat.'),
  make('aperture','Groundward aperture',aperture,sub(aperture,sub(seat,aperture)),Math.hypot(...sub(seat,aperture)),'Revised aperture in the Seat–aperture section.'),
  make('table','RE-SURFACING Table',center(table),eye,span(table),'Modeled Table annulus. Three-extent rise and Ground tie remain open.'),
  make('pittoning','PITTONING',center(pitton),far,span(pitton),'Modeled PITTONING face and inbound probe.'),
  make('arch-first','First bearing archway',first[16],eye,span(first),'XT TOWARD YT arch and its Quilling Needle brace.'),
  make('arch-second','Second bearing archway',second[16],eye,span(second),'UP OVER ACROSS arch at the Projectioning Crossing.'),
  make('mouth-far','Far tunnel mouth',far,sub(far,sub(near,far)),span(mouth),'Far endpoint of the candidate YT→YT probe.'),
  make('mouth-near','Near tunnel mouth',near,far,span(mouth),'Near probe endpoint at PITTONING and the radial interface fold.'),
  make('monitor','Flat monitor',center(plane),eye,span(plane),'Ordinary monitor plane and its registered center line.')
 ]
}

// Turn the basis and preserve the selected projection's handedness, including SECTION.
function turned(frame,bearing,elevation){
 const y=rad(bearing),p=rad(elevation)
 const yaw=([x,h,z])=>[x*Math.cos(y)+z*Math.sin(y),h,z*Math.cos(y)-x*Math.sin(y)]
 const right=yaw(frame.right),forward=yaw(frame.forward),up=yaw(frame.up)
 return {...frame,right,
  forward:add(scale(forward,Math.cos(p)),scale(up,Math.sin(p))),
  up:add(scale(up,Math.cos(p)),scale(forward,-Math.sin(p)))}
}

export function inspectionFrame(base,model,view,{bearing,elevation,stand,distance}){
 if(stand){
  const forward=unit(sub(stand.point,stand.from))
  const vertical=Math.abs(forward[1])>.99?[0,0,1]:[0,1,0]
  const right=unit(cross(forward,vertical)),up=cross(right,forward)
  const frame=turned({...base,forward,right,up,zoom:1},bearing,-elevation)
  const range=stand.size*[1,2,4][distance]
  return {...frame,eye:sub(stand.point,scale(frame.forward,range)),target:stand.point,
   range,orthographic:['section','plan','flat'].includes(view),
   screen:[500,325],pixels:[600/range,600/range]}
 }
 const {flat}=model.near_monitor
 const relay=model.projection_relay
 const layouts={
  section:relay?{right:[0,0,1],up:[0,1,0],forward:[1,0,0],screen:[230,160],pixels:[100,150]}:
   {right:[1,0,0],up:[0,1,0],forward:[0,0,1],screen:[500,175],pixels:[165,154]},
  plan:{right:[1,0,0],up:[0,0,-1],forward:[0,-1,0],screen:relay?[500,150]:[500,325],pixels:relay?[100,70]:[165,165]},
  flat:{right:[1,0,0],up:[0,1,0],forward:[0,0,-1],screen:[500,325],pixels:[850,850]}
 }
 const layout=layouts[view]
 if(layout){
  const target=view==='flat'?mid(...flat.center_line):model.emergence.registration.fixed_seat
  const frame=turned({...base,...layout,orthographic:true,target},bearing,-elevation)
  return {...frame,eye:sub(target,scale(frame.forward,4))}
 }
 const frame=turned(base,bearing,elevation)
 if(['within','volume','ceiling','groundward'].includes(view))return frame

 // Exterior and contraption bearings circle their original sight target.
 const pivot=view==='contraption'?[0,-.9,0]:model.emergence.registration.fixed_seat
 const range=sub(pivot,base.eye).reduce((sum,v,i)=>sum+v*base.forward[i],0)
 const target=add(base.eye,scale(base.forward,range))
 return {...frame,eye:sub(target,scale(frame.forward,range)),target,range}
}

export function renderLocator(svg,model,camera,stand){
 svg.replaceChildren()
 const ns='http://www.w3.org/2000/svg'
 const node=(tag,attrs)=>{
  const element=svg.ownerDocument.createElementNS(ns,tag)
  for(const [name,value] of Object.entries(attrs))element.setAttribute(name,value)
  svg.append(element)
  return element
 }
 const project=([x,y,z])=>[x-.62*z,-y+.26*x+.42*z]
 const seat=model.emergence.registration.fixed_seat
 const lines=[
  ...model.surfaces.filter(s=>s.kind==='cabinet').map(s=>[...s.points,s.points[0]]),
  model.reference_arc.samples.map(s=>s.point),
  ...model.lines.filter(s=>s.id.startsWith('zeroeth-')).map(s=>s.points)
 ]
 const eye=camera.eye,toward=add(eye,scale(camera.forward,.48))
 const points=[...lines.flat(),eye,toward,seat,...(stand?[stand.point]:[])].map(project)
 const axes=[0,1].map(i=>points.map(p=>p[i]))
 const minima=axes.map(values=>Math.min(...values))
 const spans=axes.map((values,i)=>Math.max(...values)-minima[i])
 const factor=Math.min(244/spans[0],166/spans[1])
 const local=p=>project(p).map((v,i)=>(v-minima[i]-spans[i]/2)*factor+[140,100][i])
 const trace=(points,stroke,width)=>node('polyline',{points:points.map(p=>local(p).join(',')).join(' '),fill:'none',stroke,'stroke-width':width})
 lines.forEach(points=>trace(points,'#608698',1))
 if(stand)trace([eye,stand.point],'#496a73',1)
 trace([eye,toward],'#5eead4',3)
 const mark=(point,fill,r,label)=>{
  const [cx,cy]=local(point)
  const dot=node('circle',{cx,cy,fill,r,stroke:'#071728','stroke-width':1})
  const title=svg.ownerDocument.createElementNS(ns,'title')
  title.textContent=label
  dot.append(title)
 }
 mark(seat,'#e2e8f0',4,'Fixed HERE / Seat')
 if(stand)mark(stand.point,'#fbbf24',5,stand.name)
 mark(eye,'#5eead4',4,'Inspection camera')
}
