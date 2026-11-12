import assert from 'node:assert/strict'
import {readFile,mkdir} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const output=process.env.WITNESS_DIR||'/tmp/gobs-common-material-witnesses'
await mkdir(output,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try{
 const page=await browser.newPage({viewport:{width:1440,height:1100},extraHTTPHeaders:{'Accept-Encoding':'identity'}})
 page.setDefaultTimeout(12000)
 const errors=[]
 page.on('pageerror',error=>errors.push(error.message))
 await page.goto(process.env.WEDGING_URL||'http://127.0.0.1:4015/workshop/wedging-geometry')
 await page.waitForSelector('.phx-connected')
 const root=page.locator('#cm-renderer')
 await page.waitForSelector('#cm-tunneling-scene[data-view="tunneling"]')
 assert.equal(await page.locator('#common-material [data-material]:not([data-material=""])').count(),0)
 await page.locator('#common-material').screenshot({path:output+'/01-empty.png'})
 const raw=await readFile(new URL('../../docs/visual-witnesses/snail-weave/two-woven-turns.json',import.meta.url),'utf8')
 await page.locator('#sw-restore > summary').click()
 // Load the large existing replay artifact as one paste; the actual form submit remains exercised.
 await page.locator('#sw-restore-form textarea').evaluate((input,value)=>{input.value=value;input.dispatchEvent(new Event('input',{bubbles:true}))},raw)
 await page.locator('#sw-import').click()
 await page.waitForFunction(()=>JSON.parse(document.querySelector('#cm-renderer').dataset.model).source!==null,null,{timeout:12000})
 const before=await root.getAttribute('data-model')
 const registration=JSON.parse(before)
 const exportState=async()=>{
  const download=page.waitForEvent('download')
  await page.locator('#sw-export').click()
  const file=await download
  return readFile(await file.path(),'utf8')
 }
 const sourceBefore=await exportState()
 for(const mode of ['flat','tunneling','both']){
  await page.locator('#cm-'+mode).click()
  assert.equal(await root.getAttribute('data-mode'),mode)
  assert.equal(await page.locator('#cm-'+mode).getAttribute('aria-pressed'),'true')
  assert.equal(await root.getAttribute('data-model'),before)
 }
 assert.equal(await exportState(),sourceBefore)
 const canonical=JSON.parse(sourceBefore).state
 assert.equal(canonical.footings.length,2)
 const points=async id=>page.locator(id+' [data-material][data-world]').evaluateAll(nodes=>nodes.map(n=>[n.dataset.material,n.dataset.sourceIndex,n.dataset.world]))
 assert.deepEqual(await points('#cm-flat-scene'),await points('#cm-tunneling-scene'))
 assert.ok((await points('#cm-flat-scene')).every(([id])=>id===registration.source.material.id))
 await page.locator('#common-material').screenshot({path:output+'/02-paired.png'})
 await page.locator('#cm-ledger summary').click()
 await page.locator('#cm-ledger').screenshot({path:output+'/03-ledger.png'})
 await page.locator('#cm-ledger summary').click()
 await page.setViewportSize({width:390,height:844})
 await page.locator('#common-material').scrollIntoViewIfNeeded()
 assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true)
 await page.locator('#cm-flat').focus()
 await page.keyboard.press('Enter')
 assert.equal(await page.locator('#cm-tunneling-card').isVisible(),false)
 await page.locator('#cm-both').click()
 await page.locator('#common-material').screenshot({path:output+'/04-mobile.png'})
 assert.equal(await exportState(),sourceBefore)
 assert.deepEqual(errors,[])
 console.log('PASS: empty state, one source, paired coordinates, view switching, identical canonical export, fixed HERE/NEXT/Footings, keyboard, mobile, no page errors')
}finally{await browser.close()}
