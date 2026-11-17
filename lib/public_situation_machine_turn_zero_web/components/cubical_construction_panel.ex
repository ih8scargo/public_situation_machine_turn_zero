defmodule PublicSituationMachineTurnZeroWeb.CubicalConstructionPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Workshop.CubicalConstruction, as: C
  attr :state, :map, required: true
  attr :janusite, :map, required: true

  def panel(assigns) do
    model = C.model(assigns.janusite)
    selected = C.inscription(model, assigns.state.selected)

    assigns =
      assign(assigns,
        model: model,
        selected: selected,
        gauge: C.gauge(assigns.state.comparison),
        source_hash: :crypto.hash(:sha256, Jason.encode!(model)) |> Base.encode16(case: :lower),
        selection_form:
          to_form(%{"component" => assigns.state.selected, "revision" => assigns.state.revision},
            as: :cubical
          ),
        options: Enum.map(model.components, &{&1.name, &1.id})
      )

    ~H"""
    <section
      id="cubical-construction"
      class="cc-bench"
      data-revision={@state.revision}
      data-facet={@state.facet}
      data-yaw={@state.yaw}
      data-source-hash={@source_hash}
      data-index="0"
      aria-labelledby="cc-title"
    >
      <header class="cc-heading">
        <div>
          <p class="cc-eyebrow">INSCRIBED ARCHITECTURE / {@model.version}</p><h2 id="cc-title">
            The RE-STEPPING CUBICAL
          </h2>
          <p>SIX × SIX × SIX. Two local framing references. One seated FROM HERE.</p>
        </div>
        <span class="cc-scope">Inspection · ZERO acquired turns</span>
      </header>
      <nav class="cc-facets" aria-label="Projectioning Crossing Regardings">
        <button
          :for={
            {facet, label} <- [
              {"flat", "1 · Flat / near XT"},
              {"tunneling", "2 · Tunneling ↶"},
              {"reciprocal", "3 · Reciprocal / THREE"},
              {"return", "4 · Return / FOUR"}
            ]
          }
          id={"cc-facet-#{facet}"}
          phx-click="cubical-inspect"
          phx-value-kind="facet"
          phx-value-choice={facet}
          phx-value-revision={@state.revision}
          aria-pressed={to_string(@state.facet == facet)}
        >{label}</button>
      </nav>
      <div class="cc-controls">
        <button
          id="cc-orbit-back"
          phx-click="cubical-inspect"
          phx-value-kind="orbit"
          phx-value-choice="-15"
          phx-value-revision={@state.revision}
          aria-label="Turn presentation clockwise 15 degrees"
        ><.icon name="hero-arrow-uturn-right" class="size-4" /> −15°</button>
        <button
          id="cc-orbit-forward"
          phx-click="cubical-inspect"
          phx-value-kind="orbit"
          phx-value-choice="15"
          phx-value-revision={@state.revision}
          aria-label="Turn presentation counterclockwise 15 degrees"
        ><.icon name="hero-arrow-uturn-left" class="size-4" /> +15°</button>
        <button
          id="cc-materials"
          phx-click="cubical-inspect"
          phx-value-kind="materials"
          phx-value-revision={@state.revision}
          aria-pressed={to_string(@state.materials?)}
        >Standing / staging wedges</button>
        <span>Presentation yaw {@state.yaw}° · source coordinates fixed</span>
      </div>
      <p class="cc-context">{context(@state.facet)}</p>
      <p :if={@state.notice} id="cc-notice" role="status">{@state.notice}</p>
      <div class="cc-workspace">
        <figure class="cc-figure">
          <svg
            id="cc-scene"
            viewBox={scene_box(@model, @state)}
            role="group"
            aria-label="Turnable SIX frame, near XT, straight-UP approach, halfway registration and prospective second Footing"
          >
            <g
              :for={c <- @model.components}
              :if={visible?(c, @state)}
              id={"cc-object-#{c.id}"}
              data-component={c.id}
              data-world={Jason.encode!(c.points)}
              data-material={Map.get(c, :material_id)}
              data-status={c.status}
              class={["cc-object", "cc-#{c.status}", c.id == @state.selected && "cc-selected"]}
              phx-click="cubical-inspect"
              phx-value-kind="select"
              phx-value-choice={c.id}
              phx-value-revision={@state.revision}
              phx-keydown="cubical-inspect"
              phx-key="Enter"
              tabindex="0"
              role="button"
              aria-label={"Inspect #{c.name}"}
            >
              <title>{c.name} · {c.classification} · {c.relation}</title>
              <polygon :if={c.kind in [:face, :closed]} points={C.project(c.points, @state)} />
              <polyline :if={c.kind == :line} points={C.project(c.points, @state)} />
              <polyline
                :for={edge <- if(c.kind == :box, do: C.box_lines(c.points), else: [])}
                points={C.project(edge, @state)}
              />
              <polygon :for={face <- Map.get(c, :faces, [])} points={C.project(face, @state)} />
              <circle
                :for={p <- if(c.kind == :point, do: c.points, else: [])}
                cx={xy(p, @state, 0)}
                cy={xy(p, @state, 1)}
                r="4"
              />
            </g>
            <g class="cc-labels" aria-hidden="true">
              <text x={xy([0, 0, 0], @state, 0) + 8} y={xy([0, 0, 0], @state, 1) + 20}>
                XT · near entrance
              </text>
              <text
                x={xy(@model.fixed_endpoint, @state, 0) + 8}
                y={xy(@model.fixed_endpoint, @state, 1) - 12}
              >
                A · fixed far endpoint
              </text>
              <text x={xy(@model.halfway, @state, 0) + 9} y={xy(@model.halfway, @state, 1) - 10}>
                ½ · [3,3,0]
              </text>
              <text x={xy([3, 1.5, 3], @state, 0) - 70} y={xy([3, 1.5, 3], @state, 1)}>
                ONE · candidate framing
              </text>
              <text x={xy([3, 4.5, 3], @state, 0) - 70} y={xy([3, 4.5, 3], @state, 1)}>
                TWO · prospective only
              </text>
            </g>
          </svg>
          <figcaption>
            Click a component or use the inscription selector. Whole-frame entrance, central aperture, staging window and local ceiling retain distinct identities. Aperture boundary and physical joining remain unproved.
          </figcaption>
        </figure>
        <aside class="cc-inspector" aria-label="Selected architectural inscription">
          <.form for={@selection_form} id="cc-selection-form" phx-change="cubical-select">
            <.input field={@selection_form[:revision]} type="hidden" />
            <.input
              field={@selection_form[:component]}
              id="cc-component"
              type="select"
              label="Inspect an inscription"
              options={@options}
            />
          </.form>
          <article id="cc-inscription" data-component={@selected.id}>
            <p class="cc-eyebrow">{@selected.classification}</p><h3>{@selected.name}</h3>
            <p class="cc-relation">{@selected.relation}</p>
            <dl>
              <dt>Identity</dt><dd>{@selected.id}</dd><dt>Material office</dt><dd>
                {@selected.office}
              </dd><dt>Frame / source</dt><dd>{@selected.frame} · {@selected.source}</dd><dt>
                Authority / limit
              </dt><dd>{@selected.authority}</dd>
            </dl>
            <details id="cc-exact-inscription">
              <summary>Coordinates, bearing and full record</summary><pre>{inspect(@selected,pretty: true,limit: :infinity)}</pre>
            </details>
          </article>
          <p id="cc-landing-status" class="cc-blocked">
            TWO actual entrance: nil · next cursor: nil · Landinging: nil. No new material or acquisition is supplied by an inspection point.
          </p>
        </aside>
      </div>
      <section
        id="cc-gauge"
        class={["cc-gauge", @state.facet == "return" && "cc-gauge-active"]}
        aria-labelledby="cc-gauge-title"
      >
        <div>
          <p class="cc-eyebrow">THREE PRESERVES / FOUR COMPARES</p><h3 id="cc-gauge-title">
            Oscillationing Airiness Gauge · initial source comparison
          </h3>
          <p>
            Fixed A04 SIX reference, compared at the same retained quarter-sector samples. This inset retains its own source frame. Mounting at Table THREE and operational interpolationing remain blocked.
          </p>
          <div class="cc-controls">
            <button
              :for={ref <- ~w(FOUR SIX EIGHT)}
              id={"cc-compare-#{ref}"}
              phx-click="cubical-inspect"
              phx-value-kind="comparison"
              phx-value-choice={ref}
              phx-value-revision={@state.revision}
              aria-pressed={to_string(@state.comparison == ref)}
            >{ref} source candidate</button>
          </div>
          <p
            id="cc-gauge-reading"
            data-reference={@gauge.reference.id}
            data-candidate={@gauge.candidate.id}
          >
            Δ radius {Float.round(@gauge.signed_radius_difference, 3)} · maximum matched-sample separation {Float.round(
              @gauge.maximum_separation,
              3
            )} provisional source extents.
          </p>
          <p>
            Interpolation formula: nil. Source-to-CUBICAL transform: nil. These radius labels do not resize SIX or stand for acquired turns.
          </p>
        </div>
        <figure>
          <svg
            id="cc-gauge-scene"
            viewBox="0 0 320 275"
            aria-label="Fixed reference arc and measured variation in native source frame"
          >
            <polyline
              id="cc-gauge-reference"
              data-world={Jason.encode!(@gauge.reference.points)}
              points={C.gauge_project(@gauge.reference.points)}
              fill="none"
              stroke="#4c7568"
              stroke-width="3"
            />
            <polyline
              id="cc-gauge-candidate"
              data-world={Jason.encode!(@gauge.candidate.points)}
              points={C.gauge_project(@gauge.candidate.points)}
              fill="none"
              stroke="#b77742"
              stroke-width="2"
              stroke-dasharray="5 3"
            />
            <line
              :for={
                {a, b} <-
                  Enum.zip(@gauge.reference.points, @gauge.candidate.points) |> Enum.take_every(4)
              }
              x1={gxy(a, 0)}
              y1={gxy(a, 1)}
              x2={gxy(b, 0)}
              y2={gxy(b, 1)}
              stroke="#b77742"
              opacity="0.45"
            />
            <text x="15" y="265" font-size="11">steeling-xy-v1 · Y/Z source comparison</text>
          </svg><figcaption>
            Green: fixed SIX reference. Amber: retained comparison. Spokes measure separation; they are not supplied material.
          </figcaption>
        </figure>
      </section>
      <details id="cc-provenance">
        <summary>Complete crossing registration and unresolved offices</summary>
        <p>
          Inherited unit, frame and local references; standing/staging identities; aperture, cursor and Head/Tail ancestry; acquisition evidence and pending joins belong to one registration. This is a geometry preview, not a DIRT recording.
        </p>
        <pre>{inspect(Map.take(@model,[:circuit,:mechanisms,:joins,:looking,:fixed_endpoint,:halfway,:footings,:actual_footings,:acquired_index]),pretty: true,limit: :infinity)}</pre>
        <p id="cc-preserved-fit">
          Historical rigid Snail height {@model.preserved_fit |> inspect()}: preserved failed fit in its original mounting, not a prohibition on the new local construction.
        </p>
        <p>
          Retained JANUSITE stock: {@model.inherited_janusite.id}. Flat-to-curved transfer and mounting onto these new wedges remain unproved. The A/B/C material-address and Toe/loop inspector remains below.
        </p>
      </details>
      <nav class="cc-legacy" aria-label="Retained workshop studies">
        <a href="#janusite-inheritance">JANUSITE A/B/C</a><a href="#here-wedging-study">HERE wedging / failed fit</a><a href="#geometry-exploration">Table / Gallery / return studies</a><a href="#paired-motor">Paired Motor</a>
      </nav>
    </section>
    """
  end

  defp context("flat"),
    do:
      "Near-side Flat Presentationing. The whole-frame XT corner is the entrance registration; a finite door boundary and seated optical alignment remain unappointed."

  defp context("tunneling"),
    do:
      "The presentation turns counterclockwise toward the 45° Gallery bearing. LEFT and RIGHT name source material offices, independent of which side they appear on screen."

  defp context("reciprocal"),
    do:
      "Reciprocal Regarding of the same frame and material. THREE's reference remains fixed; the native arc inset discloses its unproved mounting transform."

  defp context("return"),
    do:
      "Near-side return-circuit inspection. FOUR compares actual retained source arcs; no camera pose creates a return passage, interpolation law or qualifying Landinging."

  defp scene_box(model, state) do
    pairs =
      model.components
      |> Enum.filter(&visible?(&1, state))
      |> Enum.flat_map(& &1.points)
      |> C.project(state)
      |> String.split(" ")
      |> Enum.map(fn pair ->
        pair
        |> String.split(",")
        |> Enum.map(fn x ->
          {n, ""} = Float.parse(x)
          n
        end)
      end)

    xs = Enum.map(pairs, &Enum.at(&1, 0))
    ys = Enum.map(pairs, &Enum.at(&1, 1))
    width = max(600, Enum.max(xs) - Enum.min(xs) + 110)
    height = max(480, Enum.max(ys) - Enum.min(ys) + 110)

    "#{(Enum.max(xs) + Enum.min(xs) - width) / 2} #{(Enum.max(ys) + Enum.min(ys) - height) / 2} #{width} #{height}"
  end

  defp visible?(c, s),
    do:
      c.id != "six-frame" and c.points != [] and
        (s.materials? or
           c.id not in ~w(cubical-left cubical-right staging-window crossing-divider))

  defp xy(p, s, i),
    do:
      [p]
      |> C.project(s)
      |> String.split(",")
      |> Enum.map(fn x ->
        {n, ""} = Float.parse(x)
        n
      end)
      |> Enum.at(i)

  defp gxy(p, i),
    do:
      [p]
      |> C.gauge_project()
      |> String.split(",")
      |> Enum.map(fn x ->
        {n, ""} = Float.parse(x)
        n
      end)
      |> Enum.at(i)
end
