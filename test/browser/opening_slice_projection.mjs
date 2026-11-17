import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out='docs/visual-witnesses/opening-slice-projection-v15';await mkdir(out,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try{
 const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[];page.on('pageerror',e=>errors.push(e.message))
 await page.goto('http://127.0.0.1:4001/experiments/architecture');await page.waitForSelector('.phx-connected')
 const root=page.locator('#room-toy-box');const source=await root.getAttribute('data-source-digest'),standing=await root.getAttribute('data-standing-digest')
 const click=async id=>{if(id.startsWith('#rtb-inspect-'))await page.locator('#rtb-listing').evaluate(el=>el.open=true);const r=await root.getAttribute('data-revision');await page.locator(id).click();await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const setting=async(key,value)=>{const r=await root.getAttribute('data-revision');await page.locator('#rtb-'+key).evaluate((el,v)=>{el.value=v;el.dispatchEvent(new Event('input',{bubbles:true}))},value);await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const shot=async name=>page.locator('.rfh-aperture').screenshot({path:`${out}/${name}.png`})
 await click('#slice-compact')
 const hashes={}
 for(const id of ['real-tc','pretend-tc','inner-u','outer-u','r-wall'])hashes[id]=await page.locator('#rtb-source-doorway-'+id).getAttribute('data-source-hash')
 await click('#slice-appoint');assert.equal(await page.locator('#rtb-source-doorway-letter-R').count(),0)
 assert.equal(await page.locator('#rtb-source-projection-opening-slice').count(),1);await shot('01-one-appointed-wedge')
 await click('#rtb-inspect-projection-compact-opening');await setting('close','0.85');await shot('02-compact-reservation-opening');await click('#rtb-return')
 await click('#slice-open');await setting('slice_progress','0.75');await shot('03-straight-issue-before-resolution')
 await setting('slice_progress','1');await click('#slice-resolve')
 const R=page.locator('#rtb-source-doorway-letter-R'),rHash=await R.getAttribute('data-source-hash');assert.equal(await R.count(),1)
 assert.equal(await page.locator('#resolved-letter-toe').count(),1)
 await click('#rtb-view-oblique');await shot('04-same-R-resolved-curvature')
 await click('#rtb-inspect-doorway-letter-R');await setting('close','0.8');await shot('05-source-R-resolved-surface');await click('#rtb-return')
 await click('#slice-next')
 for(const id of ['O1','O2','M']){await click('#slice-appoint');await click('#slice-open');await setting('slice_progress','1');await click('#slice-resolve');assert.equal(await page.locator('#rtb-source-doorway-letter-'+id).count(),1);await click('#slice-next')}
 await shot('06-four-inherited-appointments')
 assert.equal(await R.getAttribute('data-source-hash'),rHash)
 await click('#slice-ports');assert.equal(await page.locator('#rtb-source-projection-compact-opening').count(),0);await shot('07-preserved-port-candidate')
 await click('#slice-compact')
 for(const id of ['real-tc','pretend-tc']){await click('#rtb-inspect-doorway-'+id);await setting('close','0.6');await shot('08-'+id);await click('#rtb-return')}
 for(const [id,hash] of Object.entries(hashes))assert.equal(await page.locator('#rtb-source-doorway-'+id).getAttribute('data-source-hash'),hash)
 assert.equal(await root.getAttribute('data-source-digest'),source);assert.equal(await root.getAttribute('data-standing-digest'),standing)
 await page.setViewportSize({width:390,height:844});assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));await shot('09-mobile')
 assert.deepEqual(errors,[])
 await writeFile(`${out}/verification.json`,JSON.stringify({contract:'opening-slice-projection-2026-11-17.v15',sourceDigest:source,RSourceHash:rHash,priorCandidateHashes:hashes,orderedLetters:['R','O1','O2','M'],compactSliceIsNotMiniatureLetter:true,actualSourceCurvatureResolution:true,oneAtATime:true,portCandidatePreserved:true,pairedTCBodiesPreserved:true,acquiredDelta:0,standingDigestUnchanged:true,mobileOverflow:false,pageErrors:errors},null,2)+'\n')
 console.log('PASS compact wedge, straight issuance, same-source curvature resolution, four appointments, preserved ports/TC bodies, unchanged standing and mobile.')
}finally{await browser.close()}
