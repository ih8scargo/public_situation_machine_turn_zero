import {apparatusPrimitives, material, cobPoint} from './apparatus.js'
export {material, cobPoint}
// Independent orthographic inspection. Vector/basis mathematics reviewed against
// crossing_rehearsal.js:locatedRegard/projectLocated; no trial apparatus constants reused.
const sub = (a, b) => a.map((v, i) => v - b[i])
const dot = (a, b) => a.reduce((sum, v, i) => sum + v * b[i], 0)
const cross = (a, b) => [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]]
const unit = a => { const n = Math.hypot(...a); if(n < 1e-10) throw new Error('Degenerate inspection frame'); return a.map(v => v/n) }
export function camera(regard = 'front', yaw = 0, targetOverride = null, directionOverride = null) {
  const target = targetOverride || (regard === 'lower' ? [15,-3,0] : ['tunneling','diorama'].includes(regard) ? [15,1,0] : ['departure','reciprocal'].includes(regard) ? [15,0,0] : [9,0,0])
  // Opposed horizontal bearings, both elevated for inspection; not specialized CAB frames.
  const base = directionOverride || (regard === 'tunneling' ? [0,.25,1] : regard === 'diorama' ? [1,-.25,-.35] : regard === 'reverse' ? [-1,-.6,1] : regard === 'plan' ? [0,-1,0] : regard === 'transverse' ? [0,0,-1] : regard === 'departure' ? [0,1,0] : regard === 'reciprocal' ? [-1,-6,-1.5] : [1,-.6,-1])
  const angle=yaw*Math.PI/180, direction=[base[0]*Math.cos(angle)+base[2]*Math.sin(angle),base[1],-base[0]*Math.sin(angle)+base[2]*Math.cos(angle)]
  const forward = unit(direction), referenceUp = regard === 'departure' ? [Math.sin(angle),0,Math.cos(angle)] : regard === 'plan' ? [-Math.sin(angle),0,-Math.cos(angle)] : [0,1,0]
  const right = unit(cross(forward, referenceUp)), up = unit(cross(right, forward))
  return {target, forward, right, up}
}
export function project(point, frame, width=1100, height=700) {
  const relative = sub(point, frame.target), scale = Math.min(width/29, height/23) * (frame.scaleFactor ?? (frame.target[1] === -3 ? 1.35 : 1)) * (frame.zoom||1)
  return {point: [width/2 + dot(relative,frame.right)*scale, height/2 - dot(relative,frame.up)*scale], depth: dot(relative,frame.forward)}
}
export function path(points, frame, closed=false, width=1100, height=700) {
  return points.map((p,i) => `${i ? 'L' : 'M'}${project(p,frame,width,height).point.map(n=>n.toFixed(3)).join(',')}`).join(' ') + (closed ? ' Z' : '')
}
// No depth sort, culling, masks, hidden-surface removal, or filled structural faces.
export function primitives(model, bearing='both') {
  const result = [{id: model.rail.id, kind:'rail', points:[model.rail.start,model.rail.end], closed:false}]
  for(let i=0;i<=18;i++) result.push({id:`rail-tick-${i}`,kind:'tick',points:[[i,-.12,0],[i,.12,0]],closed:false})
  for(const entity of Object.values(model.entities)) {
    for(const surface of entity.surfaces) result.push({id:surface.id,entity:entity.id,kind:'surface',role:surface.role,points:surface.vertices.map(i=>entity.vertices[i]),closed:true})
    for(const edge of entity.edges) result.push({id:edge.id,entity:entity.id,kind:'edge',points:edge.vertices.map(i=>entity.vertices[i]),closed:false})
  }
  if(model.steeling) {
    const s=model.steeling
    result.push(...buntingPrimitives(model))
    for(const [id,kind,points,closed] of [
      ['steeling-approach','course',s.the_public.samples,false],
      ['steeling-situation','course',s.situation.points,false],
      ['machine-from-n','machine',s.machine.points,false],
      ['ground-return-n','n-return',s.n_return.points,false],
      ['projection-return-u','u-return',s.u_return.post.points,false],
      ['gallery-plane','gallery',s.gallery.boundary,true]
    ]) result.push({id,kind,points,closed})
    for(const station of s.stations) {const [x,y,z]=station.point,r=station.index===13||station.index===18?.18:.055; result.push({id:station.id,kind:station.index===13?'u-station':station.index===18?'n-station':'station',station:station.index,points:[[x-r,y,z],[x,y+r,z],[x+r,y,z],[x,y-r,z]],closed:true})}
  }
  return result.concat(apparatusPrimitives(model,bearing))
}
// U13 calibrates the square frame. Each occurrence inherits its size and keeps its station.
function letterCage(station) {
  const vertices = Array.from({length: 8}, (_, index) =>
    station.point.map((coordinate, axis) => coordinate + (index & (1 << axis) ? 0.5 : -0.5))
  )
  const edges = vertices.flatMap((point, index) =>
    [1, 2, 4].filter(bit => !(index & bit)).map(bit => [point, vertices[index | bit]])
  )
  return {station, vertices, edges}
}

function buntingPrimitives(model) {
  const trial = model.steeling.stations.find(station => station.index === 13)
  const ground = model.entities.lower
  const crossing = model.entities.central
  if (!trial || !ground || !crossing) return []

  const cage = letterCage(trial)
  const [x, , z] = trial.point
  // Trial appointments: shared contact on lower Ground, and arrival at Crossing Y-max.
  const origin = [x, ground.vertices[0][1], z - 2]
  const arrivalY = crossing.vertices[2][1]
  const corners = [cage.vertices[6], cage.vertices[7]]
  const arrivals = corners.map(corner => {
    const scale = (arrivalY - origin[1]) / (corner[1] - origin[1])
    return corner.map((coordinate, axis) => origin[axis] + scale * (coordinate - origin[axis]))
  })
  const [left, right] = arrivals
  const receivingRegion = [left, right, ...[right, left].map(([a, b, c]) => [a, b, c + 0.5])]

  return [
    ...model.steeling.stations.flatMap(station => {
      const frame = station === trial ? cage : letterCage(station)
      return frame.edges.map((points, index) => ({
        id: `letter-cage-${station.index}-edge-${index}`,
        kind: station === trial ? 'trial-cage' : 'inherited-cage',
        points
      }))
    }),
    {id: 'unvanishing-point', kind: 'bunting', points: [[x - 0.12, origin[1], origin[2]], origin, [x + 0.12, origin[1], origin[2]]]},
    ...['xt-toward-xt', 'yt-returns-toward-xt'].map((id, index) => ({
      id, kind: 'bunting', points: [origin, corners[index], arrivals[index]]
    })),
    {id: 'u13-bunting-wedge', kind: 'bunting', points: [...corners, right, left, corners[0]]},
    {id: 'u13-re-step-region', kind: 'receiving-region', points: [...receivingRegion, left]}
  ]
}
