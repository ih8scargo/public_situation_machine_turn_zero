import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out='docs/visual-witnesses/paired-apertures';await mkdir(out,{recursive:true})
const browser=await chromium.launch({headless:true,args:['--no-sandbox']})
const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[];page.on('pageerror',e=>{errors.push(e.message);console.error(e.message)})
const host=page.locator('#crossing-rehearsal'),model=()=>host.evaluate(el=>JSON.parse(el.dataset.model)),geometry=async()=>JSON.parse(await host.getAttribute('data-geometry')),shot=async name=>page.screenshot({path:`${out}/${name}.png`,fullPage:true})
const setRange=async(id,value)=>{await page.locator('#'+id).evaluate((el,v)=>{el.value=String(v);el.dispatchEvent(new Event('input',{bubbles:true}));el.dispatchEvent(new Event('change',{bubbles:true}))},value)}
try{
 await page.goto('http://127.0.0.1:4001/experiments/architecture')
 await page.waitForFunction(()=>document.querySelector('#crossing-rehearsal')?.dataset.ready==='true')
 assert.equal((await geometry()).cabinet,45);assert.equal((await geometry()).doll,0)
 assert.equal(await page.locator('#mouse-treadmill,#inaugural-second-puff,#skate-forward').count(),0)
 await shot('01-before-pull-converging-cabinet')
 // The prominent face wheel is an operating purchase, not a decorative indicator.
 const b=await page.locator('#crossing-wheel').boundingBox();await page.mouse.move(b.x+b.width/2,b.y+b.height/2);await page.mouse.down();await page.mouse.move(b.x+b.width/2,b.y+b.height/2+80,{steps:12});await page.mouse.up()
 await page.waitForFunction(()=>Math.abs(JSON.parse(document.querySelector('#crossing-rehearsal').dataset.model).pull-.5)<.02)
 assert.ok((await geometry()).relative<1);assert.deepEqual((await geometry()).pin,[0,0,0]);await shot('02-midpoint-coincident-planes')
 await setRange('crossing-pull',1);await page.waitForFunction(()=>JSON.parse(document.querySelector('#crossing-rehearsal').dataset.model).pull===1)
 assert.equal((await geometry()).aligned,true);assert.equal((await geometry()).doll,45)
 const acquired=await geometry();await page.locator('#crossing-side').click();assert.deepEqual(await geometry(),acquired)
 await page.locator('#crossing-find-seam').click();assert.equal(await host.getAttribute('data-slice'),'seam');await shot('03-seam-wedge-side-section')
 await page.locator('#crossing-oblique').click();await setRange('crossing-feed',.7);await page.waitForFunction(()=>JSON.parse(document.querySelector('#crossing-rehearsal').dataset.model).feed===.7)
 assert.ok(await page.locator('[id^="cubical-passage-"]').count()>0);await shot('04-curved-passage-and-nozzle')
 await setRange('crossing-feed',1);await page.waitForFunction(()=>JSON.parse(document.querySelector('#crossing-rehearsal').dataset.model).feed===1)
 await page.locator('#crossing-receive').click();await page.waitForFunction(()=>document.querySelector('#crossing-rehearsal').dataset.received==='true')
 const appointed=(await model()).stick;assert.ok(appointed.curve.samples.length===65);await writeFile(`${out}/appointed-contract.json`,JSON.stringify(await model(),null,2))
 await page.locator('#crossing-slice').selectOption('all');await shot('05-cob-reception-indexed-corner')
 for(const slice of ['monitor','inner','cabinet','doll','seam','ground','far','all']){await page.locator('#crossing-slice').selectOption(slice);assert.deepEqual((await model()).stick,appointed);assert.deepEqual((await geometry()).pin,[0,0,0]);assert.equal((await geometry()).doll,45)}
 await page.locator('#crossing-ground').click();await shot('06-groundward-indexed-references');assert.deepEqual((await model()).stick,appointed)
 await setRange('crossing-pull',0);await page.waitForFunction(()=>JSON.parse(document.querySelector('#crossing-rehearsal').dataset.model).pull===0);assert.deepEqual((await model()).stick,appointed)
 await page.reload();await page.waitForFunction(()=>document.querySelector('#crossing-rehearsal')?.dataset.received==='true');assert.deepEqual((await model()).stick,appointed)
 const url=new URL(page.url());url.searchParams.set('mode','companion');await page.goto(url.href);await page.locator('#opening-geometry').waitFor();assert.deepEqual(await page.locator('#opening-geometry').evaluate(el=>JSON.parse(el.dataset.model).stick),appointed)
 url.searchParams.set('mode','geometry');await page.goto(url.href);await page.waitForFunction(()=>document.querySelector('#crossing-rehearsal')?.dataset.received==='true');assert.deepEqual((await model()).stick,appointed)
 await setRange('crossing-pull',1);await page.waitForFunction(()=>JSON.parse(document.querySelector('#crossing-rehearsal').dataset.model).pull===1)
 await page.setViewportSize({width:390,height:844});await shot('07-mobile-face-wheel-and-slices');assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth))
 assert.equal(await page.locator('path[d*="NaN"],path[d*="Infinity"]').count(),0);assert.deepEqual(errors,[])
 console.log('Paired-aperture geometry: face wheel, midpoint degeneracy, pin/alignment, slices, swept passage, indexed corner, reception and cross-mode persistence passed.')
}finally{await browser.close()}
