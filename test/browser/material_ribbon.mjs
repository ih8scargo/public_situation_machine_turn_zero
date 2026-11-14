import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE || 'playwright')
const output=process.env.WITNESS_DIR || 'docs/visual-witnesses/material-ribbon'
await mkdir(output,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try {
 const page=await browser.newPage({viewport:{width:1440,height:1050}})
 const errors=[];page.on('pageerror',e=>errors.push(e.message))
 await page.goto(process.env.WORKSHOP_URL || 'http://127.0.0.1:4001/workshop/string-ribbon')
 await page.waitForSelector('.phx-connected')
 const bench=page.locator('#material-bench')
 const world=()=>page.locator('#mr-piece-outgoing').getAttribute('data-world')
 const id=()=>page.locator('#mr-piece-outgoing').getAttribute('data-material')
 const waitRevision=async before=>page.waitForFunction(r=>Number(document.querySelector('#material-bench').dataset.revision)>r,before)
 const click=async selector=>{const r=Number(await bench.getAttribute('data-revision'));await page.locator(selector).click();await waitRevision(r)}
 const snap=async name=>bench.screenshot({path:`${output}/${name}.png`})
 const initial=await world(), material=await id()
 for (const view of ['flat','backstage','gallery','through','along','side']) {
  await click('#mr-view-'+view)
  assert.equal(await world(),initial);assert.equal(await id(),material)
  await snap('01-'+view)
 }
 const railFlat=await page.locator('#mr-rail-flat-face-140').getAttribute('data-world')
 assert.equal(railFlat,await page.locator('#mr-rail-gallery-face-140').getAttribute('data-world'))
 await click('#mr-toggle-obstacle');await click('#mr-fold-end')
 assert.match(await page.locator('#mr-fold-notice').innerText(),/BLOCKED/)
 assert.equal(await world(),initial)
 await snap('02-blocked')
 await click('#mr-toggle-obstacle');await click('#mr-fold-end')
 assert.notEqual(await world(),initial);assert.equal(await id(),material)
 await click('#mr-view-gallery')
 await snap('03-folded-gallery')
 await page.selectOption('#reference_reference','SIX')
 await page.fill('#reference_text','My SIX reference, not my path')
 await click('#mr-appoint')
 assert.match(await page.locator('#mr-appointments').innerText(),/My SIX reference/)
 const folded=await world()
 for(const selector of ['#mr-toggle-gauges','#mr-toggle-inscriptions','#mr-select-retained','#mr-hand--1'])await click(selector)
 assert.equal(await world(),folded);assert.equal(await id(),material)
 for(let i=0;i<2;i++){
  for(const selector of ['#motor-ground','#motor-pending','#motor-end','#motor-return']){
   await page.locator(selector).click()
   await page.waitForFunction(()=>!document.querySelector('#paired-motor').classList.contains('phx-click-loading'))
  }
  if(i===0)await page.locator('#motor-next').click()
 }
 await page.waitForSelector('[id="mr-trial-footing-2:entrance"]')
 assert.equal(await bench.getAttribute('data-index'),'0')
 await snap('04-retained-entrances')
 await page.setViewportSize({width:390,height:844})
 assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth))
 await snap('05-mobile')
 assert.deepEqual(errors,[])
 await writeFile(`${output}/verification.json`,JSON.stringify({views:6,worldIdentity:true,railIdentity:true,blockedFold:true,retainedEntrances:2,acquiredIndex:0,mobileOverflow:false,pageErrors:errors},null,2))
 console.log('PASS: six views, occupied blocked fold, inscriptions, retained entrances, identity and mobile; no page errors.')
} finally {await browser.close()}
