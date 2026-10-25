// Continuous NAV is projection instrumentation. Its position, velocity, tacks,
// lateral bias and sheet tension never become constitutional Standing.
export function advanceMotion(state, input, elapsed) {
  const dt = Math.min(.05, Math.max(0, elapsed))
  const desired = Math.max(-1, Math.min(1, input.along || 0))
  let velocity = state.velocity || 0
  velocity = desired ? Math.max(-1.5, Math.min(1.5, velocity + desired * 1.8 * dt)) : velocity * Math.exp(-2.8 * dt)
  if (Math.abs(velocity) < .003) velocity = 0
  let position = state.position + velocity * dt
  if (position <= 0 || position >= 6) { position = Math.max(0, Math.min(6, position)); velocity = 0 }
  const target = Math.max(-.65, Math.min(.65, input.across || 0))
  const across = state.across + (target - state.across) * (1 - Math.exp(-5 * dt))
  return {position, velocity, across}
}

export function elbowPoint(t, across = 0) {
  const u = Math.max(0, Math.min(1, t)), a = 1 - u
  const x = a*a*(-120) + 2*a*u*900 + u*u*900
  const y = a*a*630 + 2*a*u*630 + u*u*270
  const dx = 2040*a, dy = -720*u, magnitude = Math.hypot(dx,dy)
  return {x: x - dy/magnitude * across*100, y: y + dx/magnitude * across*100}
}
export function tensionFor(corners, amount) {
  return Math.min(new Set(corners).size >= 2 ? 1 : .55, Math.max(0, amount))
}

const svgNS = 'http://www.w3.org/2000/svg'
const clamp = (x, lo, hi) => Math.max(lo, Math.min(hi, x))
const svgElement = (name, attrs) => {
  const el = document.createElementNS(svgNS, name)
  for (const [key, value] of Object.entries(attrs)) el.setAttribute(key, value)
  return el
}

// One bounded Human range per running app visit; no durable projection record.
let readableProfile = 1
export const boundedScale = value => clamp(Number.isFinite(value) ? value : 1, .85, 1.15)
export const tackCount = (length, sheets) => clamp(Math.ceil(length * 2 + sheets * 2), 16, 48)
export function regardDirection(dx, dy) {
  if (Math.hypot(dx, dy) < 42) return null
  return Math.abs(dy) > Math.abs(dx) ? (dy > 0 ? 'down' : 'up') : (dx > 0 ? 'yt' : 'xt')
}
export function sheetPlacement(course, position, side) {
  const distance = course - position
  const point = elbowPoint(clamp(.36 + distance * .12, .06, .92), side * .5)
  return {x: clamp(point.x / 10 + side * 12, 10, 88), y: clamp(point.y / 6.8 - 38, 8, 58),
    turn: -side * 58, scale: clamp(1 - Math.abs(distance) * .12, .55, 1), available: Math.abs(distance) <= 2.5}
}

