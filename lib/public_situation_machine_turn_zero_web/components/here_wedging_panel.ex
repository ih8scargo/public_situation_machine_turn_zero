defmodule PublicSituationMachineTurnZeroWeb.HereWedgingPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Workshop.HereWedging, as: H
  attr :state, :map, required: true

  def panel(assigns) do
    assigns = assign(assigns, model: H.model())

    ~H"""
    <section
      id="here-wedging-study"
      class="as-bench"
      data-trial={@state.wedging_trial}
      data-side={@state.wedging_side}
      data-index="0"
    >
      <h3>HERE wedging · ONE · Snail House / SIX</h3>
      <p>
        Required mutual registration. Occupied candidate geometry and missing physical correspondences remain distinct.
      </p>
      <div class="as-controls">
        <button
          :for={trial <- ~w(simple returns)}
          id={"hw-trial-#{trial}"}
          phx-click="explore-command"
          phx-value-kind="wedge-trial"
          phx-value-choice={trial}
          phx-value-revision={@state.revision}
        >{if(trial == "simple",
          do: "Compare XT TO XT wedge",
          else: "Compare inherited/current returns"
        )}</button>
        <button
          :for={side <- ~w(left right)}
          id={"hw-side-#{side}"}
          phx-click="explore-command"
          phx-value-kind="wedge-side"
          phx-value-choice={side}
          phx-value-revision={@state.revision}
        >Regard from {side}</button>
      </div>
      <svg
        id="hw-integrated"
        viewBox="-150 -260 850 950"
        aria-label="Integrated HERE unit wedge, ONE toward THREE, and source Snail registration at SIX"
      >
        <polyline
          :for={edge <- PublicSituationMachineTurnZero.Workshop.GeometryExploration.frame_edges()}
          points={H.project(edge, @state.wedging_side)}
          fill="none"
          stroke="#bac5b5"
          stroke-dasharray="4 3"
        />
        <polyline
          :for={r <- PublicSituationMachineTurnZero.Workshop.GeometryExploration.references()}
          points={
            H.project(
              r.points ++ if(r.kind == :closed, do: [hd(r.points)], else: []),
              @state.wedging_side
            )
          }
          fill="none"
          stroke="#96aa92"
          stroke-width={if(r.id == "pillar", do: "4", else: "1")}
        />
        <g
          id="hw-occupied-wedge"
          data-world={Jason.encode!(@model.wedge.vertices)}
          data-material={@model.wedge.material_id}
        >
          <polygon
            :for={face <- @model.wedge.faces}
            :if={@state.wedging_trial == "simple"}
            points={H.project(face, @state.wedging_side)}
            fill="#c49b58"
            fill-opacity="0.6"
            stroke="#9e7e47"
          />
        </g>
        <polyline
          id="hw-unit"
          points={H.project(@model.unit.points, @state.wedging_side)}
          data-world={Jason.encode!(@model.unit.points)}
          stroke="#286c69"
          stroke-width="4"
        />
        <polyline
          points={H.project(@model.seat_toward_table, @state.wedging_side)}
          fill="none"
          stroke="#3d7d9c"
          stroke-width="3"
        >
          <title>Seated point ONE TOWARD Table THREE</title>
        </polyline>
        <g
          id="hw-snail"
          data-world={Jason.encode!(@model.snail.points)}
          data-source={@model.snail.source}
        >
          <polygon
            :for={face <- @model.snail.faces}
            points={H.project(face, @state.wedging_side)}
            fill="#81729d"
            fill-opacity="0.3"
            stroke="#81729d"
            stroke-width="0.5"
          />
        </g>
        <polyline
          id="hw-six-seam"
          points={H.project(@model.seam.points, @state.wedging_side)}
          fill="none"
          stroke="#bc6e67"
          stroke-dasharray="5 4"
        >
          <title>Required SIX relationship; candidate registration link, no physical seam</title>
        </polyline>
        <text x="-100" y="-225" font-size="13">
          Source Snail scale retained. Above-SIX conflict is visible, not extra extent.
        </text>
        <text x="-100" y="640" font-size="13">
          ZERO → XT TO XT → wedging / ONE → THREE → XT TOWARD YT → source SIX
        </text>
      </svg>
      <p id="hw-status" class="mr-notice">
        {if(@state.wedging_trial == "simple",
          do:
            "Simple occupied XT TO XT wedge trial: Seat ONE is a source vertex. Finite attachment and clearance unproved.",
          else:
            "Return-line trial BLOCKED: previous acquisition not attested, physical source-frame transform missing, current return line unappointed. B is a measure, not an invented return line."
        )}
      </p>
      <p id="hw-snail-fit">
        Snail height range {inspect(@model.snail.height_range)}; fits SIX height: {to_string(
          @model.snail.fits_six_height
        )}. No rescaling to force fit; no Public Field or extra frame.
      </p>
      <details id="hw-source-ledger">
        <summary>Exact bearings, source scale, candidate incidence and proof classification</summary>
        <p>
          Inherited source endpoints remain in their original Steeling frame. No previous lawful acquisition is invented. Mirrored Regarding changes projection only, never reflects the material source.
        </p>
        <pre>{inspect(@model.inherited_return,pretty: true)}</pre><pre>{inspect(@model.current_measure,pretty: true)}</pre><pre>{inspect(@model.return_trial,pretty: true)}</pre>
        <pre>{inspect(Map.drop(@model.snail,[:points,:faces,:source_points]),pretty: true)}</pre>
        <p>
          Required registration is established. The competing wedge mechanisms, actual Segmentationing SIX seam, finite occupied clearance and optical transfer are unproved. FT/TF references grant no actual working COB.
        </p>
      </details>
    </section>
    """
  end
end
