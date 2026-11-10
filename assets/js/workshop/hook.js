import {regardingPresentation} from './regarding.js'
import {render} from './renderer.js'
export const WorkshopRenderer = {
  mounted() {
    this.svg=this.el.querySelector('#gw-scene')
    const viewport = this.el.querySelector('#gw-regarding-viewport')
    const center = () => [
      (viewport.scrollWidth - viewport.clientWidth) / 2,
      (viewport.scrollHeight - viewport.clientHeight) / 2,
    ]
    this.zoomStep = 0
    const levels = [1, 1.5, 2, 3]
    const bring = this.el.querySelector('#gw-bring-regarding')
    const reset = this.el.querySelector('#gw-reset-regarding')
    const output = this.el.querySelector('#gw-magnification')
    const changeZoom = step => {
      this.zoomStep = step
      bring.disabled = step === levels.length - 1
      reset.disabled = step === 0
      output.value = `${levels[step]}×`
      this.draw(true)
    }
    bring.addEventListener('click', () => changeZoom(this.zoomStep + 1))
    reset.addEventListener('click', () => changeZoom(0))
    const axes = this.el.querySelector('#gw-axis-witness')
    const presentation = regardingPresentation(this.el, viewport, (...args) => this.draw(...args))
    let width = viewport.clientWidth
    this.draw = (recenter = false) => {
      const [oldX, oldY] = center()
      const offsetX = recenter ? 0 : viewport.scrollLeft - oldX
      const offsetY = recenter ? 0 : viewport.scrollTop - oldY
      const model = JSON.parse(this.el.dataset.model)
      const regarding = presentation(model)
      if (viewport.hidden) return
      width = viewport.clientWidth
      render(this.svg,model,this.el.dataset.regard,this.el.dataset.selected,Number(this.el.dataset.yaw||0),Number(this.el.dataset.letter||13),this.el.dataset.bearing||'both',Number(this.el.dataset.footing||1),JSON.parse(this.el.dataset.calibration||'null'),this.el.dataset.plane||'u-aperture',JSON.parse(this.el.dataset.instrument||'null'),levels[this.zoomStep],regarding,axes?.open,JSON.parse(this.el.dataset.groundsideDiorama||'null'))
      const [x, y] = center()
      viewport.scrollTo(this.zoomStep ? x + offsetX : 0, this.zoomStep ? y + offsetY : 0)
    }
    this.select=e=>{const plane=e.target.closest('[data-plane-select]')?.dataset.planeSelect;if(plane){this.pushEvent('select-plane',{id:plane});return}const footing=e.target.closest('[data-footing-select]')?.dataset.footingSelect;if(footing){this.pushEvent('select-footing',{sequence:footing});return}const candidate=e.target.closest('[data-bearing-select]')?.dataset.bearingSelect;if(candidate){this.pushEvent('bearing',{mode:candidate});return}const station=e.target.closest('[data-letter-select]')?.dataset.letterSelect;if(station){this.pushEvent('select-letter',{index:station});return}const id=e.target.closest('[data-entity]')?.dataset.entity;if(id) this.pushEvent('select',{id})}
    this.key=e=>{if(['Enter',' '].includes(e.key)&&e.target.matches('[role="button"]')){e.preventDefault();this.select(e)}}
    this.el.addEventListener('click',this.select)
    this.el.addEventListener('keydown',this.key)
    this.exportRef=this.handleEvent('workshop-export',({json,filename,revision})=>{
      let url, anchor
      try {
        url=URL.createObjectURL(new Blob([json],{type:'application/json'}))
        anchor=this.el.ownerDocument.createElement('a');anchor.href=url;anchor.download=filename
        this.el.append(anchor);anchor.click()
        this.pushEvent('export-complete',{revision})
      } catch(_) {this.pushEvent('export-failed',{})}
      finally {anchor?.remove();if(url) URL.revokeObjectURL(url)}
    })
    if (axes) axes.ontoggle = () => this.draw()
    this.draw()
    this.resizeObserver = new this.el.ownerDocument.defaultView.ResizeObserver(() => {
      if (viewport.hidden || viewport.clientWidth === width) return
      width = viewport.clientWidth
      viewport.scrollTo(...center())
    })
    this.resizeObserver.observe(this.el)
  },
  updated(){this.draw()},
  destroyed(){this.resizeObserver.disconnect();this.el.removeEventListener('click',this.select);this.el.removeEventListener('keydown',this.key);this.removeHandleEvent(this.exportRef)}
}
