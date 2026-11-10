import assert from 'node:assert/strict'
import {mkdir,readFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'/tmp/psm-inspection'
await mkdir(out,{recursive:true})
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH||undefined,args:['--no-sandbox']})
const page=await browser.newPage({viewport:{width:1800,height:1200}}),errors=[]
page.on('pageerror',e=>errors.push(e.message))
const model=()=>page.locator('#gw-renderer').evaluate(e=>JSON.parse(e.dataset.model))
const state=()=>page.locator('#ip-renderer').evaluate(e=>JSON.parse(e.dataset.inspection))
const instrument=()=>page.locator('#gw-renderer').evaluate(e=>JSON.parse(e.dataset.instrument))
const set=async (key,value)=>{
 await page.locator('#regarding_'+key).evaluate((el,value)=>{el.value=String(value);el.dispatchEvent(new Event('input',{bubbles:true}));el.dispatchEvent(new Event('change',{bubbles:true}))},value)
 await page.waitForFunction(({key,value})=>JSON.parse(document.querySelector('#ip-renderer').dataset.inspection).parameters[key]===value,{key,value})
}
const focus=async target=>{await page.selectOption('#locality_target',target);await page.waitForFunction(target=>{const p=JSON.parse(document.querySelector('#ip-renderer').dataset.inspection).parameters;const expected=target.startsWith('letter:')?1.02:target.startsWith('region:')?5.9:.78;return p.target===target&&Math.abs(p.distance-expected)<1e-8&&p.mode==='orbit'},target)}
const primary=async i=>{await page.locator('#ip-stand-'+i).click();await page.waitForFunction(i=>JSON.parse(document.querySelector('#ip-renderer')?.dataset.inspection||'null')?.parameters.stand===i&&JSON.parse(document.querySelector('#ip-renderer').dataset.inspection).parameters.distance===3&&JSON.parse(document.querySelector('#ip-renderer').dataset.inspection).parameters.mode==='orbit',i)}
const command=async (id,mode)=>{await page.locator('#ip-'+id).click();if(mode)await page.waitForFunction(mode=>JSON.parse(document.querySelector('#ip-renderer').dataset.inspection).parameters.mode===mode,mode)}
const signature=()=>page.locator('#ip-monitor-scene').getAttribute('data-image-signature')
const capture=async name=>page.locator('#ip-renderer').screenshot({path:out+'/'+name})
try {
 await page.goto(process.env.WORKSHOP_URL||'http://127.0.0.1:4004/workshop');await page.waitForSelector('.phx-connected');await page.waitForSelector('#gw-scene[data-structural-paths="439"]')
 for(const index of [13,18,1,25,4]){
  await page.selectOption('#pick_index',String(index));await page.waitForFunction(i=>document.querySelector('#gw-renderer').dataset.letter===String(i),index)
  await page.locator('#gw-quick-collect').click();await page.waitForFunction(i=>JSON.parse(document.querySelector('#gw-renderer').dataset.model).rehearsal.collected.includes(i),index)
 }
 await page.locator('#gw-furnish-calibration').click();await page.waitForSelector('#gw-calibration-controls')
 const before=await model(),appearances=[]
 for(const i of [3,8,13,18,23]){
  await primary(i);await command('along_forward','along_forward')
  assert.deepEqual((await state()).parameters.from,before.steeling.stations[i-1].point)
  appearances.push(await signature());assert.deepEqual(await model(),before)
  await capture(`01-stand-${i}.png`)
 }
 assert.equal(new Set(appearances).size,5)
 await primary(13);await focus('letter:1');await capture('08-temporary-t1-from-u13.png');assert.equal((await state()).parameters.stand,13)
 await focus('plane:bobbining-enclosure');await capture('09-u13-enclosure.png')
 await focus('plane:u-aperture');await command('through_aperture','orbit');await page.waitForFunction(()=>JSON.parse(document.querySelector('#ip-renderer').dataset.inspection).parameters.through);assert.equal((await state()).parameters.through,true)
 await primary(13);await focus('letter:13');await set('distance',.64)
 assert.ok(await page.locator('#ip-regarding-scene [data-letter-body="13"]').count()>0)
 await capture('02-u13-close.png')
 const edges=()=>page.locator('#ip-regarding-scene [data-letter-registration="13"]').evaluateAll(nodes=>nodes.map(n=>n.dataset.worldPoints).sort())
 const registration=await edges(),frontImage=await signature()
 await set('orbit',65);assert.notEqual(await signature(),frontImage)
 assert.deepEqual((await model()).steeling,before.steeling)
 await capture('03-u13-white-lines-side.png')
 await set('orbit',-140);await set('elevation',38);await capture('04-u13-rear-top.png')
 assert.deepEqual(await model(),before)
 await primary(13);await focus('letter:13');await set('distance',.8)
 for(const treatment of ['solid','registered','structural']) {await page.selectOption('#regarding_treatment',treatment);await page.waitForFunction(t=>JSON.parse(document.querySelector('#ip-renderer').dataset.inspection).parameters.treatment===t,treatment)}
 await page.selectOption('#regarding_treatment','registered');await page.waitForFunction(()=>JSON.parse(document.querySelector('#ip-renderer').dataset.inspection).parameters.treatment==='registered')
 const unchangedFrom=(await state()).parameters.from
 await command('monitor','monitor')
 const initialDistance=(await instrument()).monitor_distance,oldEye=(await instrument()).eye,monitor=JSON.parse(await page.locator('#ip-renderer').getAttribute('data-registry')).items.find(i=>i.id==='flat-monitor')
 await set('monitor_offset',.16)
 assert.ok((await instrument()).monitor_distance<initialDistance);assert.notDeepEqual((await instrument()).eye,oldEye)
 assert.deepEqual((await state()).parameters.from,unchangedFrom)
 assert.deepEqual(JSON.parse(await page.locator('#ip-renderer').getAttribute('data-registry')).items.find(i=>i.id==='flat-monitor'),monitor)
 assert.ok(Number(await page.locator('#ip-monitor-scene').getAttribute('data-visible-faces'))>0)
 await capture('05-monitor-approach-and-image.png')
 const monitorImage=await signature()
 await page.locator('#projection_oblique_x').fill('-0.5');await page.locator('#gw-apply-projection').click()
 await page.waitForFunction(()=>JSON.parse(document.querySelector('#gw-renderer').dataset.model).revision===1)
 const preserved=await model()
 await page.locator('#calibration_opening').fill('20');await page.locator('#gw-apply-calibration').click()
 await page.waitForFunction(()=>JSON.parse(document.querySelector('#ip-renderer').dataset.registry).parameters.opening===20)
 assert.notEqual(await signature(),monitorImage)
 await command('from','along_forward');assert.deepEqual((await state()).parameters.from,unchangedFrom)
 for(const region of ['tc','ch','central','lower']){
  await focus('region:'+region)
  await focus('plane:'+region+'-surface-z-min')
  assert.ok((await instrument()).target.source.outreadings.some(o=>o.class==='MEASURED'))
  assert.equal(await page.locator('#gw-inspect-'+region+'-surface-z-min').getAttribute('aria-pressed'),'true')
  await command('surface_along','surface_along');await command('surface_toward','orbit')
 }
 await capture('06-lower-surface-inspection.png')
 assert.deepEqual((await model()).rehearsal,before.rehearsal)
 const promise=page.waitForEvent('download');await page.locator('#gw-export').click();const envelope=JSON.parse(await readFile(await (await promise).path(),'utf8'))
 assert.equal(envelope.schema_version,5);assert.equal(envelope.extensions.inspection_v1.parameters.stand,13)
 const savedState=await state(),savedModel=await model()
 await command('overview');await page.waitForSelector('#ip-renderer',{state:'detached'});assert.equal(await page.locator('#gw-scene').getAttribute('data-regard'),'front')
 await page.locator('#gw-file-form input[type=file]').setInputFiles({name:'inspection.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(envelope))});await page.locator('#gw-import-file').click();await page.waitForSelector('#ip-renderer')
 assert.deepEqual(await state(),savedState);assert.deepEqual(await model(),savedModel)
 await page.setViewportSize({width:390,height:844});assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth))
 await primary(13);await focus('letter:13');await set('distance',.64)
 await capture('07-mobile-u13-monitor.png')
 assert.deepEqual((await model()).rehearsal,before.rehearsal);assert.deepEqual((await model()).steeling.stations,before.steeling.stations);assert.deepEqual((await model()).entities,before.entities)
 assert.deepEqual(errors,[])
 console.log('Inspection browser passed: five primary FROMs, actual course perspectives, close U13, fixed block registration, orbit/rear/top, measured monitor approach, computed projector response, all four cube surface/ledger foci, preserved acquisitions, schema-5 restore, overview and mobile.')
} catch(error){console.error('Page errors:',errors);await page.screenshot({path:out+'/failure.png',fullPage:true});throw error}finally{await browser.close()}
