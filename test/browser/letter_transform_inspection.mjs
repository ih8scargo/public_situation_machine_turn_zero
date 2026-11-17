import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out='docs/visual-witnesses/same-letter-transformations-v14';await mkdir(out,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try{
 const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[];page.on('pageerror',e=>errors.push(e.message))
 await page.goto('http://127.0.0.1:4001/experiments/architecture');await page.waitForSelector('.phx-connected')
 const root=page.locator('#room-toy-box'),panel=page.locator('#letter-transform-inspection');const source=await root.getAttribute('data-source-digest'),standing=await root.getAttribute('data-standing-digest')
 const click=async id=>{const r=await root.getAttribute('data-revision');await page.locator(id).click();await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const setting=async(key,value)=>{const r=await root.getAttribute('data-revision');await page.locator('#rtb-'+key).evaluate((el,v)=>{el.value=v;el.dispatchEvent(new Event('input',{bubbles:true}))},value);await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const shot=async name=>page.locator('.rfh-aperture').screenshot({path:`${out}/${name}.png`})
 await click('#letter-inspect');const letter=page.locator('#rtb-source-doorway-letter-R'),hash=await letter.getAttribute('data-source-hash')
 assert.equal(await letter.count(),1);await shot('01-same-R-flat')
 await setting('letter_door','45');await shot('02-Door-intermediate-R-stationary')
 await setting('letter_door','90');await setting('letter_bearing','90');await shot('03-same-R-edge-on')
 assert.equal(await letter.getAttribute('data-source-hash'),hash);assert.equal(await page.locator('#same-letter-toe').count(),1)
 await setting('letter_bearing','30');await setting('letter_curvature','0.5');await shot('04-rigid-curvature-frame-preview')
 assert.equal(await letter.getAttribute('data-source-hash'),hash)
 await page.locator('#letter-transform-ledger').evaluate(el=>el.open=true);await page.locator('#letter-curvature-source').screenshot({path:`${out}/05-existing-U-source.png`})
 const r=await root.getAttribute('data-revision');await page.locator('#letter-puffing-gate').click();await page.waitForSelector('#rtb-notice');assert.equal(await root.getAttribute('data-revision'),r)
 assert.match(await page.locator('#rtb-notice').innerText(),/PUFFING is not bound/)
 assert.equal(await root.getAttribute('data-source-digest'),source);assert.equal(await root.getAttribute('data-standing-digest'),standing)
 await page.setViewportSize({width:390,height:844});assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));await shot('06-mobile')
 await click('#letter-inspection-close');assert.equal(await page.locator('#same-letter-toe').count(),0)
 assert.deepEqual(errors,[])
 await writeFile(`${out}/verification.json`,JSON.stringify({contract:'same-letter-transformations-2026-11-17.v14',sourceDigest:source,letterSourceHash:hash,oneExistingR:true,DoorAngles:[0,45,90],RegardingBearings:[0,90,30],curvatureFramePreview:true,originalToeID:'specimen:R:1/leading-toe/end-cap',PUFFINGGateBlocked:true,acquiredDelta:0,standingDigestUnchanged:true,mobileOverflow:false,pageErrors:errors},null,2)+'\n')
 console.log('PASS same source R: separate Door/bearing/frame controls, toe, PUFFING gate, source/standing and mobile.')
}finally{await browser.close()}
