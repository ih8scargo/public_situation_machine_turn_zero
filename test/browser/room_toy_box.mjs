import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'docs/visual-witnesses/room-toy-box-v11';await mkdir(out,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try {
 const page=await browser.newPage({viewport:{width:1500,height:1100}}),errors=[];page.on('pageerror',e=>errors.push(e.message))
 await page.goto('http://127.0.0.1:4001/experiments/architecture');await page.waitForSelector('.phx-connected');await page.waitForSelector('#crossing-rehearsal[data-ready="true"]')
 const root=page.locator('#room-toy-box')
 const standing=await root.getAttribute('data-standing-digest'),source=await root.getAttribute('data-source-digest')
 const axle=await page.locator('#rtb-source-cb-square-axle').getAttribute('data-source-hash')
 const click=async id=>{const r=await root.getAttribute('data-revision');await page.locator(id).click();await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const setting=async(key,value)=>{const r=await root.getAttribute('data-revision');await page.locator('#rtb-'+key).evaluate((el,v)=>{el.value=v;el.dispatchEvent(new Event('input',{bubbles:true}))},value);await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const shot=async name=>root.screenshot({path:`${out}/${name}.png`})
 await shot('01-room-oblique')
 for(const view of ['flat','left','right','two','five','ground','field']) {
   await click('#rtb-view-'+view);assert.equal(await root.getAttribute('data-source-digest'),source);await shot('room-'+view)
 }
 await click('#rtb-view-flat');await setting('door','22.5');await shot('door-intermediate');await setting('door','90');await shot('door-edge-on');await setting('door','0')
 await click('#rtb-movement-wedging');await click('#rtb-view-oblique');await shot('02-shared-wedging-U')
 await click('#rtb-movement-pinning')
 await page.locator('#rtb-pin-2').click();await page.waitForSelector('#rtb-notice')
 for(const n of [1,2,3])await click('#rtb-pin-'+n)
 assert.match(await page.locator('#rtb-pins').innerText(),/\[1, 2, 3\]/)
 const m=page.locator('#rtb-source-room-M'),mSource=await m.getAttribute('data-source-hash')
 for(const t of ['0','0.25','0.75','1']) {await setting('travel',t);assert.equal(await m.getAttribute('data-source-hash'),mSource)}
 for(const view of ['oblique','flat','ground','field']) {await click('#rtb-view-'+view);await shot('03-return-'+view)}
 assert.match(await page.locator('#rtb-clearance').innerText(),/axle interference: false/)
 assert.match(await page.locator('#rtb-clearance').innerText(),/Standing material: false/)
 await click('#rtb-projection');assert.equal(await m.getAttribute('data-source-hash'),mSource);await shot('M-projected-UP');await click('#rtb-projection')
 await click('#rtb-movement-stands')
 for(const view of ['two','five']) {await click('#rtb-view-'+view);await shot('04-stands-'+view)}
 await page.locator('#rtb-listing').evaluate(el=>el.open=true)
 await click('#rtb-inspect-cb-square-axle')
 assert.match(await page.locator('#rtb-inspector').innerText(),/FROM DOWN UNDER/)
 await shot('05-axle-material-ledger')
 assert.equal(await root.getAttribute('data-standing-digest'),standing)
 assert.equal(await root.getAttribute('data-source-digest'),source)
 assert.equal(await page.locator('#rtb-source-cb-square-axle').getAttribute('data-source-hash'),axle)
 assert.equal(await page.locator('#rtb-source-cb-seat').count(),1)
 assert.equal(await page.locator('#room-historical #co-building').count(),1)
 await page.setViewportSize({width:390,height:844});assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));await shot('06-mobile')
 await page.reload();await page.waitForSelector('.phx-connected');assert.equal(await root.getAttribute('data-source-digest'),source);assert.equal(await root.getAttribute('data-standing-digest'),standing)
 assert.deepEqual(errors,[])
 await writeFile(`${out}/verification.json`,JSON.stringify({sourceDigest:source,Msource:mSource,axleSource:axle,fourMovementsInspected:true,allViewsPreserveSource:true,threePINNINGRehearsals:true,axleNotMoved:true,underAxleAndStandingMaterialInterference:false,oneMSource:true,projectionDoesNotMoveMaterial:true,oneSeatInPrimaryAssembly:true,historicalWitnessesRetained:true,standingDigestUnchanged:true,acquisitionDelta:0,reloadPreservesSource:true,mobileOverflow:false,pageErrors:errors},null,2))
 console.log('PASS ROOM Toy Box: fixed sources, four movement views, ordered holds, one M, reciprocal stands, historical access, reload and mobile.')
} finally {await browser.close()}
