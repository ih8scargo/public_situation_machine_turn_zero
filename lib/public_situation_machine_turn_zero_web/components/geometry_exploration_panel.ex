defmodule PublicSituationMachineTurnZeroWeb.GeometryExplorationPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Workshop.GeometryExploration, as: G
  alias PublicSituationMachineTurnZero.Workshop.SharedFaceStudy
  alias PublicSituationMachineTurnZeroWeb.BearingRegistrationPanel
  attr :state, :map, required: true

  def panel(assigns) do
    assigns =
      assign(assigns,
        model: G.model(assigns.state),
        shared_face_study: if(assigns.state.experiment == 9, do: SharedFaceStudy.model()),
        fold_form:
          to_form(%{"angle" => assigns.state.angle, "revision" => assigns.state.revision},
            as: :geometry_angle
          )
      )

    ~H"""
    <section
      id="geometry-exploration"
      class="ge-table"
      data-version={G.version()}
      data-revision={@state.revision}
      data-status={@state.frame_status}
      data-view={@state.view}
      data-index="0"
      data-coils={length(@state.coils)}
    >
      <header class="ge-header">
        <div>
          <p class="sr-eyebrow">THE GEOMETRY RE-SURFACING TABLE / EXPLORATION</p><h2>
            Begin with SIX.
          </h2><p>Square · circle · triangle · 45-degree bar</p>
        </div><span class="mr-badge">FURNISHED ≠ ACQUIRED</span>
      </header>
      <p class="ge-authority">
        Canonical source: <a href="#ge-provenance">Geometry RE-surfacing Table evidence</a>
        · <code>{G.version()}</code>
        · trial placements / no working COB in unacquired extent
      </p>
      <nav class="ge-experiments" aria-label="Geometry experiments">
        <button
          :for={{label, i} <- Enum.with_index(G.experiments(), 1)}
          id={"ge-experiment-#{i}"}
          phx-click="explore-command"
          phx-value-kind="experiment"
          phx-value-choice={i}
          phx-value-revision={@state.revision}
          aria-pressed={to_string(@state.experiment == i)}
        >{i}. {label}</button>
      </nav>
      <.shared_faces :if={@shared_face_study} study={@shared_face_study} />
      <BearingRegistrationPanel.study :if={@state.experiment == 10} />
      <div class="ge-layout">
        <div>
          <div class="ge-views">
            <button
              :for={v <- G.views()}
              id={"ge-view-#{v}"}
              phx-click="explore-command"
              phx-value-kind="view"
              phx-value-choice={v}
              phx-value-revision={@state.revision}
              aria-pressed={to_string(@state.view == v)}
            >{v}</button>
          </div>
          <.scene state={@state} model={@model} id="ge-scene" view={@state.view} />
          <.scene
            :if={@state.view == "half"}
            state={@state}
            model={@model}
            id="ge-half-scene"
            view="half"
            half={true}
          />
          <p class="ge-caption">
            {@state.view} · same source material / exploration-six-v1 · HALF changes screen projection only. Frame, HERE and source identity remain fixed.
          </p>
          <p id="ge-notice" class="mr-notice" role="status">
            {@state.notice ||
              "Appoint the frame before proposing a coil. Minimum TWO is capacity, not two pre-existing Footings."}
          </p>
        </div>
        <aside>
          <h3>{Enum.at(G.experiments(), @state.experiment - 1)}</h3>
          <p>{explanation(@state.experiment)}</p>
          <section
            id="ge-diagonal-b-witness"
            data-turn={@model.turn_measure.turn_id}
            data-status={@model.turn_measure.status}
            data-next-status="not-furnished"
            class="ge-measure-witness"
          >
            <h3>Diagonal B · this one current turn</h3>
            <dl>
              <dt>Endpoints / reference frame</dt><dd>
                {inspect(@model.turn_measure.points)} · {@model.turn_measure.frame}
              </dd>
              <dt>Actual XT TOWARD YT length</dt><dd>
                {Float.round(@model.turn_measure.actual_length, 6)} trial extents = SIX√2; vertical frame height remains SIX.
              </dd>
              <dt>THROUGH center</dt><dd>
                {inspect(@model.turn_measure.center)} · registered with A, HERE pillar and Crossing THREE.
              </dd>
              <dt>Inherited basis</dt><dd>
                XT TO XT FROM HERE · ZERO TO ONE · {@model.turn_measure.inherited_from.id}
              </dd>
              <dt>Joining boundary</dt><dd>
                Next YT TOWARD YT is not furnished. Physical joining point, interface and deformation law remain unproved.
              </dd>
            </dl>
            <button
              id="ge-continuation-overlay-toggle"
              phx-click="explore-command"
              phx-value-kind="action"
              phx-value-choice="continuation-overlay"
              phx-value-revision={@state.revision}
              aria-pressed={to_string(@state.continuation_overlay?)}
            >{if(@state.continuation_overlay?,
              do: "Hide prospective join overlay",
              else: "Inspect prospective join overlay"
            )}</button>
            <p :if={@state.continuation_overlay?} id="ge-prospective-join-note">
              PROSPECTIVE ONLY · boundary reference, not an appointed physical join. No next material path is drawn, furnished or acquired.
            </p>
          </section>
          <div class="ge-actions">
            <button
              :for={
                {command, label} <- [
                  {"furnish", "Furnish frame reference"},
                  {"select", "Select wedging reference"},
                  {"acquire", "Inspect RE-STEP blockers"},
                  {"traverse", "Attempt working / traversal"},
                  {"coil", "Propose next coil"},
                  {"ceiling", "Inspect SIX occasion"}
                ]
              }
              id={"ge-#{command}"}
              phx-click="explore-command"
              phx-value-kind="action"
              phx-value-choice={command}
              phx-value-revision={@state.revision}
            >{label}</button>
          </div>
          <dl id="ge-frame-ledger">
            <dt>Ground / Seat / Table / ceiling</dt><dd>ZERO / ONE / THREE / SIX</dd><dt>
              Diagonal A and B
            </dt><dd>rise SIX · run SIX · length {Float.round(:math.sqrt(72), 4)}</dd><dt>
              Physical capacity
            </dt><dd>Minimum TWO required; mechanism unproved. Actual Footings: 0.</dd><dt>
              Human / COB FROM
            </dt><dd>Persistent ZERO; actual working COB is unmounted.</dd>
          </dl>
          <div class="ge-actions">
            <button
              :for={hinge <- ~w(crossing seat)}
              id={"ge-hinge-#{hinge}"}
              phx-click="explore-command"
              phx-value-kind="hinge"
              phx-value-choice={hinge}
              phx-value-revision={@state.revision}
            >Trial hinge: {hinge}</button>
          </div>
          <div class="ge-actions">
            <button
              :for={axis <- ~w(x y)}
              id={"ge-axis-#{axis}"}
              phx-click="explore-command"
              phx-value-kind="axis"
              phx-value-choice={axis}
              phx-value-revision={@state.revision}
            >Axis {axis}: {if(axis == "x", do: "underfold", else: "AROUND ABOUT")}</button>
          </div>
          <.form for={@fold_form} id="ge-angle-form" phx-change="explore-angle">
            <.input field={@fold_form[:revision]} type="hidden" /><.input
              field={@fold_form[:angle]}
              type="range"
              min="0"
              max="90"
              step="5"
              label={"Rigid swing: #{@state.angle}°"}
            />
          </.form>
          <button
            id="ge-swing-end"
            phx-click="explore-command"
            phx-value-kind="angle"
            phx-value-choice="90"
            phx-value-revision={@state.revision}
          >Propose 90° swing / occupied stop</button>
          <p class="ge-fine">
            Fixed framing. Newest coil has deeper underfold; radius stays constant. A finite common-aperture collision rejects the pair rather than moving its center. Session resource bounds are unrelated to Bug count.
          </p>
        </aside>
      </div>
      <div class="ge-bottom">
        <section>
          <h3>Shared FT / TF map</h3><p>
            Inspection only. No click transports a COB or acquires extent.
          </p>
          <svg
            id="ge-map"
            viewBox="-20 100 360 460"
            aria-label="Shared material plan with HERE, proposed coil entrances and candidate axle"
          >
            <defs>
              <marker
                id="ge-map-arrow"
                markerWidth="7"
                markerHeight="7"
                refX="6"
                refY="3"
                orient="auto"
              >
                <path d="M0,0 L6,3 L0,6" fill="#826632" />
              </marker>
            </defs>
            <circle id="ge-zero-reference" cx="196" cy="450" r="4" fill="#425f4f">
              <title>Persistent pillar ZERO at [3,0,−4]</title>
            </circle>
            <polyline
              :for={r <- @model.references}
              :if={r.id in ["HERE", "NEXT", "human-circle"]}
              points={G.project(r.points ++ [hd(r.points)], "plan")}
              fill="none"
              stroke="#9aab95"
            />
            <g
              :for={coil <- @model.coils}
              id={"ge-map-#{coil.id}"}
              data-material={coil.id}
              data-status={coil.status}
            >
              <polyline
                points={G.project(coil.points, "plan")}
                fill="none"
                stroke={if(Map.has_key?(coil, :interference), do: "#ba5b59", else: "#b18746")}
                stroke-dasharray={if(Map.has_key?(coil, :interference), do: "3 3", else: "")}
              />
              <polyline
                id={"ge-direction-#{coil.id}"}
                points={G.project(Enum.take(coil.points, 3), "plan")}
                fill="none"
                stroke="#826632"
                marker-end="url(#ge-map-arrow)"
              >
                <title>Direction from increasing source material address; inspection only</title>
              </polyline>
              <circle cx="196" cy="330" r="5" fill="#547967">
                <title>{coil.id} · common center entrance, candidate only</title>
              </circle>
            </g>
            <polyline
              id="ge-axle"
              points={G.project(@model.axle, "plan")}
              fill="none"
              stroke="#776492"
            >
              <title>
                Candidate axle from accepted candidate entrances only; coincident centers do not establish curvature
              </title>
            </polyline>
            <text x="20" y="535" font-size="10">ZERO persists · actual acquired locality: none</text>
          </svg>
          <div class="ge-actions">
            <button
              :for={
                id <-
                  ["HERE", "NEXT", "pillar", "diagonal-A", "diagonal-B", "table", "craft-reservation"] ++
                    Enum.map(@state.coils, & &1.id)
              }
              id={"ge-map-select-#{id}"}
              phx-click="explore-command"
              phx-value-kind="select"
              phx-value-choice={id}
              phx-value-revision={@state.revision}
            >Inspect {id}</button>
          </div>
          <p id="ge-selection">Selected inspection locality: {@state.selected}</p>
        </section>
        <section id="ge-condition-lab">
          <h3>Condition-contract rehearsal</h3><p class="ge-fine">
            Separate stipulated fixture: these controls simulate evidence slots. They grant no actual acquired frame, Footing, securing or traversal.
          </p>
          <div class="ge-actions">
            <button
              :for={
                {action, label} <- [
                  {"encounter", "1 · Encounter"},
                  {"receipt", "2 · Local receipt fixture"},
                  {"appoint", "3 · Appoint presence"},
                  {"presence", "4 · Satisfy presence"},
                  {"exit", "5 · Exit condition"},
                  {"restomp", "6 · RE-STOMPING fixture"},
                  {"ready", "7 · State readiness"},
                  {"rezip", "8 · RE-ZIPPERING fixture"},
                  {"next", "9 · Next tunnel furnished fixture"},
                  {"button", "10 · Encounter buttoning fixture"}
                ]
              }
              id={"ge-lab-#{action}"}
              phx-click="explore-command"
              phx-value-kind="lab"
              phx-value-choice={action}
              phx-value-revision={@state.revision}
            >{label}</button>
          </div>
          <p id="ge-eligibility" data-ready={to_string(@model.eligibility)}>
            {if(@model.eligibility,
              do: "Fixture eligibility satisfied; real traversal remains blocked.",
              else: "Fixture buttoning not eligible."
            )}
          </p>
          <pre>{inspect(@state.condition_lab,pretty: true)}</pre>
          <p>No public STAND TOWARD THIS ONE BUTTONING is furnished by this fixture.</p>
        </section>
      </div>
      <PublicSituationMachineTurnZeroWeb.HereWedgingPanel.panel state={@state} />
      <PublicSituationMachineTurnZeroWeb.AlongsideStagingPanel.panel
        state={@state.staging}
        revision={@state.revision}
      />
      <details id="ge-provenance">
        <summary>Material, source, placement and rejection evidence</summary><p>
          Architectural authority: docs/architecture/geometry/README.md. All placements here are versioned trials under its requirements.
        </p>
        <pre>{inspect(Map.take(@state,[:frame_status,:from,:index,:ceiling,:proposal]),pretty: true,limit: 12)}</pre>
        <pre>{inspect(List.last(@state.events),pretty: true)}</pre>
        <div :for={coil <- @model.coils} id={"ge-coil-ledger-#{coil.id}"}>
          <strong>{coil.id}</strong>
          · radius {coil.radius} · depth {coil.depth} · lowest center {coil.minimum_center_height} · {coil.relation}
          <p>{inspect(Map.get(coil, :interference, :no_pair_test), pretty: true)}</p>
        </div>
        <p>
          Supply conservation, common hinge mechanics, finite Table/COB clearance, actual return and optical curvature remain unproved. This session is not a validated DIRT export.
        </p>
      </details>
    </section>
    """
  end

  attr :study, :map, required: true

  defp shared_faces(assigns) do
    ~H"""
    <section
      id="ge-shared-face-study"
      class="ge-measure-witness mt-4 mb-4 p-4"
      data-version={@study.version}
      data-frame={@study.frame}
      data-capacity={@study.physical_capacity}
    >
      <h3>Three-Footing shared-face study · historical body-diagonal trial</h3>
      <p>The 45° bearing registration compares the corrected inclination in these same frames.</p>
      <p>
        Two registrations fit in SIX. The third repeats blue's orientation beyond the parent boundary.
      </p>
      <p>
        Oblique registration and transverse elevation. Dashed lines are candidate coil centerlines.
      </p>
      <div class="grid gap-4 lg:grid-cols-2">
        <figure :for={
          {label, view} <- [
            {"Oblique registration", "oblique"},
            {"Transverse elevation", "transverse"}
          ]
        }>
          <figcaption>{label}</figcaption>
          <svg
            viewBox="0 -45 465 310"
            class="w-full rounded"
            style="background: #101827"
            role="img"
            aria-label={label}
          >
            <g
              :for={
                {registration, color} <-
                  Enum.zip(@study.registrations, ["#65aaff", "#facc15", "#c4b5fd"])
              }
              id={"ge-shared-#{view}-#{registration.id}"}
              data-bearing={Jason.encode!(registration.bearing)}
            >
              <polyline
                :for={edge <- SharedFaceStudy.edges(registration)}
                points={SharedFaceStudy.project(edge, view)}
                stroke={color}
                fill="none"
                stroke-opacity="0.65"
              />
              <polyline
                points={SharedFaceStudy.project(registration.bearing, view)}
                stroke={
                  %{"blue" => "#86efac", "yellow" => "#f472e8", "third" => "#c4b5fd"}[registration.id]
                }
                stroke-width="3"
                fill="none"
              />
              <polyline
                points={SharedFaceStudy.project(registration.coil.points, view)}
                stroke={color}
                stroke-dasharray="3 2"
                fill="none"
              />
            </g>
          </svg>
        </figure>
      </div>
      <div class="grid gap-3 md:grid-cols-3">
        <div :for={registration <- @study.registrations} id={"ge-shared-stock-#{registration.id}"}>
          <strong>{String.capitalize(registration.id)}</strong>
          <p>
            Origin {inspect(registration.origin)} · bearing {Float.round(
              registration.bearing_length,
              4
            )}
          </p>
          <p>
            Coil length {Float.round(registration.coil.length, 4)} · stock floor Y {Float.round(
              registration.coil.lowest_stock_y,
              4
            )}
          </p>
          <p>Trial opening {inspect(registration.coil.trial_aperture.center)} · normal +X</p>
          <p>Occupied coil inside SIX: {registration.coil.inside_parent}</p>
        </div>
      </div>
      <p
        :for={handoff <- @study.handoffs}
        id={"ge-shared-join-#{Enum.join(handoff.ids, "-")}"}
        data-face-match={to_string(handoff.face_match)}
        data-point-match={to_string(handoff.point_match)}
        data-tangent-match={to_string(handoff.tangent_match)}
        data-boundary-match={to_string(handoff.material_boundary_match)}
      >
        {Enum.join(handoff.ids, " → ")} · shared area {Float.round(handoff.face_area, 1)} ·
        turn {Float.round(handoff.turn_degrees, 3)}° · finite bars overlap: {handoff.bearing_stock_overlap}.
        End sections and material normals differ.
      </p>
      <p>
        Coil pair overlaps: {Enum.count(@study.coil_pairs, & &1.interference)} of 3 with separate trial openings.
        The existing common-aperture control overlaps. Newest stock is nearest Ground in this trial. Physical two-Footing capacity remains unproved.
      </p>
      <p>
        Registered UN-VANISHING workshop opening {@study.workshop_opening.id} at {inspect(
          @study.workshop_opening.center
        )} has normal +Z.
        The drawing shows two projected rims. Their depth, plane and material correspondence remain open.
      </p>
      <p>
        Snail THROUGH SIX at inherited scale spans Y {Enum.map_join(
          @study.snail.height_range,
          " to ",
          &Float.to_string(Float.round(&1, 4))
        )}.
        Optical curvature remains unproved. Preview only. Human RE-STEP and COB acquisition require their own witnesses.
      </p>
    </section>
    """
  end

  attr :state, :map, required: true
  attr :model, :map, required: true
  attr :id, :string, required: true
  attr :view, :string, required: true
  attr :half, :boolean, default: false

  def scene(assigns) do
    ~H"""
    <svg
      id={@id}
      viewBox="-40 -20 560 580"
      role="img"
      aria-label="Registered SIX frame, diagonals, HERE pillar and occupied candidate material"
    >
      <polyline
        :for={edge <- @model.edges}
        points={G.project(edge, @view, @half)}
        fill="none"
        stroke="#bbc5b6"
        stroke-dasharray="4 3"
      />
      <polyline
        :for={r <- @model.references}
        id={"#{@id}-#{r.id}"}
        points={
          G.project(r.points ++ if(r.kind == :closed, do: [hd(r.points)], else: []), @view, @half)
        }
        data-world={Jason.encode!(r.points)}
        fill="none"
        stroke={if(r.id in ["diagonal-A", "diagonal-B"], do: "#b18b46", else: "#718d7c")}
        stroke-width={if(r.id == "pillar", do: "5", else: "1.5")}
      >
        <title>{r.label} · {r.status}</title>
      </polyline>
      <.measure_marks
        id={@id}
        measure={@model.turn_measure}
        view={@view}
        half={@half}
        overlay={@state.continuation_overlay?}
      />
      <g
        id={"#{@id}-specimen"}
        data-material={@model.specimen.material_id}
        data-world={Jason.encode!(@model.specimen.vertices)}
      >
        <polygon
          :for={face <- @model.specimen.faces}
          points={G.project(face, @view, @half)}
          fill="#5f9584"
          fill-opacity="0.45"
          stroke="#3a7262"
        />
      </g>
      <polygon
        :for={face <- @model.stop.faces}
        points={G.project(face, @view, @half)}
        fill="#ba6860"
        fill-opacity="0.3"
        stroke="#bc8077"
      />
      <g
        :for={coil <- @model.coils}
        id={"#{@id}-#{coil.id}"}
        data-material={coil.id}
        data-world={Jason.encode!(coil.points)}
        data-depth={coil.depth}
      >
        <polygon
          :for={face <- Enum.flat_map(coil.segments, & &1.faces)}
          points={G.project(face, @view, @half)}
          fill={if(Map.has_key?(coil, :interference), do: "#b86a65", else: "#bd985f")}
          fill-opacity={if(Map.has_key?(coil, :interference), do: "0.2", else: "0.65")}
          stroke={if(Map.has_key?(coil, :interference), do: "#b86a65", else: "#a18048")}
          stroke-width="0.5"
          stroke-dasharray={if(Map.has_key?(coil, :interference), do: "2 2", else: "")}
        />
      </g>
      <text x="0" y="8" font-size="12" fill="#445e52">
        SIX frame · Ground ZERO / Seat ONE / Table THREE
      </text>
      <text x="0" y="545" font-size="11" fill="#445e52">
        Candidate geometry · no acquired working extent
      </text>
    </svg>
    """
  end

  attr :id, :string, required: true
  attr :measure, :map, required: true
  attr :view, :string, required: true
  attr :half, :boolean, default: false
  attr :overlay, :boolean, default: false

  defp measure_marks(assigns) do
    {cx, cy} = G.position(assigns.measure.center, assigns.view, assigns.half)
    {bx, by} = G.position(List.last(assigns.measure.points), assigns.view, assigns.half)
    assigns = assign(assigns, cx: cx, cy: cy, bx: bx, by: by)

    ~H"""
    <g
      id={"#{@id}-current-turn-measure"}
      data-measure={@measure.id}
      data-turn={@measure.turn_id}
      data-world={Jason.encode!(@measure.points)}
      data-status="current-turn-line-furnished"
    >
      <polyline
        points={G.project(@measure.points, @view, @half)}
        fill="none"
        stroke="#3d7a75"
        stroke-width="3"
      >
        <title>
          Diagonal B: current-turn XT TOWARD YT length SIX√2, inherited FROM HERE; no next extent
        </title>
      </polyline>
      <circle cx={@cx} cy={@cy} r="3" fill="#3d7a75">
        <title>Resolution THROUGH [3,3,0]; no physical joint inferred</title>
      </circle>
      <circle cx={@bx} cy={@by} r="4" fill="#fafbf6" stroke="#3d7a75">
        <title>Current-turn B endpoint; continuation not furnished</title>
      </circle>
    </g>
    <g
      :if={@overlay}
      id={"#{@id}-prospective-join"}
      data-status="prospective-only"
      data-basis={@measure.id}
      data-material-points="[]"
      data-acquired="false"
    >
      <circle cx={@bx} cy={@by} r="12" fill="none" stroke="#a77c53" stroke-dasharray="3 3">
        <title>
          Prospective joining reference only; physical join unappointed; no YT TOWARD YT material
        </title>
      </circle>
    </g>
    """
  end

  defp explanation(1),
    do:
      "A registers the ascending bearing; B furnishes the current-turn XT TOWARD YT length. No next YT TOWARD YT is furnished. Capacity is not pre-furnished Footings."

  defp explanation(2),
    do:
      "A finite triangular specimen stands against square/circle registration. Source, hinge, width and thickness remain distinct."

  defp explanation(3),
    do:
      "Compare Crossing and Seat hinge candidates. The occupied stop can block full swing. Rotation does not create curvature."

  defp explanation(4),
    do:
      "A constant-radius Ribbon coil passes through the same center and folds downward in a tilted plane. Mounting is a candidate."

  defp explanation(5),
    do:
      "Propose the second coil. Its deeper underfold approaches Ground while the older stays above; finite common-center interference must be shown."

  defp explanation(6),
    do:
      "The map reads only the same current candidate material. Coincident entrances do not establish an emerging curved axle."

  defp explanation(7),
    do:
      "Full/half projections share identical source points. Physical monitor, inner aperture and material aperture retain distinct IDs."

  defp explanation(10),
    do:
      "Inspect the local 45° bearings and finite stock above. The rehearsal below retains its own registrations."

  defp explanation(9),
    do: "Read the shared-face study above alongside the existing rehearsal below."

  defp explanation(8),
    do:
      "Inspect independent condition evidence in a separate fixture. Presence alone cannot authorize next buttoning or actual traversal."
end
