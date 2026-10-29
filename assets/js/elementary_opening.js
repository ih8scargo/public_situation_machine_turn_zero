const radians = n => n * Math.PI / 180
const add = (a,b) => a.map((v,i)=>v+b[i])
const scale = (a,s) => a.map(v=>v*s)
const cross = (a,b) => [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
const unit = a => scale(a,1/Math.hypot(...a))

export function project(point, pivot=0) {
  const [x,y,z]=point, a=radians(pivot)
  const xx=x*Math.cos(a)+z*Math.sin(a), zz=-x*Math.sin(a)+z*Math.cos(a)
  const perspective=12/(12+zz)
  return [400+xx*55*perspective,260-y*55*perspective]
}
export function furnishedStick(yaw,pitch,extension,length=2.6) {
  const y=radians(yaw),p=radians(pitch)
  const direction=[Math.sin(y)*Math.cos(p),Math.sin(p),Math.cos(y)*Math.cos(p)]
  return {origin:[0,0,0],direction,tip:scale(direction,length*extension),extension,yaw,pitch,length}
}
export function ringPoints(center,radii,plane='xy',direction=[0,0,1]) {
  const right=unit(cross([0,1,0],direction)), up=unit(cross(direction,right))
  return Array.from({length:65},(_,i)=>{
    const a=i*Math.PI/32, local=plane==='xy'?[radii[0]*Math.cos(a),radii[1]*Math.sin(a),0]:plane==='xz'?[radii[0]*Math.cos(a),0,radii[2]*Math.sin(a)]:[0,radii[1]*Math.cos(a),radii[2]*Math.sin(a)]
    return add(center,add(scale(right,local[0]),add(scale(up,local[1]),scale(direction,local[2]))))
  })
}
export function wireframeEdges(min,max) {
  const vertices=Array.from({length:8},(_,i)=>[i&1?max[0]:min[0],i&2?max[1]:min[1],i&4?max[2]:min[2]])
  return vertices.flatMap((p,i)=>[1,2,4].filter(bit=>(i&bit)===0).map(bit=>[p,vertices[i|bit]]))
}
export function responseOffset(dx,dy,limit=.65) {
  const size=Math.hypot(dx,dy), amount=size>limit?limit/size:1
  return [dx*amount,dy*amount,0]
}

export function settleOffset(current, target, dt) {
  const response = 1 - Math.exp(-10 * Math.min(.05, dt))
  return current.map((v,i)=>v+(target[i]-v)*response)
}

export function suspensionStep(state, velocity, acceleration, dt, length=.9) {
  const next={...state}, steps=Math.max(1,Math.ceil(Math.min(.05,dt)*120)), h=Math.min(.05,dt)/steps
  const forceX=Math.max(-5,Math.min(5,-acceleration*.012-velocity*.025))
  const forceZ=Math.max(-3,Math.min(3,velocity*velocity*.008))
  for(let i=0;i<steps;i++){
    next.vx+=(forceX-9.81/length*next.x-4*next.vx)*h
    next.vz+=(forceZ-9.81/length*next.z-4*next.vz)*h
    next.x=Math.max(-.28,Math.min(.28,next.x+next.vx*h))
    next.z=Math.max(-.2,Math.min(.2,next.z+next.vz*h))
  }
  return next
}
export function suspendedTab(purchase,state,displacement=[0,0,0]){
  const x=state.x,z=state.z,l=purchase.length
  return add(purchase.anchor,add([x,-Math.sqrt(Math.max(.01,l*l-x*x-z*z)),z],displacement))
}
// Historical four-point articulation: open purchase contracts around the held tool.
export function graspPoints(center,direction,held=false){
  const right=unit(cross([0,1,0],direction)),up=unit(cross(direction,right)),amount=typeof held==='number'?held:held?1:0,spread=.32*(1-amount)+.134*amount
  return [[-1,-1],[1,-1],[1,1],[-1,1]].map(([x,y])=>add(center,add(scale(right,x*spread),scale(up,y*spread*.65))))
}
// Reversible presentation only; no standing is authored here.
export function dioramaMechanism(amount) {
  const t=Math.max(0,Math.min(1,Number.isFinite(amount)?amount:0)),a=t*Math.PI/3
  return {amount:t,human:[-2.1+.4*(1-Math.cos(a)),0,2.1*Math.sin(a)],
    cob:[2.1-1.3*Math.sin(a),0,-1.4*(1-Math.cos(a))],angle:a*.55}
}
export function floorWall(reference,amount) {
  const [x,y,z]=reference.min,[X,Y,Z]=reference.max,m=dioramaMechanism(amount)
  const transform=([px,py,pz])=>[px*Math.cos(m.angle)+pz*Math.sin(m.angle),py,
    -px*Math.sin(m.angle)+pz*Math.cos(m.angle)]
  return {floor:[[x,y,z],[X,y,z],[X,y,Z],[x,y,Z]].map(transform),
    wall:[[x,y,Z],[X,y,Z],[X,Y,Z],[x,Y,Z]].map(transform)}
}
const clamp=(n,a,b)=>Math.max(a,Math.min(b,n))
const zeroSwing=()=>({x:0,z:0,vx:0,vz:0})
export const ElementaryOpening={
  mounted(){
    this.svg=this.el.querySelector('svg');this.host=this.el.closest('main');this.nodes=new Map()
    this.opening=0
    this.regard={scope:'opening-page',bearing:0,axis:'vertical'}
    this.swing=zeroSwing();this.offset=[0,0,0];this.target=[0,0,0];this.velocity=0;this.acceleration=0
    this.draft=furnishedStick(0,0,0);this.reduced=matchMedia('(prefers-reduced-motion: reduce)')
    this.read=()=>{this.model=JSON.parse(this.el.dataset.model);if(this.model.accomplished){this.offset=[0,0,0];this.target=[0,0,0]}this.draw()}
    this.turn=(delta,dt=.04)=>{
      const velocity=radians(delta)/Math.max(.016,dt)
      this.acceleration=clamp((velocity-this.velocity)/Math.max(.016,dt),-40,40);this.velocity=clamp(velocity,-10,10)
      this.regard.bearing+=delta
      if(this.reduced.matches){this.swing=zeroSwing();this.velocity=0;this.acceleration=0}
      else this.animate()
      this.draw()
    }
    this.beginPull=event=>{
      if(this.model.wireframe||this.el.dataset.ready!=='true'||this.pull)return
      this.pull={id:event.pointerId,x:event.clientX||0,y:event.clientY||0,dx:0,dy:0,token:null,ended:false}
      const gesture=this.pull
      this.pushEvent('take-purchase',{},reply=>{
        if(this.gone)return
        if(!reply.accepted){this.pull=null;this.draw();return}
        gesture.token=reply.token
        if(gesture.ended)this.finishPull(gesture.cancelled)
      })
    }
    this.finishPull=cancelled=>{
      const g=this.pull;if(!g)return
      g.ended=true;g.cancelled=cancelled
      if(!g.token)return
      const moved=g.dx!==0||g.dy!==0
      if(cancelled||!moved){this.pushEvent('cancel-pull',{token:g.token});this.pull=null;this.draw();return}
      this.pushEvent('pull',{token:g.token},reply=>{
        if(this.gone)return
        if(reply.accepted)this.pushEvent('release-pull',{token:g.token,measurements:{dx:g.dx,dy:g.dy}},()=>{if(!this.gone){this.pull=null;this.draw()}})
      })
    }
    this.finishFeed=()=>{
      const g=this.feed;if(!g)return
      this.feed=null
      if(this.draft.extension<1){this.draft=furnishedStick(0,0,0);this.draw();return}
      const d=this.draft
      this.pushEvent('stage-feed',{yaw:d.yaw,pitch:d.pitch,length:d.length,extension:1},reply=>{
        if(!this.gone&&reply.accepted)this.pushEvent('cob-up-over',{})
      })
    }
    this.down=e=>{
      if(e.button!==undefined&&e.button!==0)return
      if(e.target.closest('#human-push-handle')&&this.model.diorama){
        e.preventDefault();this.pushing={id:e.pointerId,y:e.clientY,start:this.opening}
        e.target.setPointerCapture(e.pointerId);return
      }
      const handle=e.target.closest('[data-turn-handle]')
      if(handle){e.preventDefault();this.turning={id:e.pointerId,x:e.clientX,time:performance.now()};handle.setPointerCapture(e.pointerId);return}
      if(e.target.closest('#pulling-ring,#tab-purchase-hit')&&!this.model.wireframe){e.preventDefault();this.beginPull(e);e.target.closest('#pulling-ring,#tab-purchase-hit').setPointerCapture(e.pointerId);return}
      if(e.target.closest('#feed-purchase')&&!this.model.accomplished){
        e.preventDefault();this.feed={id:e.pointerId,x:e.clientX,y:e.clientY};this.svg.setPointerCapture(e.pointerId)
      }
    }
    this.move=e=>{
      if(this.pushing?.id===e.pointerId){
        const travel=Math.max(80,this.svg.getBoundingClientRect().height*.3)
        this.opening=clamp(this.pushing.start+(this.pushing.y-e.clientY)/travel,0,1);this.draw();return
      }
      if(this.turning?.id===e.pointerId){const now=performance.now();this.turn((e.clientX-this.turning.x)*.65,(now-this.turning.time)/1000);this.turning.x=e.clientX;this.turning.time=now;return}
      if(this.pull?.id===e.pointerId&&!this.pull.ended){this.pull.dx=e.clientX-this.pull.x;this.pull.dy=e.clientY-this.pull.y;this.draw();return}
      if(this.feed?.id===e.pointerId){
        const dx=e.clientX-this.feed.x,dy=e.clientY-this.feed.y,extent=Math.hypot(dx,dy)
        this.draft=furnishedStick(clamp(dx*.35,-60,60),clamp(-dy*.15,-45,45),clamp(extent/100,0,1),clamp(1+extent/160,1,3));this.draw();return
      }
      if(this.model.janusite&&!this.feed){
        const r=this.svg.getBoundingClientRect()
        this.target=responseOffset((e.clientX-r.left-r.width/2)/300,-(e.clientY-r.top-r.height/2)/300,.35)
        if(this.reduced.matches){this.offset=this.target;this.draw()}else this.animate()
      }
    }
    this.up=e=>{
      if(this.pushing?.id===e.pointerId){this.pushing=null;this.draw();return}
      if(this.turning?.id===e.pointerId){this.turning=null;this.velocity=0;this.acceleration=0;this.animate();return}
      if(this.pull?.id===e.pointerId){this.finishPull(false);return}
      if(this.feed?.id===e.pointerId)this.finishFeed()
    }
    this.cancel=e=>{
      if(this.pushing?.id===e.pointerId){this.opening=this.pushing.start;this.pushing=null}
      if(this.turning?.id===e.pointerId){this.turning=null;this.velocity=0;this.acceleration=0}
      if(this.pull?.id===e.pointerId)this.finishPull(true)
      if(this.feed?.id===e.pointerId){this.feed=null;this.draft=furnishedStick(0,0,0)}
      this.draw()
    }
    this.key=e=>{
      if(e.target.closest('#human-push-handle')&&this.model.diorama){
        if(['ArrowUp','ArrowRight','ArrowDown','ArrowLeft','Home','End'].includes(e.key)){
          e.preventDefault();this.opening=e.key==='Home'?0:e.key==='End'?1:
            clamp(this.opening+(['ArrowUp','ArrowRight'].includes(e.key)?.05:-.05),0,1);this.draw();return
        }
      }
      const turning=e.target.closest('[data-turn-handle]')
      if(turning&&['ArrowLeft','ArrowRight'].includes(e.key)){e.preventDefault();this.turn(e.key==='ArrowRight'?12:-12);this.velocity=0;this.acceleration=0;return}
      if(e.target.closest('#pulling-ring,#tab-purchase-hit')&&!this.model.wireframe){
        if(['Enter',' '].includes(e.key)){e.preventDefault();if(e.repeat)return;if(this.pull)this.finishPull(false);else this.beginPull({})}
        else if(this.pull&&e.key.startsWith('Arrow')){e.preventDefault();this.pull.dx+=e.key==='ArrowRight'?12:e.key==='ArrowLeft'?-12:0;this.pull.dy+=e.key==='ArrowDown'?12:e.key==='ArrowUp'?-12:0;this.draw()}
        else if(e.key==='Escape')this.finishPull(true)
      }
      if(e.target.closest('#feed-purchase')&&!this.model.accomplished){
        if(['Enter',' '].includes(e.key)){e.preventDefault();if(e.repeat)return;if(this.feed)this.finishFeed();else this.feed={keyboard:true}}
        else if(this.feed&&['ArrowLeft','ArrowRight','ArrowUp','ArrowDown','PageUp','PageDown'].includes(e.key)){
          e.preventDefault();const d=this.draft
          this.draft=furnishedStick(clamp(d.yaw+(e.key==='ArrowRight'?6:e.key==='ArrowLeft'?-6:0),-60,60),clamp(d.pitch+(e.key==='ArrowUp'?6:e.key==='ArrowDown'?-6:0),-45,45),clamp(d.extension+(e.key==='PageUp'?.25:e.key==='PageDown'?-.25:0),0,1),d.length);this.draw()
        }else if(e.key==='Escape'){this.feed=null;this.draft=furnishedStick(0,0,0);this.draw()}
      }
    }
    this.click=e=>{const relation=e.target.closest('svg [data-held-relation]')?.dataset.heldRelation;if(relation&&!e.target.closest('[data-turn-handle],#pulling-ring,#tab-purchase-hit,#feed-purchase'))this.pushEvent('inspect',{relation})}
    this.svg.addEventListener('pointerdown',this.down);this.svg.addEventListener('pointermove',this.move);this.svg.addEventListener('pointerup',this.up);this.svg.addEventListener('pointercancel',this.cancel);this.svg.addEventListener('keydown',this.key);this.svg.addEventListener('click',this.click)
    this.read()
  },
  animate(){
    if(this.frame||this.reduced.matches)return
    let last=performance.now()
    const step=now=>{
      this.frame=null;if(this.gone)return
      const dt=Math.min(.05,(now-last)/1000);last=now
      this.swing=suspensionStep(this.swing,this.velocity,this.acceleration,dt,this.model.purchase.length)
      this.offset=settleOffset(this.offset,this.target,dt)
      this.acceleration*=.7
      if(!this.turning)this.velocity*=.7
      this.draw()
      const energy=Math.abs(this.swing.x)+Math.abs(this.swing.z)+Math.abs(this.swing.vx)+Math.abs(this.swing.vz)+Math.hypot(...this.offset.map((v,i)=>v-this.target[i]))
      if(energy>.001||this.turning)this.frame=requestAnimationFrame(step)
    }
    this.frame=requestAnimationFrame(step)
  },
  draw(){
    if(!this.model?.sheet)return
    const used=new Set(),ns='http://www.w3.org/2000/svg',pivot=this.regard.bearing
    const path=(id,points,klass,relation,closed=false)=>{
      used.add(id);let node=this.nodes.get(id)
      if(!node){node=document.createElementNS(ns,'path');node.id=id;this.svg.append(node);this.nodes.set(id,node)}
      node.setAttribute('d',points.map((p,i)=>`${i?'L':'M'}${project(p,pivot).map(n=>n.toFixed(3)).join(',')}`).join(' ')+(closed?' Z':''));node.setAttribute('class',klass)
      if(relation)node.dataset.heldRelation=relation
      return node
    }
    const square=(id,c,h,klass,relation)=>path(id,[[c[0]-h,c[1]-h,c[2]],[c[0]+h,c[1]-h,c[2]],[c[0]+h,c[1]+h,c[2]],[c[0]-h,c[1]+h,c[2]],[c[0]-h,c[1]-h,c[2]]],klass,relation,true)
    const s=this.model.sheet,side=Math.cos(radians(pivot))>=0?'front':'back'
    path('planar-sheet',[[-s.half_width,-s.half_height,0],[s.half_width,-s.half_height,0],[s.half_width,s.half_height,0],[-s.half_width,s.half_height,0]],`opening-sheet sheet-${side}`,null,true)
    path('opening-circle',ringPoints(this.model.circle.center,[this.model.circle.radius,this.model.circle.radius,0]),'opening-circle','opening-circle-available')
    const purchase=this.model.purchase
    path('purchase-anchor',ringPoints(purchase.anchor,[purchase.anchor_radius,purchase.anchor_radius,0]),'purchase-anchor')
    const displacement=this.pull?[this.pull.dx/65*Math.cos(radians(pivot)),-this.pull.dy/65,this.pull.dx/65*Math.sin(radians(pivot))]:[0,0,0],tab=suspendedTab(purchase,this.swing,displacement)
    path('hanging-string',[purchase.anchor,[tab[0],tab[1]+purchase.tab_half,tab[2]]],'hanging-string')
    const outer=square('pulling-ring',tab,purchase.tab_half,'square-pull-tab'),inner=square('pull-tab-hollow',tab,purchase.hollow_half,'pull-tab-hollow')
    outer.setAttribute('tabindex',this.model.wireframe?'-1':'0');outer.setAttribute('role','button');outer.setAttribute('aria-label','Grasp hollow square pull tab. Enter, arrow, Enter.');outer.dataset.worldCenter=JSON.stringify(tab)
    outer.setAttribute('d',outer.getAttribute('d')+' '+inner.getAttribute('d'));outer.setAttribute('fill-rule','evenodd');inner.style.pointerEvents='none'
    const tabHit=square('tab-purchase-hit',tab,.38,'tab-purchase-hit');tabHit.setAttribute('aria-hidden','true')
    // This local course carries the four Regarding purchases, not XT/YT standing.
    const course=Array.from({length:49},(_,i)=>{const a=-Math.PI*.7+i*Math.PI*1.4/48;return [Math.sin(a)*1.8,-3.25,Math.cos(a)*.65]})
    path('turning-course',course,'turning-course')
    for(let i=0;i<4;i++){
      const index=[6,18,30,42][i],center=course[index],handle=square(`turn-handle-${i}`,center,.2,'turn-handle')
      handle.dataset.turnHandle=String(i);handle.setAttribute('tabindex','0');handle.setAttribute('role','button');handle.setAttribute('aria-label',`Turning handle ${i+1}. Drag or use left and right arrows.`)
    }
    if(this.model.diorama){
      const mechanism=dioramaMechanism(this.opening),wedge=floorWall(this.model.diorama.reference,this.opening)
      for(const face of ['floor','wall']){
        const node=path(`wedge-${face}`,wedge[face],`diorama-${face}`,'opening-accomplished',true)
        node.style.opacity=String(this.opening*.85);node.style.pointerEvents=this.opening>.05?'auto':'none'
        node.dataset.reference='opening-accomplished';node.dataset.angle='90'
      }
      const rail=side=>Array.from({length:33},(_,i)=>dioramaMechanism(i/32)[side])
      path('human-push-rail',rail('human'),'diorama-rail')
      path('cob-pull-rail',rail('cob'),'diorama-rail')
      const human=square('human-push-handle',mechanism.human,.28,'diorama-human-handle')
      human.setAttribute('tabindex','0');human.setAttribute('role','slider')
      human.setAttribute('aria-label','Human pretending PUSH BACK. Drag upward to open, downward to return.')
      human.setAttribute('aria-describedby','diorama-operation-notice')
      human.setAttribute('aria-orientation','vertical');human.setAttribute('aria-valuemin','0');human.setAttribute('aria-valuemax','100')
      human.setAttribute('aria-valuenow',String(Math.round(this.opening*100)))
      human.setAttribute('aria-valuetext',`${Math.round(this.opening*100)} percent open; COB cooperatively PULLS TOWARD YT FROM XT`)
      const cooperative=square('cob-pull-handle',mechanism.cob,.23,'diorama-cob-handle')
      cooperative.setAttribute('aria-label','COB cooperative PULL derived from Human PUSH')
      path('cob-cooperative-purchase',[this.model.stick.tip,mechanism.cob],'diorama-coupling')
      this.el.dataset.dioramaOpening=String(this.opening)
    }
    if(this.model.wireframe)wireframeEdges(this.model.wireframe.min,this.model.wireframe.max).forEach((edge,i)=>path(`wireframe-${i}`,edge,'opening-wire','opening-accomplished'))
    const cob=this.model.cob
    if(this.model.janusite){
      const extent=this.model.janusite
      for(const plane of ['xy','xz','yz'])path(`janusite-${plane}`,ringPoints(extent.center,extent.radii,plane),'janusite-extent','janusite-extent-standing')
      const stick=this.model.stick||this.model.locked||this.draft,active=stick.extension>0
      const arrival=active?stick.extension:0,rest=add(cob.center,this.offset),goal=active?add(stick.tip,[0,.32,0]):rest
      const center=add(add(scale(rest,1-arrival),scale(goal,arrival)),this.model.accomplished?scale(this.offset,.1):[0,0,0]),direction=active?stick.direction:[0,0,1]
      const body=path('rounded-cob',ringPoints(center,cob.radii,'xy',direction),'rounded-cob','cob-standing',true)
      body.dataset.orientation=JSON.stringify(direction)
      for(const plane of ['xz','yz'])path(`rounded-cob-${plane}`,ringPoints(center,cob.radii,plane,direction),'cob-meridian','cob-standing')
      const contactCenter=active?add(scale(center,1-arrival),scale(stick.tip,arrival)):center
      const contacts=graspPoints(contactCenter,direction,arrival)
      contacts.forEach((contact,i)=>{
        const start=add(center,scale(contact.map((v,k)=>v-center[k]),.7))
        path(`cob-grasp-${i}`,[start,contact],'cob-grasp',this.model.accomplished?'cob-grasp-standing':null)
      })
      square('square-aperture',this.model.aperture.center,this.model.aperture.half_size,'square-aperture','aperture-available')
      if(active){
        const radius=.16
        path('receiving-cylinder-near',ringPoints(stick.origin,[radius,radius,0],'xy',direction),'receiving-cylinder',this.model.accomplished?'receiving-cylinder-standing':null)
        path('receiving-cylinder-far',ringPoints(stick.tip,[radius,radius,0],'xy',direction),'receiving-cylinder')
        const nearRing=ringPoints(stick.origin,[radius,radius,0],'xy',direction),farRing=ringPoints(stick.tip,[radius,radius,0],'xy',direction),near=[0,16,32,48].map(i=>nearRing[i]),far=[0,16,32,48].map(i=>farRing[i])
        near.forEach((p,i)=>path(`cylinder-rail-${i}`,[p,far[i]],'receiving-cylinder'))
        path('pretending-stick',[stick.origin,stick.tip],this.model.accomplished?'appointed-stick':'staging-stick',this.model.accomplished?'pointingable-standing':null)
      }
      // A short material purchase is offered AT the aperture, not a remote control.
      if(!this.model.accomplished){
        const feed=path('feed-purchase',[[-.18,-.65,-.45],[0,0,0]],'feed-purchase')
        feed.setAttribute('tabindex','0');feed.setAttribute('role','button');feed.setAttribute('aria-label','Grasp and feed THROUGH aperture. Enter, arrows to aim, Page Up to feed, Enter to release.')
      }
    }else if(cob)square('square-cob',cob.center,cob.half_size,'square-cob','cob-square-standing')
    for(const [id,node]of this.nodes)if(!used.has(id)){node.remove();this.nodes.delete(id)}
    this.el.dataset.pivot=String(pivot);this.el.dataset.scope=this.regard.scope;this.el.dataset.side=side
    this.el.querySelector('#regarding-condition').textContent=`REGARDING ${side} · the page · ${this.model.accomplished?'ACCOMPLISHED STANDING':this.feed||this.pull?'STAGING FOR STANDING':this.model.janusite?'JANUSITE extent':this.model.wireframe?'inherited wireframe':'planar page / suspended purchase'}`
  },
  updated(){this.read()},
  disconnected(){this.pull=null;this.feed=null;this.turning=null;this.pushing=null;this.opening=0;this.draw()},
  reconnected(){this.pushEvent('abandon-purchase',{})},
  destroyed(){
    this.gone=true;if(this.frame)cancelAnimationFrame(this.frame)
    for(const [name,fn]of[['pointerdown',this.down],['pointermove',this.move],['pointerup',this.up],['pointercancel',this.cancel],['keydown',this.key],['click',this.click]])this.svg.removeEventListener(name,fn)
  }
}
