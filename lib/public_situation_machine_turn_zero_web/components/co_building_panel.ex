defmodule PublicSituationMachineTurnZeroWeb.CoBuildingPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Workshop.CoBuilding, as: C
  alias PublicSituationMachineTurnZero.Workshop.CoBuildingGeometry, as: G
  attr :state, :map, required: true
  attr :standing_digest, :string, required: true

  def panel(assigns) do
    model = C.model(assigns.state)
    selected = C.selected(model, assigns.state.selected)
    faces = C.render_faces(model, assigns.state)

    assigns =
      assign(assigns,
        model: model,
        selected: selected,
        faces: Enum.reject(faces, &(&1.part.id == "cb:R")),
        r_faces: Enum.filter(faces, &(&1.part.id == "cb:R")),
        source_hash: C.source_digest(model),
        visibility: C.visibility(selected, assigns.state, model),
        r_visibility: C.visibility(C.selected(model, "cb:R"), assigns.state, model),
        form:
          to_form(
            Map.new(~w(view yaw door wedge layer circuit interpolation), fn key ->
              {key,
               Map.fetch!(
                 assigns.state,
                 %{
                   "view" => :view,
                   "yaw" => :yaw,
                   "door" => :door,
                   "wedge" => :wedge,
                   "interpolation" => :interpolation,
                   "layer" => :layer,
                   "circuit" => :circuit
                 }[key]
               )}
            end)
            |> Map.put("revision", assigns.state.revision),
            as: :settings
          ),
        trace_form: to_form(%{"text" => "R", "revision" => assigns.state.revision}, as: :trace),
        camera: C.camera(assigns.state)
      )

    ~H"""
    <section
      id="co-building"
      class="cb-workbench"
      data-revision={@state.revision}
      data-source-hash={@source_hash}
      data-standing-digest={@standing_digest}
      data-acquired-delta="0"
      data-view={@state.view}
      data-door={@state.door}
      data-r-pose={@state.r_pose}
      aria-labelledby="cb-title"
    >
      <header class="cb-heading">
        <div>
          <p class="cb-eyebrow">PUBLIC-SITUATION-MACHINE- / MATERIAL CO-BUILDINGING</p><h1 id="cb-title">
            The RE-STEPPING contraption
          </h1><p>THIS ONE SEGMENTATIONING WEDGING · a reference ready for EN-FURNISHING-MENTING</p>
        </div><span class="cb-scope">REFERENCE / REHEARSAL · acquisition disabled</span>
      </header>
      <nav class="cb-tabs" aria-label="Ordinary Regardings">
        <button
          :for={
            {view, label} <- [
              {"flat", "Flat / one R"},
              {"gallery-close", "Gallery incidence / close"},
              {"oblique", "Assembled apparatus"},
              {"side", "Side / undercurve"},
              {"tunneling-under", "Tunneling DOWN / undercurve"},
              {"tunneling", "TWO · Pretend FROM Seat"},
              {"transverse", "45° Gallery"}
            ]
          }
          id={"cb-view-#{view}"}
          phx-click="co-building-action"
          phx-value-action="view"
          phx-value-choice={view}
          phx-value-revision={@state.revision}
          aria-pressed={to_string(@state.view == view)}
        >{label}</button>
        <.link navigate={~p"/workshop/string-ribbon"} id="cb-source-workshop">Earlier geometry &amp; failed witnesses
        <.icon name="hero-arrow-up-right" class="size-4" /></.link>
      </nav>
      <nav id="cb-course-stages" class="cb-tabs" aria-label="Ordered Gallery course inspection">
        <button
          :for={
            {n, label} <- [
              {1, "1 · R Flat"},
              {2, "2 · R edge-on"},
              {3, "3 · Beneath Seat"},
              {4, "4 · 45° departure"},
              {5, "5 · Upper loop"},
              {6, "6 · AROUND ABOUT"},
              {7, "7 · Next FLAT PINNING"}
            ]
          }
          id={"cb-course-stage-#{n}"}
          phx-click="co-building-action"
          phx-value-action="course-stage"
          phx-value-choice={n}
          phx-value-revision={@state.revision}
        >{label}</button>
      </nav>
      <p id="cb-course-status" class="cb-yellow">
        One prospective source course THROUGH the Gallery; joins, folds and transverse PINNING remain YELLOW. Next PINNING lies FLAT; actual next Footing is absent.
      </p>
      <p id="cb-course-clearance" class="cb-small">
        Course / stable aperture interference: {to_string(
          @model.clearance.course_to_aperture_interference
        )}. Upper loop / departure interference: {to_string(
          @model.clearance.loop_to_departure_interference
        )}. Shared reference sections and zero endpoint gap do not certify physical joins.
      </p>
      <p :if={@state.notice} id="cb-notice" class="cb-yellow" role="status">{@state.notice}</p>
      <div class="cb-workspace">
        <div class="cb-stage">
          <svg
            id="cb-scene"
            viewBox="0 0 840 620"
            role="group"
            aria-label="Finite metal bearings, stable ZERO aperture, right-angle wedges, Table, Seat and prospective Gallery"
          >
            <defs>
              <clipPath id="cb-half-clip">
                <rect
                  x={if(@state.view == "half", do: 420, else: 0)}
                  y="0"
                  width={if(@state.view == "half", do: 420, else: 840)}
                  height="620"
                />
              </clipPath>
            </defs>
            <g clip-path="url(#cb-half-clip)">
              <polygon
                :for={face <- @faces}
                points={face.points}
                class={[
                  "cb-face",
                  "cb-#{face.part.status}",
                  "cb-#{face.part.group}",
                  face.part.id == @state.selected && "cb-selected"
                ]}
                data-part={face.part.id}
                phx-click="co-building-action"
                phx-value-action="select"
                phx-value-choice={face.part.id}
                phx-value-revision={@state.revision}
              >
                <title>{face.part.name} · {face.part.status} · {face.part.office}</title>
              </polygon>
              <g
                :for={part <- @model.parts}
                :if={C.visible?(part, @state)}
                data-source-id={part.source_id}
                data-source-hash={part.source_hash}
                data-pose-hash={C.digest(part.geometry.vertices)}
              >
                <polyline
                  :for={line <- Map.get(part, :lines, [])}
                  points={C.points(line, @state)}
                  class={["cb-guide", part.id == @state.selected && "cb-selected"]}
                  phx-click="co-building-action"
                  phx-value-action="select"
                  phx-value-choice={part.id}
                  phx-value-revision={@state.revision}
                >
                  <title>{part.name}</title>
                </polyline>
              </g>
              <g
                id="cb-letter-R"
                data-source-id="specimen:R:1"
                data-visibility={@r_visibility}
                data-source-hash={C.selected(@model, "cb:R").source_hash}
                data-world={Jason.encode!(C.selected(@model, "cb:R").geometry.vertices)}
              >
                <polygon
                  :for={face <- @r_faces}
                  points={face.points}
                  class="cb-glyph"
                  data-part="cb:R"
                  phx-click="co-building-action"
                  phx-value-action="select"
                  phx-value-choice="cb:R"
                  phx-value-revision={@state.revision}
                >
                  <title>One R · tracing / rehearsal, actual stitching false</title>
                </polygon>
              </g>
            </g>
            <g class="cb-source-labels" aria-hidden="true">
              <text x={xy(@model.zero, @state, 0) + 8} y={xy(@model.zero, @state, 1) + 18}>
                ZERO · stable aperture
              </text>
              <text x={xy(@model.one, @state, 0) + 8} y={xy(@model.one, @state, 1) - 15}>
                ONE · Seat / square axle
              </text>
              <text x={xy(@model.three, @state, 0) + 8} y={xy(@model.three, @state, 1) - 15}>
                THREE · Table / second pivot
              </text>
            </g>
          </svg>
          <div class="cb-caption">
            <span><i class="cb-key cb-key-metal"></i>Structural metal</span><span><i class="cb-key cb-key-pipe"></i>JANUSITE piping</span><span><i class="cb-key cb-key-ribbon"></i>Ribbon / wedges</span><span>Dashed / translucent: prospective or reference</span>
          </div>
          <p class="cb-small" id="cb-stage-meaning">
            Monitor stays fixed. Opening the Stage Door changes the R's depth, not its height. The separate road appointment follows the 45° source bearing.
          </p>
        </div><aside class="cb-inspector" data-selected={@selected.id} data-visibility={@visibility}>
          <p class="cb-eyebrow">SELECTED MATERIAL / {@visibility}</p><h2 id="cb-selected-name">
            {@selected.name}
          </h2><p>{@selected.office}</p>
          <div class="cb-state-line">
            <span>{@selected.status |> to_string() |> String.upcase()}</span><span id="cb-acquisition">Acquired: false · delta ZERO</span>
          </div>
          <p :if={@selected.yellow != []} class="cb-yellow">
            YELLOW: {Enum.map_join(@selected.yellow, ", ", &to_string/1)}
          </p>
          <div class="cb-buttons">
            <button
              id="cb-isolate"
              phx-click="co-building-action"
              phx-value-action="isolate"
              phx-value-revision={@state.revision}
            >Isolate selected</button><button
              id="cb-reveal"
              phx-click="co-building-action"
              phx-value-action="reveal"
              phx-value-revision={@state.revision}
            >Reveal apparatus</button>
          </div>
          <details id="cb-inscription">
            <summary>Source, plane, finite material and inheritance</summary><pre id="cb-inscription-record">{inspect(inscription(@selected),pretty: true,limit: :infinity)}</pre>
            <p>
              Visibility is a centre-ray / face-normal diagnostic; full optical and partial-occlusion calibration remains YELLOW.
            </p>
          </details>
          <div class="cb-checks">
            <h3>Measured reference interfaces</h3><p>
              Wedge miter interference:
              <strong>{to_string(@model.clearance.wedge_miter_interference)}</strong>
            </p><p>
              Registered finite miter contact area: {Float.round(
                @model.clearance.wedge_miter_contact_area,
                6
              )}.
            </p><p>
              Wedges / ZERO cylinder interference:
              <strong>{to_string(@model.clearance.wedge_to_cylinder)}</strong>
            </p><p>
              Leverage / bore interference:
              <strong>{to_string(@model.clearance.zero_leverage_to_bore)}</strong>
            </p><p>
              Square axle / bearing radial margin: {Float.round(
                @model.clearance.axle_radial_margin,
                4
              )}
            </p><p>Table and bearing radial contact: ZERO gap; securing is YELLOW.</p><p
              :if={@model.clearance.door_to_prospective_road}
              class="cb-yellow"
            >
              Door rehearsal intersects prospective road. This is not an accepted material join.
            </p>
            <p
              :if={@model.clearance.wedge_trial_interference}
              id="cb-fold-collision"
              class="cb-yellow"
            >
              Wedge B's trial swing intersects Wedge A. The reference fit is retained; this is not an accepted physical fold.
            </p>
          </div>
        </aside>
      </div>
      <section id="cb-double-passage" class="cb-details">
        <h2>One Gallery Door · outward and return · prospective four-point furnishing</h2>
        <button
          id="cb-double_passage"
          phx-click="co-building-action"
          phx-value-action="double_passage"
          phx-value-revision={@state.revision}
        >Inspect both passages and measured incidence</button>
        <p>
          OUTWARD (blue): BY WAY OF Gallery, THROUGH INTO Situationing Stage TOWARD STANDING FOR STAGING. RETURN (copper): FROM STAGING FOR STANDING, AROUND ABOUT the Seat, THROUGH the same Gallery Door TOWARD STANDING FOR STAGING.
        </p>
        <p id="cb-double-incidence" class="cb-yellow">
          Measured finite boundary points inside the Gallery opening: {@model.double_passage.quadranglementing.measured_count}. Four-point incidence UNPROVED; no four coordinates are appointed from the projected crossing.
        </p>
        <p id="cb-double-sightline">
          New String / central sightline corridor interference: {to_string(
            @model.double_passage.sightline.course_interference
          )}. Gallery frame interference: {to_string(
            @model.double_clearance.gallery_frame_interference
          )}. Stable aperture interference: {to_string(
            @model.double_clearance.stable_aperture_interference
          )}. Whole-apparatus optics and material clearance remain YELLOW.
        </p>
        <p>
          Return passage, subsequent twist (unfurnished), flat PINNING and PITTONING conversion (unperformed) remain distinct. Final Semantical In-Stringing-Menting appointment is absent. No next Footing or consequential RE-STEP is acquired.
        </p>
      </section>
      <section id="cb-three-four" class="cb-details" aria-label="THREE TO FOUR working reservation">
        <h2>THREE TO FOUR · fashioning and refashioning</h2>
        <p>
          Offset ceiling and current Tunnel references remain prospective. Preserve the previous wedge, stable aperture and inherited standing while trying material. Neither incidence nor lawful passage is established.
        </p>
        <div class="cb-buttons">
          <button
            :for={
              {action, label} <- [
                {"three_four", "Inspect offset and candidate wedge"},
                {"passage_appointment", "Propose / withdraw conditional appointment"},
                {"interpolation_projection", "Project / restore same material"}
              ]
            }
            id={"cb-#{action}"}
            phx-click="co-building-action"
            phx-value-action={action}
            phx-value-revision={@state.revision}
          >{label}</button>
        </div>
        <p id="cb-interpolation-status">
          Material bend: {@state.interpolation}. Appointment: {@model.three_four.appointment.status}. Projection only: {to_string(
            @state.interpolation_projection?
          )}. Physical join: false. Acquired next Footing: absent.
        </p>
        <p id="cb-offset-basis">
          Offset (current Tunnel TOWARD prospective ceiling): {inspect(
            @model.three_four.offset.vector
          )} trial extents; circuit separation {@model.three_four.offset.parameter_separation_degrees}°. Radial arc registration is a candidate; gaps remain YELLOW.
        </p>
        <p id="cb-interpolation-clearance">
          Named-pair material interference: aperture {to_string(
            @model.interpolation_clearance.aperture_interference
          )}, previous wedge {to_string(@model.interpolation_clearance.previous_wedge_interference)}, inherited material {to_string(
            @model.interpolation_clearance.inherited_material_interference
          )}. Whole occupied-passage clearance remains YELLOW.
        </p>
        <ol id="cb-circuit-encounters">
          <li
            :for={event <- @model.three_four.circuit.events}
            id={"cb-encounter-#{event.reference}"}
            data-parameter={event.parameter_degrees}
            data-reached={to_string(event.reached)}
          >
            {event.reference} · {event.parameter_degrees}° · reference gap {event.reference_gap} · {if event.reached,
              do: "encountered in reference sweep",
              else: "ahead"}; physical passage unproved
          </li>
        </ol>
        <p class="cb-yellow">
          Ceiling precedes current Tunnel in the increasing reference circuit from 0°. This is a reference encounter witness, not COB Traversaling. Opening, closing, occupied clearance and arc mounting remain YELLOW.
        </p>
      </section>
      <section class="cb-controls" aria-label="Working rehearsals">
        <div>
          <h2>Regard, park, return</h2><.form
            for={@form}
            id="cb-settings"
            phx-change="co-building-setting"
          >
            <.input field={@form[:revision]} type="hidden" />
            <.input
              field={@form[:view]}
              id="cb-view"
              type="select"
              label="Regarding"
              options={Enum.map(C.views(), &{view_name(&1), &1})}
            />
            <.input
              field={@form[:yaw]}
              id="cb-yaw"
              type="range"
              label={"Regarding pivot #{@state.yaw}°"}
              min="0"
              max="360"
              step="0.5"
            />
            <.input
              field={@form[:door]}
              id="cb-door"
              type="range"
              label={"Stage Door swing #{@state.door}° · material rehearsal"}
              min="0"
              max="90"
              step="0.5"
            />
            <.input
              field={@form[:wedge]}
              id="cb-wedge"
              type="range"
              label={"Wedge B trial swing #{@state.wedge}° · inspect interference"}
              min="0"
              max="90"
              step="0.5"
            />
            <.input
              field={@form[:interpolation]}
              id="cb-interpolation"
              type="range"
              label="THREE TO FOUR candidate curvature · material refashioning only"
              min="0"
              max="1"
              step="0.05"
            />
            <.input
              field={@form[:layer]}
              id="cb-layer"
              type="select"
              label="Construction layer (later evidence is retained)"
              options={[
                {"ZERO / square / cylinder", 0},
                {"Structural metal / Seat / pivots", 1},
                {"Segmentationing wedge planes", 2},
                {"JANUSITE metal piping", 3},
                {"Three material offices / R", 4},
                {"Prospective return / next local extent", 5}
              ]}
            />
            <.input
              field={@form[:circuit]}
              id="cb-circuit"
              type="range"
              label="Gallery inspection cursor · not COB Traversaling"
              min="0"
              max="360"
              step="1"
            />
          </.form>
          <div class="cb-buttons">
            <button
              :for={
                {action, label} <- [
                  {"park_view", "Park Regarding"},
                  {"restore_view", "Return Regarding"},
                  {"park_door", "Park Door"},
                  {"restore_door", "Return Door"}
                ]
              }
              id={"cb-#{action}"}
              phx-click="co-building-action"
              phx-value-action={action}
              phx-value-revision={@state.revision}
            >{label}</button>
          </div>
          <p class="cb-small">
            {@camera.meaning}. Ground-side and Field-side keep distinct source identities on the shared Y=0 plane.
          </p>
        </div>
        <div>
          <h2>One R · three material offices</h2><.form
            for={@trace_form}
            id="cb-trace-form"
            phx-submit="co-building-trace"
          >
            <.input field={@trace_form[:revision]} type="hidden" /><.input
              field={@trace_form[:text]}
              id="cb-input-R"
              label="Ordinary input through the opening Slate (bounded specimen: R)"
              maxlength="1"
            /><button id="cb-trace">Trace R upon the Glass</button>
          </.form>
          <div class="cb-buttons">
            <button
              id="cb-R-flat"
              phx-click="co-building-action"
              phx-value-action="r_pose"
              phx-value-choice="flat"
              phx-value-revision={@state.revision}
            >R on source / Stage Door</button><button
              id="cb-R-road"
              phx-click="co-building-action"
              phx-value-action="r_pose"
              phx-value-choice="road"
              phx-value-revision={@state.revision}
            >Rehearse R TOWARD 45° road</button><button
              id="cb-stitch"
              phx-click="co-building-action"
              phx-value-action="stitch"
              phx-value-revision={@state.revision}
            >Doll's two-Toe stitching rehearsal</button>
          </div>
          <p id="cb-letter-status">
            One source: specimen:R:1 · tracing {inspect(@state.traced?)} · actual stitching false. The Doll, Quilling Stitching Needle, Inkwelling and Never-Ending Stringing Thing keep separate offices.
          </p>
          <p class="cb-yellow">
            STANDING FOR STAGING is an inherited-reference fixture without an attested Landinging. Its presence does not confer FROM DOWN UNDER acquisition on new staging.
          </p>
          <button
            id="cb-M-projection"
            phx-click="co-building-action"
            phx-value-action="m_projection"
            phx-value-revision={@state.revision}
          >Inspect same M DOWN / projected UP FROM DOWN UNDER</button>
        </div>
      </section>
      <details id="cb-overlays" class="cb-details">
        <summary>Working overlays · hide, reveal and isolate</summary><div class="cb-buttons">
          <button
            id="cb-bare-metal"
            phx-click="co-building-action"
            phx-value-action="bare"
            phx-value-revision={@state.revision}
          >Bare structural metal</button><button
            :for={g <- C.groups()}
            id={"cb-toggle-#{g}"}
            phx-click="co-building-action"
            phx-value-action="toggle"
            phx-value-choice={g}
            phx-value-revision={@state.revision}
            aria-pressed={to_string(@state.layers[g])}
          >{group_name(g)}</button>
        </div>
      </details>
      <details id="cb-listing" class="cb-details">
        <summary>THIS ONE DISCRETE TURN — MATERIAL LISTING OF LISTINGS</summary><p>
          Preview turn {@model.turn_id}; {@model.contract}. REFERENCE / READY / REHEARSAL / PROSPECTIVE / ACQUIRED / YELLOW are distinct. No part in this scope is ACQUIRED.
        </p>
        <details id="cb-yt-reservation" class="cb-details">
          <summary>
            RESERVED · YT TOWARD YT Stringing / Ground-side–Field-side correspondence · YELLOW
          </summary>
          <p>
            The Human may appoint the Seat's square axle TOWARD a Groundward reference and, within the current Discrete Turn, Pretend to draw a source-addressed YT TOWARD YT String OUT OF the monitor, AROUND ABOUT through the JANUSITE course.
          </p>
          <p>
            Keep distinct registrations for the Groundward object, its Field-side standing, the Human-appointed axle reference and the String course. Sharing a reference plane does not merge their identities.
          </p>
          <p>
            Reserved for later THREE-to-FOUR inspection. No object, target, String course or correspondence is appointed here. Geometrical implementation remains YELLOW; no physical detection, material transportation or consequential RE-STEP follows from appointment.
          </p>
        </details>
        <div class="cb-list">
          <button
            :for={p <- @model.parts}
            id={"cb-inspect-"<>String.replace(p.id,":","-")}
            phx-click="co-building-action"
            phx-value-action="select"
            phx-value-choice={p.id}
            phx-value-revision={@state.revision}
            data-material-id={p.source_id}
          ><span>{p.name}</span><small>{p.status} · {p.material} · {p.office}</small></button>
        </div>
        <pre>{inspect(%{frame: @model.frame,inherited: @model.inherited,material_sources: @model.material_sources,pending: @model.pending,acquisition: @model.acquisition,readiness: @model.readiness},pretty: true,limit: :infinity)}</pre>
      </details>
      <details id="cb-regarding-inheritance" class="cb-details">
        <summary>Regarding inheritance / rehearsal trace</summary><p>
          Earlier source geometry remains available when overlays are hidden. Returning a view does not erase evidence. This session trace is not an acquired-standing or DIRT ledger.
        </p><pre>{inspect(@state.trace,pretty: true,limit: :infinity)}</pre>
      </details>
      <p class="cb-footer">
        Ready for EN-FURNISHING-MENTING inspection. Finite reference geometry is registered; manufacture, securing, feeds, return twist and lawful material interfaces remain YELLOW. No consequential RE-STEP, next Footing or actual COB Traversaling has occurred.
      </p>
      <a class="cb-legacy-link" href="#crossing-rehearsal">Retained paired-aperture rehearsal ↓</a>
    </section>
    """
  end

  defp xy(p, s, i), do: C.project(p, s) |> Enum.at(i)

  defp inscription(p),
    do:
      p
      |> Map.drop([:geometry, :source_geometry, :vertices, :face_normals, :display_geometry])
      |> Map.merge(%{
        occupied_vertices: length(p.geometry.vertices),
        faces: length(p.geometry.faces),
        sample_vertices: Enum.take(p.geometry.vertices, 12),
        sample_normals: Enum.take(p.face_normals, 6),
        registered_center:
          if(p.geometry.vertices == [], do: nil, else: G.centroid(p.geometry.vertices))
      })

  defp view_name(v),
    do:
      %{
        "flat" => "Flat Presentationing",
        "gallery-close" => "Gallery plane / finite incidence close-up",
        "side" => "Side / elevation",
        "plan" => "Plan",
        "transverse" => "Transverse to bearing",
        "oblique" => "Oblique assembly",
        "half" => "Half / retained source",
        "tunneling" => "Tunneling FROM Seat",
        "tunneling-under" => "Tunneling DOWN beneath Seat",
        "groundside" => "Ground-side",
        "fieldside" => "Field-side reciprocal"
      }[v]

  defp group_name(g),
    do:
      %{
        "references" => "Reference planes / SIX",
        "metal" => "Structural metal",
        "aperture" => "ZERO square / circle / cylinder",
        "wedges" => "Segmentationing wedge planes",
        "pipes" => "JANUSITE metal pipes",
        "sources" => "Material sources / Needle",
        "office-trace" => "STAGING FOR STAGING",
        "office-road" => "STAGING FOR STANDING",
        "office-standing" => "STANDING FOR STAGING",
        "return" => "Prospective return / next fold",
        "guides" => "Projectioning guides",
        "under-curve" => "Groundward undercurve",
        "gallery-through" => "THROUGH Gallery",
        "gallery-departure" => "45° departure",
        "upper-loop" => "Upper XT TOWARD YT loop",
        "around-course" => "AROUND ABOUT course",
        "next-flat" => "Next FLAT PINNING",
        "subsequent-up" => "Subsequent material toward PITTONING",
        "interpolation-material" => "THREE TO FOUR candidate material",
        "offset-references" => "Offset reference arc / ceiling / Tunnel",
        "conditional-appointment" => "Conditional passage proposal",
        "double-material" => "YT String outward / AROUND / return",
        "double-incidence" => "Measured double-passage incidence / four-point YELLOW"
      }[g]
end
