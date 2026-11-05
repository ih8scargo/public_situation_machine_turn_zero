import test from 'node:test'
import assert from 'node:assert/strict'
import {readFile} from 'node:fs/promises'
const source=await readFile(new URL('../../assets/js/crossing_rehearsal.js',import.meta.url),'utf8')
const {pairedGeometry,indexedCourse,passage,sweep,sectionPolygon,offeredPath}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
const near=(a,b)=>a.forEach((v,i)=>assert.ok(Math.abs(v-b[i])<1e-9))
test('shared hinge pins head, preserves toe radius, aligns inner plane and exposes the midpoint degeneracy',()=>{
 for(let i=0;i<=100;i++){const g=pairedGeometry(i/100);assert.deepEqual(g.pin,[0,0,0]);assert.ok(Math.abs(Math.hypot(...g.toes)-2.4)<1e-10);assert.ok(Math.abs(g.cabinet+g.doll-45)<1e-10)}
 near(pairedGeometry(1).innerNormal,[0,0,1]);near(pairedGeometry(.5).innerNormal,pairedGeometry(.5).dollNormal)
 assert.equal(pairedGeometry(.5).relative,0);assert.equal(pairedGeometry(1).doll,45)
})
test('THE three and PUBLIC six are actual perpendicular indexed extents within the 5 by 5 by SIX reference',()=>{
 const letters=indexedCourse();assert.equal(letters.length,25);assert.equal(letters.map(l=>l.letter).join(''),'THEPUBLICSITUATIONMACHINE')
 assert.deepEqual(['THE','PUBLIC','SITUATION','MACHINE'].map(w=>letters.filter(l=>l.word===w).length),[3,6,9,7])
 near(letters[2].end,letters[3].start);near(letters[2].end.map((v,i)=>v-letters[2].start[i]),[1,0,0]);near(letters[3].end.map((v,i)=>v-letters[3].start[i]),[0,0,1]);assert.equal(letters[8].end[2],6)
})
test('offered reference reaches the pin continuously and swept CUBICAL passage follows its curve',()=>{
 const before=offeredPath(),curve=passage(),sections=sweep(curve);near(before.at(-1),curve[0]);near(curve.at(-1),[1.6,0,1.6]);assert.equal(sections.length,65)
 for(const s of sections){assert.equal(s.corners.length,4);for(const p of s.corners)assert.ok(Math.abs(Math.hypot(...p.map((v,i)=>v-s.center[i]))-Math.SQRT2*.16)<1e-9)}
 const cut=sectionPolygon([[-1,-1,-1],[1,-1,1],[1,1,1],[-1,1,-1]],{origin:[0,0,0],normal:[0,0,1]});assert.equal(cut.length,2);for(const p of cut)assert.equal(p[2],0)
})

