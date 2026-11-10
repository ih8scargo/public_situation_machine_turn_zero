import assert from 'node:assert/strict'
import {mkdir,readFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'/tmp/snail-body-witnesses';await mkdir(out,{recursive:true})
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH||undefined,args:['--no-sandbox']})
const page=await browser.newPage({viewport:{width:1500,height:1100}}),errors=[]
page.on('pageerror',e=>errors.push(e.message))
const model=()=>page.locator('#sb-renderer').evaluate(e=>JSON.parse(e.dataset.model))
const download=async id=>{const pending=page.waitForEvent('download');await page.locator(id).click();return JSON.parse(await readFile(await(await pending).path(),'utf8'))}
const view=async id=>{await page.locator('#sb-view-'+id).click();await page.waitForSelector('#sb-scene[data-view="'+id+'"]')}
const shot=async name=>page.locator('#sb-renderer').screenshot({path:out+'/'+name})
const fold=async n=>{await page.locator('#body_fold').fill(String(n));await page.waitForFunction(n=>JSON.parse(document.querySelector('#sb-renderer').dataset.model).fold.degrees===n,n)}
try{
 await page.goto(process.env.WEDGING_URL||'http://127.0.0.1:4007/workshop/wedging-geometry');await page.waitForSelector('.phx-connected');if(await page.locator('#sw-ancestry').count())await page.locator('#sw-ancestry').evaluate(e=>e.open=true);await page.waitForSelector('#sb-scene[data-view="external"]')
 const gallery=await download('#wgr-export'),initial=await download('#sb-export'),fixed=(await model()).fixed
 await shot('01-stationary-body.png')
 for(const mode of ['section','plan','reverse','within','external']){await view(mode);assert.deepEqual((await model()).fixed,fixed);assert.deepEqual(await download('#sb-export'),initial)}
 await fold(0);await shot('02-vertical-partial-rings.png');assert.equal((await model()).fold.normal[1],0)
 await fold(45);const diagonal=(await model()).fold.normal;assert.ok(diagonal[1]<0&&diagonal[1]>-1)
 await fold(90);assert.equal((await model()).fold.normal[1],-1);await shot('03-downward-quarter-turn.png')
 await page.selectOption('#body_quarter','3');await page.waitForFunction(()=>JSON.parse(document.querySelector('#sb-renderer').dataset.model).fold.quarter===3);assert.deepEqual((await model()).fixed,fixed)
 await view('within');await shot('04-within-downward-tunneling.png')
 await page.selectOption('#body_quarter','0');await page.waitForFunction(()=>JSON.parse(document.querySelector('#sb-renderer').dataset.model).fold.quarter===0)
 await view('section');await shot('05-intermediate-and-down-under.png')
 await view('external');const instrumentation=(await model()).instrumentation
 const target=page.locator('#sb-scene [data-body-object="cabinet-side-aperture"]');await target.focus();await page.waitForFunction(()=>document.querySelector('#sb-outreading').textContent.includes('cabinet-side-aperture'));await page.keyboard.press('Enter');assert.equal(await page.locator('#sb-outreading').getAttribute('data-pinned'),'true');await page.keyboard.press('Escape')
 await shot('06-side-access-outreading.png')
 await page.locator('#sb-instrument-visibility').click();assert.deepEqual((await model()).instrumentation,instrumentation);await page.waitForSelector('#sb-scene [data-body-object="side-AROUND-THE-CORNER"]',{state:'detached'});await page.locator('#sb-instrument-visibility').click()
 await page.locator('#sb-take').focus();await page.keyboard.press('Enter');await page.waitForSelector('#sb-needle-status[data-condition="held"]')
 await page.locator('#quill_text').fill('Quilling retained WITH this held piece.');await page.locator('#sb-withdraw').click();await page.waitForSelector('#sb-line-status[data-outstanding="500"]');assert.equal(await page.locator('#quill_text').inputValue(),'Quilling retained WITH this held piece.')
 await page.locator('#sb-quill').click();await page.waitForSelector('#sb-flat-monitor p:has-text("Quilling retained")')
 await page.locator('#sb-withdraw').click();await page.waitForSelector('#sb-line-status[data-outstanding="1000"]');await page.locator('#sb-withdraw').click();await page.waitForSelector('#sb-line-status[data-outstanding="1500"]')
 const held=await download('#sb-export');await page.locator('.sb-grid').screenshot({path:out+'/07-held-quilling-and-yt.png'})
 await view('section');await view('external');assert.deepEqual(await download('#sb-export'),held)
 await page.locator('#sb-return').click();await page.waitForSelector('#sb-needle-status[data-condition="gathering"]');assert.ok(await page.locator('#sb-take').isDisabled())
 await page.locator('#sb-gather').click();await page.waitForSelector('#sb-line-status[data-outstanding="1000"][data-gathered="500"]');await shot('08-measured-gathering.png')
 await page.locator('#sb-gather-all').click();await page.waitForSelector('#sb-ready[data-ready="true"]')
 const resolved=await download('#sb-export');assert.equal(resolved.state.withdrawn,1500);assert.equal(resolved.state.gathered,1500);assert.equal(resolved.state.outstanding,0);assert.equal(resolved.state.held,null);assert.deepEqual(resolved.state.material,held.state.material);assert.deepEqual((await model()).fixed,fixed);assert.deepEqual(await download('#wgr-export'),gallery)
 await page.locator('.sb-grid').screenshot({path:out+'/09-readied-provenance-retained.png'})
 await page.locator('#sb-restore > summary').click();await page.locator('#body_witness_json').fill(JSON.stringify(held));await page.locator('#sb-import').click();await page.waitForSelector('#sb-needle-status[data-condition="held"]');assert.deepEqual(await download('#sb-export'),held)
 await page.setViewportSize({width:390,height:844});await page.waitForFunction(()=>document.documentElement.scrollWidth<=innerWidth);await shot('10-mobile-body.png')
 assert.deepEqual(errors,[])
 console.log('Snail body browser passed: A fixed standing; B 0/45/90-degree folds and inward tunneling; C side corner/outreading/hidden provenance; D held Quilling/draft/keyboard; E conserved gathering/readying/persistence; F shield and DOWN UNDER; existing Gallery unchanged; mobile; no page errors.')
}catch(e){console.error(errors);await page.screenshot({path:out+'/failure.png',fullPage:true});throw e}finally{await browser.close()}
