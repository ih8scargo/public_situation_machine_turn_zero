import assert from 'node:assert/strict'
import {mkdir} from 'node:fs/promises'

const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright')
const out=process.env.WITNESS_DIR||'/tmp/regarding-wheel-witnesses'
await mkdir(out,{recursive:true})
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH,args:['--no-sandbox']})
try {
  const page=await browser.newPage({viewport:{width:1440,height:1000}})
  const errors=[]
  page.on('pageerror',error=>errors.push(error.message))
  const url=process.env.WEDGING_URL||'http://127.0.0.1:4007/workshop/wedging-geometry'
  await page.goto(url)
  await page.waitForSelector('.phx-connected')
  const wheel=page.locator('#sw-wheel')
  const scene=page.locator('#sw-scene')
  const renderer=page.locator('#sw-renderer')
  const camera=async()=>JSON.parse(await scene.getAttribute('data-camera'))
  const model=()=>renderer.getAttribute('data-model')
  const standing=await model()
  const waitBearing=async(view,angle)=>{
    await page.waitForFunction(({view,angle})=>
      document.querySelector(`#sw-scene[data-view="${view}"][data-inspection="active"] text:last-child`)?.textContent.includes('AROUND ABOUT '+angle+'°'),{view,angle})
    assert.equal(await wheel.getAttribute('aria-valuenow'),String(angle))
  }
  const registeredObjects=()=>scene.locator('[data-body-object][data-world]').evaluateAll(nodes=>
    [...new Set(nodes.map(node=>node.dataset.bodyObject+' '+node.dataset.world))].sort())
  const selectView=async view=>{
    if(view==='external')await selectView('section')
    await page.locator(view==='external'?'#sw-alongside':'#sw-view-'+view).click()
    await page.waitForSelector(`#sw-scene[data-view="${view}"]:not([data-inspection])`,{state:'attached'})
  }
  assert.ok(await wheel.isVisible())
  await selectView('section')
  const origin=await camera(),sectionObjects=await registeredObjects()
  await renderer.screenshot({path:out+'/01-section-registered.png'})
  await wheel.scrollIntoViewIfNeeded()
  const rim=await wheel.boundingBox()
  const x=rim.x+rim.width/2,y=rim.y+rim.height/2,r=rim.width*.36
  await page.mouse.move(x,y-r)
  await page.mouse.down()
  await page.mouse.move(x+r,y,{steps:6})
  await page.mouse.up()
  await waitBearing('section',90)
  assert.notDeepEqual(await camera(),origin)
  assert.deepEqual(await registeredObjects(),sectionObjects)
  await renderer.screenshot({path:out+'/02-section-around-about.png'})
  await wheel.press('End')
  await waitBearing('section',359)
  await wheel.press('ArrowRight')
  await waitBearing('section',4)

  await page.selectOption('#sw-stand','seat')
  await waitBearing('section',0)
  const middle=await camera()
  await page.locator('#sw-closer').click()
  await page.waitForFunction(()=>document.querySelector('#sw-bearing').textContent.includes('Close'))
  const close=await camera()
  assert.notDeepEqual(close.eye,middle.eye)
  assert.ok(await scene.locator('[data-body-object="Seat-fixed-HERE-datum"]').count())
  assert.ok(await scene.locator('[data-stand-point="seat"]').count())
  await page.locator('#sw-up').click()
  await page.waitForFunction(()=>document.querySelector('#sw-bearing').textContent.includes('vertical 15°'))
  assert.notDeepEqual((await camera()).eye,close.eye)
  await wheel.press('Shift+ArrowRight')
  await waitBearing('section',45)
  await renderer.screenshot({path:out+'/03-seat-close-up.png'})
  await page.locator('#sw-down').click()
  await page.locator('#sw-farther').click()
  await page.waitForFunction(()=>document.querySelector('#sw-bearing').textContent.includes('vertical 0° · Middle'))
  await page.locator('#sw-wheel-reset').click()
  assert.deepEqual(await camera(),origin)
  assert.equal(await wheel.getAttribute('aria-valuenow'),'0')
  assert.equal(await page.locator('#sw-stand').inputValue(),'')
  assert.equal(await model(),standing)

  for(const view of ['flat','section','plan','within','ceiling','contraption','volume','groundward','external']){
    await selectView(view)
    const before=await camera(),source=await model()
    await wheel.press('Shift+ArrowRight')
    await waitBearing(view,45)
    assert.notDeepEqual(await camera(),before,view)
    assert.equal(await model(),source,view)
    if(view==='flat')assert.ok(await scene.locator('[data-body-object="ordinary-monitor-center-line"]').count())
    if(['within','volume','ceiling','groundward'].includes(view))assert.ok((await camera()).eye.every((n,i)=>Math.abs(n-before.eye[i])<1e-10),view)
    await page.locator('#sw-wheel-return').click()
    assert.deepEqual(await camera(),before,view)
  }
  await selectView('contraption')
  for(const id of ['seat','eye','aperture','table','pittoning','arch-first','arch-second','mouth-far','mouth-near','monitor']){
    await page.selectOption('#sw-stand',id)
    await waitBearing('contraption',0)
    await scene.locator(`[data-stand-point="${id}"]`).waitFor({state:'attached'})
    assert.ok((await camera()).eye.every(Number.isFinite),id)
  }
  await page.selectOption('#sw-stand','mouth-near')
  await scene.locator('[data-stand-point="mouth-near"]').waitFor({state:'attached'})
  await renderer.screenshot({path:out+'/04-near-mouth.png'})

  await page.locator('#sw-view-within').click()
  await page.waitForSelector('#sw-scene[data-view="within"]')
  const seated=await camera()
  await page.locator('#emergence_quarter_turn').fill('90')
  await page.waitForSelector('#sw-regarding-correspondence[data-angle="90"]',{state:'attached'})
  const tunneling=await camera()
  assert.deepEqual(tunneling.eye,seated.eye)
  assert.ok(tunneling.forward[1]<-.99)
  const before=JSON.parse(standing), after=JSON.parse(await model())
  for(const key of ['fixed','lines','surfaces','landinging_registration']){
    assert.deepEqual(after[key],before[key],key)
  }
  assert.deepEqual(after.emergence.registration,before.emergence.registration)
  await renderer.screenshot({path:out+'/05-seated-tunneling.png'})
  const ground=after.near_monitor.groundward_check
  assert.equal(ground.aperture_to_seat_degrees,45)
  assert.ok(ground.aperture_to_eye_degrees>60)
  assert.equal(ground.monitor_45_within_center_line,false)
  await page.locator('#sw-view-groundward').click()
  await page.waitForSelector('#sw-scene[data-view="groundward"]')
  await page.locator('#sw-groundward-check > summary').click()
  await page.locator('#sw-groundward-check').screenshot({path:out+'/06-groundward-check.png'})
  assert.deepEqual(errors,[])

  const mobile=await browser.newPage({viewport:{width:390,height:844},isMobile:true,hasTouch:true})
  await mobile.goto(url)
  await mobile.waitForSelector('.phx-connected')
  await mobile.waitForSelector('#sw-scene[data-view="flat"]',{state:'attached'})
  const touchWheel=mobile.locator('#sw-wheel')
  await touchWheel.scrollIntoViewIfNeeded()
  const box=await touchWheel.boundingBox()
  const cx=box.x+box.width/2,cy=box.y+box.height/2,reach=box.width*.36
  const cdp=await mobile.context().newCDPSession(mobile)
  await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:cx,y:cy-reach}]})
  await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x:cx-reach,y:cy}]})
  await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]})
  await mobile.waitForSelector('#sw-scene[data-view="flat"][data-inspection="active"]')
  const touched=Number(await touchWheel.getAttribute("aria-valuenow"))
  assert.ok(Math.abs(touched-270)<=2,'touch bearing: '+touched)
  assert.ok(await mobile.evaluate(()=>document.documentElement.scrollWidth<=innerWidth))
  await mobile.locator('#sw-renderer').screenshot({path:out+'/07-wheel-touch.png'})
  console.log('Regarding browser passed: all nine views, SECTION geometry, ten stands, Seat approach, vertical bearing, reset, seated sweep, Groundward source, mouse, keyboard and touch.')
} finally {
  await browser.close()
}
