import assert from 'node:assert/strict'
import {mkdir} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE || 'playwright')
const output=process.env.WITNESS_DIR || '/tmp/string-ribbon-witnesses'
await mkdir(output,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try {
 const page=await browser.newPage({viewport:{width:1365,height:1000}})
 const errors=[];page.on('pageerror',e=>errors.push(e.message))
 await page.goto('http://127.0.0.1:4001/workshop/string-ribbon');await page.waitForSelector('.phx-connected')
 const world=async id=>page.locator('#sr-object-0-'+id).getAttribute('data-world')
 const initialHere=await world('here'), monitor=await world('monitor'), table=await world('table')
 const checkSquares=async()=>{for(const id of ['sr-square-0','sr-square-1']){const r=await page.locator('#'+id).boundingBox();assert.ok(Math.abs(r.width-r.height)<1)}assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth))}
 const screenshot=async name=>page.screenshot({path:`${output}/${name}.png`,fullPage:true})
 const inspect=async(v,c)=>{
  if(await page.locator('#inspection_view').inputValue()!==v)await page.selectOption('#inspection_view',v);await page.waitForSelector(`#string-ribbon-workshop[data-view=${v}]`)
  if(await page.locator('#inspection_course').inputValue()!==c)await page.selectOption('#inspection_course',c);await page.waitForSelector(`#string-ribbon-workshop[data-course=${c}]`)
 }
 await checkSquares();assert.equal(await page.locator('#sr-office-0').getAttribute('data-cob'),await page.locator('#sr-office-1').getAttribute('data-cob'));assert.equal(await page.locator('#sr-take').isDisabled(),true)
 await screenshot('01-from-here')
 await page.locator('#sr-register').click();await page.waitForSelector('#sr-furnish-form')
 await page.fill('#sr-marking','ONE STRING FROM HERE')
 await page.locator('#sr-furnish').click();await page.waitForSelector('#sr-object-0-material')
 const material=await page.locator('#string-ribbon-workshop').getAttribute('data-material')
 const path=await world('material')
 assert.equal(await page.locator('#sr-object-1-material').count(),0)
 await page.locator('#sr-take').focus();await page.locator('#sr-take').press('Enter')
 await page.waitForSelector('#sr-object-1-material')
 assert.equal(await page.locator('#sr-object-1-material').getAttribute('data-material'),material)
 assert.equal(await page.locator('#sr-object-1-material').getAttribute('data-world'),path)
 await screenshot('02-provided-and-taken')
 for(const v of ['tunneling','top','roundabout','flat']){
  await inspect(v,'ribbon')
  assert.equal(await world('material'),path)
  assert.equal(await page.locator('#sr-object-1-material').getAttribute('data-world'),path)
  assert.equal(await world('here'),initialHere);assert.equal(await world('monitor'),monitor);assert.equal(await world('table'),table)
  assert.equal(await page.locator('#sr-material-ledger').getAttribute('data-footings'),'0')
  assert.equal(await page.locator('#sr-error').count(),0)
  await screenshot('03-'+v)
 }
 for(const c of ['square-lock','rising','pocketing','triangles']){
  await inspect('roundabout',c)
  const id=c==='triangles'?'xt-triangle':c
  await page.locator('#sr-inscription-'+id).click()
  assert.equal(await world('here'),initialHere)
  const before=await world(id)
  await page.locator('#sr-progress').fill('50')
  await page.waitForSelector('#string-ribbon-workshop[data-progress="0.5"]')
  assert.equal(await world(id),before)
  await page.locator('#sr-progress').fill('100');await page.waitForSelector('#string-ribbon-workshop[data-progress="1.0"]')
  if(c==='triangles'){await page.locator('#sr-fold').fill('100');await page.waitForSelector('#string-ribbon-workshop[data-fold="1.0"]')}
  await screenshot('04-'+c)
 }
 await page.locator('#sr-advance').click();await page.waitForFunction(()=>document.querySelector('#sr-taken').textContent.includes('1/2'))
 await page.locator('#sr-advance').click();await page.waitForSelector('#sr-advance[disabled]')
 assert.equal(await page.locator('#sr-material-ledger').getAttribute('data-footings'),'0')
 await page.selectOption('#bugs_count','3');await page.waitForFunction(()=>document.querySelector('#bugs_count').value==='3')
 await inspect('flat','ribbon')
 assert.equal(await world('material'),path)
 await page.setViewportSize({width:390,height:844});await page.emulateMedia({reducedMotion:'reduce'})
 await checkSquares();await screenshot('05-mobile')
 assert.equal(await page.locator('#sr-error').count(),0)
 await page.locator('#sr-coming-aboard').click();await page.waitForSelector('#ca-common-machine')
 assert.equal(await page.locator('#ca-common-machine').getAttribute('data-open'),'false')
 assert.deepEqual(errors,[])
 console.log('String-Ribbon Chromium passed: exact same source/path in both offices, reversible four views, prefix/fold candidates, no acquisition, desktop/mobile and legacy link. '+output)
}finally{await browser.close()}
