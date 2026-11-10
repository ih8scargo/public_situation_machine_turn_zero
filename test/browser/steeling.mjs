import assert from 'node:assert/strict'
import {mkdir,readFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'/tmp/psm-steeling'
await mkdir(out,{recursive:true})
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH||undefined,args:['--no-sandbox']})
const page=await browser.newPage({viewport:{width:1600,height:1150}}),errors=[]
page.on('pageerror',e=>errors.push(e.message))
const model=()=>page.locator('#gw-renderer').evaluate(e=>JSON.parse(e.dataset.model))
const rev=r=>page.waitForFunction(r=>document.querySelector('#geometric-workshop')?.dataset.revision===String(r),r)
const pivot=async yaw=>{await page.locator('#inspection_yaw').evaluate((el,value)=>{el.value=String(value);el.dispatchEvent(new Event('input',{bubbles:true}));el.dispatchEvent(new Event('change',{bubbles:true}))},yaw);await page.waitForFunction(yaw=>document.querySelector('#gw-scene')?.dataset.yaw===String(yaw),yaw)}
const download=async()=>{const promise=page.waitForEvent('download');await page.locator('#gw-export').click();return JSON.parse(await readFile(await (await promise).path(),'utf8'))}
try {
 await page.goto(process.env.WORKSHOP_URL||'http://127.0.0.1:4001/workshop')
 await page.waitForSelector('#gw-scene[data-structural-paths="439"]');await page.waitForFunction(()=>document.querySelector('.phx-connected'))
 const initial=await model()
 assert.deepEqual(initial.positions,{tc:0,ch:6});assert.deepEqual(initial.entities.central.frame.origin,[12,0,-3]);assert.deepEqual(initial.entities.lower.frame.origin,[12,-6,-3])
 assert.equal(initial.steeling.stations.length,25)
 for(let i=1;i<=25;i++){await page.locator('#gw-station-'+i).click();await page.waitForSelector(`#gw-station-${i}[aria-pressed=true]`)}
 assert.deepEqual(await model(),initial)
 await page.locator('#gw-station-13').click()
 await page.locator('#gw-view-front').click();await page.locator('#geometric-workshop').scrollIntoViewIfNeeded()
 await page.screenshot({path:out+'/01-structural-index-overview.png',fullPage:true})
 const world=await page.locator('#gw-steeling-letter-13').getAttribute('data-world-points')
 for(const view of ['plan','transverse','reverse','front']) {
   await page.locator('#gw-view-'+view).click()
   for(const yaw of [-140,-30,0,61,180]) {await pivot(yaw);assert.deepEqual(await model(),initial);assert.equal(await page.locator('#gw-steeling-letter-13').getAttribute('data-world-points'),world)}
 }
 await page.locator('#steeling_approach_bend').fill('4.5');await page.locator('#steeling_n_heading').fill('123');await page.locator('#steeling_machine_reach').fill('7.2')
 await page.locator('#gw-apply-steeling').click();await rev(1)
 const adjusted=await model()
 assert.deepEqual(adjusted.steeling.u_return,initial.steeling.u_return)
 assert.deepEqual(adjusted.entities,initial.entities);assert.deepEqual(adjusted.turn,initial.turn)
 assert.notDeepEqual(adjusted.steeling.machine.points,initial.steeling.machine.points)
 assert.equal(adjusted.steeling.machine.inherited_from,adjusted.steeling.n_return.id)
 assert.deepEqual(adjusted.steeling.machine.origin,adjusted.steeling.n_return.point)
 await page.locator('#gw-view-transverse').click();await pivot(0);await page.locator('#gw-station-18').click()
 assert.equal(await page.locator('#gw-steeling-letter-13').count(),1);assert.equal(await page.locator('#gw-steeling-letter-18').count(),1)
 assert.ok(await page.locator('#gw-scene path').evaluateAll(nodes=>nodes.every(n=>getComputedStyle(n).fill==='none')))
 await page.locator('#gw-steeling-form').scrollIntoViewIfNeeded();await page.screenshot({path:out+'/02-u13-n18-return-inspection.png',fullPage:true})
 await page.locator('#gw-lock').click();await rev(2)
 assert.equal(await page.locator('#gw-apply-steeling').isDisabled(),true)
 const envelope=await download();assert.deepEqual(envelope.construction,await model());assert.deepEqual(envelope.view,{regarding:'transverse',yaw:0,bearing:'both'})
 await page.locator('#gw-release').click();await rev(3);await page.locator('#gw-reset-steeling').click();await rev(4)
 assert.deepEqual((await model()).steeling,initial.steeling)
 await page.locator('#gw-file-form input[type=file]').setInputFiles({name:'steeling.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(envelope))})
 await page.locator('#gw-import-file').click();await rev(2);assert.deepEqual(await model(),envelope.construction)
 await page.setViewportSize({width:390,height:844});assert.deepEqual(await model(),envelope.construction)
 assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));assert.equal(await page.locator('#gw-scene path').count(),439)
 await page.locator('#gw-two-returns').scrollIntoViewIfNeeded();await page.screenshot({path:out+'/03-mobile-returns.png',fullPage:true})
 await page.setViewportSize({width:1600,height:1150})
 const old=JSON.parse(await readFile(new URL('../fixtures/workshop_milestone_one.json',import.meta.url),'utf8'))
 const oldEnvelope={schema_version:1,construction:old,view:{regarding:'front'}}
 await page.locator('#gw-file-form input[type=file]').setInputFiles({name:'old.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(oldEnvelope))})
 await page.locator('#gw-import-file').click();await page.waitForSelector('#gw-legacy');assert.deepEqual(await model(),old)
 assert.equal(await page.locator('#gw-move').isDisabled(),true);assert.equal(await page.locator('#gw-scene path').count(),92)
 assert.deepEqual(await download(),oldEnvelope)
 await page.locator('#gw-migrate').click();await page.waitForSelector('#gw-steeling-form')
 const migrated=await model();assert.deepEqual(migrated.legacy_source,oldEnvelope);assert.deepEqual(migrated.positions,{tc:0,ch:6});assert.notEqual(migrated.construction_id,old.construction_id)
 assert.deepEqual(errors,[])
 console.log('Steeling browser passed: 25 selections, U/N invariants, N-derived MACHINE, editable course, yaw/view/resize invariance, all-outline geometry, LOCK, JSON reload, legacy inspection and explicit migration.')
} finally {await browser.close()}
