// These hooks own only ephemeral projection. Every consequential request is
// named explicitly and checked by Elixir; neither a hit nor an overlap seats.
const normalize = n => ((n % 360) + 360) % 360
const angularDelta = (a, b) => ((a - b + 540) % 360) - 180
const bind = (owner, node, name, fn, options) => {
  node.addEventListener(name, fn, options)
  owner.cleanups.push(() => node.removeEventListener(name, fn, options))
}
const svgPoint = (svg, event) => {
  const p = new DOMPoint(event.clientX, event.clientY)
  return p.matrixTransform(svg.getScreenCTM().inverse())
}

export const RegardingWheel = {
  mounted() {
    this.cleanups = []
    this.svg = this.el.querySelector("svg")
    this.angle = Number(this.el.dataset.angle)
    this.lastSent = 0
    const paint = () => {
      const a = normalize(this.angle)
      this.el.querySelector("[data-wheel-rotor]").setAttribute("transform", `rotate(${a} 100 100)`)
      this.svg.setAttribute("aria-valuenow", String(Math.round(a)))
      this.svg.setAttribute("aria-valuetext", `${Math.round(a)} degrees of Regard`)
    }
    this.paint = paint
    const send = () => {
      this.pushEvent("wheel", {angle: normalize(this.angle)})
      this.lastSent = performance.now()
    }
    bind(this, this.svg, "pointerdown", event => {
      if (this.el.dataset.disabled === "true" || event.button !== 0) return
      event.preventDefault()
      this.svg.focus()
      this.svg.setPointerCapture(event.pointerId)
      const p = svgPoint(this.svg, event)
      this.drag = {id: event.pointerId, angle: Math.atan2(p.y - 100, p.x - 100) * 180 / Math.PI}
    })
    bind(this, this.svg, "pointermove", event => {
      if (!this.drag || event.pointerId !== this.drag.id) return
      const p = svgPoint(this.svg, event)
      const angle = Math.atan2(p.y - 100, p.x - 100) * 180 / Math.PI
      this.angle += angularDelta(angle, this.drag.angle)
      this.drag.angle = angle
      paint()
      if (performance.now() - this.lastSent > 80) send()
    })
    const finish = event => {
      if (!this.drag || event.pointerId !== this.drag.id) return
      this.drag = null
      send()
    }
    bind(this, this.svg, "pointerup", finish)
    bind(this, this.svg, "pointercancel", finish)
    bind(this, this.svg, "keydown", event => {
      if (this.el.dataset.disabled === "true") return
      const directions = {ArrowLeft: -1, ArrowDown: -1, ArrowRight: 1, ArrowUp: 1}
      if (event.key in directions) this.angle += directions[event.key] * (event.shiftKey ? 30 : 7.5)
      else if (event.key === "Home") this.angle = 0
      else if (event.key === "End") this.angle = 359
      else return
      event.preventDefault()
      paint()
      send()
    })
    this.updated()
  },
  updated() {
    if (!this.drag) {
      this.angle = Number(this.el.dataset.angle)
      this.paint()
    }
    this.svg.setAttribute("aria-disabled", this.el.dataset.disabled)
  },
  destroyed() { this.cleanups.forEach(cleanup => cleanup()) },
}

