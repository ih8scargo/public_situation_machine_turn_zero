// Rehearsal markers and affine material presentation share the registered lower source.
// Marker cross widths are inspection glyph sizes, never physical Footing dimensions.
const add=(a,b)=>a.map((v,i)=>v+b[i])
export const applyMatrix=(matrix,p)=>matrix.slice(0,3).map(row=>row.slice(0,3).reduce((sum,n,i)=>sum+n*p[i],row[3]))
export function material(model) {
  if(!model.projection||!model.rehearsal)return []
  return model.rehearsal.footings.map(f=>({footing:f,vertical:{footing_id:f.id,station_id:f.station_id,source:f.source_point,point:applyMatrix(model.projection.vertical.matrix,f.source_point),transform:model.projection.vertical.id},oblique:{footing_id:f.id,station_id:f.station_id,source:f.source_point,point:applyMatrix(model.projection.oblique.matrix,f.source_point),transform:model.projection.oblique.id}}))
}
export function cobPoint(model) {
  const [a,b]=model.projection.course.points,t=model.rehearsal.progress
  return a.map((v,i)=>v+(b[i]-v)*t)
}
const marker=(p,r=.12)=>[add(p,[-r,0,0]),add(p,[r,0,0]),p,add(p,[0,-r,0]),add(p,[0,r,0]),p,add(p,[0,0,-r]),add(p,[0,0,r])]
export function apparatusPrimitives(model,mode='both') {
  if(!model.projection||!model.rehearsal)return []
  const p=model.projection,result=[
    {id:'lower-source-plane',kind:'source-plane',points:p.source.outline,closed:true},
    {id:'lower-source-origin',kind:'source',points:marker(p.source.origin,.22)},
    {id:p.course.id,kind:'reference-course',points:p.course.points},
    {id:p.height_reference.id,kind:'height-measure',points:p.height_reference.points},
    {id:'cob-progress-witness',kind:'cob-progress',points:marker(cobPoint(model),.22)}
  ]
  for(const bearing of ['vertical','oblique'])if(mode==='both'||mode===bearing) {
    result.push({id:`candidate-${bearing}`,kind:`projection-${bearing}`,bearing,points:p[bearing].points})
    result.push({id:`crossing-intersection-${bearing}`,kind:`projection-${bearing}`,bearing,points:[p[bearing].intersection.from,p[bearing].intersection.to]})
    result.push({id:`crossing-entry-${bearing}`,kind:`projection-${bearing}`,bearing,points:marker(p[bearing].entry,.16)})
  }
  for(const item of material(model)) {
    const f=item.footing
    result.push({id:`footing-${f.sequence}-association`,kind:'provisional-association',footing:f.sequence,points:[f.station_point,f.source_point]})
    result.push({id:`footing-${f.sequence}-index-reference`,kind:'acquired-index',footing:f.sequence,points:marker(f.station_point,.17)})
    result.push({id:`footing-${f.sequence}-source`,kind:'footing-source',footing:f.sequence,points:marker(f.source_point,.17)})
    for(const bearing of ['vertical','oblique'])if(mode==='both'||mode===bearing) {
      result.push({id:`footing-${f.sequence}-${bearing}-ray`,kind:`projection-${bearing}`,bearing,footing:f.sequence,points:[f.source_point,item[bearing].point]})
      result.push({id:`footing-${f.sequence}-${bearing}`,kind:`footing-${bearing}`,bearing,footing:f.sequence,points:marker(item[bearing].point,.18)})
    }
  }
  return result
}
