// Geometry reconciliation: normalized stock is a historical fold witness, not revised Seat/Craft fit.
// Authority: docs/architecture/geometry/README.md and impact-ledger.md; no acquisition from presentation.
import {assemblePanels} from "../panel_assembly.js"

// Normalized drawing stock from bearing-archway/archway.png, lower two cells.
// x=0,1,2 traces columns 622,803,982; y=0,1 traces rows 443,623.
// UP is a separate trial axis. These coordinates carry no physical scale.
const a = [0, 0, 0]
const b = [1, 1, 0]
const flapTip = [0, 1, 0]
const root = [1, 0, 0]
const diagonal = [a, b]
const extentCount = 6
const rightAngle = Math.PI / 2

export const poses = {
  held: [0, 0, 0],
  loosened: [1, 0, 0],
  curved: [1, 1, 0],
  folded: [1, 1, 1],
}

export function compose([release, curve, fold]) {
  // Rotate the free vertex around the traced diagonal. Both hinge points stay put.
  const angle = fold * rightAngle
  const movingTip = [
    .5 - .5 * Math.cos(angle),
    .5 + .5 * Math.cos(angle),
    -Math.SQRT1_2 * Math.sin(angle),
  ]

  const line = [root]
  for (let index = 1; index <= extentCount; index++) {
    const turn = curve * rightAngle * (index - .5) / extentCount
    const [x, y, up] = line.at(-1)
    line.push([x, y + Math.cos(turn) / extentCount, up + Math.sin(turn) / extentCount])
  }

  return {
    diagonal,
    flap: [a, fold === 0 ? flapTip : movingTip, b],
    squareRemainder: [a, root, b],
    retained: [b, [2, 0, 0], [2, 1, 0]],
    reference: [root, b],
    line,
    hold: [a, root].map(([x, y, up]) => [x, y - release / 8, up]),
  }
}

function draw(canvas, stock, pose, flat) {
  const ctx = canvas.getContext('2d')
  const [release, curve] = pose
  const project = ([x, y, up]) => flat
    ? [160 + 150 * x, 100 + 150 * y]
    : [132 + 172 * x + 72 * y, 132 + 87 * y - 151 * up]

  const path = (points, stroke, fill, width = 2, dashed = false) => {
    ctx.beginPath()
    points.forEach((point, index) => {
      const [x, y] = project(point)
      if (index === 0) ctx.moveTo(x, y)
      else ctx.lineTo(x, y)
    })
    if (fill) {
      ctx.closePath()
      ctx.fillStyle = fill
      ctx.fill()
    }
    ctx.strokeStyle = stroke
    ctx.lineWidth = width
    ctx.setLineDash(dashed ? [5, 5] : [])
    ctx.stroke()
  }

  ctx.clearRect(0, 0, canvas.width, canvas.height)
  path(stock.squareRemainder, '#88a8b2', '#1c3843')
  path(stock.retained, '#a0c9cc', '#254b52')
  path(stock.flap, '#fcd586', '#664d32')
  path(stock.diagonal, '#fcd586', null, 3)
  path(stock.reference, '#6ee7b7', null, 2, true)
  path(stock.line, '#d4cbff', null, 3)
  path(stock.hold, '#fda4af', null, 5)

  if (curve > 0 && !flat) {
    ctx.fillStyle = '#d4cbff'
    stock.line.slice(1).forEach((point, index) => {
      const appearing = Math.min(1, Math.max(0, 6 * curve - index))
      if (appearing === 0) return
      ctx.beginPath()
      ctx.arc(...project(point), 3 * appearing, 0, 2 * Math.PI)
      ctx.fill()
    })
  }

  ctx.font = '16px system-ui'
  ctx.fillStyle = '#fda4af'
  ctx.fillText(release === 0 ? 'XT TOWARD YT · held' : 'XT TOWARD YT · loosened', 24, 29)
  ctx.fillStyle = '#d4cbff'
  ctx.fillText('XT TOWARD XT', 24, 310)
  ctx.fillStyle = '#6ee7b7'
  ctx.fillText('XT TO XT · fixed reference', 24, 334)
  ctx.fillStyle = '#fcd586'
  ctx.fillText('HERE square / diagonal', 396, 310)
  ctx.fillStyle = '#a0c9cc'
  ctx.fillText('Retained triangle', 396, 334)
}

