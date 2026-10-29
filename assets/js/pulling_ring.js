// Pointer coordinates live only in this hook. The server receives lifecycle and
// displacement/duration witness. No absolute positions or pointer trajectory is retained.
export const PullingRing = {
  mounted() {
    this.ring = this.el.querySelector('#pulling-ring')
    this.ring.disabled = this.el.dataset.disabled === 'true'
    this.live = this.el.querySelector('.opening-pull-live')
    this.gesture = null
    this.gone = false
    this.setLive = text => { this.live.textContent = text }
    this.reset = () => {
      this.ring.style.transform = ''
      this.el.dataset.pulling = 'false'
      this.gesture = null
    }
    this.draw = gesture => {
      const distance = Math.hypot(gesture.dx, gesture.dy)
      const scale = distance > 160 ? 160 / distance : 1
      this.ring.style.transform = `translate(${gesture.dx * scale}px, ${gesture.dy * scale}px)`
      this.setLive(distance > 0 ? 'Pulling. Release at another locality to stand the Toy Box UP.' : 'Purchase taken. Pull some extent.')
    }
    this.progress = gesture => {
      if (gesture.token && !gesture.sentMove && (gesture.dx !== 0 || gesture.dy !== 0)) {
        gesture.sentMove = true
        this.pushEvent('pull', {token: gesture.token})
      }
    }
    this.finish = (gesture, cancelled) => {
      if (gesture.stoppedAt === undefined) gesture.stoppedAt = performance.now()
      if (!gesture.token) { gesture.finish = cancelled ? 'cancel' : 'release'; return }
      const displaced = gesture.dx !== 0 || gesture.dy !== 0
      if (!cancelled && displaced) this.progress(gesture)
      const payload = {token: gesture.token}
      if (!cancelled && displaced) payload.measurements = {dx:gesture.dx,dy:gesture.dy,duration_ms:Math.max(0,gesture.stoppedAt-gesture.startedAt)}
      this.pushEvent(!cancelled && displaced ? 'release-pull' : 'cancel-pull', payload, reply => {
        if (!this.gone && !reply.accepted) this.setLive('The pull was not accepted. Try again, or reload this composition.')
      })
      if (!cancelled && displaced) this.setLive('The completed pull stands TOWARD its consequence.')
      else this.setLive('Relinquished without a completed pull. The ring remains available.')
      this.reset()
    }
    this.begin = (kind, x, y, pointerId = null) => {
      if (this.gesture || this.el.dataset.disabled === 'true') return
      const gesture = {kind, x, y, dx: 0, dy: 0, pointerId, startedAt: performance.now(), token: null, sentMove: false, finish: null}
      this.gesture = gesture
      this.el.dataset.pulling = 'true'
      this.setLive('Purchase taken. Pull some extent.')
      this.pushEvent('take-purchase', {}, reply => {
        if (this.gone) return
        if (!reply.accepted) { this.reset(); this.setLive('This ring is unavailable. Reload to resume its actual standing.'); return }
        gesture.token = reply.token
        if (gesture.finish) this.finish(gesture, gesture.finish === 'cancel')
        else this.progress(gesture)
      })
    }
    this.down = event => {
      if (event.button !== undefined && event.button !== 0) return
      event.preventDefault()
      this.begin('pointer', event.clientX, event.clientY, event.pointerId)
      if (this.gesture?.pointerId === event.pointerId) this.ring.setPointerCapture(event.pointerId)
    }
    this.move = event => {
      const gesture = this.gesture
      if (!gesture || gesture.kind !== 'pointer' || gesture.pointerId !== event.pointerId || gesture.finish) return
      gesture.dx = event.clientX - gesture.x
      gesture.dy = event.clientY - gesture.y
      this.draw(gesture)
      this.progress(gesture)
    }
    this.up = event => {
      const gesture = this.gesture
      if (!gesture || gesture.kind !== 'pointer' || gesture.pointerId !== event.pointerId || gesture.finish) return
      gesture.dx = event.clientX - gesture.x
      gesture.dy = event.clientY - gesture.y
      this.finish(gesture, false)
      if (this.ring.hasPointerCapture(event.pointerId)) this.ring.releasePointerCapture(event.pointerId)
    }
    this.cancel = () => { if (this.gesture && !this.gesture.finish) this.finish(this.gesture, true) }
    this.key = event => {
      if ([' ', 'Enter'].includes(event.key)) {
        event.preventDefault()
        if (event.repeat) return
        if (!this.gesture) this.begin('keyboard', 0, 0)
        else if (this.gesture.kind === 'keyboard') this.finish(this.gesture, false)
      } else if (event.key === 'Escape') {
        event.preventDefault(); this.cancel()
      } else if (['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'].includes(event.key) && this.gesture?.kind === 'keyboard') {
        event.preventDefault()
        if (this.gesture.finish) return
        this.gesture.dx += event.key === 'ArrowRight' ? 12 : event.key === 'ArrowLeft' ? -12 : 0
        this.gesture.dy += event.key === 'ArrowDown' ? 12 : event.key === 'ArrowUp' ? -12 : 0
        this.draw(this.gesture)
        this.progress(this.gesture)
      }
    }
    this.blur = () => this.cancel()
    this.ring.addEventListener('pointerdown', this.down)
    this.ring.addEventListener('pointermove', this.move)
    this.ring.addEventListener('pointerup', this.up)
    this.ring.addEventListener('pointercancel', this.cancel)
    this.ring.addEventListener('lostpointercapture', this.cancel)
    this.ring.addEventListener('keydown', this.key)
    this.ring.addEventListener('blur', this.blur)
  },
  updated() { this.ring.disabled = this.el.dataset.disabled === 'true' },
  disconnected() {
    if (this.gesture) this.gesture.finish = 'cancel'
    this.reset()
  },
  reconnected() { this.pushEvent('abandon-purchase', {}) },
  destroyed() {
    this.gone = true
    this.ring.removeEventListener('pointerdown', this.down)
    this.ring.removeEventListener('pointermove', this.move)
    this.ring.removeEventListener('pointerup', this.up)
    this.ring.removeEventListener('pointercancel', this.cancel)
    this.ring.removeEventListener('lostpointercapture', this.cancel)
    this.ring.removeEventListener('keydown', this.key)
    this.ring.removeEventListener('blur', this.blur)
  }
}
