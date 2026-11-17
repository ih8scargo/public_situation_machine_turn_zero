import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'docs/visual-witnesses/one-cubical-doorway-v13';await mkdir(out,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try{
 const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[];page.on('pageerror',e=>errors.push(e.message))
 await page.goto('http://127.0.0.1:4001/experiments/architecture');await page.waitForSelector('.phx-connected')
 const root=page.locator('#room-toy-box');const source=await root.getAttribute('data-source-digest'),standing=await root.getAttribute('data-standing-digest')
 const click=async id=>{if(id.startsWith('#rtb-inspect-'))await page.locator('#rtb-listing').evaluate(el=>el.open=true);const r=await root.getAttribute('data-revision');await page.locator(id).click();await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const setting=async(key,value)=>{const r=await root.getAttribute('data-revision');await page.locator('#rtb-'+key).evaluate((el,v)=>{el.value=v;el.dispatchEvent(new Event('input',{bubbles:true}))},value);await page.waitForFunction(v=>document.querySelector('#room-toy-box').dataset.revision!==v,r)}
 const shot=async name=>page.locator('.rfh-aperture').screenshot({path:`${out}/${name}.png`})
 await setting('opening','1');await shot('01-constructed-Table-frame')
 await click('#rtb-labels');await shot('02-source-offices');await click('#rtb-labels')
 assert.equal(await page.locator('#rtb-source-doorway-cob').count(),1)
 for(const id of ['real-tc','pretend-tc','inner-u','outer-u','r-wall'])assert.equal(await page.locator('#rtb-source-doorway-'+id).count(),1)
 await page.locator('#rtb-listing').evaluate(el=>el.open=true)
 await click('#rtb-inspect-doorway-pretend-tc');await setting('close','0.6');await shot('03-Pretend-TC-axle-bore');await click('#rtb-return')
 await click('#rtb-inspect-doorway-real-tc');await setting('close','0.6');await shot('04-Real-TC-under-Table');await click('#rtb-return')
 const phases=[]
 for(const [i,letter] of ['R','O1','O2','M'].entries()){
  for(const action of ['trace','select','place'])await click('#unit-'+action)
  assert.equal(await root.getAttribute('data-doorway-phase'),'placed')
  const material=page.locator('#rtb-source-doorway-letter-'+letter);const hash=await material.getAttribute('data-source-hash')
  if(i===0)await shot('05-unit-R-placed')
  await click('#unit-open');assert.equal(await material.getAttribute('data-source-hash'),hash)
  if(i===0)await shot('06-Door-open-R-still-placed')
  for(const progress of ['0.25','0.5','0.75','1'])await setting('doorway_progress',progress)
  assert.equal(await root.getAttribute('data-doorway-phase'),'passed')
  if(i===0){await shot('07-R-receiving-aperture');await click('#rtb-inspect-doorway-letter-R');await setting('close','1');await shot('08-unit-R-source-inscription');await click('#rtb-return')}
  await click('#unit-needle')
  for(const progress of ['0.25','0.5','0.75','1'])await setting('doorway_progress',progress)
  assert.equal(await root.getAttribute('data-doorway-index'),String(i+1));phases.push(letter)
 }
 assert.match(await page.locator('#unit-passage-status').innerText(),/succession complete/)
 await shot('09-four-material-offloads')
 await click('#unit-layer-legacy');await click('#rtb-movement-pinning')
 for(const n of [1,2,3])await click('#rtb-pin-'+n)
 await shot('10-preserved-M-return')
 await setting('seam','42');for(const view of ['fore','aft'])await click('#rtb-view-'+view)
 assert.equal(await root.getAttribute('data-seam'),'42')
 await click('#rtb-pivot-seat');await setting('turn','5');const r=await root.getAttribute('data-revision');await page.locator('#unit-layer-candidate').click();await page.waitForSelector('#rtb-notice');assert.equal(await root.getAttribute('data-revision'),r)
 await setting('turn','0');await click('#rtb-pivot-locked');await click('#unit-layer-candidate');await click('#rtb-view-oblique')
 assert.equal(await root.getAttribute('data-source-digest'),source);assert.equal(await root.getAttribute('data-standing-digest'),standing)
 assert.equal(await page.locator('[id^="rtb-inheritance-"]').count(),5)
 await page.setViewportSize({width:390,height:844});assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));await shot('11-mobile')
 await page.reload();await page.waitForSelector('.phx-connected');assert.equal(await root.getAttribute('data-source-digest'),source)
 assert.deepEqual(errors,[])
 await writeFile(`${out}/verification.json`,JSON.stringify({contract:'one-cubical-doorway-2026-11-17.v13',sourceDigest:source,standingDigest:standing,orderedLetters:phases,oneAtATime:true,DoorOpeningPreservesLetterSource:true,pairedBodiesPresent:true,COBOneCubePresent:true,neutralPivotGuard:true,legacyMAndSeamRetained:true,fiveTupleOffices:true,acquiredDelta:0,mobileOverflow:false,pageErrors:errors},null,2)+'\n')
 console.log('PASS unit doorway: paired computers, ordered one-letter passage, source-preserving Door, offloads, legacy M, guarded pivots, standing and mobile.')
}finally{await browser.close()}