function drawReferences(canvas, reference, showWedge = false) {
  const ctx = canvas.getContext('2d')
  const trace = (points, project, color, closed = false) => {
    ctx.beginPath()
    points.forEach((point, index) => {
      const [x, y] = project(point)
      if (index === 0) ctx.moveTo(x, y)
      else ctx.lineTo(x, y)
    })
    if (closed) ctx.closePath()
    ctx.strokeStyle = color
    ctx.stroke()
  }

  // Two native frames with independent projections and no shared transform.
  const table = ([x, y, z]) => [158 + 75 * x + 39 * z, 104 - 43 * y + 33 * z]
  for (const surface of reference.surfaces) trace(surface.points, table, surface.color, true)
  for (const line of reference.lines) trace(line.points, table, line.color)

  if (showWedge) {
    ctx.lineWidth = 3
    trace(reference.wedge.points, table, '#fda4af', true)
    ctx.font = '15px system-ui'
    ctx.fillStyle = '#e2e8f0'
    ctx.fillText('Outlined wedging · tunnel mouth', 24, 222)
    return
  }

  const aperture = ([x, y, z]) => [485 + 25 * x + 50 * z, 66 - 51 * y + 12 * x]
  const {panels, hinge} = assemblePanels(reference.panels, 0, 45)
  const doll = panels.find(panel => panel.id === 'doll')
  const glass = panels.find(panel => panel.id === 'glass')
  trace(doll.points, aperture, '#c4b5fd', true)
  trace(glass.points, aperture, '#6ee7b7', true)
  trace(hinge, aperture, '#fcd586')
  trace([[0, 0, 0], [0, -2.4, 0]], aperture, '#64748b')

  ctx.font = '15px system-ui'
  ctx.fillStyle = '#e2e8f0'
  ctx.fillText('SnailBody · Table / spindle / passage', 24, 222)
  ctx.fillText('Pinned Doll · 45° / Glass', 367, 222)
}

export const ComingAboardComposition = {
  mounted() {
    this.canvas = this.el.querySelector('#ca-stock')
    drawReferences(this.el.querySelector('#ca-native-reference'), JSON.parse(this.el.dataset.reference))
    this.pose = poses[this.el.dataset.pose]
    this.paint(this.pose, this.el.dataset.regarding === 'flat' && this.el.dataset.pose === 'folded')
  },

  updated() {
    cancelAnimationFrame(this.frame)
    const target = poses[this.el.dataset.pose]
    const flat = this.el.dataset.regarding === 'flat' && this.el.dataset.pose === 'folded'
    const start = this.pose
    if (matchMedia('(prefers-reduced-motion: reduce)').matches ||
        target.every((value, index) => value === start[index])) {
      this.paint(target, flat)
      return
    }

    const startedAt = performance.now()
    const advance = now => {
      const fraction = Math.min(1, Math.max(0, (now - startedAt) / 580))
      const current = start.map((value, index) => value + (target[index] - value) * fraction)
      this.paint(current, fraction === 1 && flat)
      if (fraction < 1) this.frame = requestAnimationFrame(advance)
    }
    this.frame = requestAnimationFrame(advance)
  },

  paint(pose, flat) {
    this.pose = pose
    const stock = compose(pose)
    draw(this.canvas, stock, pose, flat)
    this.canvas.dataset.geometry = JSON.stringify(stock)
  },

  destroyed() { cancelAnimationFrame(this.frame) },
}

export const ComingAboardNativeReference = {
  mounted() {
    drawReferences(
      this.el.querySelector('canvas'),
      JSON.parse(this.el.dataset.reference),
      this.el.dataset.showWedge === 'true',
    )
  },
}
