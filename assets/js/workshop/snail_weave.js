import {inspectionFrame,regardingStands,renderLocator} from './regarding_stands.js'
import {renderBody} from './snail_body.js'
export const SnailWeave={
 mounted(){
  this.pinned=false
  this.focus='seat'
  this.bearing=0
  this.elevation=0
  this.distance=1
  this.standId=''
  this.orbit=false
  this.sourceView=this.el.dataset.view
  const standSelect=this.el.querySelector('#sw-stand')
  const closer=this.el.querySelector('#sw-closer'),farther=this.el.querySelector('#sw-farther')
  const up=this.el.querySelector('#sw-up'),down=this.el.querySelector('#sw-down')
  const defaultStand={flat:'monitor',within:'eye',volume:'eye',groundward:'aperture',ceiling:'arch-second'}
  this.draw=()=>{
   const model=JSON.parse(this.el.dataset.model),view=this.el.dataset.view
   const stands=regardingStands(model)
   if(standSelect.options.length===1){
    for(const stand of stands)standSelect.add(new Option(stand.name,stand.id))
   }
   const stand=stands.find(r=>r.id===this.standId)
   const inspection=this.orbit?{bearing:this.bearing,elevation:this.elevation,distance:this.distance,stand}:null
   this.el.dataset.inspection=this.orbit?'active':'parked'
   const camera=renderBody(this.el.querySelector('#sw-scene'),model,view,true,{focus:this.focus,inspection})
   const monitor=stands.find(r=>r.id==='monitor')
   const locatorCamera=!inspection&&['flat','section','plan'].includes(view)?
    inspectionFrame(camera,model,view,{bearing:0,elevation:0}):camera
   renderLocator(this.el.querySelector('#sw-locator'),model,locatorCamera,stand||(view==='flat'?monitor:null))
   this.el.querySelector('#sw-from').textContent='Outreading FROM '+(stand?.name||view.toUpperCase())
   this.el.querySelector('#sw-stand-source').textContent=stand?
    `${stand.source} Anchor [${stand.point.map(n=>Number(n.toFixed(3))).join(', ')}]. Camera offset ${camera.range.toFixed(2)} model units.`:
    view==='flat'&&!inspection?'Ordinary monitor-local outreading. The locator marks the monitor plane and its face-on bearing.':
    'The teal mark locates the camera and its sight direction. Inspection changes neither Human standing nor COB operation.'
   const flat=this.el.querySelector('#sw-flat-material')
   if(flat){const material=model.near_monitor.flat.material;flat.dataset.material=material?.id||'';flat.querySelector('[data-composition-text]').textContent=material?.text||'';flat.querySelector('[data-composition-source]').textContent=material?material.id+' · existing monitor-stage registration':''}
   const status=this.el.querySelector('#sw-bearing')
   if(status)status.textContent=inspection?`${view.toUpperCase()} · AROUND ABOUT ${this.bearing}° · vertical ${this.elevation}°${stand?' · '+['Close','Middle','Far'][this.distance]:''}`:['within','volume'].includes(view)?'FROM HERE: seated eye [0, 0.63, 0] · '+model.emergence.regard.quarter_turn+'° from +Z toward DOWN UNDER (−Y) · fixed Seat and body':view==='flat'?'Longhouse Gallery Wall · ordinary fixed monitor · one vertical center line · staged material OVER ACROSS on the right':view==='contraption'?'EXTERNAL CONTRAPTION INSPECTION · fixed Seat, eye and Groundward aperture':view==='groundward'?'Groundward aperture Regarding · registered line-like material source':'ENGINEERING INSPECTION · '+view
   for(const b of this.el.querySelectorAll('[data-orientation]'))b.setAttribute('aria-pressed',String(b.dataset.orientation===this.focus))
   const r=model.near_monitor.orientation.find(r=>r.id===this.focus),context=this.el.querySelector('#sw-orientation-reading');if(context)context.textContent=r.name+' · ['+r.point.join(', ')+'] · '+r.relation
  }
  const wheel=this.el.querySelector('#sw-wheel')
  const back=this.el.querySelector('#sw-wheel-return')
  const reset=this.el.querySelector('#sw-wheel-reset')
  const rotor=wheel.querySelector('[data-wheel-rotor]')
  const bearing=this.el.querySelector('#sw-wheel-bearing')
  const mode=this.el.querySelector('#sw-wheel-mode')
  const listeners=new AbortController()
  this.stopWheel=()=>listeners.abort()
  const listen=(node,event,handler)=>node.addEventListener(event,handler,{signal:listeners.signal})
  this.updateWheel=()=>{
   rotor.setAttribute('transform',`rotate(${this.bearing} 60 60)`)
   wheel.setAttribute('aria-valuenow',this.bearing)
   wheel.setAttribute('aria-valuetext',`${this.bearing} degrees, ${this.orbit?'orbit active':'orbit parked'}`)
   bearing.textContent=`${this.bearing}°`
   mode.textContent=this.orbit?`Inspection active · vertical ${this.elevation}°`:'Ready to turn'
   standSelect.value=this.standId
   closer.disabled=Boolean(this.standId)&&this.distance===0
   farther.disabled=Boolean(this.standId)&&this.distance===2
   up.disabled=this.elevation===60
   down.disabled=this.elevation===-60
   back.hidden=!this.orbit
  }
  const turn=angle=>{
   this.bearing=((Math.round(angle)%360)+360)%360
   this.orbit=true
   this.updateWheel()
   if(this.wheelFrame==null)this.wheelFrame=requestAnimationFrame(()=>{
    this.wheelFrame=null
    this.draw()
   })
  }
  const leave=()=>{
   this.orbit=false
   this.bearing=0
   this.elevation=0
   this.distance=1
   this.standId=''
   this.updateWheel()
   this.draw()
  }
  const pointerAngle=(e,r)=>Math.atan2(e.clientX-r.left-r.width/2,r.top+r.height/2-e.clientY)*180/Math.PI
  let drag
  listen(wheel,'pointerdown',e=>{
   if(drag||e.button!==0)return
   e.preventDefault()
   const bounds=wheel.getBoundingClientRect()
   wheel.focus({preventScroll:true})
   wheel.setPointerCapture(e.pointerId)
   drag={id:e.pointerId,bounds,last:pointerAngle(e,bounds),angle:this.bearing}
   turn(drag.angle)
  })
  listen(wheel,'pointermove',e=>{
   if(drag?.id!==e.pointerId)return
   const angle=pointerAngle(e,drag.bounds)
   drag.angle+=(angle-drag.last+540)%360-180
   drag.last=angle
   turn(drag.angle)
  })
  listen(wheel,'lostpointercapture',e=>{if(drag?.id===e.pointerId)drag=undefined})
  listen(wheel,'keydown',e=>{
   const step=e.shiftKey?45:5
   const values={ArrowRight:this.bearing+step,ArrowUp:this.bearing+step,
    ArrowLeft:this.bearing-step,ArrowDown:this.bearing-step,Home:0,End:359,
    PageUp:this.bearing+45,PageDown:this.bearing-45}
   if(!Object.hasOwn(values,e.key))return
   e.preventDefault()
   turn(values[e.key])
  })
  listen(reset,'click',leave)
  listen(standSelect,'change',()=>{
   this.standId=standSelect.value
   this.distance=1
   this.elevation=0
   turn(0)
  })
  const approach=step=>{
   if(!this.standId)this.standId=defaultStand[this.el.dataset.view]||'seat'
   this.distance=Math.max(0,Math.min(2,this.distance+step))
   turn(this.bearing)
  }
  listen(closer,'click',()=>approach(-1))
  listen(farther,'click',()=>approach(1))
  const elevate=step=>{
   this.elevation=Math.max(-60,Math.min(60,this.elevation+step))
   turn(this.bearing)
  }
  listen(up,'click',()=>elevate(15))
  listen(down,'click',()=>elevate(-15))
  listen(back,'click',()=>{
   wheel.focus()
   leave()
  })
  listen(this.el.closest('#snail-weave'),'click',e=>{
   if(e.target.closest('[phx-click="weave-view"]'))leave()
  })
  this.resetInspection=leave
  this.updateWheel()
  const reading=this.el.querySelector('[data-outreading]')
  this.read=e=>{if(this.pinned)return;const node=e.target.closest('[data-body-object]');if(node)reading.textContent=node.dataset.bodyObject+' · world '+node.dataset.world+(node.dataset.material?' · one canonical material '+node.dataset.material:' · registered inspection witness; physical hypotheses remain in ledger')}
  this.pin=e=>{const choice=e.target.closest('[data-orientation]');if(choice){this.focus=choice.dataset.orientation;this.pinned=false;this.draw();return}this.read(e);if(e.target.closest('[data-body-object]')){this.pinned=!this.pinned;reading.dataset.pinned=String(this.pinned)}}
  this.key=e=>{if(e.key==='Escape'){this.pinned=false;reading.dataset.pinned='false'}if((e.key==='Enter'||e.key===' ')&&e.target.closest('[data-body-object]'))this.pin(e)}
  this.el.addEventListener('mouseover',this.read);this.el.addEventListener('focusin',this.read);this.el.addEventListener('click',this.pin);this.el.addEventListener('keydown',this.key)
  this.ref=this.handleEvent('snail-weave-export',({json})=>{const url=URL.createObjectURL(new Blob([json],{type:'application/json'})),a=document.createElement('a');a.href=url;a.download='snail-weave.json';a.click();URL.revokeObjectURL(url)})
  this.draw()
 },updated(){
  const view=this.el.dataset.view
  if(view!==this.sourceView){
   this.sourceView=view
   this.resetInspection()
   return
  }
  this.draw()
 },destroyed(){this.stopWheel();cancelAnimationFrame(this.wheelFrame);this.el.removeEventListener('mouseover',this.read);this.el.removeEventListener('focusin',this.read);this.el.removeEventListener('click',this.pin);this.el.removeEventListener('keydown',this.key);this.removeHandleEvent(this.ref)}
}
