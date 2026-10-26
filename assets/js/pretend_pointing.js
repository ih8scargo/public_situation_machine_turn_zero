export const PretendPointing = {
  mounted() {
    let x = 50, y = 50
    const mark = this.el.querySelector('.spindle-pointer-mark')
    const draw = () => { mark.style.left = `${x}%`; mark.style.top = `${y}%` }
    this.move = event => {
      const rect = this.el.getBoundingClientRect()
      x = Math.max(0, Math.min(100, (event.clientX - rect.left) / rect.width * 100))
      y = Math.max(0, Math.min(100, (event.clientY - rect.top) / rect.height * 100))
      draw()
    }
    this.key = event => {
      if (!['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'].includes(event.key)) return
      event.preventDefault()
      x = Math.max(0, Math.min(100, x + (event.key === 'ArrowRight' ? 3 : event.key === 'ArrowLeft' ? -3 : 0)))
      y = Math.max(0, Math.min(100, y + (event.key === 'ArrowDown' ? 5 : event.key === 'ArrowUp' ? -5 : 0)))
      draw()
    }
    this.el.addEventListener('pointermove', this.move)
    this.el.addEventListener('pointerdown', this.move)
    this.el.addEventListener('keydown', this.key)
  },
  destroyed() {
    this.el.removeEventListener('pointermove', this.move)
    this.el.removeEventListener('pointerdown', this.move)
    this.el.removeEventListener('keydown', this.key)
  }
}
