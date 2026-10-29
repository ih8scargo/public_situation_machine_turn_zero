// Compression is temporary computering. Only the saved domain result embodies COB.
export function compressionDepth(start, current) {
  return Math.max(0, Math.min(1, (current - start) / 38))
}

export const PuffingCompression = {
  mounted() {
    this.button = this.el.querySelector('button')
    this.sync = () => { this.button.disabled = this.el.dataset.puffed === 'true' || this.el.dataset.ready !== 'true' }
    this.sync()
    this.down = event => {
      if (this.button.disabled || (event.button !== undefined && event.button !== 0)) return
      this.start = event.clientY
      this.button.style.setProperty('--compression', '.65')
      this.button.setPointerCapture(event.pointerId)
    }
    this.move = event => {
      if (this.start === undefined) return
      this.button.style.setProperty('--compression', String(Math.max(.65, compressionDepth(this.start, event.clientY))))
    }
    this.release = () => { this.start = undefined; this.button.style.setProperty('--compression', '0') }
    this.click = () => {
      if (this.button.disabled) return
      // Native button click also supplies keyboard/assistive-technology activation.
      this.pushEvent('puff', {})
    }
    this.button.addEventListener('pointerdown', this.down)
    this.button.addEventListener('pointermove', this.move)
    this.button.addEventListener('pointerup', this.release)
    this.button.addEventListener('pointercancel', this.release)
    this.button.addEventListener('lostpointercapture', this.release)
    this.button.addEventListener('click', this.click)
  },
  updated() { this.sync() },
  destroyed() {
    for (const [name, fn] of [['pointerdown',this.down],['pointermove',this.move],['pointerup',this.release],['pointercancel',this.release],['lostpointercapture',this.release],['click',this.click]]) this.button.removeEventListener(name, fn)
  }
}
