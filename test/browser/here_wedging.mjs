import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE || 'playwright')
const output='docs/visual-witnesses/here-wedging';await mkdir(output,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try{
 const page=await browser.newPage({viewport:{width:1440,height:1050}});const errors=[];page.on('pageerror',e=>errors.push(e.message))
 await page.goto('http://127.0.0.1:4001/workshop/string-ribbon');await page.waitForSelector('.phx-connected')
 const root=page.locator('#geometry-exploration'),study=page.locator('#here-wedging-study')
 const click=async id=>{const r=Number(await root.getAttribute('data-revision'));await page.locator(id).click();await page.waitForFunction(n=>Number(document.querySelector('#geometry-exploration').dataset.revision)>n,r)}
 const source=await page.locator('#hw-snail').getAttribute('data-world'),unit=await page.locator('#hw-unit').getAttribute('data-world')
 assert.match(await page.locator('#hw-snail-fit').innerText(),/false/)
 await study.screenshot({path:`${output}/01-integrated-left.png`})
 const svg=await page.locator('#hw-integrated').evaluate(el=>{el.setAttribute('data-geometry-contract','geometry-table-2026-11-13.v4');return new XMLSerializer().serializeToString(el)})
 await writeFile('docs/architecture/geometry/diagrams/M.svg',svg)
 await click('#hw-side-right');assert.equal(await page.locator('#hw-snail').getAttribute('data-world'),source);assert.equal(await page.locator('#hw-unit').getAttribute('data-world'),unit)
 await study.screenshot({path:`${output}/02-right-regarding.png`})
 await click('#hw-trial-returns');assert.match(await page.locator('#hw-status').innerText(),/BLOCKED/)
 await page.locator('#hw-source-ledger summary').click()
 await study.screenshot({path:`${output}/03-return-sources-blocked.png`})
 await page.locator('#hw-source-ledger summary').click();await click('#hw-trial-simple')
 await page.setViewportSize({width:390,height:844});assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth))
 await study.screenshot({path:`${output}/04-mobile.png`});assert.equal(await root.getAttribute('data-index'),'0');assert.deepEqual(errors,[])
 await writeFile(`${output}/verification.json`,JSON.stringify({geometryContract:'geometry-table-2026-11-13.v4',sameUnitAndSnailAcrossSides:true,returnTrial:'blocked',sourceScalePreserved:true,sixHeightFit:false,acquiredIndex:0,pageErrors:errors,mobileOverflow:false},null,2))
 console.log('PASS HERE wedge: integrated source, mirrored identity, explicit return/fit blockers and mobile.')
}finally{await browser.close()}
