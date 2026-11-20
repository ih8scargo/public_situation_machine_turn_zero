const svgNS = "http://www.w3.org/2000/svg"
const radians = degrees => degrees * Math.PI / 180
const finish = {
  reference: "#7793aa", door: "#4b697e", upper: "#457a8d", lower: "#31596f",
  bar: "#b27c4f", letter: "#ffe2a7", coil: "#84d9cf", datum: "#c3b499",
  crossing: "#ffcd80", projection: "#efad91", first: "#e5c480",
  alongside: "#db9bce", stacked: "#ae9bed", opening: "#fff2cc",
  approach: "#f4c07e", course: "#66dec4", return: "#c4a9ed",
  blocked: "#db857c", principal: "#638caa", slice: "#ffebba", resolution: "#e397cb",
  "bow-image": "#e397cb", passage: "#ca9cbe", u: "#a3bed0", ground: "#71968c", bow: "#d1b98b", cage: "#638caa", halfway: "#fff2cc",
  upright: "#d1b98b", ft: "#82dac6", tf: "#82dac6"
}

function svg(tag, attrs, content) {
  const node = document.createElementNS(svgNS, tag)
  Object.entries(attrs).forEach(([key, value]) => node.setAttribute(key, value))
  if (content) node.textContent = content
  return node
}

function camera(center, orbit, elevation, unit, cx = 320, cy = 320) {
  const a = radians(orbit), b = radians(elevation)
  return ([x, y, z]) => {
    const dx = x - center[0], dy = y - center[1], dz = z - center[2]
    const right = dx * Math.cos(a) - dz * Math.sin(a)
    const forward = dx * Math.sin(a) + dz * Math.cos(a)
    return [
      cx + unit * right,
      cy - unit * (dy * Math.cos(b) - forward * Math.sin(b)),
      forward * Math.cos(b) + dy * Math.sin(b)
    ]
  }
}

function centroid(points) {
  return [0, 1, 2].map(axis => points.reduce((total, p) => total + p[axis], 0) / points.length)
}

function trace(project, points) {
  return points.map(project).map(([x, y]) => [x.toFixed(2), y.toFixed(2)].join(",")).join(" ")
}

function draw(target, pieces, project, selected, identify) {
  const fragments = []
  for (const piece of pieces) {
    const active = piece.id === selected
    const color = finish[piece.kind]
    for (const face of piece.faces) {
      const depth = project(centroid(face))[2]
      const opacity = piece.kind === "reference" ? 0.17 : 0.82
      fragments.push([depth, svg("polygon", {
        points: trace(project, face), fill: color, "fill-opacity": opacity,
        stroke: active ? "#fff0c5" : color, "stroke-opacity": active ? 1 : 0.45,
        "stroke-width": active ? 1.6 : 0.65, "data-source": piece.id
      })])
    }
    for (const path of piece.paths) {
      const depth = project(centroid(path))[2]
      const attrs = {"data-source": piece.id, stroke: active ? "#fff0c5" : color}
      const [x, y] = project(path[0])
      const element = path.length === 1
        ? svg("circle", {...attrs, cx: x, cy: y, r: 5, fill: "#121f2b"})
        : svg("polyline", {...attrs, points: trace(project, path), fill: "none",
          "stroke-width": active ? 3 : 1.7, "stroke-linejoin": "round",
          "stroke-dasharray": piece.kind === "projection" || piece.kind === "approach" ? "5 5" : "none"})
      fragments.push([depth, element])
    }
  }

  fragments.sort(([depthA], [depthB]) => depthA - depthB)
  const layers = fragments.map(([, node]) => node)
  if (identify) {
    const chosen = pieces.find(piece => piece.id === selected)
    if (chosen) {
      const point = centroid(chosen.paths.flat().concat(chosen.faces.flat()))
      const [x, y] = project(point)
      layers.push(svg("text", {
        x: Math.max(14, Math.min(x + 10, 625 - chosen.label.length * 7.3)),
        y: Math.max(25, Math.min(y - 11, 624)),
        class: "lzero-inscription", "pointer-events": "none"
      }, chosen.label))
    }
  }
  target.replaceChildren(...layers)
}

