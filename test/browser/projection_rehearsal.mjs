import assert from 'node:assert/strict'
import {mkdir,readFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'/tmp/psm-projection-rehearsal'
await mkdir(out,{recursive:true})
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH||undefined,args:['--no-sandbox']})
const page=await browser.newPage({viewport:{width:1600,height:1200}}),errors=[]
page.on('pageerror',e=>errors.push(e.message))
const model=()=>page.locator('#gw-renderer').evaluate(e=>JSON.parse(e.dataset.model))
const wait=async predicate=>page.waitForFunction(predicate)
const pick=async index=>{await page.selectOption('#pick_index',String(index));await page.waitForFunction(index=>document.querySelector('#gw-renderer')?.dataset.letter===String(index),index)}
const collect=async index=>{await pick(index);const before=(await model()).rehearsal;await page.locator('#gw-quick-collect').click();if(!before.collected.includes(index))await page.waitForFunction(count=>JSON.parse(document.querySelector('#gw-renderer').dataset.model).rehearsal.collected.length===count,before.collected.length+1)}
const progress=async t=>{await page.locator('#traversal_progress').fill(String(t));await page.locator('#gw-set-progress').click();await page.waitForFunction(t=>JSON.parse(document.querySelector('#gw-renderer').dataset.model).rehearsal.progress===t,t)}
const importFile=async envelope=>{await page.locator('#gw-file-form input[type=file]').setInputFiles({name:`witness-schema-${envelope.schema_version}.json`,mimeType:'application/json',buffer:Buffer.from(JSON.stringify(envelope))});await page.locator('#gw-import-file').click()}
const capture=async name=>{await page.locator('.gw-stage').screenshot({path:out+'/'+name})}
try {
 await page.goto(process.env.WORKSHOP_URL||'http://127.0.0.1:4001/workshop')
 await page.waitForSelector('#gw-scene[data-structural-paths="439"]');await wait(()=>document.querySelector('.phx-connected'))
 const initial=await model();assert.equal(initial.schema_version,3);assert.equal(initial.rehearsal.collected.length,0)
 assert.equal(await page.locator('#gw-companion').textContent(),'Shall we collect a letter?')
 await capture('01-initial-shared-apparatus.png')
 await progress(.65)
 for(const index of [13,18,1])await collect(index)
 const three=await model();assert.deepEqual(three.rehearsal.collected,[13,18,1]);assert.equal(three.rehearsal.progress,.65)
 await collect(13);assert.deepEqual((await model()).rehearsal,three.rehearsal)
 assert.equal(await page.locator('#gw-footing-3-source').count(),1)
 assert.equal(await page.locator('#gw-footing-3-vertical').count(),1)
 assert.equal(await page.locator('#gw-footing-3-oblique').count(),1)
 await capture('02-three-acquired-footings.png')
 for(const mode of ['vertical','oblique','both']) {
   await page.locator('#gw-bearing-'+mode).click();await page.waitForFunction(mode=>document.querySelector('#gw-scene').dataset.bearing===mode,mode)
   assert.deepEqual(await model(),three)
   assert.equal(await page.locator('#gw-footing-1-vertical').count(),mode==='oblique'?0:1)
   assert.equal(await page.locator('#gw-footing-1-oblique').count(),mode==='vertical'?0:1)
   assert.equal(await page.locator('#gw-scene .gw-edge').count(),48)
 }
 for(const view of ['departure','reciprocal','transverse','plan','front']) {
   await page.locator('#gw-view-'+view).click()
   await page.waitForFunction(view=>document.querySelector('#gw-scene').dataset.regard===view,view)
   await page.locator('#inspection_yaw').evaluate(el=>{el.value='41';el.dispatchEvent(new Event('input',{bubbles:true}));el.dispatchEvent(new Event('change',{bubbles:true}))})
   await wait(()=>document.querySelector('#gw-scene').dataset.yaw==='41')
   assert.deepEqual(await model(),three)
 }
 const verticalBefore=three.projection.vertical
 await page.locator('#projection_oblique_x').fill('-0.5');await page.locator('#projection_oblique_z').fill('2');await page.locator('#gw-apply-projection').click()
 await wait(()=>JSON.parse(document.querySelector('#gw-renderer').dataset.model).revision===1)
 const adjusted=await model();assert.deepEqual(adjusted.projection.vertical,verticalBefore);assert.deepEqual(adjusted.rehearsal,three.rehearsal)
 await page.locator('#inspection_yaw').evaluate(el=>{el.value='0';el.dispatchEvent(new Event('input',{bubbles:true}));el.dispatchEvent(new Event('change',{bubbles:true}))});await wait(()=>document.querySelector('#gw-scene').dataset.yaw==='0')
 await page.locator('#gw-footing-2').click()
 await capture('03-both-bearing-inspection.png')
 await collect(25);assert.equal((await model()).rehearsal.ready,false)
 await collect(4)
 const five=await model();assert.equal(five.rehearsal.ready,true);assert.deepEqual(five.rehearsal.collected,[13,18,1,25,4]);assert.equal(five.rehearsal.progress,.65);assert.deepEqual(five.turn,initial.turn)
 assert.equal(await page.locator('#gw-readiness').textContent(),'READY TO STAND TOWARD RE-STEPPING')
 await pick(2);assert.equal(await page.locator('#gw-quick-collect').isDisabled(),true)
 await page.locator('#gw-lock').click();await wait(()=>!!JSON.parse(document.querySelector('#gw-renderer').dataset.model).lock)
 const lock=(await model()).witnesses
 await progress(.2);assert.deepEqual((await model()).witnesses,lock)
 assert.ok(await page.locator('#gw-scene path').evaluateAll(nodes=>nodes.every(n=>getComputedStyle(n).fill==='none')))
 await capture('04-five-footings-through-crossing.png')
 await page.locator('#gw-rehearsal').screenshot({path:out+'/05-readiness-ledger.png'})
 const promise=page.waitForEvent('download');await page.locator('#gw-export').click();const envelope=JSON.parse(await readFile(await (await promise).path(),'utf8'))
 assert.deepEqual(envelope.construction,await model())
 await page.locator('#gw-reset-rehearsal').click();await wait(()=>JSON.parse(document.querySelector('#gw-renderer').dataset.model).rehearsal.collected.length===0)
 const reset=await model();assert.deepEqual(reset.entities,five.entities);assert.equal(reset.rehearsal.previous_runs.at(-1).footings.length,5);assert.equal(reset.rehearsal.progress,0)
 await collect(3);await collect(25);assert.deepEqual((await model()).rehearsal.footings.map(f=>f.letter),['E','E'])
 await importFile(envelope);await wait(()=>JSON.parse(document.querySelector('#gw-renderer').dataset.model).rehearsal.ready)
 assert.deepEqual(await model(),envelope.construction)
 await page.setViewportSize({width:390,height:844});assert.deepEqual(await model(),envelope.construction)
 assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));assert.equal(await page.locator('#gw-footing-5-oblique').count(),1)
 await page.locator('#gw-rehearsal').screenshot({path:out+'/06-mobile-readiness.png'})
 await page.setViewportSize({width:1600,height:1200})
 const old=JSON.parse(await readFile(new URL('../fixtures/workshop_assignment_two.json',import.meta.url),'utf8'))
 const oldEnvelope={schema_version:2,construction:old,view:{regarding:'transverse',yaw:27}}
 await importFile(oldEnvelope);await page.waitForSelector('#gw-legacy');assert.deepEqual(await model(),old);assert.equal(await page.locator('#gw-rehearsal').count(),0)
 assert.equal(await page.locator('#gw-scene path').count(),428)
 await page.locator('#gw-migrate').click();await page.waitForSelector('#gw-rehearsal')
 const migrated=await model();assert.deepEqual(migrated.legacy_source,oldEnvelope);assert.equal(migrated.rehearsal.collected.length,0)
 assert.deepEqual(errors,[])
 console.log('Projection rehearsal browser passed: shared source, both candidates/modes, acquisitions and duplicate identity, independent COB progress, five-letter readiness, view/resize invariants, LOCK separation, reset archive, JSON reload and schema-2 preservation/explicit migration.')
} catch(error) {
 console.error('Page errors:', errors);console.error('Browser state:',await page.locator('#gw-message').textContent().catch(()=>''),await page.locator('#gw-file-form').textContent().catch(()=>''), 'schema', (await model()).schema_version)
 await page.screenshot({path:out+'/failure.png',fullPage:true});throw error
} finally {await browser.close()}
