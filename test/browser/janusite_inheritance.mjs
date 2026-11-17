import assert from 'node:assert/strict'
import {mkdir,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE || 'playwright');const out='docs/visual-witnesses/janusite-inheritance';await mkdir(out,{recursive:true})
const b=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try{const p=await b.newPage({viewport:{width:1440,height:1050}}),errors=[];p.on('pageerror',e=>errors.push(e.message));await p.goto('http://127.0.0.1:4001/workshop/string-ribbon');await p.waitForSelector('.phx-connected')
const root=p.locator('#geometry-exploration'),panel=p.locator('#janusite-inheritance');const click=async id=>{const r=await root.getAttribute('data-revision');await p.locator(id).click();await p.waitForFunction(v=>document.querySelector('#geometry-exploration').dataset.revision!==v,r)}
const world=await p.locator('#ji-source-world').getAttribute('data-world'),id=await panel.getAttribute('data-source');await panel.screenshot({path:`${out}/01-road-room.png`})
for(const view of ['longhouse','tunneling','flat']){await click('#ji-view-'+view);assert.equal(await p.locator('#ji-source-world').getAttribute('data-world'),world);assert.equal(await panel.getAttribute('data-source'),id);if(view==='longhouse')await panel.screenshot({path:`${out}/05-curved-detail.png`})}
await click('#ji-mode-B');await click('#ji-view-longhouse');await p.waitForSelector('#janusite-inheritance[data-mode="B"][data-view="longhouse"]');await panel.screenshot({path:`${out}/02-shared-source.png`})
await click('#ji-mode-C');await click('#ji-footing-two');assert.match(await p.locator('#ji-origin').innerText(),/nil/);await click('#ji-toggle-fixture');assert.match(await p.locator('#ji-origin').innerText(),/hypothetical/);await p.waitForSelector('#janusite-inheritance[data-mode="C"][data-view="longhouse"]');await panel.screenshot({path:`${out}/03-two-cursor-no-length.png`})
assert.equal(await root.getAttribute('data-index'),'0');assert.equal(await p.locator('#here-wedging-study').count(),1)
await p.setViewportSize({width:390,height:844});assert.ok(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));await panel.screenshot({path:`${out}/04-mobile.png`});assert.deepEqual(errors,[])
await writeFile(`${out}/verification.json`,JSON.stringify({sameSource:true,views:3,twoOrigin:'hypothetical-only',nextMaterial:[],index:0,pageErrors:errors,mobileOverflow:false},null,2));console.log('PASS JANUSITE A/B/C source identity, TWO cursor restraint and mobile.')
}finally{await b.close()}
