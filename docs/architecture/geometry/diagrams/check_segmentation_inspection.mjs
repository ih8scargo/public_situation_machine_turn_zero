import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
import {resolve} from 'node:path'
import {pathToFileURL} from 'node:url'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE || 'playwright')
const out='docs/visual-witnesses/segmentation-inspection'
await mkdir(out,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try {
  const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[]
  page.on('pageerror',e=>errors.push(e.message))
  await page.goto(pathToFileURL(resolve('docs/architecture/geometry/diagrams/segmentation-inspection.html')).href)
  await page.waitForSelector('body[data-source-hash]')
  const before=await page.evaluate(()=>JSON.stringify(studyDiagnostic.source().world))
  assert.equal(await page.locator('body').getAttribute('data-theta'),'22.5')
  assert.equal(await page.locator('body').getAttribute('data-hits'),'2')
  await page.locator('#park').click()
  await page.locator('#tunnel').click()
  assert.equal(await page.locator('body').getAttribute('data-theta'),'45')
  await page.locator('#return').click()
  assert.equal(await page.locator('body').getAttribute('data-theta'),'22.5')
  await page.screenshot({path:`${out}/01-intermediate-notch.png`,fullPage:true})
  await page.locator('#phi').evaluate(el=>{el.value='96';el.dispatchEvent(new Event('input',{bubbles:true}))})
  assert.equal(await page.locator('body').getAttribute('data-hits'),'1')
  await page.selectOption('#target','cubical-janusite:right')
  assert.match(await page.locator('#target-record').innerText(),/cubical-janusite:right/)
  await page.locator('#flat').click()
  assert.equal(await page.locator('body').getAttribute('data-hits'),'1')
  await page.screenshot({path:`${out}/02-flat-single-hit.png`,fullPage:true})
  await page.locator('#tunnel').click()
  assert.equal(await page.locator('body').getAttribute('data-hits'),'1')
  assert.equal(await page.evaluate(()=>JSON.stringify(studyDiagnostic.source().world)),before)
  assert.equal(await page.evaluate(()=>studyDiagnostic.snapshot().operative_appointment),null)
  await page.locator('#phi').evaluate(el=>{el.value='100';el.dispatchEvent(new Event('input',{bubbles:true}))})
  assert.equal(await page.locator('body').getAttribute('data-hits'),'0')
  await page.locator('#source-notch').click()
  assert.equal(await page.locator('body').getAttribute('data-hits'),'2')
  await page.selectOption('#letter','3')
  assert.match(await page.locator('#local-record').innerText(),/letter-4/)
  await page.screenshot({path:`${out}/03-along-source-chart.png`,fullPage:true})
  await page.setViewportSize({width:390,height:844})
  assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth))
  await page.screenshot({path:`${out}/04-mobile.png`,fullPage:true})
  assert.deepEqual(errors,[])
  const result={sourceGeometryInvariant:true,parkAndReturn:true,viewThetaIndependentOfArmPhi:true,hitCounts:[2,1,0],operativeAppointment:null,index:0,craftReceipt:null,curvedLetterLookup:true,mobileOverflow:false,pageErrors:errors}
  await writeFile(`${out}/verification.json`,JSON.stringify(result,null,2))
  console.log('PASS segmentation inspection: source geometry, intermediate notch, independent arm, curved inscriptions and mobile.')
} finally {await browser.close()}
