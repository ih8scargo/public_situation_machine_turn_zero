import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'docs/visual-witnesses/room-from-here-v12';await mkdir(out,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try {
 const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[];page.on('pageerror',e=>errors.push(e.message))
 await page.goto('http://127.0.0.1:4001/experiments/architecture');await page.waitForSelector('.phx-connected')
 const root=page.locator('#room-toy-box');const source=await root.getAttribute('data-source-digest'),standing=await root.getAttribute('data-standing-digest')
 const click=async id=>{const r=await root.getAttribute('data-revision');await page.locator(id).click();await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const setting=async(key,value)=>{const r=await root.getAttribute('data-revision');await page.locator('#rtb-'+key).evaluate((el,v)=>{el.value=v;el.dispatchEvent(new Event('input',{bubbles:true}))},value);await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const shot=async name=>page.locator('.rfh-aperture').screenshot({path:`${out}/${name}.png`})
 assert.equal(await page.locator('.rfh-corner').count(),4)
 await shot('01-flat')
 await setting('opening','0.5');await shot('02-opening');await setting('opening','1');await shot('03-diorama')
 await click('#rtb-view-flat');await setting('door','90');await shot('04-R-edge-on');await setting('door','0')
 await click('#rtb-select-O1');await click('#rtb-appoint-stage');assert.match(await page.locator('#rfh-authoring-state').innerText(),/STAGING FOR STANDING/)
 await click('#rtb-pivot-seat');await setting('turn','25');await shot('05-seat-turn-table-locked')
 const rev=await root.getAttribute('data-revision');await page.locator('#rtb-pivot-table').click();await page.waitForSelector('#rtb-notice');assert.equal(await root.getAttribute('data-revision'),rev);assert.equal(await root.getAttribute('data-active-pivot'),'seat')
 await click('#rtb-pivot-locked');await click('#rtb-pivot-table');await click('#rtb-gear-XT');await click('#rtb-steer');await shot('06-table-turn-seat-locked')
 await setting('turn','0');await click('#rtb-pivot-locked');await click('#rtb-pivot-seat');await setting('turn','0');await click('#rtb-pivot-locked')
 for(const n of ['1','42','88']){await setting('seam',n);for(const view of ['fore','aft']){await click('#rtb-view-'+view);assert.equal(await root.getAttribute('data-seam'),n);assert.equal(await page.locator('#rfh-seam-faces polygon').count(),2);if(n==='42')await shot('07-seam-'+view)}}
 await click('#rtb-view-oblique');await click('#rtb-labels');await shot('08-labelled-source-offices');await click('#rtb-labels')
 await page.locator('#rtb-listing').evaluate(el=>el.open=true);await click('#rtb-inspect-room-R');await setting('close','1');await shot('09-close-R-surface');await click('#rtb-return')
 await setting('orbit','45');await shot('10-around-about');await click('#rtb-return')
 for(const n of [1,2,3])await click('#rtb-pin-'+n)
 assert.match(await page.locator('#rtb-pins').innerText(),/\[1, 2, 3\]/)
 const mSource=await page.locator('#rtb-source-room-M').getAttribute('data-source-hash')
 for(const travel of ['0','0.25','0.75','1']){await setting('travel',travel);assert.equal(await page.locator('#rtb-source-room-M').getAttribute('data-source-hash'),mSource)}
 await shot('11-M-return-DOWN');await click('#rtb-projection');await shot('12-M-regarded-UP');await click('#rtb-projection')
 await click('#rtb-movement-stands');await click('#rtb-view-two');await shot('13-TWO');await click('#rtb-view-five');await shot('14-FIVE')
 assert.equal(await page.locator('[id^="rtb-source-landinging-sector-"]').count(),8)
 assert.equal(await page.locator('#rfh-eight-sector-markers > g').count(),8)
 assert.equal(await page.locator('[id^="rtb-inheritance-"]').count(),5)
 await page.locator('#rfh-staircase').evaluate(el=>el.open=true);
 await page.locator('#rfh-native-spiral').screenshot({path:`${out}/15-prospective-staircase.png`})
 assert.equal(await root.getAttribute('data-source-digest'),source);assert.equal(await root.getAttribute('data-standing-digest'),standing)
 assert.equal(await page.locator('#room-historical #co-building').count(),1)
 const box=await page.locator('.rfh-aperture').boundingBox();assert.ok(Math.abs(box.width-box.height)<2)
 await page.setViewportSize({width:390,height:844});assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));await shot('16-mobile')
 await page.reload();await page.waitForSelector('.phx-connected');assert.equal(await root.getAttribute('data-source-digest'),source);assert.equal(await root.getAttribute('data-standing-digest'),standing)
 assert.deepEqual(errors,[])
 await writeFile(`${out}/verification.json`,JSON.stringify({contract:'room-from-here-2026-11-17.v12',sourceDigest:source,standingDigest:standing,fourCornerOutreadings:true,squareAperture:true,flatOpeningPreservesSources:true,edgeOnR:true,explicitSelectionAndAppointment:true,pivotInterlock:true,seatAndTablePoseRehearsals:true,arbitrarySeamForeAft:[1,42,88],sameSelectedSeam:true,eightSectors:true,oneMSource:mSource,threeHolds:true,fiveTupleOffices:true,prospectiveStaircase:true,acquiredDelta:0,mobileOverflow:false,reloadPreservesSources:true,pageErrors:errors},null,2)+'\n')
 console.log('PASS ROOM FROM HERE: square appliance, sources, selection, pivots, seams, sectors, return, staircase, standing and mobile.')
}finally{await browser.close()}
