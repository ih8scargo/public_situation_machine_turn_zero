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

test('cabinet side courses truly converge on the shared Human reference; finite nozzle clearance is conditional',async()=>{
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
