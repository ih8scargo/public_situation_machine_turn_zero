import {outreadings,targetReading} from './outreadings.js'
import {presentation,pose,locality,MONITOR,OPTICS} from './inspection.js'
const ns='http://www.w3.org/2000/svg'
const str=points=>points.map(p=>p.map(n=>Number(n.toFixed(3))).join(',')).join(' ')
function draw(svg,image,p,monitor){
 const seen=new Set();const readingAttrs=(key,name)=>{const first=!seen.has(key);seen.add(key);return {'data-reading':key,role:'button',tabindex:first?0:-1,'aria-label':`Outreading ${name}; Enter to pin`}}
 svg.replaceChildren();svg.setAttribute('viewBox',monitor?'0 0 960 720':'0 0 1100 700')
 const node=(tag,attrs,text)=>{const el=svg.ownerDocument.createElementNS(ns,tag);for(const [k,v]of Object.entries(attrs))el.setAttribute(k,String(v));if(text!==undefined)el.textContent=text;svg.append(el);return el}
 for(const line of image.lines){const key=targetReading(line.target,line.id);node('polyline',{points:str(line.screen),fill:'none',stroke:line.color,'stroke-width':1,class:'ip-world-line'});node('polyline',{points:str(line.screen),fill:'none',stroke:'transparent','stroke-width':14,'vector-effect':'non-scaling-stroke','pointer-events':'stroke','data-inspect-target':line.target||'',class:'ip-hit-line',...readingAttrs(key,line.id)})}
 for(const face of image.faces){
  node('polygon',{points:str(face.screen),fill:face.front?'#050505':'#222',stroke:p.treatment==='structural'?'#ddd':'none','stroke-width':.5,'data-inspect-target':`letter:${face.station}`,'data-letter-body':face.station,...readingAttrs(`letter:${face.station}`,`letter ${face.station}`)})
  if(p.treatment!=='solid')for(const edge of face.boundary){const points=image.transform(edge,false);if(points.length)node('polyline',{points:str(points),fill:'none',stroke:'white','stroke-width':1.1,'data-letter-registration':face.station,'data-world-points':JSON.stringify(edge),'pointer-events':'none'})}
 }
 node('text',{x:18,y:28,fill:'#163846','font-size':16,'font-family':'monospace'},monitor?'FIXED MONITOR · 2.4 × 1.8 · Z=-2':`FROM stand ${p.stand} · ${image.frame.target.label}`)
 svg.dataset.eye=JSON.stringify(image.frame.eye);svg.dataset.imageSignature=String(image.faces.slice(0,20).reduce((s,f)=>s+f.screen.flat().reduce((a,v)=>a+v,0),0).toFixed(5))
 svg.dataset.visibleFaces=String(image.faces.length)
}
export const ApproachingRegarding={
 mounted(){
  this.draw=()=>{
   const model=JSON.parse(this.el.dataset.model),registry=JSON.parse(this.el.dataset.registry),s=JSON.parse(this.el.dataset.inspection),p=s.parameters
   this.records=outreadings(model,registry)
   const select=this.el.querySelector('#ip-outreading-choice'),previous=select.value
   select.replaceChildren()
   for(const [key,record]of this.records){const option=select.ownerDocument.createElement('option');option.value=key;option.textContent=record.name;select.append(option)}
   select.value=this.records.has(previous)?previous:'letter:13'
   const frame=pose(model,registry,p)
   draw(this.el.querySelector('#ip-regarding-scene'),presentation(model,registry,p),p,false)
   const display=presentation(model,registry,p,true)
   draw(this.el.querySelector('#ip-monitor-scene'),display,p,true)
   this.el.querySelector('#ip-projection-detail').textContent=JSON.stringify({classification:'PROVISIONAL two-stage geometric relay; not completed optics',optics:OPTICS,fixed_monitor:MONITOR,projection_thing_origin:registry.projection_thing.origin,opening_degrees:registry.parameters.opening,source_field_eye:display.frame.eye,observer_eye:frame.eye,original_from:p.from,u_reference:{origin:[15,3,0],normal:[0,0,1],quarter_turn_limit:90},display_frame:'world basis inherited from U; constitutional letter orientation unappointed',occlusion:'opaque letter faces use painter depth ordering; structural outlines retain rear edges'},null,2)
   if(this.currentKey)this.showReading(this.currentKey,this.pinned,false)
   const readout=this.el.querySelector('#ip-pose-readout');readout.textContent=`Inspection eye [${frame.eye.map(v=>v.toFixed(3)).join(', ')}] · monitor normal distance ${frame.monitor_distance.toFixed(3)} extents (signed ${frame.monitor_signed.toFixed(3)}) · target ${frame.target.label}. Original FROM [${p.from.join(', ')}].`
  }
  this.showReading=(key,pin=false,tooltip=true)=>{
   const record=this.records.get(key);if(!record){this.el.querySelector('#ip-outreading-status').textContent='Source unavailable in the current registration; retained readout is historical.';this.el.querySelector('#ip-approach-outreading').disabled=true;return}
   const serialized=JSON.stringify(record,null,2),changed=this.pinned&&this.currentKey===key&&this.lastReading&&this.lastReading!==serialized
   this.currentKey=key;this.pinned=pin
   this.el.querySelector('#ip-outreading-detail').textContent=serialized
   this.lastReading=serialized
   this.el.querySelector('#ip-outreading-status').textContent=`${pin?'PINNED':'PREVIEW'}${changed?' · updated registration':''} · ${record.name} · ${record.classification}`
   const choice=this.el.querySelector('#ip-outreading-choice');choice.value=key
   const tip=this.el.querySelector('#ip-outreading-tooltip');tip.textContent=`${record.name} · ${record.classification} · world ${JSON.stringify(record.coordinates).slice(0,150)}`;tip.hidden=!tooltip||pin
   this.el.querySelector('#ip-approach-outreading').disabled=!record.approach_target
  }
  this.preview=e=>{const hit=e.target.closest('[data-reading]');if(hit&&!this.pinned)this.showReading(hit.dataset.reading,false,e.type!=='focusin')}
  this.move=e=>{const tip=this.el.querySelector('#ip-outreading-tooltip');if(!tip.hidden){const bounds=this.el.getBoundingClientRect();tip.style.left=Math.max(0,Math.min(bounds.width-280,e.clientX-bounds.left+14))+'px';tip.style.top=e.clientY-bounds.top+18+'px'}}
  this.select=e=>{
   const hit=e.target.closest('[data-reading]');if(hit){this.showReading(hit.dataset.reading,true,false);return}
   if(e.target.closest('#ip-unpin-outreading')){this.pinned=false;this.showReading(this.currentKey,false,false)}
   if(e.target.closest('#ip-approach-outreading')){const target=this.records.get(this.currentKey)?.approach_target;if(target)this.pushEvent('inspection-focus',{target})}
  }
  this.key=e=>{if(e.key==='Escape'){this.pinned=false;this.el.querySelector('#ip-outreading-tooltip').hidden=true;if(this.currentKey)this.showReading(this.currentKey,false,false)}else if(['Enter',' '].includes(e.key)){const hit=e.target.closest('[data-reading]');if(hit){e.preventDefault();this.showReading(hit.dataset.reading,true,false)}}}
  this.choice=e=>{if(e.target.id==='ip-outreading-choice')this.showReading(e.target.value,true,false)}
  this.leave=()=>{this.el.querySelector('#ip-outreading-tooltip').hidden=true}
  this.handlers={pointerover:this.preview,focusin:this.preview,pointermove:this.move,click:this.select,keydown:this.key,change:this.choice,pointerleave:this.leave}
  for(const [name,fn]of Object.entries(this.handlers))this.el.addEventListener(name,fn)
  this.draw();this.showReading('letter:13',false,false)
 },updated(){this.draw()},destroyed(){for(const [name,fn]of Object.entries(this.handlers))this.el.removeEventListener(name,fn)}
}
