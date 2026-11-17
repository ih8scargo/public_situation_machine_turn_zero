defmodule PublicSituationMachineTurnZeroWeb.JanusiteInheritancePanel do
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Workshop.JanusiteInheritance, as: J
  attr :state, :map, required: true
  attr :revision, :integer, required: true

  def panel(assigns) do
    assigns =
      assign(assigns,
        model: J.model(assigns.state),
        cursor:
          [J.model(assigns.state).inheritance.two_cursor]
          |> J.project(assigns.state.view)
          |> String.split(",")
          |> Enum.map(&coordinate/1),
        form:
          to_form(%{"text" => assigns.state.text, "revision" => assigns.revision}, as: :janusite)
      )

    ~H"""
    <section
      id="janusite-inheritance"
      class="as-bench"
      data-source={@model.id}
      data-view={@state.view}
      data-mode={@state.mode}
      data-index="0"
    >
      <h3>JANUSITE · one source · ONE TOWARD TWO</h3><p>
        Candidate material-addressed inspection. No constitutional operations or acquisition.
      </p>
      <div class="as-controls">
        <button
          :for={mode <- ~w(A B C)}
          id={"ji-mode-#{mode}"}
          aria-pressed={to_string(@state.mode == mode)}
          phx-click="janusite-inspect"
          phx-value-kind="mode"
          phx-value-choice={mode}
          phx-value-revision={@revision}
        >{mode}: {case mode do
          "A" -> "Road / letters"
          "B" -> "Shared curve / Table"
          _ -> "ONE-to-TWO inheritance"
        end}</button>
        <button
          :for={view <- ~w(flat longhouse tunneling)}
          id={"ji-view-#{view}"}
          aria-pressed={to_string(@state.view == view)}
          phx-click="janusite-inspect"
          phx-value-kind="view"
          phx-value-choice={view}
          phx-value-revision={@revision}
        >{view}</button>
        <button
          :for={footing <- ~w(one two)}
          id={"ji-footing-#{footing}"}
          aria-pressed={to_string(@state.footing == footing)}
          phx-click="janusite-inspect"
          phx-value-kind="footing"
          phx-value-choice={footing}
          phx-value-revision={@revision}
        >Footing {footing}</button>
        <button
          :for={
            {key, label} <- [
              {"stitches", "Two Toe stitches"},
              {"loops", "Upper guiding loop"},
              {"fixture", "Hypothetical Landinging fixture"}
            ]
          }
          id={"ji-toggle-#{key}"}
          phx-click="janusite-inspect"
          phx-value-kind="toggle"
          phx-value-choice={key}
          phx-value-revision={@revision}
        >{label}</button>
      </div>
      <.form for={@form} id="ji-author-form" phx-submit="janusite-author">
        <.input field={@form[:revision]} type="hidden" /><.input
          field={@form[:text]}
          label="LEFT-TO-RIGHT authored String (1–12 uppercase letters)"
          maxlength="12"
        /><button id="ji-author">Furnish candidate specimen</button>
      </.form>
      <p id="ji-measures">
        TOP-TO-BOTTOM candidate extent {@model.road.top_to_bottom}; authored length {@model.road.length}. Conversion to manufactured road remains unproved; THREE is not this measure.
      </p>
      <p id="ji-mode-explanation">
        {case @state.mode do
          "A" ->
            "Finite road, individual wedges, exactly two Toe registrations and separate guide loops."

          "B" ->
            "One source line for road and COB; Table exchange link is unproved, not a camera repair."

          _ ->
            "ONE returns toward the central aperture. TWO cursor marks WHERE only; no actual Landinging or next finite material."
        end}
      </p>
      <p :if={@state.footing == "two"}>
        Inherited ONE stays visible for comparison. TWO has a cursor/reference only, not new finite material.
      </p>
      <svg
        id="ji-scene"
        viewBox={view_box(@model, @state)}
        role="img"
        aria-label="Source-bearing finite road and letter wedges, two Toe registrations and guide loops"
      >
        <polygon
          :for={face <- @model.cob_course.profile.faces}
          :if={@state.mode == "B" && @state.view != "flat"}
          points={J.project(face, @state.view)}
          fill="#427a81"
          fill-opacity="0.6"
          stroke="#315e64"
        >
          <title>Diagnostic COB envelope intersects road; actual Craft and clearance unproved</title>
        </polygon>
        <polygon
          :for={face <- @model.fold_trial.faces}
          :if={@state.mode == "C" && @state.view != "flat"}
          points={J.project(face, @state.view)}
          fill="#ad8961"
          fill-opacity="0.45"
          stroke="#896e50"
        >
          <title>
            Source HERE unit wedge, explicit candidate 45° material rotation; not a camera fold or proved TWO join
          </title>
        </polygon>
        <polyline
          :if={@state.mode == "C" && @state.view != "flat"}
          points={
            J.project(
              PublicSituationMachineTurnZero.Workshop.AlongsideStaging.aperture().points,
              @state.view
            )
          }
          fill="none"
          stroke="#36899a"
        >
          <title>Registered central aperture; gathering/next floor joining blocked</title>
        </polyline>
        <polyline
          :if={@state.loops? && @state.view != "flat"}
          points={J.project(@model.guide_rail, @state.view)}
          fill="none"
          stroke="#86649a"
        >
          <title>Upper guide from same indexed curve, distinct from road and Craft</title>
        </polyline>
        <g
          id="ji-source-world"
          data-world={Jason.encode!(@model.source_line.points)}
          data-source-line={@model.source_line.id}
        >
          <polygon
            :for={
              face <-
                if(@state.view == "flat", do: [], else: Enum.flat_map(@model.road.cells, & &1.faces))
            }
            points={J.project(face, @state.view)}
            fill="#bb975a"
            fill-opacity="0.35"
            stroke="#ac8950"
            stroke-width="0.4"
          />
          <rect
            :if={@state.view == "flat"}
            x="70"
            y="300"
            width={@model.road.length * 30}
            height="30"
            fill="#d7bd84"
            stroke="#9c7c42"
          >
            <title>Flat road: same addressed stock; constant top-to-bottom ONE candidate unit</title>
          </rect>
          <line
            :if={@state.loops? && @state.view == "flat"}
            x1="70"
            x2={70 + @model.road.length * 30}
            y1="292.5"
            y2="292.5"
            stroke="#86649a"
          >
            <title>Addressed straight incoming guide; physical curved transfer unproved</title>
          </line>
          <polyline
            :if={@state.view != "flat"}
            points={J.project(@model.cob_course.points, @state.view)}
            fill="none"
            stroke="#427a81"
            stroke-dasharray="3 3"
          >
            <title>COB diagnostic course: EXACT same source line; occupied placement unproved</title>
          </polyline>
          <g
            :for={{letter, i} <- Enum.with_index(@model.letters)}
            id={"ji-letter-#{i}"}
            data-letter-id={letter.id}
            data-toes="2"
            data-loop-stitch="false"
          >
            <polygon
              :for={face <- if(@state.view == "flat", do: [], else: letter.wedge.faces)}
              points={J.project(face, @state.view)}
              fill="#759987"
              fill-opacity="0.5"
              stroke="#547d69"
            />
            <polygon
              :if={@state.view == "flat"}
              points={"#{70+(i+0.2)*@model.road.length*30/length(@model.letters)},330 #{70+(i+0.8)*@model.road.length*30/length(@model.letters)},330 #{70+(i+0.5)*@model.road.length*30/length(@model.letters)},304.5"}
              fill="#88a88c"
            />
            <ellipse
              :if={@state.loops? && @state.view == "flat"}
              cx={70 + (i + 0.5) * @model.road.length * 30 / length(@model.letters)}
              cy="292.5"
              rx="2.4"
              ry="2.4"
              fill="none"
              stroke="#86649a"
            >
              <title>Upper guiding loop, not a third stitch</title>
            </ellipse>
            <text
              :if={@state.view == "flat"}
              x={70 + (i + 0.4) * @model.road.length * 30 / length(@model.letters)}
              y="320"
              font-size="14"
            >
              {letter.letter}
            </text>
            <polyline
              :if={@state.loops? && @state.view != "flat"}
              points={J.project(letter.loop.points, @state.view)}
              fill="none"
              stroke="#86649a"
              stroke-width="2"
            >
              <title>Distinct overhead guide loop; not a stitch</title>
            </polyline>
            <polygon
              :for={face <- Enum.flat_map(letter.loop.occupied_profile, & &1.faces)}
              :if={@state.loops? && @state.view != "flat"}
              points={J.project(face, @state.view)}
              fill="#86649a"
              fill-opacity="0.4"
            >
              <title>Finite candidate guiding-loop profile; no third stitch</title>
            </polygon>
            <circle
              :for={{toe, j} <- Enum.with_index(letter.toes)}
              :if={@state.stitches? && @state.view == "flat"}
              cx={70 + (i + 0.2 + j * 0.6) * @model.road.length * 30 / length(@model.letters)}
              cy="330"
              r="3"
              fill="#a95b50"
            >
              <title>{toe.id} Toe stitching registration</title>
            </circle>
            <polygon
              :for={face <- Enum.flat_map(letter.toes, & &1.solid.faces)}
              :if={@state.stitches? && @state.view != "flat"}
              points={J.project(face, @state.view)}
              fill="#a95b50"
              stroke="#a95b50"
            >
              <title>Finite Toe registration; candidate attachment</title>
            </polygon>
          </g>
        </g>
        <polyline
          :if={@state.mode in ~w(B C) && @state.view != "flat"}
          points={
            J.project([@model.table.point, @model.inheritance.returning_string.endpoint], @state.view)
          }
          fill="none"
          stroke="#bf756b"
          stroke-dasharray="5 5"
        >
          <title>Table exchange BLOCKED: reference link, no material joining proved</title>
        </polyline>
        <circle
          :if={@state.mode in ~w(B C) && @state.view != "flat"}
          cx={Enum.at(project_point(@model.table.point, @state.view), 0)}
          cy={Enum.at(project_point(@model.table.point, @state.view), 1)}
          r="2"
          fill="#bf756b"
        >
          <title>Table THREE reference; material exchange blocked</title>
        </circle>
        <circle
          :if={@state.mode == "C"}
          id="ji-two-cursor"
          cx={Enum.at(@cursor, 0)}
          cy={Enum.at(@cursor, 1)}
          r="6"
          fill="none"
          stroke="#c56b44"
          stroke-dasharray="3 2"
        >
          <title>WHERE only; not new material length or actual Landinging</title>
        </circle>
      </svg>
      <p id="ji-origin">
        Footing {@state.footing}: next origin {inspect(@model.inheritance.next_xt_origin)}. No actual Landinging. Next material points: [].
      </p>
      <p id="ji-fit" class="mr-notice">
        Preserved failed SIX-height witness: {inspect(@model.preserved_fit)}. Table exchange and occupied joining BLOCKED; no shrinking, new frame or acquisition.
      </p>
      <div class="as-ledgers">
        <section>
          <h4>Letter/source registrations</h4><p>
            Head {hd(@model.letters).letter}; Tail {List.last(@model.letters).letter}. Individual carriages are not the Traversaling Craft.
          </p><pre>{inspect(Enum.map(@model.letters, fn l -> %{id: l.id, letter: l.letter, address: l.address, tangent: l.carriage.tangent, toes: Enum.map(l.toes, &Map.take(&1, [:id, :point, :address])), loop: %{id: l.loop.id, stitch: false}, wedge_thickness: l.wedge.thickness} end),pretty: true,limit: :infinity)}</pre>
        </section><section>
          <h4>ONE-to-TWO material ledger</h4><pre>{inspect(@model.inheritance,pretty: true)}</pre><pre>{inspect(@model.clearance,pretty: true)}</pre><pre>{inspect(@model.table,pretty: true)}</pre><p>
            Opening/closing conditions are inspection fixtures only; no IF–THEN evaluator or operational BUTTONING.
          </p>
        </section>
      </div>
    </section>
    """
  end

  defp view_box(model, %{view: "flat"}),
    do: "40 270 #{max(350, model.road.length * 30 + 60)} 90"

  defp view_box(model, state) do
    points = model.source_line.points ++ model.guide_rail
    points = if state.mode in ~w(B C), do: points ++ [model.table.point], else: points
    points = if state.mode == "C", do: points ++ model.fold_trial.vertices, else: points

    projected =
      points
      |> J.project(state.view)
      |> String.split(" ")
      |> Enum.map(fn pair -> pair |> String.split(",") |> Enum.map(&coordinate/1) end)

    xs = Enum.map(projected, &Enum.at(&1, 0))
    ys = Enum.map(projected, &Enum.at(&1, 1))

    "#{Enum.min(xs) - 25} #{Enum.min(ys) - 25} #{max(100, Enum.max(xs) - Enum.min(xs) + 50)} #{max(100, Enum.max(ys) - Enum.min(ys) + 50)}"
  end

  defp coordinate(value) do
    {number, ""} = Float.parse(value)
    number
  end

  defp project_point(point, view),
    do: [point] |> J.project(view) |> String.split(",") |> Enum.map(&coordinate/1)
end
