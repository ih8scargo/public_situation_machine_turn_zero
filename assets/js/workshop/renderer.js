import {camera, project, path, primitives, material, cobPoint} from './projection.js'
const ns='http://www.w3.org/2000/svg'
export function render(svg, model, regard, selected, yaw=0, letter=13, bearing='both', selectedFooting=1, calibration=null, plane='u-aperture', instrument=null, magnification=1, regarding=null, showAxes=false, groundside=null) {
  const document=svg.ownerDocument, reference=model.projection?.oblique.regarding_reference, source=model.projection?.source.origin, direction=regard==='reciprocal'&&reference?source.map((v,i)=>v-reference[i]):null, target=regard==='lower'?[model.entities.lower.frame.origin[0]+3,-3,0]:['departure','reciprocal'].includes(regard)?[15,0,0]:null, frame=camera(regard,yaw,target,direction)
  const focused=calibration&&['tunneling','diorama','reciprocal'].includes(regard)
  if(focused){frame.zoom=1.8;frame.target=[15,-.3,0]}
  if (regarding) {
    const focus = regarding.anchors[regarding.stand] ?? frame.target
    frame.scaleFactor = frame.target[1] === -3 ? 1.35 : 1
    frame.target = [focus[0], regarding.height, focus[2]]
  }
  svg.dataset.calibrationFocus=focused?'true':'false'
  svg.replaceChildren()
  const node=(tag, attrs, text)=>{const el=document.createElementNS(ns,tag); for(const [key,value] of Object.entries(attrs)) el.setAttribute(key,String(value)); if(text !== undefined) el.textContent=text; svg.append(el); return el}
  node('title',{},'SEEING THROUGHING · four registered CUBICAL regions on one rail')
  if (groundside) {
    groundside.edges.forEach((points, index) => {
      node('path', {id:`gw-groundside-allowance-${index}`, d:path(points, frame),
        class:'gw-groundside-allowance', 'data-world-points':JSON.stringify(points)})
    })
    node('path', {id:'gw-groundside-strip', d:path(groundside.strip, frame, true),
      class:'gw-groundside-strip', 'data-world-points':JSON.stringify(groundside.strip)})
    const corners = groundside.edges.slice(0, 4).map(([point]) => project(point, frame).point)
    const x = Math.max(...corners.map(([x]) => x))
    const y = Math.max(...corners.map(([,y]) => y))
    node('text', {x, y:y + 28, class:'gw-groundside-label', 'text-anchor':'end'},
      'Projectioning allowance · +6')
  }
  for(const item of primitives(model,bearing)) {
    const reference=item.role?.startsWith('Ground') ? ' ground-reference' : item.role?.startsWith('Monitor') ? ' monitor-reference' : ''
    node('path',{id:`gw-${item.id}`,d:path(item.points,frame,item.closed),fill:'none',stroke:'currentColor','vector-effect':'non-scaling-stroke',class:`gw-geometry gw-${item.kind} gw-entity-${item.entity || 'rail'}${item.entity===selected||item.footing===Number(selectedFooting)?' gw-selected':''}${reference}`,'data-entity':item.entity || '', 'data-footing-select':item.footing||'', 'data-bearing-select':item.bearing||'', 'data-letter-select':item.station||'', 'data-plane-select':item.kind==='surface'?item.id:'', 'data-surface':item.kind==='surface'?item.id:'','data-world-points':JSON.stringify(item.points)})
  }
  for(let i=0;i<=18;i+=3) {const [x,y]=project([i,0,0],frame).point;node('text',{x,y:y+18,class:'gw-axis-label'},String(i))}
  for(const entity of Object.values(model.entities)) {
    const [x,y,z]=entity.frame.origin, center=[x+3,y+(entity.id==='lower'?3:6),z+3], screen=project(center,frame).point
    const label=entity.id==='central'?(model.schema_version===1?'CENTRAL · 6 × 6 × 6':'CROSSING · 6 × 6 × 6'):entity.id==='lower'?'LOWER · 6 × 6 × 6':`${entity.id.toUpperCase()} · 6 × 6 × 6`
    node('text',{x:screen[0],y:screen[1]-14,class:`gw-label gw-entity-${entity.id}`,'text-anchor':'middle','data-entity':entity.id,role:'button',tabindex:'0','aria-label':`Select ${entity.name}`},label)
  }
  for(const [p,text] of [[[model.entities.lower.frame.origin[0]+3,-6,0],'GROUND-SIDE · zero-standing'],[[model.entities.lower.frame.origin[0]+3,0,0],'MONITOR-SIDE · lower top']]) {
    const [x,y]=project(p,frame).point;node('text',{x:x+12,y:y-8,class:'gw-reference-label'},text)
  }
  if(model.steeling) {
    for(const station of model.steeling.stations) {
      const [x,y]=project(station.point,frame).point, isReturn=station.index===13||station.index===18
      node('text',{x:x+(isReturn?12:0),y:y-(isReturn?12:8),class:`gw-letter-label ${isReturn?'gw-return-label':''} ${station.index===13?'gw-u-label':station.index===18?'gw-n-label':''} ${station.index===Number(letter)?'gw-letter-selected':''}`,'data-letter-select':station.index,role:'button',tabindex:0,'aria-label':`Inspect letter ${station.index} ${station.letter} in ${station.group}`},isReturn?(focused?`${station.letter}${station.index}`:`${station.letter}${station.index} · ${station.index===13?'Projectioning center':'Ground return'}`):station.letter)
    }
    const n=model.steeling.n_return, end=model.steeling.machine.points.at(-1), [mx,my]=project(end,frame).point
    node('text',{x:mx-10,y:my-18,class:'gw-letter-label'},'MACHINE ← N18')
  }
  if(model.projection&&model.rehearsal) {
    const label=(point,text,klass='gw-material-label',footing=null,dy=-9)=>{const [x,y]=project(point,frame).point;node('text',{x:x+7,y:y+dy,class:klass,'data-footing-select':footing||'',role:footing?'button':'note',tabindex:footing?0:-1},text)}
    label(model.projection.source.origin,'LOWER STAGING · shared source','gw-material-label',null,60)
    label(model.projection.height_reference.points[1],'CROSSING HEIGHT · 6','gw-material-label',null,-14)
    label(cobPoint(model),`COB t=${model.rehearsal.progress}`,'gw-material-label gw-cob-label',null,19)
    for(const kind of ['vertical','oblique'])if(bearing==='both'||bearing===kind)label(model.projection[kind].exit,kind==='vertical'?'V · straight UP':'O · UP / OVER ACROSS',`gw-material-label gw-${kind}-label`,null,kind==='vertical'?-30:-12)
    for(const item of material(model)) {
      const f=item.footing, detail=f.sequence===Number(selectedFooting)?` ${f.letter}${f.station_index}`:''
      label(f.source_point,`S${f.sequence}${detail}`,'gw-material-label',f.sequence,16+f.sequence%2*10)
      for(const kind of ['vertical','oblique'])if(bearing==='both'||bearing===kind)label(item[kind].point,`${kind==='vertical'?'V':'O'}${f.sequence}${detail}`,`gw-material-label gw-${kind}-label`,f.sequence,kind==='vertical'?-10:-24)
    }
  }
  if(calibration) {
    const original=new Set(primitives(model,bearing).map(item=>item.id))
    const items=calibration.items.filter(item=>!original.has(item.id)&&!item.id.includes('-surface-'))
    for(const item of items) {
      const selected=item.id===plane
      node('path',{id:`gw-cal-${item.id}`,d:path(item.points,frame,item.closed),fill:'none',stroke:'currentColor','vector-effect':'non-scaling-stroke',class:`gw-geometry gw-calibration-path gw-calibration-${item.id} gw-cal-${item.material_status==='STANDING FOR STAGING'?'standing':'prospective'}${selected?' gw-cal-selected':''}`,'data-plane-select':item.id,'data-world-points':JSON.stringify(item.points),role:'button',tabindex:0,'aria-label':item.label})
      if(selected||['SIX-upstage','HERE','NEXT','camera-zero','camera-one','camera-two','projection-thing'].includes(item.id)) {
        const [x,y]=project(item.points[0],frame).point
        const offsets={'HERE':25,'NEXT':-20,'camera-one':-12,'camera-zero':20,'projection-thing':34,'camera-two':48,'SIX-upstage':-28,'quarter-turn':-18}
        node('text',{x:x+10,y:y+(offsets[item.id]||-14),class:'gw-calibration-label','data-plane-select':item.id,role:'button',tabindex:0},({'HERE':'HERE','NEXT':'NEXT → HERE','camera-zero':'ZERO · first Footing bottom','camera-one':'ONE · RE-STEP line','camera-two':'TWO · Human aperture-toward','projection-thing':'PROJECTIONING THING','SIX-upstage':'SIX · 90° upstage end','quarter-turn':`CURVATURE ${calibration.parameters.quarter_turn}° / 90°`})[item.id]||item.label)
      }
    }
    svg.dataset.calibrationPaths=String(items.length)
  } else {svg.dataset.calibrationPaths='0'}
  if(instrument&&instrument.mode!=='overview') {
    const p=instrument.eye,r=.18
    node('path',{id:'ip-assembly-eye',d:path([[p[0]-r,p[1],p[2]],p,[p[0]+r,p[1],p[2]],p,[p[0],p[1]+r,p[2]]],frame),fill:'none',stroke:'#bd1766','stroke-width':3})
    node('path',{id:'ip-assembly-bearing',d:path([p,instrument.target.point],frame),fill:'none',stroke:'#bd1766','stroke-dasharray':'5 3'})
    node('path',{id:'ip-assembly-monitor-normal',d:path([p,[p[0],p[1],-2]],frame),fill:'none',stroke:'#416bbe','stroke-dasharray':'3 3'})
    const [x,y]=project(p,frame).point;node('text',{x,y:y-10,class:'gw-reference-label'},'INSPECTION STAND · separate instrument')
  }
  if (showAxes && model.projection) {
    const center = model.projection.vertical.presentation_origin
    const levels = model.entities.central.vertices.map(point => point[1])
    const points = [Math.min(...levels), Math.max(...levels)].map(y => [center[0], y, center[2]])
    const [[x1,y1], [x2,y2]] = points.map(point => project(point, frame).point)
    const [x,y] = project(center, frame).point
    node('line', {id:'gw-crossing-axis', x1, y1, x2, y2, class:'gw-crossing-axis',
      'data-world-points': JSON.stringify(points)})
    node('circle', {cx:x, cy:y, r:5, class:'gw-crossing-axis-center'})
    node('text', {x:x+10, y:y-13, class:'gw-crossing-axis-label'}, 'Crossing pivot · +Y')
  }
  if (regarding) {
    regarding.anchors.forEach((point, stand) => {
      if (!point) return
      const [x, y] = project(point, frame).point
      node('text', {id: `gw-stand-reference-${stand}`, x: x + 8, y: y + 20,
        class: 'gw-reference-label gw-stand-witness', 'data-world-point': JSON.stringify(point)},
      stand === 0 ? '0 · stationary rail zero reference' : '2 · N / MACHINE rail witness')
      if (regarding.cob === stand) {
        node('text', {id: 'gw-cob-placement-witness', x: x + 8, y: y + 35,
          class: 'gw-reference-label gw-cob-stand-witness', 'data-world-point': JSON.stringify(point)},
        `COB · Stand ${stand} witness`)
      }
    })
  }
  svg.dataset.bearing=bearing
  svg.dataset.yaw=String(yaw)
  svg.dataset.regard=regard
  svg.dataset.construction=model.construction_id
  svg.dataset.revision=String(model.revision)
  svg.dataset.structuralPaths=String(primitives(model,bearing).length)
  svg.dataset.seeingThroughing='outline-only; all structural edges retained'
  if (magnification === 1) {
    if (groundside) {
      const bounds = svg.getBBox()
      const left = Math.min(0, bounds.x - 12)
      const top = Math.min(-200, bounds.y - 12)
      const size = Math.max(1100 - left, 900 - top,
        bounds.x + bounds.width + 12 - left, bounds.y + bounds.height + 12 - top)
      svg.setAttribute('viewBox', `${left} ${top} ${size} ${size}`)
    } else {
      svg.setAttribute('viewBox', '0 -200 1100 1100')
    }
    svg.style.removeProperty('width')
    svg.style.removeProperty('height')
    return
  }

  const station = model.steeling?.stations.find(station => station.index === Number(letter))
  const [centerX, centerY] = project(regarding ? frame.target : station?.point ?? frame.target, frame).point
  const aperture = 1100 / magnification
  const bounds = svg.getBBox()
  // Retain the selected station at the center while leaving both ends of each axis reachable.
  const halfWidth = Math.max(550, centerX - bounds.x + 12, bounds.x + bounds.width - centerX + 12)
  const halfHeight = Math.max(550, centerY - bounds.y + 12, bounds.y + bounds.height - centerY + 12)
  svg.setAttribute('viewBox', `${centerX - halfWidth} ${centerY - halfHeight} ${2 * halfWidth} ${2 * halfHeight}`)
  svg.style.width = `${200 * halfWidth / aperture}cqw`
  svg.style.height = `${200 * halfHeight / aperture}cqw`
}