test('historical convergence witness remains reproducible; finite nozzle clearance is conditional',async()=>{
 const {convergingPoint,hinge}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`),human=[0,0,-24]
 for(const p of [[-2,-2,0],[2,-2,0],[2,2,0],[-2,2,0]].map(p=>hinge(p,45))){const nearPoint=convergingPoint(p,human);near(nearPoint.map((v,i)=>(v-human[i])/.86),p.map((v,i)=>v-human[i]))}
 // This verifies a finite Glass section, not clearance derived from a zero-width wedge tip.
 const contract=JSON.parse(await readFile(new URL('../../docs/visual-witnesses/paired-apertures/appointed-contract.json',import.meta.url)))
 assert.ok(contract.stick.nozzle.half<contract.stick.nozzle.glass_half);assert.ok(contract.stick.nozzle.passage_half<contract.stick.nozzle.half)
 const actual=passage(contract.stick);near(actual[0],[0,0,0]);near(actual.at(-1),contract.stick.tip);assert.equal(actual.length,65)
})

test('the existing reference renderer keeps the appointed curved instrument rather than dropping its geometry',async()=>{
 const oldSource=await readFile(new URL('../../assets/js/elementary_opening.js',import.meta.url),'utf8'),{retainedInstrumentPoints}=await import(`data:text/javascript;base64,${Buffer.from(oldSource).toString('base64')}`),contract=JSON.parse(await readFile(new URL('../../docs/visual-witnesses/paired-apertures/appointed-contract.json',import.meta.url)))
 const stick=contract.stick,before=JSON.stringify(stick),points=retainedInstrumentPoints(stick,{tip:stick.tip,direction:stick.direction})
 assert.equal(points.length,65);for(let i=0;i<points.length;i++)near(points[i],stick.curve.samples[i]);assert.equal(JSON.stringify(stick),before)
})

test('ground-monitor reference and pinned purchase remain fixed throughout the pull',()=>{
 const reference={head_purchase:[0,0,0],monitor:{origin:[0,0,0],normal:[0,0,1]},ground:{origin:[0,-2.5,0],normal:[0,1,0]}}
 const before=JSON.stringify(reference)
 for(let i=0;i<=100;i++){
  const g=pairedGeometry(i/100,reference)
  near(g.pin,reference.monitor.origin)
  assert.deepEqual(g.planes.ground,reference.ground)
  assert.deepEqual(g.planes.monitor,reference.monitor)
  assert.equal(g.planes.monitor.normal.reduce((sum,v,j)=>sum+v*g.planes.ground.normal[j],0),0)
 }
 assert.equal(JSON.stringify(reference),before)
})

test('CAB looks through the head Glass; alongside and roundabout Regard preserve world geometry',async()=>{
 const {locatedRegard,projectLocated}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
 const pin=[0,0,0],curve=passage(),before=JSON.stringify(curve),cab=locatedRegard('cab',pin)
 near(projectLocated(pin,cab).point,[550,500]);assert.ok(projectLocated(pin,cab).depth>0)
 assert.ok(projectLocated(curve.at(-1),cab).depth>projectLocated(pin,cab).depth)
 const alongside=locatedRegard('alongside',pin)
 assert.ok(alongside.origin[1]>pin[1]);assert.notDeepEqual(alongside.origin,cab.origin)
 for(const kind of ['cab','alongside'])for(const yaw of [-180,-90,0,90,180]){
  const frame=locatedRegard(kind,pin,yaw)
  for(const p of curve){const view=projectLocated(p,frame);assert.ok(view.point.every(Number.isFinite))}
  near(frame.purchase,pin)
 }
 assert.equal(JSON.stringify(curve),before);assert.deepEqual(locatedRegard('cab',pin),cab)
})
test('located view clips behind-eye polygons and crossing lines at a positive near plane',async()=>{
 const {locatedPath}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
 const view=p=>({point:[p[0]/Math.max(.08,p[2]),p[1]/Math.max(.08,p[2])],depth:p[2]})
 assert.equal(locatedPath([[0,0,-2],[1,0,-1]],view),'')
 assert.equal(locatedPath([[0,0,-2],[1,0,-1],[0,1,-1]],view,true),'')
 for(const closed of [false,true]){const d=locatedPath([[-1,0,-1],[1,0,1],[0,1,1]],view,closed);assert.ok(d.startsWith('M'));assert.ok(!/NaN|Infinity/.test(d))}
})

test('inscription inspection interpolates supplied samples without changing geometry or standing; N and end remain distinct purchases',async()=>{
 const {inscriptionPose}=await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`)
 const words=['THE','PUBLIC','SITUATION','MACHINE'];let index=0
 const resolution={letters:words.flatMap(word=>[...word].map(letter=>{
  const i=index++;return {id:`inscription-letter-${i+1}`,letter,word,relations:[word==='MACHINE'?'return':'face'],samples:[{point:[i,0,0]},{point:[i+1,0,0]}]}
 })),relations:[{id:'face',bearing:'XT toward YT'},{id:'return',bearing:'YT toward YT'}],twist:{purchase:18},end_bearing:'XT toward XT'}
 const before=JSON.stringify(resolution)
 near(inscriptionPose(resolution,9.25).point,[9.25,0,0])
 assert.equal(inscriptionPose(resolution,18).letter.letter,'N')
 assert.equal(inscriptionPose(resolution,18).twist,true)
 assert.equal(inscriptionPose(resolution,18).end,false)
 assert.equal(inscriptionPose(resolution,18.1).letter.word,'MACHINE')
 assert.equal(inscriptionPose(resolution,18.1).reading,'YT toward YT')
 assert.equal(inscriptionPose(resolution,25).reading,'XT toward XT')
 near(inscriptionPose(resolution,99).point,[25,0,0]);near(inscriptionPose(resolution,-1).point,[0,0,0])
 assert.equal(JSON.stringify(resolution),before)
})
