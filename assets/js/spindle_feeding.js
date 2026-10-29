export const inside = (rect,x,y) => !!rect && x>=rect.left && x<=rect.right && y>=rect.top && y<=rect.bottom
export const SpindleFeeding = {
  mounted() {
    this.button = this.el.querySelector('#feed-stick'); this.live = this.el.querySelector('.feed-live'); this.ghost = this.el.querySelector('.feed-ghost'); this.gesture = null
    this.begin = (kind,event) => {
      if (this.gesture || this.el.dataset.disabled==='true') return
      const g = {kind,pointerId:event?.pointerId,token:null,stage:0,baseY:null,extent:Number(this.el.dataset.extent),desired:Number(this.el.dataset.extent),busy:false,ended:false}
      this.gesture = g
      this.pushEvent('start-feed',{},reply => { if (!reply.accepted) {this.gesture=null;return} g.token=reply.token; g.extent=reply.extent; g.startExtent=reply.extent; g.desired=Math.max(g.desired,reply.extent); this.flush(g) })
      this.ghost.style.opacity='0.6'; this.live.textContent = 'Take the Stick through your Square FOR Regarding.'
    }
    this.flush = g => {
      if (!g.token || g.busy) return
      const nextSquare = g.sentStage||0
      if (nextSquare < g.stage) {
        g.busy=true
        this.pushEvent('feed-through',{token:g.token,square:nextSquare===0?'regarding-square':'center-square'},reply=>{g.busy=false;if(reply.accepted){g.sentStage=nextSquare+1;this.flush(g)}else{this.gesture=null}})
      } else if (g.stage===2 && g.extent<g.desired) {
        g.busy=true
        this.pushEvent('feed',{token:g.token,extent:g.extent+1},reply=>{g.busy=false;if(reply.accepted){g.extent=reply.extent;this.flush(g)}else{this.gesture=null}})
      } else if (g.ended) { this.pushEvent('cancel-feed',{token:g.token}); this.gesture=null }
    }
    this.finish = () => { const g=this.gesture;if(!g)return;g.ended=true;this.ghost.style.transform='';this.ghost.style.opacity='0';this.flush(g) }
    this.move = event => {
      const g=this.gesture;if(!g || g.kind!=='pointer' || g.pointerId!==event.pointerId || g.ended)return
      const rect=this.el.getBoundingClientRect();this.ghost.style.transform=`translate(${event.clientX-rect.left}px,${event.clientY-rect.top}px)`
      if(g.stage===0 && inside(this.el.querySelector('#square-for-regarding').getBoundingClientRect(),event.clientX,event.clientY)){g.stage=1;this.live.textContent='Now UP THROUGH the already-standing center square.'}
      const center=document.querySelector('#center-square')
      if(g.stage===1 && center && inside(center.getBoundingClientRect(),event.clientX,event.clientY)){g.stage=2;g.baseY=event.clientY;this.live.textContent='Continue feeding UP. The Spindle rises; the square stays.'}
      if(g.stage===2)g.desired=Math.min(Number(this.el.dataset.limit),Math.max(g.desired,(g.startExtent??g.extent)+Math.floor(Math.max(0,g.baseY-event.clientY)/24)))
      this.flush(g)
    }
    this.down = e=>{if(e.button!==undefined&&e.button!==0)return;e.preventDefault();this.begin('pointer',e);if(this.gesture)this.button.setPointerCapture(e.pointerId)}
    this.up = e=>{if(this.gesture?.kind==='pointer' && this.gesture.pointerId===e.pointerId)this.finish()}
    this.blur = ()=>{if(this.gesture?.kind==='keyboard')this.finish()}
    this.key = e=>{
      if(![' ','Enter','r','R','c','C','ArrowUp','Escape'].includes(e.key))return;e.preventDefault()
      if(e.key==='Escape'){this.finish();return}
      if(!this.gesture){if(e.key===' '||e.key==='Enter')this.begin('keyboard',e);return}
      const g=this.gesture;if(g.kind!=='keyboard')return
      if((e.key==='r'||e.key==='R')&&g.stage===0)g.stage=1
      if((e.key==='c'||e.key==='C')&&g.stage===1)g.stage=2
      if(e.key==='ArrowUp'&&g.stage===2)g.desired=Math.min(Number(this.el.dataset.limit),g.desired+1)
      this.flush(g)
    }
    this.button.addEventListener('pointerdown',this.down);this.button.addEventListener('pointermove',this.move);this.button.addEventListener('pointerup',this.up);this.button.addEventListener('pointercancel',this.up);this.button.addEventListener('keydown',this.key);this.button.addEventListener('blur',this.blur)
  },
  disconnected(){if(this.gesture){this.gesture.ended=true;this.gesture.desired=this.gesture.extent}this.gesture=null;this.ghost.style.opacity='0'},
  reconnected(){this.pushEvent('abandon-purchase',{})},
  updated(){this.button.disabled=this.el.dataset.disabled==='true'},
  destroyed(){this.finish();this.button.removeEventListener('pointerdown',this.down);this.button.removeEventListener('pointermove',this.move);this.button.removeEventListener('pointerup',this.up);this.button.removeEventListener('pointercancel',this.up);this.button.removeEventListener('keydown',this.key);this.button.removeEventListener('blur',this.blur)}
}
