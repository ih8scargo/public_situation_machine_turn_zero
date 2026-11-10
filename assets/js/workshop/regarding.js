// Presentation references. A feature point is a sighting target, not an appointed FROM frame.
const stands = [
  {from: 'Pretend entry at aperture center', toward: 'XT → XT orientation reference',
    source: 'T1 / THE-PUBLIC curve start is the rail witness. The U13 cage wedge is a separate trial. The entry aperture-center attachment and bearing are unmeasured.'},
  {from: 'Provisional open bend', toward: 'Middle of the broad face',
    source: 'THE/PUBLIC curve and gallery boundary are visible. The open bend station and the intended broad face are unassigned. The structural overview is retained.'},
  {from: 'Provisional N / MACHINE stand', toward: 'YT → YT sharp turn',
    source: 'N18 cage center and MACHINE origin share a point. Incoming and outgoing segments witness the turn, with the eye frame unappointed.'},
  {from: 'Provisional descending return', toward: 'XT → YT returning toward XT → XT near Traversaling Seat',
    source: 'Steeling reserves descent without a curve. The U13 wedge supplies no seat attachment. The structural overview is retained.'},
]

export function regardingPresentation(root, viewport, draw) {
  const find = id => root.querySelector('#gw-' + id)
  const panel = find('pretend-regarding')
  const flat = find('flat-page')
  if (!panel) return () => null

  const entry = find('pretend-entry'), flip = find('flat-flip')
  const up = find('elevator-up'), down = find('elevator-down')
  const place = find('place-cob'), clear = find('clear-cob')
  const buttons = [...panel.querySelectorAll('[data-regarding-stand]')]
  let stand = null, cob = null, height = 0, scroll = [0, 0], limits = [0, 0]

  function update() { draw(true) }
  entry.onclick = () => { stand = 0; height = 0; update() }
  buttons.forEach((button, index) => { button.onclick = () => { stand = index; update() } })
  up.onclick = () => { height = Math.min(height + 1, limits[1]); update() }
  down.onclick = () => { height = Math.max(height - 1, limits[0]); update() }
  place.onclick = () => { cob = stand; draw() }
  clear.onclick = () => { cob = null; draw() }
  flip.onclick = () => {
    const opening = flat.hidden
    if (opening) scroll = [viewport.scrollLeft, viewport.scrollTop]
    flat.hidden = !opening
    viewport.hidden = opening
    viewport.previousElementSibling.hidden = opening
    flip.setAttribute('aria-expanded', String(opening))
    flip.textContent = opening ? 'Return to structural Regarding' : 'Flat Page Regarding'
    draw()
    if (!opening) viewport.scrollTo(...scroll)
  }

  return model => {
    const course = model.steeling
    panel.hidden = !course
    if (!course) {
      if (!flat.hidden) {
        flat.hidden = true
        viewport.hidden = false
        viewport.previousElementSibling.hidden = false
        flip.setAttribute('aria-expanded', 'false')
        flip.textContent = 'Flat Page Regarding'
      }
      return null
    }

    const vertices = Object.values(model.entities).flatMap(entity => entity.vertices)
    const levels = [...vertices, ...course.stations.map(station => station.point)].map(point => point[1])
    limits = [Math.min(...levels), Math.max(...levels)]
    height = Math.max(limits[0], Math.min(height, limits[1]))
    const entered = stand !== null
    const locality = stands[stand]
    entry.disabled = entered
    find('entry-status').textContent = entered
      ? 'Zero registered in Pretend · helmet down · Stand 0 stays on the rail · before Groundward FROM-standing'
      : 'Before entry · before Groundward FROM-standing'
    find('stand-source').textContent = locality
      ? `FROM ${locality.from} · TOWARD ${locality.toward}. ${locality.source}`
      : 'Stand 0 stays on the 25-letter rail line as the orientation reference.'
    buttons.forEach((button, index) => {
      button.disabled = !entered
      button.setAttribute('aria-pressed', String(index === stand))
    })
    up.disabled = !entered || height >= limits[1]
    down.disabled = !entered || height <= limits[0]
    find('elevator-level').value = `Regarding only · Y ${height} (${limits[0]} to ${limits[1]})`
    place.disabled = !entered || cob === stand
    clear.disabled = cob === null
    find('cob-stand').textContent = cob === null ? 'COB follows the rehearsal course.'
      : `COB placement witness · Stand ${cob} · ${cob === 0 || cob === 2 ? 'at rail reference' : 'location unresolved'} · separate from rehearsal progress`

    if (!flat.hidden) {
      const cards = JSON.parse(root.dataset.flatMaterial).map(item => {
        const card = root.ownerDocument.createElement('article')
        const heading = root.ownerDocument.createElement('h3')
        const source = root.ownerDocument.createElement('p')
        const detail = root.ownerDocument.createElement('p')
        const standing = item.id === 'monitor-already-standing'
        card.dataset.stage = standing ? 'standing' : 'prospective'
        heading.textContent = standing ? 'Already standing · HERE' : 'Staging toward standing · NEXT'
        source.textContent = `FROM ${item.relations.FROM} · TOWARD ${item.relations.regards_toward}`
        detail.textContent = standing
          ? 'HERE projects above the monitor reference line.'
          : 'NEXT projects below the monitor reference line, above physical Ground.'
        card.append(heading, source, detail)
        return card
      })
      find('flat-material').replaceChildren(...cards)
    }

    const anchors = [course.reference_origin, null, course.n_return.point, null]
    return entered ? {stand, cob, height, anchors} : null
  }
}
