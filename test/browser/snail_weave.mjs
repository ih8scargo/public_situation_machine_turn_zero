import assert from 'node:assert/strict'
import {mkdir,readFile,writeFile} from 'node:fs/promises'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'/tmp/snail-weave-witnesses';await mkdir(out,{recursive:true})
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH||undefined,args:['--no-sandbox']})
const page=await browser.newPage({viewport:{width:1500,height:1100}}),errors=[]
page.on('pageerror',e=>errors.push(e.message))
const model=()=>page.locator('#sw-renderer').evaluate(e=>JSON.parse(e.dataset.model))
const download=async()=>{const pending=page.waitForEvent('download');await page.locator('#sw-export').click();return JSON.parse(await readFile(await(await pending).path(),'utf8'))}
const view=async v=>{await page.locator(v==='external'?'#sw-alongside':'#sw-view-'+v).click();await page.waitForSelector('#sw-scene[data-view="'+v+'"]',{state:'attached'})}
const shot=async name=>page.locator('#sw-renderer').screenshot({path:out+'/'+name})
const take=async(mode)=>{await page.selectOption('#weave_take_mode',mode);await page.locator('#weave_take_human').fill(mode==='actual'?'This One Visiting Constitutioning Human':'This One Authoring Constitutioning Human');await page.locator('#sw-take').click();await page.waitForSelector('#sw-transverse[data-held="true"]')}
const finish=async()=>{for(let i=1;i<=2;i++){await page.locator('#sw-advance').click();await page.waitForFunction(i=>JSON.parse(document.querySelector('#sw-renderer').dataset.model).crossing.second.position===i,i)}await page.locator('#sw-complete').click();await page.waitForSelector('#sw-transverse[data-held="false"]')}
try{
 await page.goto(process.env.WEDGING_URL||'http://127.0.0.1:4007/workshop/wedging-geometry');await page.waitForSelector('.phx-connected');await page.locator('#sw-alongside').click();await page.waitForSelector('#sw-scene[data-view="external"]')
 const fresh=await download();assert.equal(fresh.state.yt,false);assert.equal(fresh.state.opening.events.length,0)
 for(const v of ['ceiling','plan','within','flat','external']){await view(v);assert.deepEqual(await download(),fresh)}
 await page.locator('#sw-pull').click();await page.waitForFunction(()=>!document.querySelector('#sw-puff').disabled);await page.locator('#sw-puff').click();await page.waitForFunction(()=>!document.querySelector('#sw-brace').disabled)
 await page.locator('#sw-brace').focus();await page.keyboard.press('Enter');await page.waitForFunction(()=>!document.querySelector('#sw-quill').disabled)
 assert.equal((await download()).state.yt,false)
 await page.locator('#weave_quill_text').fill('ONE material carried through this furnished turn.');await page.locator('#sw-quill').click();await page.waitForSelector('#sw-yt-standing[data-available="true"]')
 await page.locator('#sw-seat').click();for(const id of ['xt','yt']){await page.locator('#sw-appoint-'+id).click();await page.waitForFunction(id=>document.querySelector('#sw-appoint-'+id).disabled,id)}
 const registered=await model();assert.deepEqual(registered.sight_tests.upward_to_ceiling,[]);assert.deepEqual(registered.sight_tests.toward_receiver,[])
 await view('ceiling');await shot('01-zeroeth-ceiling-crossing.png');await view('section');await shot('02-integrated-section.png');await view('plan');await shot('03-front-run-conflict.png')
 await page.locator('#sw-point').click();await view('external');await shot('04-seated-pointing.png')
 const preserved=[]
 for(let i=1;i<=2;i++){
  await page.locator('#sw-provide').click();await page.waitForSelector('#sw-current-turn[data-status="furnishing"]');await page.locator('#sw-register').click();await page.waitForSelector('#sw-current-turn[data-status="emplacing"]')
  const placing=await download(),ids=(await model()).tags.map(t=>t.id);assert.equal(new Set(ids).size,1)
  await page.locator('#sw-across').click();assert.deepEqual(await download(),placing)
  await page.locator('#sw-inspection > summary').click();await page.locator('#weave_inspect_quarter').selectOption(String(i-1));await page.locator('#weave_inspect_pose').fill('45');await page.waitForFunction(()=>document.querySelector('#sw-message').textContent.includes('actively emplacing'))
  assert.deepEqual(await download(),placing)
  await page.locator('#weave_inspect_look').fill('35');await page.waitForFunction(()=>document.querySelector('#weave_inspect_look').value==='35');assert.deepEqual(await download(),placing)
  await page.locator('#sw-inspection > summary').click()
  await page.locator('#sw-settle').click();await page.waitForSelector('#sw-current-turn[data-status="provided"]')
  const standing=await download(),tags=(await model()).tags
  for(const v of ['flat','external','section','within']){await view(v);assert.deepEqual(await download(),standing);assert.deepEqual((await model()).tags,tags);await shot(`05-turn-${i}-${v}.png`)}
  await page.locator('#sw-across').click();await page.waitForFunction(()=>JSON.parse(document.querySelector('#sw-renderer').dataset.model).interface.mode==='across');assert.deepEqual(await download(),standing);await shot(`06-turn-${i}-over-across.png`)
  await page.locator('#sw-alongside').click();await page.waitForFunction(()=>JSON.parse(document.querySelector('#sw-renderer').dataset.model).interface.mode==='alongside');assert.deepEqual(await download(),standing)
  // An attempted alternate course is rejected by the LiveView/domain boundary.
  await page.locator('#weave_take_passage').evaluate(e=>e.value='unfurnished-alternate');await page.locator('#sw-take').click();await page.waitForFunction(()=>document.querySelector('#sw-message').textContent.includes('unfurnished_alternate'));assert.deepEqual(await download(),standing)
  await page.locator('#weave_take_passage').evaluate(e=>e.value='continuous-spooning-scooping')
  if(i===1){await take('rehearsal');await finish();assert.equal((await download()).state.footings.length,0)}
  await take('actual');await view('ceiling');await shot(`07-turn-${i}-TC-holds-UP.png`);await finish();await page.waitForSelector('#sw-acquisitions[data-count="'+i+'"]')
  const done=await download();assert.equal(done.state.footings.length,i);if(i===2)assert.deepEqual(done.state.footings[0],preserved[0]);preserved.push(done.state.footings.at(-1));await page.locator('#sw-latest-footing').screenshot({path:out+`/09-turn-${i}-own-footing.png`})
  assert.ok(await page.locator('#sw-complete').isDisabled())
 }
 const saved=await download();await writeFile(out+'/two-woven-turns.json',JSON.stringify(saved,null,2));assert.equal(saved.state.turns.length,2);assert.equal(saved.state.body.material.length,1)
 await page.locator('#sw-restore > summary').click();await page.locator('#weave_witness_json').fill(JSON.stringify(saved));await page.locator('#sw-import').click();await page.waitForFunction(()=>document.querySelector('#sw-message').textContent.includes('replayed'));assert.deepEqual(await download(),saved)
 await page.setViewportSize({width:390,height:844});await page.waitForFunction(()=>document.documentElement.scrollWidth<=innerWidth);await view('plan');await shot('08-mobile-common-apparatus.png')
 assert.deepEqual(errors,[])
 console.log('Integrated Snail House browser passed A–F: labor-earned YT/brace, real opening, Seat/ceiling rays, projection conflict, one material across four Regardings, narrow placement lock, ALONGSIDE/OVER ACROSS invariance, alternate rejection, rehearsal/no Footing, two appointed actual completions, UP holding, pointing, replay and mobile.')
}catch(e){console.error(errors);await page.screenshot({path:out+'/failure.png',fullPage:true});throw e}finally{await browser.close()}
