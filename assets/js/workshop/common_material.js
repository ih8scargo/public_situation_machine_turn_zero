const sub=(a,b)=>a.map((v,i)=>v-b[i])
const dot=(a,b)=>a.reduce((n,v,i)=>n+v*b[i],0)
const unit=a=>a.map(v=>v/Math.hypot(...a))
const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]

// Both views consume identical world geometry. No material or standing is written.
export function projection(model,view){
 if(view==='flat')return p=>[p[0],-p[1]]
 const eye=model.eye,forward=unit(sub(model.diagonal.midpoint,eye))
 const right=unit(cross([0,1,0],forward)),up=cross(forward,right)
 return p=>{
  const delta=sub(p,eye),depth=dot(delta,forward)
  if(depth<=1e-8)return null
  return [dot(delta,right)/depth,-dot(delta,up)/depth]
 }
}

export function renderCommonMaterial(svg,model,view){
 svg.replaceChildren()
 const doc=svg.ownerDocument,ns='http://www.w3.org/2000/svg'
 const node=(tag,attrs,text)=>{
  const el=doc.createElementNS(ns,tag)
  for(const [key,value] of Object.entries(attrs))el.setAttribute(key,String(value))
  if(text!==undefined)el.textContent=text
  svg.append(el)
  return el
 }
 const raw=projection(model,view)
 const world=[...model.diagonal.endpoints,...model.mapping.endpoints,...model.xt.endpoints]
 const focus=view==='tunneling'?[...model.diagonal.endpoints,...model.mapping.endpoints]:world
 const ps=focus.map(raw).filter(Boolean)
 const min=[0,1].map(i=>Math.min(...ps.map(p=>p[i])))
 const max=[0,1].map(i=>Math.max(...ps.map(p=>p[i])))
 const scale=Math.min(470/Math.max(max[0]-min[0],.01),220/Math.max(max[1]-min[1],.01))
 const project=p=>{const q=raw(p);return q&&q.map((v,i)=>(v-(max[i]+min[i])/2)*scale+[300,157][i])}
 const line=(id,points,color,dash)=>{
  const projected=points.map(project)
  if(projected.some(p=>!p))return
  node('polyline',{points:projected.map(p=>p.join(',')).join(' '),fill:'none',stroke:color,
   'stroke-width':3,...(dash?{'stroke-dasharray':'6 5'}:{}),
   'data-reference':id,'data-world':JSON.stringify(points)})
 }
 line(model.diagonal.id,model.diagonal.endpoints,'#7995ad',true)
 line(model.xt.id,model.xt.endpoints,'#5eead4')
 line(model.mapping.id,model.mapping.endpoints,'#fbbf24',true)
 for(const [name,p] of [['D0',model.diagonal.endpoints[0]],['D1',model.diagonal.endpoints[1]],['M',model.diagonal.midpoint]]){
  const q=project(p);if(!q)continue
  const [cx,cy]=q
  const mark=node('circle',{cx,cy,r:name==='M'?7:4,fill:'#071523',stroke:'#d9e5ee','stroke-width':2,
   'data-reference':name,'data-world':JSON.stringify(p),tabindex:0})
  const title=doc.createElementNS(ns,'title');title.textContent=`${name} [${p.join(', ')}]`;mark.append(title)
  node('text',{x:cx+10,y:cy-12,fill:'#d9e5ee','font-size':18},name)
 }
 const id=model.source?.material.id
 const shown=model.samples.length<=20?model.samples:[...model.samples.slice(0,8),...model.samples.slice(-8)]
 for(const sample of shown){
  const p=project(sample.point);if(!p)continue
  const attrs={'data-material':sample.material,'data-source-index':sample.index,
   'data-world':JSON.stringify(sample.point),'data-parameter':sample.t}
  if(model.samples.length<=20){
   node('text',{x:p[0],y:p[1]+24,fill:'#fbbf24','font-size':18,'text-anchor':'middle',...attrs},sample.text)
  }else{
   const marker=node('circle',{cx:p[0],cy:p[1],r:3,fill:'#fde68a',tabindex:0,...attrs})
   const title=doc.createElementNS(ns,'title')
   title.textContent=`Source grapheme ${sample.index+1}: ${sample.text}`
   marker.append(title)
  }
 }
 svg.dataset.view=view
 svg.dataset.material=id||''
 svg.dataset.mapping=JSON.stringify(model.mapping)
}

export function selectRegarding(root,mode){
 if(!['both','tunneling','flat'].includes(mode))return
 root.dataset.mode=mode
 for(const button of root.querySelectorAll('[data-cm-mode]'))button.setAttribute('aria-pressed',String(button.dataset.cmMode===mode))
 root.querySelector('#cm-tunneling-card').hidden=mode==='flat'
 root.querySelector('#cm-flat-card').hidden=mode==='tunneling'
 root.querySelector('#cm-view-status').textContent=`${mode==='both'?'Paired':mode==='flat'?'Flat':'Tunneling'} inspection · same source, fixed registrations, no furnishing or acquisition.`
}

export const CommonMaterial={
 mounted(){
  this.mode='both'
  this.select=e=>{const button=e.target.closest('[data-cm-mode]');if(button){this.mode=button.dataset.cmMode;selectRegarding(this.el,this.mode)}}
  this.el.addEventListener('click',this.select)
  this.draw=()=>{
   const model=JSON.parse(this.el.dataset.model)
   renderCommonMaterial(this.el.querySelector('#cm-tunneling-scene'),model,'tunneling')
   renderCommonMaterial(this.el.querySelector('#cm-flat-scene'),model,'flat')
   selectRegarding(this.el,this.mode)
  }
  this.draw()
 },
 updated(){this.draw()},
 destroyed(){this.el.removeEventListener('click',this.select)}
}
