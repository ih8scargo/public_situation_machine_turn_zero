import assert from 'node:assert/strict'
import {mkdir,readFile,writeFile} from 'node:fs/promises'
import {createHash} from 'node:crypto'
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'/tmp/rail-recovery-witnesses'
await mkdir(out,{recursive:true})
const protectedPaths=['lib/public_situation_machine_turn_zero/architecture/inscription_resolution.ex','lib/public_situation_machine_turn_zero/workshop/steeling.ex','lib/public_situation_machine_turn_zero/workshop/snail_body.ex','docs/visual-witnesses/snail-weave/two-woven-turns.json']
const hashes=async()=>Object.fromEntries(await Promise.all(protectedPaths.map(async p=>[p,createHash('sha256').update(await readFile(p)).digest('hex')])));
const before=await hashes()
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROMIUM_PATH||undefined,args:['--no-sandbox']})
const page=await browser.newPage({viewport:{width:1500,height:1100}})
const errors=[];page.on('pageerror',e=>errors.push(e.message))
try {
  await page.goto(process.env.RECOVERY_URL||'http://127.0.0.1:4007/workshop/rail-recovery')
  await page.waitForSelector('.phx-connected')
  assert.equal(await page.locator('#rr-letters tbody tr').count(),25)
  const letters=await page.locator('#rr-letters').textContent()
  const collisions=await page.locator('#rr-collisions').textContent()
  for(const hand of ['1','-1']) {
    await page.selectOption('#inspection_hand',hand)
    for(const stand of ['N-M-before','N-M-within','N-M-after']) {
      await page.selectOption('#inspection_stand',stand)
      await page.waitForFunction(s=>document.querySelector('#rr-located').parentElement.querySelector('h2').textContent.includes(s),stand)
      await page.waitForFunction(h=>Math.sign(Number(document.querySelector('[id="rr-roll-18.5"]').dataset.roll))===Number(h),hand)
      assert.equal(await page.locator('#rr-letters').textContent(),letters)
      assert.equal(await page.locator('#rr-collisions').textContent(),collisions)
      assert.equal(await page.locator('#rr-standing').getAttribute('data-index'),'unchanged')
      await page.locator('.rr-views').screenshot({path:`${out}/${hand==='1'?'positive':'negative'}-${stand}.png`})
    }
  }
  for(const stand of ['table-plan','table-section','axle','TC','corner','cubical','deformation','pointer']) {
    await page.selectOption('#inspection_stand',stand)
    await page.waitForFunction(s=>document.querySelector('#rr-located').parentElement.querySelector('h2').textContent.includes(s),stand)
    await page.locator('.rr-views').screenshot({path:`${out}/${stand}.png`})
  }
  await page.locator('#rr-located g[tabindex="0"]').first().focus()
  assert.equal(await page.locator('#rr-located g[tabindex="0"]').first().evaluate(e=>e===document.activeElement),true)
  await page.setViewportSize({width:390,height:844})
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true)
  await page.locator('.rr-views').screenshot({path:out+'/mobile.png'})
  assert.deepEqual(await hashes(),before)
  assert.deepEqual(errors,[])
  await writeFile(out+'/invariance.json',JSON.stringify({protectedFiles:before,letters:25,sourceUnchanged:true,acquisitionArtifactUnchanged:true,errors},null,2))
  console.log('Rail recovery browser passed: both handedness candidates, before/within/after and apparatus stands; keyboard focus, mobile, retained source and acquisition hashes.')
} finally {await browser.close()}