export const LayeringZero = {
  mounted() {
    const model = JSON.parse(this.el.dataset.model)
    const field = key => this.el.querySelector(`#lzero-${key}`)
    const scene = field("scene")
    const wayfinding = field("wayfinding")
    const source = field("source")
    const select = id => {
      if (!model.pieces.some(piece => piece.id === id)) return
      source.value = id
      render()
    }
    for (const piece of model.pieces.filter(piece => piece.faces.length || piece.paths.length)) {
      source.add(new Option(piece.label, piece.id))
    }
    source.value = "gallery-door:1"
    let view = "bulb"
    let door = model.opening.doors[0]

    const render = () => {
      const addressedDoor = model.opening.doors.find(item =>
        source.value === item.id || source.value.startsWith(item.id + ":"))
      if (addressedDoor) door = addressedDoor
      const slice = field("slice").value
      const office = field("office").value
      const historic = field("control").checked || field("specimen").value === "blocked"
        || source.value.startsWith("transverse:") || source.value.startsWith("monitor:")
      const specimen = field("specimen").value
      const selected = model.pieces.find(piece => piece.id === source.value)
      const selectedPoint = centroid(selected.paths.flat().concat(selected.faces.flat()))
      const chosenSection = ["first", "alongside", "stacked", "blocked"]
      const present = model.pieces.filter(piece => {
        if (chosenSection.includes(piece.kind)) {
          return piece.kind === specimen || (["alongside", "stacked"].includes(specimen) && piece.kind === "first")
        }
        if (piece.kind === "opening") return specimen !== "none" && specimen !== "blocked"
        if (["bar", "letter", "crossing", "projection"].includes(piece.kind)
            || piece.id === "transverse:axis") {
          return historic && (piece.kind !== "projection" && piece.id !== "transverse:axis" || field("projection").checked)
        }
        if (["principal", "slice"].includes(piece.kind)) return piece.id.startsWith(door.id + ":")
        if (piece.kind === "passage") return slice !== "source" && piece.id.startsWith(door.id + ":")
        if (piece.kind === "resolution") return piece.id.startsWith(door.id + ":") &&
          (slice === "compare" || piece.id.endsWith(":" + slice))
        if (["ft", "tf"].includes(piece.kind)) return piece.kind === office && piece.id.startsWith(door.id + ":")
        if (["upright", "halfway"].includes(piece.kind)) return specimen !== "none" && specimen !== "blocked"
        if (piece.kind === "bow-image") return slice !== "source" || piece.id === source.value
        if (piece.kind === "cage") return piece.id === source.value || source.value === "bowstring:out"
        if (piece.kind === "upper" || piece.kind === "lower") return field(piece.kind).checked
        if (piece.kind === "ground") return field("lower").checked
        if (piece.id === "cb:monitor" || piece.id === "cb:glass") return field("wall").checked
        return true
      })

      const references = ["cb:monitor", "cb:glass", "cb:seat", "cb:square-axle", "cb:table"]
      const flat = new Set([...references.slice(0, 2), "transverse:bar", "transverse:axis", "monitor:intersection", "monitor:projection"])
      const coil = ["halfway", "upright", "ft", "tf", "bow", "bow-image", "u", "coil", "approach", "course", "return", "datum", "opening", ...chosenSection]
      const bulb = ["door", "upper", "lower", "ground", "coil", "principal", "slice", "resolution", "passage", "ft", "tf"]
      const wheel = field("pose").value === "wheel"
      const anchor = field("anchor").value
      const zoom = Number(field("zoom").value)
      const orbit = Number(field("orbit").value)
      const elevation = Number(field("elevation").value)
      const center = anchor === "material" ? selectedPoint : model[anchor]
      const visible = view === "diorama" ? present : present.filter(piece => {
        if (view === "flat") return historic ? flat.has(piece.id) || piece.kind === "letter"
          : ["principal", "slice", "resolution", "passage", "ft", "tf", "cage"].includes(piece.kind)
        return (view === "coil" ? coil : bulb).includes(piece.kind)
      })
      // A pose rotates only the shell stock and its coil around the ring diameter.
      // References and the canonical section remain in their registered frame.
      const rotate = ([x, y, z]) => [x, model.center[1] - (z - model.center[2]), model.center[2] + (y - model.center[1])]
      const posed = wheel && (view === "bulb" || view === "diorama")
      const posedKinds = ["door", "upper", "lower", "coil", "ground"]
      const transformed = posed ? visible.map(piece => posedKinds.includes(piece.kind) ? {
        ...piece,
        faces: piece.faces.map(face => face.map(rotate)),
        paths: piece.paths.map(path => path.map(rotate))
      } : piece) : visible
      const doorAngle = model.opening.doors.indexOf(door) * 45
      const reciprocal = slice === "positive" || slice === "negative"
      const facing = {
        flat: historic ? camera([3, 1.48, model.monitor_z], 0, 0, 151 * zoom)
          : camera(door.origins.gallery, doorAngle + 90 + (reciprocal ? (slice === "positive" ? 35 : -35) : 0),
            reciprocal ? 20 : 0, 440 * zoom),
        bulb: camera(model.center, reciprocal ? doorAngle + (slice === "positive" ? 40 : -40) : orbit,
          posed ? 23 : reciprocal ? -30 : 76, 145 * zoom),
        coil: camera(model.center, 0, -75, 116 * zoom),
        diorama: camera(center, orbit, elevation, 65 * zoom, 320, anchor === "seat" ? 420 : 320)
      }

      draw(scene, transformed, facing[view], source.value, true)
      if (view === "bulb") {
        const [x, y] = facing.bulb(model.center)
        scene.append(svg("circle", {cx: x, cy: y, r: 14, fill: "none", stroke: "#f3d9a8", "stroke-width": 1.5}))
      }
      draw(wayfinding, present.filter(piece => coil.includes(piece.kind) || piece.id === source.value),
        camera(model.center, 0, -89, 32, 320, 66), source.value, false)
      wayfinding.append(svg("text", {x: 16, y: 25, class: "lzero-inscription"}, "COIL · FROM DOWN BELOW"))
      field("reading").textContent = `${selected.id} · [${selectedPoint.map(value => value.toFixed(3)).join(", ")}]`
      this.el.dataset.pose = posed ? "upright" : "registered"
      this.el.dataset.door = door.id
      this.el.dataset.office = office
      this.el.dataset.view = view
      this.el.dataset.selected = source.value
      this.el.dataset.specimen = specimen
      this.el.querySelectorAll("[data-view]").forEach(button => {
        button.setAttribute("aria-pressed", String(button.dataset.view === view))
      })
    }

    this.el.addEventListener("input", render)
    this.el.addEventListener("click", event => {
      const button = event.target.closest("button[data-view]")
      if (button) {
        view = button.dataset.view
        render()
      } else if (event.target.dataset.source) {
        select(event.target.dataset.source)
      }
    })

    let drag
    scene.addEventListener("pointerdown", event => {
      if (view !== "diorama" || event.button !== 0) return
      drag = {x: event.clientX, y: event.clientY, orbit: Number(field("orbit").value),
        elevation: Number(field("elevation").value)}
    })
    scene.addEventListener("pointermove", event => {
      if (!drag || !event.buttons) return
      const dx = event.clientX - drag.x, dy = event.clientY - drag.y
      if (Math.hypot(dx, dy) < 4) return
      scene.setPointerCapture(event.pointerId)
      field("orbit").value = ((drag.orbit + dx * 0.6 + 540) % 360) - 180
      field("elevation").value = Math.max(-89, Math.min(89, drag.elevation + dy * 0.6))
      render()
    })
    for (const event of ["pointerup", "pointercancel"]) {
      scene.addEventListener(event, () => { drag = undefined })
    }

    render()
  }
}
