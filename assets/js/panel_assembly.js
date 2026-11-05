// Panel stock recovered from crossing_rehearsal.js. Coordinates are model units.
// Hinges and angles are trial assembly choices, never constitutional operations.
const add=(a,b)=>a.map((v,i)=>v+b[i])
const rotate=(p,degrees)=>{const a=degrees*Math.PI/180;return [p[0],p[1]*Math.cos(a)-p[2]*Math.sin(a),p[1]*Math.sin(a)+p[2]*Math.cos(a)]}
export const rectangle=(x,y,z=0)=>[[-x,-y,z],[x,-y,z],[x,y,z],[-x,y,z]]
export const dollStock=()=>[[-.4,0,0],[.4,0,0],[.4,-2.4,0],[-.4,-2.4,0]]
export const panelInventory=Object.freeze([
 {id:'monitor',name:'Monitor',size:'5 × 5',source:'fixed monitor reference'},
 {id:'cabinet',name:'Cabinet face',size:'4.3 × 4.3',source:'projected cabinet face'},
 {id:'front',name:'Outward front',size:'5 × 5',source:'cabinet front at Z = −3'},
 {id:'doll',name:'Doll-side panel',size:'0.8 × 2.4',source:'existing head-to-toes panel'},
 {id:'ground',name:'HERE ground square',size:'5 × 3',source:'operating reference; distinct from acquired Landinging'},
 {id:'glass',name:'Glass',size:'0.48 × 0.48',source:'finite opening hypothesis, normal to seam'}
])
export function assemblePanels(reference,cabinetAngle=45,dollAngle=0){
 const clamp=a=>Math.max(-90,Math.min(90,Number.isFinite(a)?a:0))
 const cabinet=clamp(cabinetAngle),doll=clamp(dollAngle)
 const face=rectangle(2.15,2.15).map(p=>rotate(p,cabinet)),front=rectangle(2.5,2.5,reference.cabinet_front_z)
 const panels=[
  {id:'monitor',points:rectangle(2.5,2.5)},
  {id:'cabinet',points:face},
  {id:'front',points:front},
  {id:'doll',points:dollStock().map(p=>rotate(p,doll))},
  {id:'ground',points:reference.here_square.map(p=>[...p])},
  {id:'glass',points:[[0,-.24,-.24],[0,.24,-.24],[0,.24,.24],[0,-.24,.24]]}
 ]
 const normal=rotate([0,0,1],cabinet),dollNormal=rotate([0,0,1],doll)
 const dot=normal.reduce((s,v,i)=>s+v*dollNormal[i],0)
 const planeAngle=Math.acos(Math.min(1,Math.abs(dot)))*180/Math.PI
 const innerCenter=rotate([0,-.5,0],cabinet)
 return {panels,cabinet,doll,normal,dollNormal,innerCenter,
  hinge:[[-.4,0,0],[.4,0,0]],
  observations:{planeAngle,coincident:planeAngle<1e-7,monitorAligned:Math.abs(normal[2])>1-1e-9,
   apertureCenterOffset:Math.hypot(...innerCenter),
   // Cabinet radius .9, inner radius .55, centers .5 apart in the same face.
   innerWithinCabinet:.5+.55<=.9,
   glassNozzleMargin:.24-.23}}
}
