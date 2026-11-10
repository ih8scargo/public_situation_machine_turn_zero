import {primitives} from './projection.js'
export function outreadings(model,registry){
 const result=new Map()
 for(const item of primitives(model,'both')){
  const delta=item.points.length>1?item.points.at(-1).map((v,i)=>v-item.points[0][i]):[0,0,0],length=Math.hypot(...delta),measuredBearing=length?delta.map(v=>v/length):null
  const entity=model.entities[item.entity],footing=item.footing?model.rehearsal.footings.find(f=>f.sequence===item.footing):null
  result.set(`line:${item.id}`,{id:item.id,name:item.id,kind:item.kind,classification:footing?'REGISTERED acquisition reference / PROVISIONAL display witness':'MEASURED registered geometry; architectural role only where explicitly appointed',coordinates:item.points,frame:entity?.frame||null,bearing:measuredBearing,relations:entity?{WITHIN:entity.name}:null,provenance:footing||{source:'existing workshop registration',entity:entity?.id||null},display_hypothesis:footing?'Marker sizes and presentation transforms are provisional; original Footing transition retained':'No architectural preposition inferred from screen position',approach_target:item.station?`letter:${item.station}`:item.kind==='surface'?`plane:${item.id}`:item.entity?`region:${item.entity}`:null})
 }
 for(const item of registry.items)result.set(`line:${item.id}`,{...item,name:item.label,classification:'MEASURED coordinates with explicit APPOINTED / PROVISIONAL outreadings',coordinates:item.points,bearing:item.frame.bearing,approach_target:`plane:${item.id}`})
 for(const station of model.steeling.stations){
  const record={id:station.id,name:`${station.letter}${station.index} · ${station.group}`,kind:'letter',classification:'REGISTERED original station; PROVISIONAL extruded display body',coordinates:station.point,frame:{origin:station.point,basis:[[1,0,0],[0,1,0],[0,0,1]],status:'display basis inherited from U; constitutional letter orientation unappointed'},bearing:{inherited_U_reference:[0,0,1],FROM_face:[0,0,-1]},relations:{indexed_station:station.index,references:station.references},provenance:{source:'original Steeling registration',station_id:station.id,acquisition:'Inspection is not acquisition; see original Footing ledger'},display_hypothesis:{height:.5,width:5/7*.5,depth:.08,FROM_z_offset:-.04},approach_target:`letter:${station.index}`}
  result.set(`letter:${station.index}`,record)
 }
 return result
}
export function targetReading(target,lineId){return target?.startsWith('letter:')?target:`line:${lineId}`}
