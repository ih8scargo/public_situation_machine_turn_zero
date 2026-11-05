import assert from 'node:assert/strict'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const browser=await chromium.launch({headless:true,args:['--no-sandbox'],...(process.env.CHROMIUM_PATH?{executablePath:process.env.CHROMIUM_PATH}:{})})
const page=await browser.newPage({viewport:{width:1440,height:1100}}),errors=[]
page.on('pageerror',e=>errors.push(e.message))
const host=page.locator('#crossing-rehearsal'),model=()=>host.evaluate(el=>JSON.parse(el.dataset.model))
const range=async purchase=>page.locator('#crossing-inscription').evaluate((el,value)=>{el.value=value;el.dispatchEvent(new Event('input',{bubbles:true}));el.dispatchEvent(new Event('change',{bubbles:true}))},purchase)
try{
 await page.goto(process.env.ZEROETH_URL||'http://127.0.0.1:4001/experiments/architecture')
 await page.waitForFunction(()=>document.querySelector('#crossing-rehearsal')?.dataset.ready==='true')
 await page.locator('#inscription-letter-25-course').waitFor()
 for(const id of ['crossing-pull','crossing-feed']){
  await page.locator('#'+id).evaluate(el=>{el.value='1';el.dispatchEvent(new Event('input',{bubbles:true}));el.dispatchEvent(new Event('change',{bubbles:true}))})
  await page.waitForFunction(field=>JSON.parse(document.querySelector('#crossing-rehearsal').dataset.model)[field]===1,id==='crossing-pull'?'pull':'feed')
 }
 await page.locator('#crossing-lock').click()
 await page.waitForFunction(()=>!!JSON.parse(document.querySelector('#crossing-rehearsal').dataset.model).registration)
 await page.locator('#crossing-receive').click()
 await page.waitForFunction(()=>document.querySelector('#crossing-rehearsal').dataset.received==='true')
 const before=await model()
 assert.ok(before.stick.curve.samples.length>0)
 assert.equal(before.inscription_resolution.letters.length,25)
 const world=()=>page.locator('#inscription-letter-10-face-1').getAttribute('data-world-points')
 const face=await world()
 for(const purchase of [0,3,9,18,18.5,25,0]){
  await range(purchase)
  assert.equal(await host.getAttribute('data-inscription-purchase'),String(purchase))
  if(purchase===18)assert.match(await page.locator('#crossing-inscription-status').textContent(),/SITUATION.*N.*twist/)
  if(purchase===25)assert.match(await page.locator('#crossing-inscription-status').textContent(),/MACHINE.*XT toward XT/)
  assert.deepEqual(await model(),before)
 }
 for(const regard of ['cab','alongside','inspection']){
  await page.locator('#crossing-'+regard).click()
  assert.equal(await world(),face)
  assert.deepEqual(await model(),before)
 }
 await page.reload();await page.locator('#inscription-letter-25-course').waitFor()
 assert.deepEqual(await model(),before)
 await page.setViewportSize({width:390,height:844})
 assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth))
 assert.equal(await page.locator('path[d*="NaN"],path[d*="Infinity"]').count(),0)
 assert.deepEqual(errors,[])
 console.log('Inscription course, N purchase, MACHINE return, unchanged receipt/Standing, located Regards, reload and mobile checks passed.')
}finally{await browser.close()}
