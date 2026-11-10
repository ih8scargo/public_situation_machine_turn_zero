import assert from 'node:assert/strict'
import {mkdir,readFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'/tmp/psm-wedging-round-two';await mkdir(out,{recursive:true})
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH||undefined,args:['--no-sandbox']})
const page=await browser.newPage({viewport:{width:1500,height:1100}}),errors=[]
page.on('pageerror',e=>errors.push(e.message))
const model=()=>page.locator('#wgr-renderer').evaluate(e=>JSON.parse(e.dataset.room))
const download=async()=>{const promise=page.waitForEvent('download');await page.locator('#wgr-export').click();return JSON.parse(await readFile(await(await promise).path(),'utf8'))}
const view=async id=>{await page.locator('#wgr-view-'+id).click();await page.waitForFunction(id=>document.querySelector('#wgr-scene')?.dataset.view===id,id)}
const capture=async name=>page.locator('#wgr-renderer').screenshot({path:out+'/'+name})
const propose=async()=>{await page.locator('#wgr-propose').click();await page.waitForSelector('#wgr-candidate-review')}
try{
 await page.goto(process.env.WEDGING_URL||'http://127.0.0.1:4007/workshop/wedging-geometry');await page.waitForSelector('.phx-connected');if(await page.locator('#sw-ancestry').count())await page.locator('#sw-ancestry').evaluate(e=>e.open=true);await page.waitForSelector('#wgr-scene[data-view="external"]')
 const initial=await download()
 await view('within');assert.deepEqual((await download()).state,initial.state);await capture('01-from-within-gallery.png')
 await page.locator('#wgr-appoint-furnishing').click();await page.waitForFunction(()=>document.querySelector('#wgr-furnishing-status').textContent.includes('APPOINTED'))
 await page.locator('#wgr-bay-0').click();await page.waitForFunction(()=>document.querySelector('#wgr-selected').textContent.includes('Bay 1'))
 await page.locator('#candidate_purpose').fill('Human-held paired curvature trial')
 await propose();const candidate=(await model()).proposal;assert.equal(candidate.parameters.layout,'same');assert.ok(candidate.clearance>0)
 await view('external');await capture('02-common-spine-paired-proposal.png')
 await page.selectOption('#candidate_layout','previous');await page.locator('#wgr-revise').click();await page.waitForFunction(()=>JSON.parse(document.querySelector('#wgr-renderer').dataset.room).proposal.parameters.layout==='previous')
 assert.ok((await model()).proposal.clearance<0)
 await page.locator('#wgr-confirm').click();await page.waitForFunction(()=>document.querySelector('#wgr-message').textContent.includes('clearance'))
 assert.equal((await download()).state.founding,null)
 await page.selectOption('#candidate_layout','next');await page.locator('#wgr-revise').click();await page.waitForFunction(()=>JSON.parse(document.querySelector('#wgr-renderer').dataset.room).proposal.parameters.layout==='next')
 assert.ok((await model()).proposal.clearance>0);await capture('03-neighbor-mouth-alternative.png')
 await page.selectOption('#candidate_layout','same');await page.locator('#wgr-revise').click();await page.waitForFunction(()=>JSON.parse(document.querySelector('#wgr-renderer').dataset.room).proposal.parameters.layout==='same')
 await page.locator('#wgr-confirm').click();await page.waitForFunction(()=>JSON.parse(document.querySelector('#wgr-renderer').dataset.room).pairs.length===1)
 const first=(await download()).state,id=first.confirmed[0].id,founding=first.founding.id
 assert.ok(first.furnishing);assert.equal(first.traversaling,null)
 await page.locator('#wgr-appoint-traversaling').click();await page.waitForFunction(()=>document.querySelector('#wgr-traversaling-status').textContent.includes('APPOINTED'))
 await page.locator('.wgr-offices').screenshot({path:out+'/09-two-appointed-offices.png'})
 for(const course of ['up_over','ordinary']){
  await page.locator(`#wgr-enter-${id}-${course}`).click();await page.waitForFunction(course=>JSON.parse(document.querySelector('#wgr-renderer').dataset.room).active?.course===course,course)
  const points=[]
  for(let i=1;i<=4;i++){await page.locator('#wgr-travel-step').click();await page.waitForFunction(t=>JSON.parse(document.querySelector('#wgr-renderer').dataset.room).active.progress===t,i/4);points.push((await model()).active.point)}
  assert.ok(points.some(p=>Math.hypot(p[0],p[2])>1));assert.ok(Math.hypot(points.at(-1)[0],points.at(-1)[2])<1e-9)
 }
 await page.waitForSelector('#wgr-footing-2')
 const completed=(await download()).state
 assert.equal(completed.footings.length,2);assert.equal(completed.founding.first_footing,completed.footings[0].id)
 assert.equal(completed.footings[0].holds_inaugural_office,true);assert.equal(completed.footings[1].holds_inaugural_office,false)
 assert.notEqual(completed.furnishing.TOWARD,completed.traversaling.TOWARD)
 await capture('04-traversal-return-here.png')
 await page.locator('#wgr-footings').screenshot({path:out+'/05-two-footings.png'})
 for(const mode of ['within','plan','section','external']){await view(mode);assert.deepEqual((await download()).state,completed);if(mode==='within'||mode==='section')await capture('10-furnished-'+mode+'.png')}
 // Camera keyboard adjustment leaves experimental standing untouched.
 await page.locator('#camera_orbit').focus();await page.keyboard.press('ArrowRight')
 await page.waitForFunction(()=>JSON.parse(document.querySelector('#wgr-renderer').dataset.view).orbit===36)
 assert.deepEqual((await download()).state,completed)
 await page.locator('#wgr-bearing-next').click();await page.waitForFunction(()=>document.querySelector('#wgr-bearing-context').textContent.includes('90°'))
 await page.locator('#wgr-bay-2').click();await page.waitForFunction(()=>document.querySelector('#wgr-selected').textContent.includes('Bay 3'))
 await propose();await page.locator('#wgr-discard').click();await page.waitForSelector('#wgr-candidate-review',{state:'detached'})
 assert.equal((await download()).state.founding.id,founding)
 await propose();await page.locator('#wgr-confirm').click();await page.waitForFunction(()=>JSON.parse(document.querySelector('#wgr-renderer').dataset.room).pairs.length===2)
 const inherited=(await download()).state;assert.equal(inherited.founding.id,founding);assert.equal(inherited.confirmed[1].inherits,id)
 await view('external');await capture('06-inherited-second-pair.png')
 await page.locator('#wgr-show-founding').click();await page.waitForSelector('#wgr-scene[data-view="plan"]');await capture('07-recover-founding-pittoning.png')
 await page.setViewportSize({width:390,height:844});await page.waitForFunction(()=>innerWidth===390&&document.documentElement.scrollWidth<=innerWidth);await view('within');await capture('08-mobile-from-within.png')
 await page.setViewportSize({width:1500,height:1100});const saved=await download();await page.locator('#wg-reset').click();await page.waitForSelector('#wgr-footing-1',{state:'detached'})
 await page.locator('#wgr-import-form').evaluate(e=>e.closest('details').open=true);await page.locator('#wgr-import-form').locator('textarea').fill(JSON.stringify(saved));await page.locator('#wgr-import').click();await page.waitForSelector('#wgr-footing-2');assert.deepEqual((await download()).state,saved.state)
 assert.deepEqual(errors,[])
 console.log('Wedging Round Two browser passed: shared FROM WITHIN/external/plan/section; real clearance rejection; same/neighbor alternatives; two office appointments; both distance-driven courses and HERE returns; two Footings; one inherited PITTONING; discard/add growth; camera invariance; keyboard; mobile; witness restore.')
}catch(e){console.error('Page errors:',errors);console.log(await page.evaluate(()=>({w:innerWidth,sw:document.documentElement.scrollWidth,items:[...document.querySelectorAll('*')].filter(e=>e.scrollWidth>e.clientWidth+5&&e.clientWidth>0).map(e=>[e.tagName,e.id,e.clientWidth,e.scrollWidth,getComputedStyle(e).overflowX]).slice(0,40)})));await page.screenshot({path:out+'/failure.png',fullPage:true});throw e}finally{await browser.close()}
