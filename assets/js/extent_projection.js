// Keyed projection of domain-supplied standing. No camera travel and no domain decisions.
const UNIT = 30
const radians = n => n * 180 / Math.PI
export function pointAlong(points, t) {
  const x = Math.max(0, Math.min(1, t)) * (points.length - 1)
  const i = Math.min(points.length - 2, Math.floor(x)), f = x - i
  return points[i].map((v, axis) => v + (points[i + 1][axis] - v) * f)
}
export function segmentStyle(a, b) {
  const dx = b[0]-a[0], dy = -(b[1]-a[1]), dz = b[2]-a[2]
  const length = Math.hypot(dx,dy,dz)
  return {width: `${length * UNIT}px`, transform: `translate3d(${a[0]*UNIT}px,${-a[1]*UNIT}px,${a[2]*UNIT}px) rotateY(${-radians(Math.atan2(dz,dx))}deg) rotateZ(${radians(Math.atan2(dy,Math.hypot(dx,dz)))}deg)`}
}
export const ExtentProjection = {
  mounted() {
    this.nodes = new Map()
    this.world = document.createElement('div'); this.world.className = 'constitutional-world'; this.el.append(this.world)
    this.offset = 0; this.last = null
    this.click = event => {
      const character = event.target.closest('[data-material]')
      if (character) this.pushEvent('material', {material: character.dataset.material})
      else {
        const relation = event.target.closest('[data-relation]')
        if (relation) this.pushEvent('inspect', {relation: relation.dataset.relation})
      }
    }
    this.key = event => { if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); this.click(event) } }
    this.el.addEventListener('click',this.click); this.el.addEventListener('keydown',this.key)
    this.read()
    this.frame = now => {
      if (this.last !== null && !this.model.selected_material && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) this.offset = (this.offset + Math.min(now-this.last,100)*0.000025)%1
      this.last = now; this.material(); this.raf = requestAnimationFrame(this.frame)
    }
    this.raf = requestAnimationFrame(this.frame)
  },
  node(id, cls, text = '', parent = this.world) {
    if (!this.nodes.has(id)) {
      const el = document.createElement('div'); el.id = id; el.className = cls; el.textContent = text
      parent.append(el); this.nodes.set(id,el)
    }
    return this.nodes.get(id)
  },
  position(el, p, suffix = '') { el.style.transform = `translate3d(${p[0]*UNIT}px,${-p[1]*UNIT}px,${p[2]*UNIT}px) ${suffix}` },
  line(id, a, b, cls, relation) {
    const el = this.node(id,`world-segment ${cls}`); Object.assign(el.style,segmentStyle(a,b)); el.dataset.relation = relation; el.title = relation
  },
  read() {
    this.model = JSON.parse(this.el.dataset.model)
    const {objects,view,extent} = this.model
    this.world.style.transform = `rotateX(${view.tilt}deg) rotateY(${view.turn}deg)`
    this.world.dataset.bearing = this.model.bearing
    const volume = objects.landinging
    const diameter = volume.radius*2*UNIT
    const top = this.node('landinging-top','landinging-disc top-disc')
    const bottom = this.node('landinging-bottom','landinging-disc bottom-disc')
    for (const [el,y] of [[top,volume.top],[bottom,volume.bottom]]) {
      el.style.width = `${diameter}px`; el.style.height = `${diameter}px`
      this.position(el,[0,y,0],'translate(-50%,-50%) rotateX(90deg)'); el.dataset.relation = volume.relation
    }
    for (let i=0;i<24;i++) {
      const angle = i*2*Math.PI/24, side = this.node(`landinging-side-${i}`,'landinging-side')
      side.style.width = `${2*volume.radius*Math.tan(Math.PI/24)*UNIT+1}px`; side.style.height = `${(volume.top-volume.bottom)*UNIT}px`
      this.position(side,[volume.radius*Math.sin(angle),(volume.top+volume.bottom)/2,volume.radius*Math.cos(angle)],`translate(-50%,-50%) rotateY(${radians(angle)}deg)`)
      side.dataset.relation = volume.relation
    }
    const square = objects['center-square'], sq = this.node(square.id,'center-square','')
    sq.style.width = `${square.size*UNIT}px`; sq.style.height = `${square.size*UNIT}px`
    this.position(sq,square.position,'translate(-50%,-50%) rotateX(90deg)'); sq.dataset.relation = square.relation; sq.setAttribute('aria-label','The same already-standing center square'); sq.tabIndex = 0
    this.el.dataset.squareIdentity = square.id
    const fountain = this.node('fountaining','fountaining-body','F'); this.position(fountain,objects.fountaining.position); fountain.dataset.relation = objects.fountaining.relation
    const points = objects['xt-course'].points
    const piping = objects['underlying-track']?.points || points
    piping.slice(1).forEach((p,i) => this.line(`track-segment-${i}`,piping[i],p,'track-segment','track-standing'))
    points.slice(1).forEach((p,i) => this.line(`xt-rail-segment-${i}`,points[i],p,'xt-rail-segment','xt-upon-track'))
    const xt = this.node('xt-bearing','world-label','XT / ALONG THROUGH'); this.position(xt,[-2,5.6,1],this.billboard()); xt.dataset.relation = 'xt-standing'
    const legend = this.node('cubical-readiness','world-label cubical-readiness','CUBICAL · READYINGMENTING TOWARD EN-FURNISHINGMENTING'); this.position(legend,[-4,-3,4.6],this.billboard()); legend.dataset.relation='extent-readying'
    const cob = this.node('cob-appliance','cob-appliance'); cob.dataset.relation = 'cob-standing'; cob.setAttribute('aria-label','COB already standing, a responsive appliance without a face')
    const light = this.node('cob-appliance-light','cob-appliance-light','',cob); light.dataset.active = String(extent>0)
    this.position(cob,objects['cob-appliance'].resolved_position,this.billboard())
    const chain = objects['cob-chain'].resolved_points
    chain.slice(1).forEach((p,i) => this.line(`cob-chain-segment-${i}`,chain[i],p,'cob-chain-segment','cob-chain-standing'))
    const chainRoot = this.node('cob-chain','world-label chain-purchase','COB / SAME STOOD CHAIN'); this.position(chainRoot,[.8,-2.7,-.3],this.billboard()); chainRoot.dataset.relation = 'cob-chain-standing'; chainRoot.dataset.embeddingRelation = this.model.cob_embedding_relation || ''
    if (objects.spindle) {
      const spindle = this.node('spindle','world-spindle')
      spindle.style.height = `${objects.spindle.extent*UNIT}px`; spindle.style.width = '18px'
      this.position(spindle,[0,objects.spindle.extent/2,0],'translate(-50%,-50%)'); spindle.dataset.relation = objects.spindle.relation; spindle.dataset.extent = String(objects.spindle.extent)
      // Crossed axial surfaces represent finite extent; the center square is never moved.
      const cross = this.node('spindle-cross','world-spindle-cross','',spindle); cross.style.height = '100%'
    }
    this.material()
  },
  billboard() { return `rotateY(${-this.model.view.turn}deg) rotateX(${-this.model.view.tilt}deg)` },
  material() {
    if (!this.model) return
    const points = this.model.objects['xt-course'].points
    for (const item of this.model.material) {
      const el = this.node(item.id,'fountaining-character',item.glyph)
      this.position(el,pointAlong(points,(item.purchase+this.offset)%1),this.billboard())
      el.dataset.courseParameter = String((item.purchase+this.offset)%1); el.dataset.material = item.id; el.dataset.relation = item.relation; el.tabIndex = 0
      el.dataset.held = String(this.model.selected_material === item.id); el.title = `${item.id} · same stood material ALONG THROUGH XT`
    }
  },
  updated() { this.read() },
  destroyed() { cancelAnimationFrame(this.raf); this.el.removeEventListener('click',this.click); this.el.removeEventListener('keydown',this.key) }
}
