defmodule PublicSituationMachineTurnZeroWeb.ArchitectureScene do
  @moduledoc "Toy-craft aperture, roundabout and interior tubular Regard. The engineering ledger stays outside."
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Architecture, as: Lab
  alias PublicSituationMachineTurnZero.Architecture.{Craft, Projection}

  attr :lab, :map, required: true
  attr :materials, :any, required: true
  attr :inherited, :list, required: true

  def aperture(assigns) do
    ~H"""
    <div
      id="architecture-projection"
      data-nav={@lab.nav}
      data-bearing={@lab.bearing}
      data-mode={if @lab.flat?, do: "flat", else: "diorama"}
      data-craft={to_string(@lab.craft.open?)}
      class={[
        "toy-diorama",
        @lab.flat? && "is-flat",
        @lab.craft.open? && "is-crafting",
        @lab.bearing == "groundward" && "is-groundward",
        @lab.approach && "is-approaching"
      ]}
    >
      <svg
        :if={!@lab.flat?}
        id="architecture-geometry"
        class="toy-architecture"
        viewBox="0 0 1000 680"
        preserveAspectRatio="none"
        role="img"
        aria-labelledby="architecture-scene-title"
      >
        <title id="architecture-scene-title">
          {if Lab.stepped?(@lab),
            do: "Regard FROM WITHIN a gently curving tubular passage",
            else: "Roundabout Stationing around a stable central standing"}
        </title>
        <defs>
          <linearGradient id="toy-wall" x2="0.1" y2="1">
            <stop stop-color="#e9e3cc" /><stop offset="1" stop-color="#b5b99e" />
          </linearGradient>
          <linearGradient id="toy-floor" x2="0.2" y2="1">
            <stop stop-color="#999f87" /><stop offset="1" stop-color="#e1dcc4" />
          </linearGradient>
          <radialGradient id="toy-interior">
            <stop stop-color="#737e69" /><stop offset="0.65" stop-color="#d3d2b7" /><stop
              offset="1"
              stop-color="#eee7ce"
            />
          </radialGradient>
        </defs>
        <rect width="1000" height="680" fill="url(#toy-wall)" />
        <%= if Lab.stepped?(@lab) do %>
          <g id="tunnel-geometry" data-regard="from-within">
            <rect width="1000" height="680" fill="url(#toy-interior)" />
            <path d={Projection.tube(@lab.nav).ceiling} class="toy-tube-seam" />
            <path d={Projection.tube(@lab.nav).left_wall} class="toy-tube-seam" />
            <path d={Projection.tube(@lab.nav).right_wall} class="toy-tube-seam" />
            <path d={Projection.tube(@lab.nav).floor} fill="url(#toy-floor)" />
            <path id="rail-left" d={Projection.rail(@lab.nav, -1)} class="toy-floor-rail" />
            <path id="rail-right" d={Projection.rail(@lab.nav, 1)} class="toy-floor-rail" />
            <path
              d={"M340 720 Q#{Projection.tube(@lab.nav).center - 140} 425 #{Projection.tube(@lab.nav).center} #{Projection.tube(@lab.nav).horizon + 55}"}
              class="toy-provenance-course"
            />
            <g
              id="quiet-approach"
              data-enclosure={if Lab.quiet_complete?(@lab), do: "full", else: "half"}
              transform={"translate(#{Projection.tube(@lab.nav).center},#{Projection.tube(@lab.nav).horizon}) scale(#{0.4 + @lab.nav / 14})"}
            >
              <path d="M-90 0 A90 105 0 0 1 90 0" class="toy-receiving-arc" />
              <path
                :if={Lab.quiet_complete?(@lab)}
                d="M90 0 A90 105 0 0 1 -90 0"
                class="toy-receiving-arc"
              />
              <text x="0" y="-123" text-anchor="middle" class="toy-geometry-label">
                QUIET ALCOVE / RECEIVING
              </text>
            </g>
          </g>
        <% else %>
          <g
            id="zeroeth-geometry"
            data-enclosure={if Lab.zeroeth_complete?(@lab), do: "full", else: "half"}
          >
            <ellipse cx="500" cy="480" rx="440" ry="155" fill="url(#toy-floor)" />
            <path d="M65 440 C75 200 920 200 935 440" class="toy-roundabout-course" />
            <path d="M65 440 C95 605 900 605 935 440" class="toy-roundabout-lip" />
            <path d="M75 440 C95 230 910 230 925 440" class="toy-roundabout-inner" />
            <path
              :if={Lab.zeroeth_complete?(@lab)}
              d="M65 440 C40 150 960 150 935 440"
              class="toy-enclosing-return"
            />
            <path d="M200 680 L325 535 M360 680 L435 552" class="toy-entrance" />
            <ellipse cx="500" cy="475" rx="40" ry="17" class="toy-central-opening" />
            <text x="500" y="515" text-anchor="middle" class="toy-geometry-label">
              CENTRAL OPENING
            </text>
            <g
              :if={Lab.furnished?(@lab, "tc-positioned")}
              id="projected-tc"
              data-appointed={to_string(Lab.furnished?(@lab, "tc-appointed"))}
              transform="translate(790,500) scale(.45)"
            >
              <path
                d="M-75 -30 L30 -46 L60 -4 L-45 12 Z M-75 -30 V-105 L28 -120 V-46"
                class="toy-mini-computer"
              />
            </g>
          </g>
        <% end %>
      </svg>
      <div
        id="architecture-materials"
        phx-update="stream"
        class="toy-course-material"
        inert={@lab.craft.open?}
        aria-label="Material standing along the course"
      >
        <article
          :for={{dom_id, item} <- @materials}
          id={dom_id}
          data-material={item["id"]}
          data-origin={item["origin"]}
          data-bearing={item["bearing"]}
          data-approached={to_string(item["approached"])}
          style={item["style"]}
          class="toy-inscription"
          inert={@lab.craft.open? || (!@lab.flat? && @lab.approach != nil && !item["approached"])}
        >
          <p class="toy-inscription-source">{item["origin"]} → {item["toward"]}</p>
          <h2>{item["title"]}</h2>
          <div
            class="toy-inscription-reading"
            style={
              if item["approached"],
                do: "--read-x: #{@lab.read_x * 24}px; --read-y: #{@lab.read_y * 28}px",
                else: ""
            }
          >
            <p>{item["text"]}</p>
            <p :if={item["dependencies"] != []} class="toy-inscription-source">
              {if item["usingable"],
                do: "Dependencies hold",
                else: "Pending: #{Enum.join(item["missing"], ", ")}"}
            </p>
          </div>
          <button
            id={"approach-#{item["id"]}"}
            phx-click="approach-material"
            phx-value-id={item["id"]}
            class="toy-approach-handle"
          >NAV-STEP TOWARD</button>
          <a
            :if={@lab.flat? || item["approached"]}
            id={"inspect-#{item["id"]}"}
            href="#composement"
            phx-click="inspect-material"
            phx-value-id={item["id"]}
          >Engineering record</a>
        </article>
      </div>
      <div
        :if={@lab.bearing == "groundward" && !@lab.craft.open?}
        id="continuing-from"
        class="toy-floor-provenance"
        data-tunnel={to_string(Lab.stepped?(@lab))}
      >
        <h2>FROM HERE / CONTINUING FROM ZEROETH</h2>
        <ol>
          <li
            :for={{relation, index} <- Enum.with_index(@inherited)}
            id={"inherited-#{relation["id"]}"}
            style={"--provenance-index: #{index}"}
          >
            <strong>{relation["subject"]} → {relation["predicate"]} → {relation["object"]}</strong>
            <span>{relation["provenance"]}</span>
          </li>
        </ol>
      </div>
      <div
        :if={Lab.stepped?(@lab) && @lab.nav >= 4}
        id="continuing-toward"
        class="toy-receiving-notice"
      >
        CONTINUING TOWARD / QUIET ALCOVE
        <span>{if Lab.quiet_complete?(@lab),
          do: "Development enclosure fixture",
          else: "Enclosingmenting remains pending"}</span>
      </div>
      <.craft lab={@lab} />
      <div
        :if={@lab.approach && !@lab.craft.open?}
        id="material-nav"
        class="toy-reading-nav"
        aria-label="NAV within material Regard"
      >
        <button id="material-back" phx-click="read-nav" phx-value-op="back">← Backing NAV</button>
        <button id="material-left" phx-click="read-nav" phx-value-op="left" aria-label="NAV left">←</button><button
          id="material-up"
          phx-click="read-nav"
          phx-value-op="up"
          aria-label="NAV upward"
        >↑</button><button
          id="material-down"
          phx-click="read-nav"
          phx-value-op="down"
          aria-label="NAV downward"
        >↓</button><button
          id="material-right"
          phx-click="read-nav"
          phx-value-op="right"
          aria-label="NAV right"
        >→</button>
      </div>
    </div>
    """
  end

  attr :lab, :map, required: true

  def craft(assigns) do
    ~H"""
    <div
      :if={!@lab.flat?}
      id="craft-projection"
      phx-hook="ToyCraft"
      phx-update="ignore"
      data-state={Jason.encode!(Craft.projection(@lab))}
      data-held={@lab.craft.held || ""}
      data-articulation={Craft.articulation(@lab)}
      data-nav={@lab.nav}
      class="toy-craft-projection"
    >
      <svg
        id="toy-craft-svg"
        viewBox="0 0 1000 680"
        preserveAspectRatio="none"
        role="group"
        aria-label="Co-Bobbing and manipulable craft apparatus"
      >
        <defs>
          <radialGradient id="bobbing-volume" cx="35%" cy="25%">
            <stop stop-color="#808e75" /><stop offset=".6" stop-color="#46563f" /><stop
              offset="1"
              stop-color="#253628"
            />
          </radialGradient><linearGradient id="craft-metal" x2=".3" y2="1">
            <stop stop-color="#e0caa2" /><stop offset="1" stop-color="#9e7852" />
          </linearGradient>
        </defs>
        <g data-part="workspace" display="none">
          <ellipse cx="500" cy="485" rx="410" ry="155" class="toy-work-ground" />
          <g
            role="button"
            tabindex="0"
            aria-label="Draw Pointing-able Thing from central opening"
            data-craft-op="draw-pointer"
          >
            <ellipse cx="500" cy="476" rx="38" ry="16" class="toy-central-opening" /><path
              d="M500 473 L500 450"
              stroke="#d6bf88"
              stroke-width="6"
            />
          </g>
          <g
            data-part="box"
            class="toy-box-extent"
            role="button"
            tabindex="0"
            aria-label="Open or close Toy Box"
            data-craft-op="box"
          >
            <path d="M150 378 L295 363 L335 393 L190 413 Z M150 378 V445 L190 482 L335 462 V393 M190 413 V482" />
            <path data-part="box-lid" d="M150 378 L295 363 L335 393 L190 413 Z" />
            <text x="235" y="505" text-anchor="middle">TOY BOX</text>
          </g>
          <g
            data-part="chair"
            role="button"
            tabindex="0"
            aria-label="Point toward THIS ONE LITTLE SQUARE CHAIR"
            data-point="little-square-chair"
          >
            <path
              d="M560 390 L685 365 L745 416 L615 445 Z"
              fill="#a4ac91"
              stroke="#525e43"
              stroke-width="3"
            />
            <path
              d="M560 390 V465 L615 510 V445 M745 416 V490 L615 510 M560 465 L685 440 L745 490"
              fill="none"
              stroke="#525e43"
              stroke-width="3"
            />
            <path d="M570 378 V325 L690 302 V365" fill="none" stroke="#707e5d" stroke-width="10" />
            <text x="660" y="540" text-anchor="middle">THIS ONE LITTLE SQUARE CHAIR</text>
          </g>
          <g data-part="wrap" display="none" class="toy-wrapping-rehearsal">
            <path d="M560 385 L680 360 L745 415 L745 480 L620 505 L560 465 Z" /><path d="M610 374 V493 M695 375 V494" />
          </g>
          <g
            data-part="tc"
            data-point="projected-tc"
            tabindex="0"
            role="button"
            aria-label="Point toward THIS ONE TERRESTRIAL COMPUTER projected furnishing"
          >
            <ellipse cx="0" cy="17" rx="75" ry="18" fill="#27392822" />
            <path
              d="M-68 -10 L35 -27 L76 8 L-30 28 Z"
              fill="url(#craft-metal)"
              stroke="#64503b"
              stroke-width="3"
            />
            <path d="M-68 -10 V-84 L35 -101 V-27 Z" fill="#b1bb9d" stroke="#64503b" stroke-width="5" />
            <path d="M-57 -23 V-74 L23 -86 V-35 Z" fill="#4e6558" />
            <path d="M-40 1 L30 -10 M-29 10 L41 -2" stroke="#827052" stroke-width="3" />
          </g>
          <g
            data-part="buckle"
            data-point="square-buckle"
            tabindex="0"
            role="button"
            aria-label="Point toward THIS ONE SQUARE BUCKLE"
          >
            <path
              d="M-43 -40 L35 -51 L48 27 L-31 39 Z M-27 -26 L22 -33 L31 13 L-17 21 Z"
              fill="url(#craft-metal)"
              fill-rule="evenodd"
              stroke="#6b5136"
              stroke-width="4"
            />
            <path d="M-4 -31 L5 17" stroke="#71513a" stroke-width="7" />
          </g>
          <g data-part="held-halo" display="none">
            <circle
              r="105"
              class="toy-turn-ring"
              tabindex="0"
              role="slider"
              aria-label="Turn held artifact AROUND ABOUT"
              aria-valuemin="0"
              aria-valuemax="359"
              aria-valuenow="0"
              data-drag="turn"
            /><circle
              r="80"
              fill="transparent"
              class="toy-carry-hit"
              data-drag="carry"
              role="button"
              tabindex="0"
              aria-label="Carry held artifact; arrow keys move it"
            />
          </g>
          <g
            data-part="calibration"
            tabindex="0"
            role="button"
            aria-label="Point at calibration mark"
            data-point="calibration-mark"
          >
            <circle cx="825" cy="210" r="23" fill="none" stroke="#6b7258" stroke-dasharray="3 4" /><path
              d="M812 210 H838 M825 197 V223"
              stroke="#6b7258"
              stroke-width="2"
            /><text x="825" y="255" text-anchor="middle">POINTING-ABLE</text>
          </g>
          <text x="500" y="606" text-anchor="middle">
            PROJECTED FURNISHINGS / ACTUAL TC REMAINS ALONGSIDE
          </text>
          <text data-part="artifact-label" x="300" y="552" text-anchor="middle">
            THIS ONE TERRESTRIAL COMPUTER
          </text>
        </g>
        <g data-part="pointer" display="none">
          <path d="M0 0 L145 -52" stroke="#866743" stroke-width="9" stroke-linecap="round" /><path
            d="M145 -52 L164 -61 L151 -41 Z"
            fill="#dfcc99"
            stroke="#715239"
            stroke-width="2"
          />
        </g>
        <g
          id="co-bobbing"
          data-part="bobbing"
          data-identity="co-bobbing"
          transform="translate(490,560)"
        >
          <g class="toy-bobbing-breath">
            <path
              d="M-42 0 Q-26 -35 4 -31 Q33 -28 43 3 Q28 32 -5 30 Q-34 26 -42 0Z"
              fill="url(#bobbing-volume)"
              stroke="#2e4030"
              stroke-width="2"
            /><path d="M-29 -9 Q0 -33 28 -8" fill="none" stroke="#c3cda760" stroke-width="2" />
          </g>
          <g data-part="articulation" data-count="4">
            <circle data-point-index="0" cx="-35" cy="-22" r="5" /><circle
              data-point-index="1"
              cx="35"
              cy="-22"
              r="5"
            /><circle data-point-index="2" cx="35" cy="22" r="5" /><circle
              data-point-index="3"
              cx="-35"
              cy="22"
              r="5"
            />
          </g>
        </g>
      </svg>
    </div>
    <p :if={!@lab.flat?} id="co-bobbing-caption" class="toy-cob-caption">
      THIS ONE CO-BOBBING THING <span>{crew_line(@lab)}</span>
    </p>
    <div
      :if={@lab.craft.open?}
      id="craft-controls"
      class="toy-craft-controls"
      aria-label="Composementing craft operations"
    >
      <button
        :if={!@lab.craft.pointer?}
        id="craft-draw-pointer"
        phx-click="craft"
        phx-value-op="draw-pointer"
      >Draw Pointing-able Thing ↑</button>
      <button id="craft-box" phx-click="craft" phx-value-op="box">{if @lab.craft.box?,
        do: "Close",
        else: "Open"} Toy Box</button>
      <button
        :if={@lab.craft.box? && !@lab.craft.held}
        id="craft-next-piece"
        phx-click="craft"
        phx-value-op="next-piece"
      >Another piece ↻</button>
      <button
        :if={@lab.craft.pointer? && !@lab.craft.held}
        id="craft-point-offer"
        phx-click="point-artifact"
        phx-value-id={@lab.craft.offered}
      >Point toward offered piece</button>
      <button
        :if={@lab.craft.pointer? && !@lab.craft.held}
        id="craft-point-calibration"
        phx-click="point-artifact"
        phx-value-id="calibration-mark"
      >Point toward calibration mark</button>
      <button
        :if={@lab.craft.pointed == "calibration-mark" && !Lab.furnished?(@lab, "pointing-calibrated")}
        id="craft-calibrate"
        phx-click="craft"
        phx-value-op="calibrate"
      >Exercise Pointing-able relation</button>
      <button
        :if={Craft.graspable?(@lab, @lab.craft.pointed) && !@lab.craft.held}
        id="craft-grasp"
        phx-click="craft"
        phx-value-op="grasp"
      >Grasp</button>
      <%= if @lab.craft.held do %>
        <button id="craft-lift" phx-click="craft" phx-value-op="lift">Lift ↑</button><button
          id="craft-turn"
          phx-click="craft"
          phx-value-op="turn"
        >Turn ↻</button>
        <button :if={!@lab.craft.target} id="craft-toward" phx-click="craft" phx-value-op="toward">Bring TOWARD Chair</button>
        <button
          :if={@lab.craft.target && !@lab.craft.aligned?}
          id="craft-align"
          phx-click="craft"
          phx-value-op="align"
        >Align square into square</button>
        <button
          :if={@lab.craft.held == "projected-tc" && @lab.craft.aligned?}
          id="craft-seat"
          phx-click="craft"
          phx-value-op="seat"
        >Seat DOWN</button>
        <button
          :if={@lab.craft.held == "square-buckle" && @lab.craft.target && !@lab.craft.wrapped?}
          id="craft-wrap"
          phx-click="craft"
          phx-value-op="wrap"
        >Wrap extent</button>
        <button
          :if={@lab.craft.held == "square-buckle" && @lab.craft.aligned? && @lab.craft.wrapped?}
          id="craft-buckle"
          phx-click="craft"
          phx-value-op="buckle"
        >Buckle / Appoint</button>
        <button id="craft-release" phx-click="craft" phx-value-op="release">Release</button>
      <% end %>
    </div>
    """
  end

  defp crew_line(lab) do
    cond do
      Lab.stepped?(lab) ->
        "Regard #{lab.nav} / FROM holds."

      lab.craft.held && lab.craft.target ->
        "A receiving relation stands. Your seating stroke remains yours."

      lab.craft.held ->
        "Held for Regard."

      Craft.graspable?(lab, lab.craft.pointed) ->
        "This piece stands available for grasp."

      true ->
        "Attending from here."
    end
  end
end