export const ToyCraft = {
  mounted() {
    this.cleanups = []
    this.svg = this.el.querySelector("svg")
    this.part = name => this.svg.querySelector(`[data-part="${name}"]`)
    this.drag = null
    this.state = JSON.parse(this.el.dataset.state)
    this.render = () => {
      const c = this.state
      const show = (name, visible) => this.part(name).setAttribute("display", visible ? "" : "none")
      show("workspace", c.open)
      show("pointer", c.open && c.pointer)
      this.part("box-lid").setAttribute("transform", c.box ? "translate(0 -45) skewX(-12)" : "")
      show("tc", c.open && (c.seated || (c.box && c.offered === "projected-tc") || c.held === "projected-tc"))
      show("buckle", c.open && (c.appointed || (c.box && c.offered === "square-buckle") || c.held === "square-buckle"))
      show("wrap", c.open && (c.wrapped || c.appointed))
      const pose = (name, identity, seatedX, seatedY) => {
        const held = c.held === identity
        const placed = identity === "projected-tc" ? c.seated : c.appointed
        const x = held ? c.x : placed ? seatedX : 295
        const y = held ? c.y : placed ? seatedY : 340
        const angle = held ? c.turn : 0
        const squash = .85 + .15 * Math.cos(angle * Math.PI / 180)
        this.part(name).setAttribute("transform", `translate(${x} ${y}) rotate(${angle}) scale(1 ${squash})`)
      }
      pose("tc", "projected-tc", 642, 388)
      pose("buckle", "square-buckle", 650, 390)
      show("held-halo", c.open && Boolean(c.held))
      this.part("held-halo").setAttribute("transform", `translate(${c.x} ${c.y})`)
      const turnRing = this.part("held-halo").querySelector("[data-drag=turn]")
      turnRing.setAttribute("aria-valuenow", String(Math.round(c.turn)))
      this.part("artifact-label").textContent = c.held === "square-buckle" || (!c.held && c.offered === "square-buckle") ? "THIS ONE SQUARE BUCKLE" : "THIS ONE TERRESTRIAL COMPUTER"
      this.part("artifact-label").setAttribute("display", c.box || c.held ? "" : "none")
      // Bobbing keeps its Human-facing basal extent. Only the four-point
      // articulation follows a held turn / receiving preview.
      const bx = c.tunnel ? 420 + c.nav * 22 : c.open ? 470 : 495
      const by = c.tunnel ? 565 - c.nav * 16 : c.open ? 545 : 560
      this.part("bobbing").setAttribute("transform", `translate(${bx} ${by})`)
      this.part("bobbing").dataset.nav = String(c.nav)
      const near = c.held && Math.hypot(c.x - 642, c.y - 380) < 120
      const form = c.articulation === "square" || near ? "square" : c.articulation
      const points = form === "square" ? [[-38,-38],[38,-38],[38,38],[-38,38]] : form === "grasp" ? [[-27,-15],[27,-15],[27,15],[-27,15]] : form === "offer" ? [[-46,-28],[46,-28],[46,28],[-46,28]] : [[-35,-22],[35,-22],[35,22],[-35,22]]
      this.part("articulation").setAttribute("transform", `translate(${c.held ? c.x - bx : 0} ${c.held ? c.y - by : 0}) rotate(${c.held ? c.turn : 0})`)
      this.part("articulation").dataset.articulation = form
      points.forEach(([x,y], i) => {
        const point = this.part("articulation").querySelector(`[data-point-index="${i}"]`)
        point.setAttribute("cx", x)
        point.setAttribute("cy", y)
      })
      const targets = {"projected-tc": [c.held === "projected-tc" ? c.x : 295, c.held === "projected-tc" ? c.y : 340], "square-buckle": [c.held === "square-buckle" ? c.x : 295, c.held === "square-buckle" ? c.y : 340], "little-square-chair": [650,390], "calibration-mark": [825,210]}
      const target = targets[c.pointed] || [500,475]
      const aim = Math.atan2(target[1] - by, target[0] - bx) * 180 / Math.PI + 20
      this.part("pointer").setAttribute("transform", `translate(${bx} ${by}) rotate(${aim})`)
      this.el.dataset.held = c.held || ""
    }
    const commitPose = () => this.pushEvent("craft-pose", {x: this.state.x, y: this.state.y, turn: normalize(this.state.turn)})
    bind(this, this.svg, "pointerdown", event => {
      const handle = event.target.closest("[data-drag]")
      if (!handle || !this.state.open || !this.state.held || event.button !== 0) return
      event.preventDefault()
      handle.focus()
      this.svg.setPointerCapture(event.pointerId)
      const p = svgPoint(this.svg, event)
      this.el.dataset.dragging = "true"
      this.drag = {id: event.pointerId, kind: handle.dataset.drag, x: p.x, y: p.y, startX: this.state.x, startY: this.state.y, turn: this.state.turn, angle: Math.atan2(p.y - this.state.y, p.x - this.state.x) * 180 / Math.PI}
    })
    bind(this, this.svg, "pointermove", event => {
      if (!this.drag || event.pointerId !== this.drag.id) return
      const p = svgPoint(this.svg, event)
      if (this.drag.kind === "carry") {
        this.state.x = Math.max(100, Math.min(900, this.drag.startX + p.x - this.drag.x))
        this.state.y = Math.max(100, Math.min(550, this.drag.startY + p.y - this.drag.y))
      } else {
        const a = Math.atan2(p.y - this.state.y, p.x - this.state.x) * 180 / Math.PI
        this.state.turn = normalize(this.drag.turn + angularDelta(a, this.drag.angle))
      }
      this.state.aligned = false
      this.render()
    })
    const finish = event => {
      if (!this.drag || event.pointerId !== this.drag.id) return
      this.drag = null
      this.suppressClick = event.type === "pointerup"
      this.el.dataset.dragging = "false"
      commitPose()
    }
    bind(this, this.svg, "pointerup", finish)
    bind(this, this.svg, "pointercancel", finish)
    const activate = event => {
      if (this.suppressClick) { this.suppressClick = false; return }
      const point = event.target.closest("[data-point]")
      const operation = event.target.closest("[data-craft-op]")
      if (point) this.pushEvent("point-artifact", {id: point.dataset.point})
      else if (operation) this.pushEvent("craft", {op: operation.dataset.craftOp})
    }
    bind(this, this.svg, "click", activate)
    bind(this, this.svg, "keydown", event => {
      const handle = event.target.closest("[data-drag]")
      const keys = {ArrowLeft: [-15,0], ArrowRight: [15,0], ArrowUp: [0,-15], ArrowDown: [0,15]}
      if (handle && this.state.held && event.key in keys) {
        event.preventDefault()
        if (handle.dataset.drag === "turn") this.state.turn = normalize(this.state.turn + (event.key === "ArrowLeft" || event.key === "ArrowDown" ? -15 : 15))
        else { this.state.x = Math.max(100, Math.min(900, this.state.x + keys[event.key][0])); this.state.y = Math.max(100, Math.min(550, this.state.y + keys[event.key][1])) }
        this.render()
        commitPose()
      } else if ((event.key === "Enter" || event.key === " ") && event.target.closest("[data-point], [data-craft-op]")) {
        event.preventDefault()
        activate(event)
      }
    })
    this.render()
  },
  updated() {
    const next = JSON.parse(this.el.dataset.state)
    // A server consequence wins over an in-flight local pose (e.g. OFF, STEP).
    if (this.drag && next.held === this.state.held && next.open) return
    this.drag = null
    this.state = next
    this.render()
  },
  destroyed() { this.cleanups.forEach(cleanup => cleanup()) },
}
