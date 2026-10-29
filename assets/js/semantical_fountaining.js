// Geometry and face bearings are supplied by held, typed semantic transitions.
// This hook only Regards along the already-stood course; it never furnishes standing.
export function sampleCourse(course, phase) {
  const target=Math.max(0,Math.min(1,phase))*course.length
  const points=course.samples
  let i=0
  while(i<points.length-2 && points[i+1].distance<target)i++
  const a=points[i],b=points[i+1],f=b.distance>a.distance?(target-a.distance)/(b.distance-a.distance):0
  const p={relation:b.relation}
  for(const key of ['x','y','face_angle','text_angle'])p[key]=a[key]+(b[key]-a[key])*Math.max(0,Math.min(1,f))
  return p
}
export const SemanticalFountaining={
  mounted(){
    this.layer=this.el.querySelector('#ordinary-material');this.slider=this.el.querySelector('#material-progress');this.play=this.el.querySelector('#material-play');this.restart=this.el.querySelector('#material-restart')
    this.nodes=new Map();this.phase=0;this.last=null;this.paused=false;this.read()
    this.onPlay=()=>{if(this.phase>=1){this.phase=0;this.paused=false}else{this.paused=!this.paused}this.updateLabel()}
    this.onRestart=()=>{this.phase=0;this.paused=true;this.updateLabel();this.draw()}
    this.onInput=()=>{this.phase=Number(this.slider.value)/1000;this.paused=true;this.updateLabel();this.draw()}
    this.onPick=e=>{const n=e.target.closest('[data-material]');if(n){this.paused=true;this.pushEvent('material',{material:n.dataset.material});this.updateLabel()}}
    this.onKey=e=>{if((e.key==='Enter'||e.key===' ')&&e.target.closest('[data-material]')){e.preventDefault();this.onPick(e)}}
    this.play.addEventListener('click',this.onPlay);this.restart.addEventListener('click',this.onRestart);this.slider.addEventListener('input',this.onInput);this.layer.addEventListener('click',this.onPick);this.layer.addEventListener('keydown',this.onKey)
    this.frame=now=>{
      if(this.last!==null&&!this.paused&&!window.matchMedia('(prefers-reduced-motion: reduce)').matches)this.phase=Math.min(1,this.phase+Math.min(100,now-this.last)/12000)
      this.last=now;if(this.phase>=1)this.updateLabel();this.draw();this.raf=requestAnimationFrame(this.frame)
    }
    this.raf=requestAnimationFrame(this.frame)
  },
  read(){
    this.course=JSON.parse(this.el.dataset.course);this.material=JSON.parse(this.el.dataset.material)
    for(const item of this.material){
      if(!this.nodes.has(item.id)){
        const el=document.createElement('span');el.id=item.id;el.className='ordinary-character';el.dataset.material=item.id;el.dataset.course=item.course;el.dataset.stitched='false';el.tabIndex=0;el.setAttribute('role','button');el.setAttribute('aria-label',`Follow the same ${item.glyph}; ${item.id}`)
        const face=document.createElement('span');face.className='ordinary-character-face';face.textContent=item.glyph;el.append(face);this.layer.append(el);this.nodes.set(item.id,el)
      }
    }
    this.draw()
  },
  updateLabel(){this.play.textContent=this.phase>=1?'Rehearse the same S again':this.paused?'Let it travel':'Pause to Regard'},
  draw(){
    if(!this.course)return
    for(const item of this.material){
      const progress=this.phase+item.order*.08
      const el=this.nodes.get(item.id),p=sampleCourse(this.course,Math.max(0,progress))
      const normal=p.text_angle*Math.PI/180,offset=-9
      el.style.left=`${(p.x-Math.sin(normal)*offset)/800*100}%`;el.style.top=`${(p.y+Math.cos(normal)*offset)/600*100}%`;el.style.opacity=progress<0||progress>1?'0':'1';el.style.pointerEvents=progress<0||progress>1?'none':'auto'
      el.style.transform=`translate(-50%,-50%) rotate(${p.text_angle}deg)`
      el.firstElementChild.style.transform=`rotateY(${p.face_angle}deg)`
      el.dataset.phase=String(Math.max(0,progress));el.dataset.faceAngle=String(p.face_angle);el.dataset.transition=p.relation;el.dataset.held=String(this.el.dataset.selected===item.id)
    }
    if(document.activeElement!==this.slider)this.slider.value=String(Math.round(this.phase*1000))
  },
  updated(){this.read()},
  destroyed(){cancelAnimationFrame(this.raf);this.play.removeEventListener('click',this.onPlay);this.restart.removeEventListener('click',this.onRestart);this.slider.removeEventListener('input',this.onInput);this.layer.removeEventListener('click',this.onPick);this.layer.removeEventListener('keydown',this.onKey)}
}
