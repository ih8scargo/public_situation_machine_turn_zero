defmodule PublicSituationMachineTurnZeroWeb.RoomToyBoxPanel do
  use PublicSituationMachineTurnZeroWeb, :html

  alias PublicSituationMachineTurnZero.Workshop.{
    RoomFromHere,
    CoBuilding,
    TupleExcursionInheritance
  }

  alias RoomFromHere, as: T
  attr :state, :map, required: true
  attr :standing_digest, :string, required: true

  def panel(assigns) do
    m = T.model(assigns.state)
    selected = Enum.find(m.pieces, &(&1.id == assigns.state.selected)) || hd(m.pieces)

    assigns =
      assign(assigns,
        model: m,
        tuple_inheritance: TupleExcursionInheritance.model(m),
        camera: T.camera(assigns.state, m),
        faces: T.faces(m, assigns.state),
        labels: T.labels(m, assigns.state),
        selected: selected,
        source_digest: CoBuilding.digest(Enum.map(m.pieces, &[&1.id, &1.content_hash])),
        form:
          to_form(
            %{
              "revision" => assigns.state.revision,
              "travel" => assigns.state.travel,
              "door" => assigns.state.door,
              "opening" => assigns.state.opening,
              "close" => assigns.state.close,
              "orbit" => assigns.state.orbit,
              "turn" =>
                if(assigns.state.pivot == "table",
                  do: assigns.state.table_angle,
                  else: assigns.state.seat_angle
                ),
              "seam" => assigns.state.seam
            },
            as: :toy
          )
      )

    ~H"""
    <section
      id="room-toy-box"
      class="rtb"
      data-revision={@state.revision}
      data-source-digest={@source_digest}
      data-standing-digest={@standing_digest}
      data-acquired-delta="0"
      data-view={@state.view}
      data-movement={@state.movement}
      data-contract={@model.contract}
      data-doorway-contract={@model.doorway.contract}
      data-slice-phase={@state.opening_projection.phase}
      data-slice-index={@state.opening_projection.index}
      data-slice-active={to_string(@state.opening_projection.active)}
      data-doorway-phase={@state.doorway.phase}
      data-doorway-index={@state.doorway.index}
      data-seam={@state.seam}
      data-active-pivot={@state.pivot}
    >
      <header class="rtb-heading">
        <div>
          <p class="rtb-eyebrow">PUBLIC-SITUATION-MACHINE- / CONSTITUTIONAL ROOM TOY BOX</p><h1>
            ROOM, furnished FROM HERE
          </h1>
          <p>
            Fixed Seat ONE · square axle FROM DOWN UNDER · ZERO TO ONE retained through every rehearsal
          </p>
        </div>
        <span class="rtb-status">PROSPECTIVE MATERIAL · acquisition ZERO</span>
      </header>
      <nav class="rtb-controls" aria-label="Construction movements">
        <button
          :for={
            {id, label} <- [
              {"room", "1 · ROOM & axle"},
              {"wedging", "2 · Shared wedging & U"},
              {"pinning", "3 · Three PINNING rehearsals"},
              {"stands", "4 · Standing / Regarding Stands"}
            ]
          }
          id={"rtb-movement-"<>id}
          phx-click="room-toy-action"
          phx-value-action="movement"
          phx-value-choice={id}
          phx-value-revision={@state.revision}
          aria-pressed={to_string(@state.movement == id)}
        >{label}</button>
      </nav>
      <nav class="rtb-controls rtb-views" aria-label="Regardings of one material source">
        <button
          :for={
            {id, label} <- [
              {"flat", "Flat"},
              {"left", "Left / intermediate"},
              {"right", "Right / intermediate"},
              {"oblique", "Oblique"},
              {"two", "TWO · from Seat"},
              {"five", "FIVE → FOUR → THREE"},
              {"ground", "Ground-side"},
              {"field", "Field-side"},
              {"fore", "Seam · Foreview"},
              {"aft", "Seam · Aft view"},
              {"surface", "Selected surface"}
            ]
          }
          id={"rtb-view-"<>id}
          phx-click="room-toy-action"
          phx-value-action="view"
          phx-value-choice={id}
          phx-value-revision={@state.revision}
          aria-pressed={to_string(@state.view == id)}
        >{label}</button>
      </nav>
      <p :if={@state.notice} id="rtb-notice" class="rtb-yellow" role="status">{@state.notice}</p>
      <div class="rtb-workspace">
        <div class="rtb-drawing rfh-aperture">
          <div class="rfh-corner rfh-nw">
            <details id="rfh-corner-source">
              <summary>XT · FROM HERE</summary><p>
                ZERO → ONE → TWO → THREE<br />Seated relation; source material remains distinct.
              </p>
            </details>
          </div>
          <div class="rfh-corner rfh-ne">
            <details id="rfh-corner-bearing">
              <summary>YT · THROUGH</summary><p>
                [6,6,6] body-bearing<br />35.264390° elevation · Flat 45°
              </p>
            </details>
          </div>
          <div class="rfh-corner rfh-sw">
            <details id="rfh-corner-return">
              <summary>XT · AROUND ABOUT</summary><p>
                One M · UNDER return<br />Source room-ribbon:1/M
              </p>
            </details>
          </div>
          <div class="rfh-corner rfh-se">
            <details id="rfh-corner-standing">
              <summary>YT · INHERITANCE</summary><p>
                EIGHT sectors · SIX cube<br />Prospective standing · acquisition ZERO
              </p>
            </details>
          </div>
          <svg
            id="rtb-scene"
            viewBox="0 0 840 840"
            role="group"
            aria-label="One square appliance aperture; source-identical Flat and CUBICAL Diorama"
          >
            <defs>
              <clipPath id="rfh-cutout">
                <rect
                  x={120 * (1 - @state.opening)}
                  y={200 * (1 - @state.opening)}
                  width={840 - 240 * (1 - @state.opening)}
                  height={840 - 400 * (1 - @state.opening)}
                  rx="12"
                />
              </clipPath>
            </defs>
            <g clip-path="url(#rfh-cutout)">
              <polygon
                :for={f <- @faces}
                points={f.points}
                data-piece={f.id}
                class={["rtb-face", f.id == @state.selected && "rtb-selected"]}
                phx-click="room-toy-action"
                phx-value-action="select"
                phx-value-choice={f.id}
                phx-value-revision={@state.revision}
              >
                <title>{f.id} · finite source-addressed material</title>
              </polygon>
              <g
                :for={p <- @model.pieces}
                :if={T.visible?(p, @state)}
                id={"rtb-source-"<>String.replace(p.id,":","-")}
                data-source-id={p.source_identity}
                data-source-hash={p.content_hash}
              >
                <polyline
                  :for={line <- p.lines}
                  points={T.points(line, @camera)}
                  class={["rtb-guide", p.id == @state.selected && "rtb-selected"]}
                />
              </g>
              <g :if={@state.opening > 0.01} id="rfh-eight-sector-markers">
                <g
                  :for={{sector, i} <- Enum.with_index(@model.sectors)}
                  data-source-id={sector.source_identity}
                >
                  <circle
                    cx={xy(hd(hd(sector.lines)), @camera, 0)}
                    cy={xy(hd(hd(sector.lines)), @camera, 1)}
                    r="2.5"
                    class="rfh-sector-marker"
                  >
                    <title>{sector.id} · source boundary reference</title>
                  </circle>
                  <text
                    x={xy(Enum.at(hd(sector.lines), 2), @camera, 0)}
                    y={xy(Enum.at(hd(sector.lines), 2), @camera, 1) - 6}
                  >
                    {i + 1}
                  </text>
                </g>
              </g>
              <g
                :if={@model.letter_inspection.active}
                id="same-letter-toe"
                data-source-id={@model.letter_inspection.toe.id}
              >
                <line
                  x1={xy(@model.letter_inspection.toe.world_point, @camera, 0)}
                  y1={xy(@model.letter_inspection.toe.world_point, @camera, 1)}
                  x2={xy(@model.letter_inspection.issuing.target, @camera, 0)}
                  y2={xy(@model.letter_inspection.issuing.target, @camera, 1)}
                  class="rtb-guide"
                >
                  <title>Issuing reference TOWARD back-wall YT; PINNING/PITTONING unaccepted</title>
                </line>
                <circle
                  cx={xy(@model.letter_inspection.toe.world_point, @camera, 0)}
                  cy={xy(@model.letter_inspection.toe.world_point, @camera, 1)}
                  r="4"
                  fill="#bc503a"
                >
                  <title>Original R leading-toe end-cap centroid</title>
                </circle>
                <text
                  x={xy(@model.letter_inspection.toe.world_point, @camera, 0) + 10}
                  y={xy(@model.letter_inspection.toe.world_point, @camera, 1) + 18}
                >
                  R · leading toe / issuing reference
                </text>
              </g>
              <g
                :if={@model.opening_projection.toe.visible}
                id="resolved-letter-toe"
                data-source-id={@model.opening_projection.toe.source.id}
              >
                <circle
                  cx={xy(@model.opening_projection.toe.resolved_point, @camera, 0)}
                  cy={xy(@model.opening_projection.toe.resolved_point, @camera, 1)}
                  r="4"
                  fill="#bc503a"
                >
                  <title>
                    Same original R toe resolved through the bound chart; purchase unaccepted
                  </title>
                </circle>
                <text
                  x={xy(@model.opening_projection.toe.resolved_point, @camera, 0) + 8}
                  y={xy(@model.opening_projection.toe.resolved_point, @camera, 1) + 16}
                >
                  R · same resolved toe
                </text>
              </g>
              <g :if={@state.labels?} id="rfh-material-labels">
                <g :for={{label, i} <- Enum.with_index(@labels)}>
                  <line
                    x1={Enum.at(label.screen, 0)}
                    y1={Enum.at(label.screen, 1)}
                    x2={Enum.at(label.screen, 0) + 18}
                    y2={Enum.at(label.screen, 1) - 12 - rem(i, 3) * 12}
                    class="rtb-guide"
                  />
                  <text
                    x={Enum.at(label.screen, 0) + 18}
                    y={Enum.at(label.screen, 1) - 12 - rem(i, 3) * 12}
                  >
                    {label.name}
                  </text>
                </g>
              </g>
              <g :if={@state.view in ["fore", "aft"]} id="rfh-seam-faces">
                <polygon
                  points={T.points(@model.selected_seam.arriving.face, @camera)}
                  class="rfh-arriving"
                >
                  <title>Arriving finite end face</title>
                </polygon>
                <polygon
                  points={T.points(@model.selected_seam.departing.face, @camera)}
                  class="rfh-departing"
                >
                  <title>Departing finite start face</title>
                </polygon>
              </g>
              <g :for={
                {label, point} <- [
                  {"ZERO", @model.zero},
                  {"ONE · Seat / square axle", @model.one},
                  {"THREE · Table", @model.three}
                ]
              }>
                <text x={xy(point, @camera, 0) + 8} y={xy(point, @camera, 1) - 8}>{label}</text>
              </g>
              <g :for={stand <- @model.stands} :if={@state.movement == "stands"}>
                <text x={xy(stand.point, @camera, 0) + 8} y={xy(stand.point, @camera, 1) - 8}>
                  {stand.id} · {stand.kind}
                </text>
              </g>
            </g>
          </svg>
          <p class="rfh-caption">
            Solid faces: finite registered stock. Dashed: reference / unproved correspondence. No reference overlay is an acquired ROOM.
          </p>
        </div>
        <details
          class="rtb-inspector"
          id="rtb-inspector"
          data-selected={@selected.id}
          open={@state.selected != "room:volume"}
        >
          <summary>Selected material · {@selected.name}</summary>
          <p class="rtb-eyebrow">ONE SOURCE / ONE MATERIAL OFFICE</p><h2 id="rtb-selected-name">
            {@selected.name}
          </h2><p>{@selected.material_office}</p>
          <p class="rtb-status">{@selected.status} · {@selected.source_identity}</p>
          <p :if={@selected.yellow != []} class="rtb-yellow">
            YELLOW: {Enum.map_join(@selected.yellow, ", ", &to_string/1)}
          </p>
          <details id="rtb-selected-ledger">
            <summary>Source, locality, bearing, purchase and inheritance</summary><pre>{inspect(Map.drop(@selected,[:geometry,:source_geometry,:display_geometry]),pretty: true,limit: :infinity)}</pre>
          </details>
          <h3>Tested material, bounded claims</h3>
          <p id="rtb-frame">
            SIX cube: {inspect(@model.frame.minimum)} → {inspect(@model.frame.maximum)}. Seat and Table remain fixed.
          </p>
          <p id="rtb-body-bearing">
            THROUGH bearing: [6, 6, 6] · {Float.round(@model.body_bearing.length, 6)} extents · 35.264390° physical elevation · 45° Flat appearance.
          </p>
          <p id="rtb-axle">
            Axle source cb:square-axle · FROM DOWN UNDER. ZERO TO ONE follows its registered height and fixed Seat, with the inherited ZERO-to-axle offset explicit.
          </p>
          <p id="rtb-clearance">
            Ribbon / square axle interference: {to_string(@model.clearance["cb:square-axle"])}. Seat: {to_string(
              @model.clearance["cb:seat"]
            )}. Aperture: {to_string(@model.clearance["cb:zero"])}. Standing material: {to_string(
              @model.clearance["cb:standing-material"]
            )}.
          </p>
        </details>
      </div>
      <PublicSituationMachineTurnZeroWeb.OpeningSlicePanel.panel
        state={@state}
        model={@model.opening_projection}
      />
      <PublicSituationMachineTurnZeroWeb.LetterTransformPanel.panel
        state={@state}
        record={@model.letter_inspection}
      />
      <PublicSituationMachineTurnZeroWeb.OneCubicalDoorwayPanel.panel
        state={@state}
        model={@model.doorway}
      />
      <PublicSituationMachineTurnZeroWeb.RoomFromHereControls.panel
        state={@state}
        model={@model}
        form={@form}
      />
      <p id="rtb-port-failures" class="rtb-yellow">
        Historical v11/v12 attachment tests report ribbon interference at R-wall: {to_string(
          @model.joining_diagnostics["room:r-wall"]
        )}, inner U: {to_string(@model.joining_diagnostics["room:inner-u"])}, transverse U: {to_string(
          @model.joining_diagnostics["room:within-u"]
        )}. These are unresolved ports, not completed joins or PITTONING purchases.
      </p>
      <section class="rtb-labor" aria-label="Bounded material affordments">
        <div>
          <h2>Appoint three holds in rehearsal</h2><p>
            PINNING appoints a hold. PITTONING purchase, PUFFING and lawful RE-STEP remain distinct and unavailable here.
          </p>
          <div class="rtb-controls">
            <button
              :for={p <- @model.pins}
              id={"rtb-pin-#{p.number}"}
              phx-click="room-toy-action"
              phx-value-action="pin"
              phx-value-choice={p.number}
              phx-value-revision={@state.revision}
            >Rehearse {p.number} · {p.toward}</button>
          </div>
          <p id="rtb-pins">
            Rehearsed: {inspect(@state.pins)}. Second PINNING is registered at THREE; its clear material approach is offset pending an actual centre purchase.
          </p>
        </div>
        <div>
          <h2>One M, from source to returned material</h2><.form
            for={@form}
            id="rtb-settings"
            phx-change="room-toy-setting"
          >
            <.input field={@form[:revision]} type="hidden" />
            <.input
              field={@form[:travel]}
              id="rtb-travel"
              type="range"
              min="0"
              max="1"
              step="0.025"
              label="Pose the same M ALONG THROUGH the continuous material course"
            />
            <.input
              field={@form[:door]}
              id="rtb-door"
              type="range"
              min="0"
              max="90"
              step="0.5"
              label="Pivot the same Situationing Stage Door / unappointed R"
            />
          </.form>
          <button
            id="rtb-projection"
            phx-click="room-toy-action"
            phx-value-action="projection"
            phx-value-revision={@state.revision}
          >Regard M UP / restore material pose</button>
          <p id="rtb-m-status">
            M source room-ribbon:1/M · half twist 180° in 24 finite intervals · same Door outward / return. Tail endpoint is registered DOWN. Projection only: {to_string(
              @state.projection?
            )}.
          </p>
        </div>
      </section>
      <details id="rtb-listing" class="rtb-details">
        <summary>Toy Box · material and control ledger</summary>
        <div class="rtb-list">
          <button
            :for={p <- @model.pieces}
            id={"rtb-inspect-"<>String.replace(p.id,":","-")}
            phx-click="room-toy-action"
            phx-value-action="select"
            phx-value-choice={p.id}
            phx-value-revision={@state.revision}
          >{p.name}<small>{p.material_office} · {p.status}</small></button>
        </div>
        <section id="rtb-tuple-inheritance" aria-labelledby="rtb-tuple-inheritance-title">
          <h3 id="rtb-tuple-inheritance-title">Inherited Tuple material offices</h3>
          <p>
            The RE-STEP Wall at FOUR–FIVE remains a material purchase and calibration reference.
            COB takes purchase THROUGH its Gimbalizing PITON and pushes off FROM the Wall
            TOWARD the Purchase Surface at FIVE. The FIVE Regarding Stand is separately registered.
            SIX retains its return and inherited calibrated-reference offices.
          </p>
          <p class="rtb-yellow" id="rtb-tuple-material-status">
            Toy Box material transforms, PITON fit, occupied excursion clearance and return joining
            remain YELLOW. The SIX arc does not replace the return. Push-off alone is not RE-STEP.
          </p>
          <details
            :for={entry <- @tuple_inheritance.entries}
            id={"rtb-inheritance-" <> String.replace(entry.id, ":", "-")}
            data-source-id={entry.source_identity}
          >
            <summary>{entry.name} · {entry.material_office}</summary>
            <pre>{inspect(entry, pretty: true, limit: :infinity)}</pre>
          </details>
          <h4>FOUR / FIVE / SIX correspondence obligations</h4>
          <pre id="rtb-tuple-correspondences">{inspect(@tuple_inheritance.correspondences, pretty: true, limit: :infinity)}</pre>
        </section>
        <h3>Every primary control has an office</h3><table>
          <thead>
            <tr>
              <th>Control</th><th>Office</th><th>Kind</th>
            </tr>
          </thead><tbody>
            <tr :for={c <- T.controls()}>
              <td>{c.id}</td><td>{c.office}</td><td>{c.kind}</td>
            </tr>
          </tbody>
        </table>
        <h3>Standing Stands and Regarding Stands</h3><pre>{inspect(@model.stands,pretty: true,limit: :infinity)}</pre>
        <h3>Occupied bounds / inherited foundation exceptions</h3><pre>{inspect(@model.containment,pretty: true,limit: :infinity)}</pre>
      </details>
      <details id="rtb-evidence" class="rtb-details">
        <summary>Four movement checkpoints · YELLOW and constitutional boundaries</summary>
        <p id="rtb-yellow">
          Below-Ground foundation is retained outside the Y0..6 ROOM reference. The Stage Door swing envelope is measured separately; opening does not resize ROOM. SIXTH/EIGHTH shell joining, source ink/wall attachment and centre purchase remain unproved. No Airiness law or actual COB traversal is invented.
        </p>
        <pre>{inspect(%{movements: @model.movements,stopped_portions: @model.stopped_portions,clearance: @model.clearance,
    joining_diagnostics: @model.joining_diagnostics,
    port_registration: @model.port_registration,acquisition: @model.acquisition,events: @state.events},pretty: true,limit: :infinity)}</pre>
      </details>
      <footer id="rtb-acquisition">
        Acquisition delta ZERO. No PITTONING, PUFFING, RE-STEP or PENDING UN-BUTTONING is performed by these controls. Historical trials remain below under their original source versions.
      </footer>
    </section>
    """
  end

  defp xy(p, c, i), do: T.project(p, c) |> Enum.at(i)
end