export const QuietLocality = {
  mounted() {
    this.cleanups = []
    this.listen = (node, name, handler, options) => {
      node.addEventListener(name, handler, options)
      this.cleanups.push(() => node.removeEventListener(name, handler, options))
    }
    this.part = name => this.el.querySelector(`[data-part="${name}"]`)
    this.svg = this.el.querySelector('svg')
    this.scene = JSON.parse(this.el.dataset.scene)
    this.motion = {position: 0, velocity: 0, across: 0}
    this.input = {along: 0, across: 0}
    this.cursor = {x: 500, y: 550}
    this.body = {x: 500, y: 550}
    this.pointer = {drawn: false, held: false, angle: -40, turned: false, peak: 0, emergence: 1}
    this.sheet = {id: null, corners: [], tension: 0}
    this.regard = 'center'
    this.sweep = 1
    this.scale = readableProfile
    this.pressed = false
    this.lastSample = 0
    this.raf = null
    this.coordinate = event => new DOMPoint(event.clientX, event.clientY).matrixTransform(this.svg.getScreenCTM().inverse())
    this.buildMaterials = () => {
      this.part('sheets').replaceChildren()
      this.part('provenance').replaceChildren()
      this.part('sheet-attachments').replaceChildren()
      this.part('tacks').replaceChildren()
      this.tacks = Array.from({length: tackCount(this.scene.courseLength || 6, this.scene.sheets.length)}, () => {
        const mark = svgElement('path', {class: 'quiet-nav-tack'})
        this.part('tacks').append(mark)
        return mark
      })
      this.sheetNodes = new Map()
      for (const [index, material] of this.scene.sheets.entries()) {
        const node = this.part('sheet-template').content.firstElementChild.cloneNode(true)
        node.dataset.sheet = material.id
        node.setAttribute('aria-label', `Take ${material.title} through the Inner Aperture`)
        node.querySelector('h2').textContent = material.title
        node.querySelector('.quiet-sheet-text').textContent = material.text
        node.style.setProperty('--sheet-width', `${clamp(230 + material.text.length * .12, 230, 410)}px`)
        node.style.setProperty('--sheet-height', `${clamp(160 + material.text.length * .25, 180, 345)}px`)
        this.part('sheets').append(node)
        const attachment = svgElement('path', {class: 'quiet-sheet-attachment'})
        this.part('sheet-attachments').append(attachment)
        this.sheetNodes.set(material.id, {node, material, attachment, side: index % 2 ? 1 : -1})
      }
      const from = svgElement('text', {class: 'quiet-floor-from'})
      from.textContent = `FROM ${this.scene.from || ''}`
      this.part('provenance').append(from)
      this.provenance = [{text: from, index: 0}, ...this.scene.provenance.map((relation, index) => {
        const text = svgElement('text', {class: 'quiet-floor-relation'})
        text.textContent = `${relation.subject} → ${relation.predicate} → ${relation.object}`
        this.part('provenance').append(text)
        return {text, index: index + 1}
      })]
      this.part('provenance').setAttribute('data-from', this.scene.from || '')
      const bearing = this.scene.bearing
      this.part('bearing-inscription').textContent = bearing ? `${bearing.from} · ALONG THROUGH · TOWARD ${bearing.toward}` : ''
      this.part('bearing-regard').dataset.toward = bearing?.toward || ''
    }
    this.buildMaterials()
    this.renderContext = context => {
      const leaf = this.part('context').querySelector('.quiet-context-leaf')
      leaf.replaceChildren()
      const append = (tag, text, id) => {
        const node = document.createElement(tag)
        node.textContent = text
        if (id) node.dataset.material = id
        leaf.append(node)
      }
      for (const material of context?.materials || []) {
        append('h3', material.title, material.id)
        append('p', material.text, material.id)
      }
      for (const relation of context?.relations || []) {
        append('h3', `${relation.subject} → ${relation.predicate} → ${relation.object}`, relation.id)
        append('p', relation.provenance, relation.id)
      }
      for (const revision of context?.revisions || []) {
        append('p', `${revision.origin} · ${revision.action} · ${revision.revision}`)
      }
      this.part('context').dataset.origin = context?.origin || ''
    }
    this.sendMotion = () => {
      if (!this.scene.tunnel) return
      this.pushEvent('nav-motion', {position: this.motion.position, across: this.motion.across})
      this.lastSample = performance.now()
    }
    this.sheetEvent = (op, extra = {}) => this.pushEvent('sheet', {op, ...extra}, reply => {
      if (reply?.accepted === false && op === 'resolve') this.sheet = {id: null, corners: [], tension: 0}
    })
    this.pointerEvent = (op, extra = {}) => this.pushEvent('pointer', {op, ...extra})
    this.beginTool = () => {
      const op = this.pointer.drawn ? 'hold' : 'draw'
      if (!this.pointer.drawn) this.pointer.emergence = 0
      this.pointer.drawn = true
      this.pointer.held = true
      this.pointerEvent(op)
    }
    this.turnTool = angle => {
      this.pointer.angle = ((angle + 180) % 360 + 360) % 360 - 180
      this.pointer.turned = true
      this.pointer.peak = Math.max(this.pointer.peak, Math.abs(this.pointer.angle))
    }
    this.releaseTool = () => {
      if (!this.pointer.held) return
      this.pointerEvent('turn', {angle: this.pointer.turned ? this.pointer.peak : 0})
      this.pointerEvent('release')
      this.pointer.held = false
    }
    this.look = direction => {
      if (!this.scene.tunnel) return
      this.regard = direction
      if (direction === 'xt') this.sweep = -1
      if (direction === 'yt') this.sweep = 1
      if (direction === 'xt') {
        const material = this.sheetNodes.get(this.sheet.id)?.material
        this.renderContext(material?.context || this.scene.context)
      }
      this.sheetEvent('regard', {direction})
    }
    this.resolve = id => {
      const record = this.sheetNodes.get(id)
      if (!record || !sheetPlacement(record.material.course, this.motion.position, record.side).available) return
      this.sendMotion()
      this.sheet = {id, corners: [], tension: 0}
      this.motion.velocity *= .2
      this.input = {along: 0, across: 0}
      this.regard = 'yt'
      this.sweep = 1
      this.renderContext(record.material.context)
      this.part('inner-aperture').dataset.material = id
      this.sheetEvent('resolve', {id})
    }
    this.relinquish = () => {
      this.sheet = {id: null, corners: [], tension: 0}
      this.regard = 'center'
      this.sweepDrag = null
      this.input.across = 0
      this.part('inner-aperture').dataset.material = ''
      this.sheetEvent('relinquish')
    }
    this.calibrate = amount => {
      this.scale = boundedScale(this.scale + amount)
      readableProfile = this.scale
      this.sheetEvent('calibrate', {scale: this.scale})
    }
    this.startSweep = (point, pointerId) => { this.sweepDrag = {x: point.x, y: point.y, id: pointerId, direction: null} }
    this.listen(this.el, 'pointermove', event => {
      const point = this.coordinate(event)
      this.cursor = {x: clamp(point.x, 85, 915), y: clamp(point.y, 120, 610)}
      if (this.pointer.held) this.turnTool(Math.atan2(point.y - this.body.y, point.x - this.body.x) * 180 / Math.PI + 16)
      if (this.sweepDrag?.id === event.pointerId) {
        const direction = regardDirection(point.x - this.sweepDrag.x, point.y - this.sweepDrag.y)
        if (direction && direction !== this.sweepDrag.direction) {
          this.sweepDrag.direction = direction
          this.look(direction)
        }
      } else if (this.floorDrag?.id === event.pointerId) this.input.across = clamp((point.x - this.floorDrag.x) / 220, -.65, .65)
    })
    this.listen(this.el, 'pointerdown', event => {
      if (event.button !== 0) return
      const point = this.coordinate(event)
      this.cursor = {x: clamp(point.x, 85, 915), y: clamp(point.y, 120, 610)}
      this.pressed = true
      const nav = event.target.closest('[data-nav]')
      const sheet = event.target.closest('[data-sheet]')
      const target = event.target.closest('[data-room-target]')
      const grip = event.target.closest('[data-inner-grip], [data-part="regard-purchase"]')
      const release = event.target.closest('[data-inner-release]')
      if (!this.scene.tunnel && !this.scene.entered) return
      if (this.scene.tunnel) {
        if (release) this.relinquish()
        else if (nav) {
          if (this.sheet.id) this.relinquish()
          const direction = nav.dataset.nav
          if (direction === 'forward' || direction === 'back') this.input.along = direction === 'forward' ? 1 : -1
          else this.input.across = direction === 'right' ? .65 : -.65
        } else if (grip) this.startSweep(point, event.pointerId)
        else if (sheet) {
          if (this.sheet.id === sheet.dataset.sheet && event.target.closest('.quiet-sheet-writing')) return
          this.resolve(sheet.dataset.sheet)
          this.startSweep(point, event.pointerId)
        } else this.floorDrag = {id: event.pointerId, x: point.x}
      } else if (target) this.beginTool()
      else return
      event.preventDefault()
      this.el.setPointerCapture(event.pointerId)
    })
    const release = () => {
      this.pressed = false
      this.input.along = 0
      this.input.across = 0
      this.sweepDrag = null
      this.floorDrag = null
      this.releaseTool()
      if (this.scene.tunnel) this.sendMotion()
    }
    this.listen(this.el, 'pointerup', release)
    this.listen(this.el, 'pointercancel', release)
    this.listen(window, 'blur', release)
    this.listen(document, 'visibilitychange', () => { if (document.hidden) release() })
    this.listen(this.el, 'pointerleave', () => { if (!this.pressed) this.cursor = {x: 500, y: 550} })
    this.listen(this.el, 'keydown', event => {
      const arrows = {ArrowLeft: 'xt', ArrowRight: 'yt', ArrowUp: 'up', ArrowDown: 'down'}
      const nav = event.target.closest('[data-nav]')
      if (event.key === 'Escape') { if (this.scene.tunnel) this.relinquish(); this.releaseTool(); return }
      if (this.scene.tunnel) {
        if (event.target.closest('.quiet-sheet-writing, .quiet-context-leaf') && !event.altKey) return
        if (event.altKey && arrows[event.key]) { event.preventDefault(); this.look(arrows[event.key]); return }
        if (event.target.closest('[data-part="inner-aperture"]') && ['+', '=', '-'].includes(event.key)) {
          event.preventDefault(); this.calibrate(event.key === '-' ? -.025 : .025); return
        }
        if (['Enter', ' '].includes(event.key) && event.target.closest('[data-inner-release]')) {
          event.preventDefault(); this.relinquish(); return
        }
        const sheet = event.target.closest('[data-sheet]')
        if (sheet && ['Enter', ' '].includes(event.key)) { event.preventDefault(); this.resolve(sheet.dataset.sheet); return }
        if (nav && ['Enter', ' '].includes(event.key)) {
          event.preventDefault()
          if (this.sheet.id) this.relinquish()
          const direction = nav.dataset.nav
          if (direction === 'forward' || direction === 'back') this.input.along = direction === 'forward' ? 1 : -1
          else this.input.across = direction === 'right' ? .65 : -.65
          return
        }
        if (arrows[event.key]) {
          event.preventDefault()
          if (this.sheet.id) this.look(arrows[event.key])
          else if (event.key === 'ArrowUp' || event.key === 'ArrowDown') this.input.along = event.key === 'ArrowUp' ? 1 : -1
          else this.input.across = event.key === 'ArrowRight' ? .65 : -.65
        }
      } else if (this.scene.entered) {
        if (['Enter', ' '].includes(event.key) && event.target.closest('[data-room-target]')) {
          event.preventDefault(); this.pressed = true; this.beginTool()
        } else if (this.pointer.held && ['ArrowLeft', 'ArrowRight'].includes(event.key)) {
          event.preventDefault(); this.turnTool(this.pointer.angle + (event.key === 'ArrowRight' ? 15 : -15))
        }
      }
    })
    this.listen(this.el, 'keyup', event => {
      if (['ArrowUp', 'ArrowDown', 'Enter', ' '].includes(event.key)) this.input.along = 0
      if (['ArrowLeft', 'ArrowRight', 'Enter', ' '].includes(event.key)) this.input.across = 0
      if (['Enter', ' '].includes(event.key)) { this.pressed = false; this.releaseTool() }
    })
    this.listen(this.el, 'wheel', event => {
      if (event.ctrlKey && event.target.closest('[data-part="inner-aperture"]')) {
        event.preventDefault(); this.calibrate(Math.sign(-event.deltaY) * .025)
      } else if (this.pointer.held) {
        event.preventDefault(); this.turnTool(this.pointer.angle + Math.sign(event.deltaY) * 8)
      }
    }, {passive: false})
    this.renderScene = () => {
      const {tunnel, entered, wheel} = this.scene
      this.part('roundabout').setAttribute('display', !tunnel && !entered ? '' : 'none')
      this.part('room').setAttribute('display', !tunnel && entered ? '' : 'none')
      this.part('tunnel').setAttribute('display', tunnel ? '' : 'none')
      this.part('appointment').hidden = tunnel || entered
      this.part('nav').hidden = !tunnel
      this.el.classList.toggle('is-entered', entered)
      this.el.classList.toggle('is-tunnel', tunnel)
      this.part('gesture-hint').textContent = tunnel ? 'Skate; take up a sheet. Hold Bobbing or the aperture to sweep Regard.' : entered ? 'Point through Bobbing. Press the circle, hold, turn, release.' : ''
      const angle = wheel * Math.PI / 180
      this.part('appointment').style.left = `${50 + Math.sin(angle) * 31}%`
      this.part('appointment').style.top = `${28 + (1 - Math.cos(angle)) * 7}%`
      this.part('appointment').style.transform = `translateX(-50%) rotateY(${-Math.sin(angle) * 62}deg)`
    }
    this.renderScene()
    this.lastFrame = performance.now()
    this.renderSheet = (id, record) => {
      const {node, material, side, attachment} = record
      const base = sheetPlacement(material.course, this.motion.position, side)
      const selected = this.sheet.id === id
      node.hidden = !this.scene.tunnel || (!selected && !base.available)
      attachment.setAttribute('display', selected ? '' : 'none')
      if (node.hidden) return
      const tension = selected ? this.sheet.tension : 0
      const sweep = selected ? this.sweep : 1
      const targetX = sweep < 0 ? 84 : 58
      const x = base.x * (1 - tension) + targetX * tension
      const y = base.y * (1 - tension) + 12 * tension
      node.style.left = `${x}%`
      node.style.top = `${y}%`
      node.style.transform = `translateX(-50%) rotateY(${base.turn * (1 - tension) + (sweep < 0 ? -65 : 0) * tension}deg) scale(${base.scale * (1 - tension) + tension})`
      node.style.setProperty('--readable-scale', String(this.scale))
      node.classList.toggle('is-attending', selected)
      node.classList.toggle('is-square', tension > .98)
      node.classList.toggle('is-yt-privileged', selected && this.regard === 'yt')
      node.style.zIndex = selected ? '6' : '2'
      node.querySelector('.quiet-sheet-cloth path').setAttribute('d', tension > .98 ? 'M8 8 H392 V348 H8Z' : `M8 8 Q200 ${28 - 20 * tension} 392 8 L384 340 Q200 ${362 - 14 * tension} 16 340Z`)
      if (selected) {
        const rect = node.getBoundingClientRect()
        const end = this.coordinate({clientX: rect.x, clientY: rect.y})
        attachment.setAttribute('d', `M${base.x * 10} ${base.y * 6.8 - 24} Q${base.x * 10} ${end.y - 15} ${end.x} ${end.y}`)
      }
    }
    const frame = now => {
      const dt = Math.min(.05, (now - this.lastFrame) / 1000)
      this.lastFrame = now
      if (this.scene.tunnel) {
        this.motion = advanceMotion(this.motion, {along: this.sheet.id ? 0 : this.input.along, across: this.input.across}, dt)
        const point = elbowPoint(.27 + this.motion.position * .035, this.motion.across)
        const attend = this.sweepDrag ? .15 : .025
        this.body.x += (point.x + (this.cursor.x - 500) * attend - this.body.x) * (1 - Math.exp(-12 * dt))
        this.body.y += (point.y + (this.cursor.y - 500) * attend - this.body.y) * (1 - Math.exp(-12 * dt))
        this.tacks.forEach((tack, index) => {
          const t = ((index / this.tacks.length - this.motion.position * .23) % 1 + 1) % 1
          const p = elbowPoint(t, (index % 3 - 1) * .2)
          const extent = 2 + 4 * (1 - t)
          tack.setAttribute('d', `M${p.x - extent} ${p.y} l${extent} ${-extent / 2} l${extent} ${extent / 2}`)
          tack.style.opacity = String(.2 + (1 - t) * .35)
        })
        // Looking DOWN recovers the complete same FROM, at every NAV position.
        this.provenance.forEach(({text, index}) => {
          const t = .22 + index * .085 - (this.regard === 'down' ? 0 : this.motion.position * .04)
          const point = elbowPoint(clamp(t, 0, 1), -.35)
          text.setAttribute('x', point.x); text.setAttribute('y', point.y - 12)
          text.style.opacity = t > 0 && t < 1 ? '1' : '0'
        })
        this.part('motion-reading').textContent = `${this.motion.velocity < -.02 ? 'BACK' : this.motion.velocity > .02 ? 'ALONG' : 'SETTLING'} / ${Math.abs(this.motion.velocity).toFixed(1)}`
        if (now - this.lastSample > 150) this.sendMotion()
      } else {
        const target = this.scene.entered ? this.cursor : {x: 500 + (this.cursor.x - 500) * .3, y: 550 + (this.cursor.y - 550) * .15}
        this.body.x += (target.x - this.body.x) * (1 - Math.exp(-10 * dt))
        this.body.y += (target.y - this.body.y) * (1 - Math.exp(-10 * dt))
      }
      const lean = this.scene.tunnel ? this.motion.velocity * 6 : clamp((this.cursor.x - this.body.x) * .04, -8, 8)
      this.part('bobbing').setAttribute('transform', `translate(${this.body.x} ${this.body.y}) rotate(${lean}) scale(${this.pressed ? 1.08 : 1} ${this.pressed ? .88 : 1})`)
      this.part('pointing-tool').setAttribute('display', this.pointer.drawn && !this.scene.tunnel ? '' : 'none')
      this.pointer.emergence = Math.min(1, this.pointer.emergence + dt * 4)
      const emergence = this.pointer.emergence
      this.part('pointing-tool').setAttribute('transform', `translate(${500 * (1 - emergence) + this.body.x * emergence} ${482 * (1 - emergence) + this.body.y * emergence}) rotate(${this.pointer.angle}) scale(${emergence})`)
      this.part('pointing-tool').dataset.roomTarget = 'tool'
      const points = this.part('points').querySelectorAll('circle')
      const spread = this.pressed || this.pointer.held ? 23 : 34
      const offsets = [[-spread, -spread * .65], [spread, -spread * .65], [spread, spread * .65], [-spread, spread * .65]]
      points.forEach((point, i) => { point.setAttribute('cx', offsets[i][0]); point.setAttribute('cy', offsets[i][1]) })
      this.part('points').setAttribute('transform', `rotate(${this.pointer.held ? this.pointer.angle : 0})`)
      this.part('inner-aperture').hidden = !this.scene.tunnel || (!this.sheet.id && this.regard === 'center')
      if (this.sheet.id) {
        this.sheet.tension += (1 - this.sheet.tension) * (1 - Math.exp(-9 * dt))
        const rect = this.part('inner-aperture').getBoundingClientRect()
        const corners = [[rect.x, rect.y], [rect.x + rect.width, rect.y], [rect.x + rect.width, rect.y + rect.height], [rect.x, rect.y + rect.height]]
        points.forEach((point, i) => {
          const purchase = this.coordinate({clientX: corners[i][0], clientY: corners[i][1]})
          point.setAttribute('cx', purchase.x - this.body.x); point.setAttribute('cy', purchase.y - this.body.y)
        })
        this.part('points').setAttribute('transform', '')
      }
      for (const [id, record] of this.sheetNodes) this.renderSheet(id, record)
      const held = Boolean(this.sheet.id)
      const inner = this.part('inner-aperture')
      inner.hidden = !this.scene.tunnel || (!held && this.regard === 'center')
      inner.dataset.regard = this.regard
      inner.style.setProperty('--inner-scale', String(this.scale))
      this.part('context').hidden = !this.scene.tunnel || this.regard !== 'xt'
      this.part('context').style.setProperty('--readable-scale', String(this.scale))
      this.part('bearing-regard').style.opacity = this.regard === 'up' ? '1' : '0'
      this.part('bearing-regard').setAttribute('aria-hidden', String(this.regard !== 'up'))
      this.el.classList.toggle('is-looking-down', this.regard === 'down')
      this.el.classList.toggle('is-looking-up', this.regard === 'up')
      this.el.classList.toggle('is-looking-xt', this.regard === 'xt')
      this.el.classList.toggle('is-reading', held && this.sheet.tension > .98 && this.regard === 'yt')
      this.el.classList.toggle('has-held-sheet', held)
      const grip = this.part('regard-purchase')
      grip.hidden = !this.scene.tunnel
      grip.style.left = `${this.body.x / 10}%`; grip.style.top = `${this.body.y / 6.8}%`
      this.raf = requestAnimationFrame(frame)
    }
    this.raf = requestAnimationFrame(frame)
  },
  updated() {
    const next = JSON.parse(this.el.dataset.scene)
    if (next.reset !== this.scene.reset || next.tunnel !== this.scene.tunnel) {
      this.motion = {position: 0, velocity: 0, across: 0}
      this.input = {along: 0, across: 0}
      this.pointer = {drawn: false, held: false, angle: -40, turned: false, peak: 0, emergence: 1}
      this.sheet = {id: null, corners: [], tension: 0}
      this.regard = 'center'
      this.sweepDrag = null
      this.pressed = false
    }
    const changed = JSON.stringify(next.sheets) !== JSON.stringify(this.scene.sheets) || JSON.stringify(next.provenance) !== JSON.stringify(this.scene.provenance)
    this.scene = next
    if (changed) this.buildMaterials()
    this.renderScene()
  },
  destroyed() { cancelAnimationFrame(this.raf); this.cleanups.forEach(cleanup => cleanup()) },
}
