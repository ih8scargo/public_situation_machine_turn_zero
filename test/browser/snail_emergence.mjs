import assert from 'node:assert/strict'
import {readFile,mkdir} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'/tmp/snail-emergence-witnesses';await mkdir(out,{recursive:true})
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH||undefined,args:['--no-sandbox']})
const page=await browser.newPage({viewport:{width:1500,height:1100}}),errors=[];page.on('pageerror',e=>errors.push(e.message))
const model=()=>page.locator('#sw-renderer').evaluate(e=>JSON.parse(e.dataset.model))
const download=async()=>{const p=page.waitForEvent('download');await page.locator('#sw-export').click();return JSON.parse(await readFile(await(await p).path(),'utf8'))}
const view=async v=>{await page.locator('#sw-view-'+v).click();await page.waitForSelector('#sw-scene[data-view="'+v+'"]',{state:'attached'})}
const shot=async n=>page.locator('#sw-renderer').screenshot({path:out+'/'+n})
try{
 await page.goto(process.env.WEDGING_URL||'http://127.0.0.1:4007/workshop/wedging-geometry');await page.waitForSelector('.phx-connected');await page.waitForSelector('#sw-scene[data-view="flat"]',{state:'attached'})
 assert.equal((await model()).emergence.binding.source_footing,null)
 await page.locator('#sw-restore > summary').click();const saved=JSON.parse(await readFile('docs/visual-witnesses/snail-weave/two-woven-turns.json','utf8'));await page.locator('#weave_witness_json').fill(JSON.stringify(saved));await page.locator('#sw-import').click();await page.waitForSelector('#sw-acquisitions[data-count="2"]')
 const original=await download(),m=await model(),e=m.emergence,id=e.wall_test.material.id
 assert.deepEqual(e.registration.fixed_seat,[0,0,0]);assert.ok(e.registration.revised_eye[1]>0);assert.equal(e.registration.COB_eye[1],e.registration.revised_eye[1]);assert.equal(e.registration.bearing_degrees,45)
 const body=JSON.stringify(m.surfaces.filter(s=>s.kind==='corkscrew'))
 await view('contraption');await shot('01-contraption-seat-aperture-eye.png')
 await view('volume');await shot('02-volume-curved-wall.png');assert.ok(await page.locator('#sw-scene text[data-host-surface]').count()>0)
 const glyph=page.locator('#sw-scene text[data-host-surface]').first();assert.equal(await glyph.getAttribute('data-material'),id);await glyph.focus();await page.waitForFunction(id=>document.querySelector('#sw-outreading').textContent.includes(id),id)
 await view('flat');await shot('03-flat-same-material.png');assert.equal(await page.locator('#sw-flat-material').getAttribute('data-material'),id)
 await view('groundward');await shot('04-groundward-unvanishing-line.png');assert.equal(await page.locator('#sw-scene [data-body-object="Unvanishing Line source registration"]').getAttribute('data-material'),id)
 await page.locator('#emergence_quarter_turn').fill('0');await page.waitForFunction(()=>JSON.parse(document.querySelector('#sw-renderer').dataset.model).emergence.regard.quarter_turn===0)
 await view('volume');assert.equal(JSON.stringify((await model()).surfaces.filter(s=>s.kind==='corkscrew')),body);assert.deepEqual(await download(),original)
 await page.locator('#emergence_quarter_turn').fill('90');await page.waitForFunction(()=>JSON.parse(document.querySelector('#sw-renderer').dataset.model).emergence.regard.quarter_turn===90)
 await page.locator('#sw-fresh-engineering > summary').click();await page.locator('#emergence_extent').fill('10000');await page.waitForFunction(()=>JSON.parse(document.querySelector('#sw-renderer').dataset.model).emergence.fresh.inspected_later_extent===10000);assert.deepEqual(await download(),original)
 await page.locator('#sw-fresh').click();await page.waitForFunction(()=>JSON.parse(document.querySelector('#sw-renderer').dataset.model).emergence.fresh.inspected_later_extent===0)
 assert.equal((await model()).emergence.fresh.local_fashioning_extent,0);assert.equal((await model()).emergence.fresh.inherited_material_ids.length,1)
 await page.locator('#sw-fresh-state').screenshot({path:out+'/05-fresh-zero-inherited-material.png'})
 await page.selectOption('#emergence_candidate','arrival');await page.waitForFunction(()=>JSON.parse(document.querySelector('#sw-renderer').dataset.model).emergence.selected_candidate==='arrival');assert.equal((await model()).emergence.opportunities.find(c=>c.id==='arrival').eligible,false)
 await page.selectOption('#emergence_candidate','through');await page.waitForFunction(()=>JSON.parse(document.querySelector('#sw-renderer').dataset.model).emergence.selected_candidate==='through');assert.equal((await model()).emergence.opportunities.find(c=>c.id==='through').eligible,true)
 await view('contraption');await shot('06-wedging-candidate.png');assert.deepEqual(await download(),original)
 assert.ok(await page.locator('#weave_quill_text').isEnabled())
 await page.setViewportSize({width:390,height:844});await page.waitForFunction(()=>document.documentElement.scrollWidth<=innerWidth);await view('volume');await shot('07-mobile-volume.png')
 assert.deepEqual(errors,[])
 console.log('Seat-to-Spiral browser passed: revised fixed Seat/45° aperture/common eye; existing acquired source; actual wall glyphs and same flat/source ID; camera-only quarter turn; inherited material at zero; unrestricted later amount; puff eligibility without operation; canonical acquisition byte equality; mobile and no page errors.')
}catch(e){console.error(errors);await page.screenshot({path:out+'/failure.png',fullPage:true});throw e}finally{await browser.close()}
