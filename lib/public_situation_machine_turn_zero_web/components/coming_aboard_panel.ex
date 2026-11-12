defmodule PublicSituationMachineTurnZeroWeb.ComingAboardPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  import PublicSituationMachineTurnZeroWeb.ComingAboardMachinePanel, only: [machine: 1]
  alias PublicSituationMachineTurnZero.Architecture
  alias PublicSituationMachineTurnZero.Workshop.ComingAboardAppliance

  attr :appliance, :map, required: true
  attr :ready, :boolean, required: true
  attr :reference, :string, required: true
  attr :cab_wedge, :string, required: true

  def appliance(assigns) do
    assigns =
      assign(assigns,
        common_registration:
          PublicSituationMachineTurnZero.Workshop.ComingAboardMachine.registration(),
        doors: ComingAboardAppliance.doors(),
        draft_form: to_form(%{"text" => ""}, as: :draft),
        inquiry_form: to_form(%{"text" => ""}, as: :inquiry),
        config_form:
          to_form(%{"bugs" => assigns.appliance.bugs, "restep" => assigns.appliance.restep},
            as: :config
          ),
        selected: Map.get(assigns.appliance.material, assigns.appliance.door)
      )

    ~H"""
    <section
      id="ca-appliance"
      class="ca-appliance"
      data-ship={@appliance.ship}
      data-cob={@appliance.cob}
      data-here={@appliance.here}
      data-illuminations={@appliance.illuminations}
    >
      <header class="ca-section-heading">
        <div>
          <p class="ca-eyebrow">ONE APPLIANCE · ONE COB · FROM HERE</p><h2>
            The room-making appliance
          </h2>
        </div>
        <span class="ca-status">{if @ready,
          do: "Furnished for rehearsal",
          else: "Standing material · Toy Box held"}</span>
      </header>
      <p class="ca-description">
        Seated FROM HERE. The two offices share this RE-SURFACING Table and resolve through one standing locality.
      </p>
      <.machine state={@appliance} />
      <section
        id="ca-pull-witness"
        class="ca-pull-witness"
        data-here={@appliance.here}
        data-opening={if @ready, do: "accepted", else: "held"}
      >
        <div>
          <h3 id="ca-opening-phase" role="status">
            {if @ready, do: "After the pull", else: "Before the pull"}
          </h3>
          <p :if={!@ready}>Toy Box held · XT TOWARD YT hold engaged.</p>
          <p :if={@ready}>
            UP AND OUT · displaced release accepted. Standing String attached in the common Groundward extent frame.
          </p>
        </div>
        <div class="ca-pull-reference">
          <svg
            viewBox="0 0 240 76"
            role="img"
            aria-label={
              if @ready,
                do:
                  "Hold released. The registered Standing String retains its Groundward FROM HERE attachment and seated return reference.",
                else: "Hold engaged on the fixed reference"
            }
          >
            <path d="M16 58 H224" fill="none" stroke="#87b6a3" stroke-width="2" />
            <path d="M193 58 V14 H216 V58" fill="none" stroke="#adc7c7" stroke-width="2" />
            <circle cx="43" cy="58" r="5" fill="#87b6a3" />
            <path
              d="M58 46 H127"
              fill="none"
              stroke="#728e8e"
              stroke-width="2"
              stroke-dasharray="3 3"
            />
            <path
              id="ca-opening-hold"
              d={if @ready, do: "M75 30 H144", else: "M58 46 H127"}
              fill="none"
              stroke="#fda4af"
              stroke-width="4"
              stroke-linecap="round"
            />
            <g
              :if={@ready}
              id="ca-groundward-trace"
              data-from={@appliance.here}
              data-source="ground-monitor-head-v1"
              data-attachment="registered"
              data-return={@appliance.here}
            >
              <path
                d="M43 58 L65 12 H112 M105 8 L112 12 L105 16"
                class="ca-groundward-toward"
              />
              <path
                d="M112 18 H70 L48 53 M49 46 L48 53 L55 50"
                class="ca-groundward-return"
              />
              <circle cx="118" cy="12" r="5" fill="none" stroke="#e3c184" stroke-width="2" />
              <text x="129" y="16" fill="#e3c184" font-size="10">Registered</text>
            </g>
            <text x="43" y="72" text-anchor="middle" fill="#c8e4dd" font-size="10">FROM HERE</text>
            <text x="203" y="72" text-anchor="middle" fill="#c8e4dd" font-size="10">Monitor</text>
          </svg>
          <div class="ca-ground-witness" data-source="ground-monitor-head-v1">
            <strong>Groundward reference · FROM HERE</strong>
            <p>Constitutioning Human seated at the HERE square and rugging locality.</p>
            <p>Real pretending Terrestrial Computer OVER ACROSS THERE · fixed monitor plane.</p>
          </div>
        </div>
        <p :if={@ready} id="ca-groundward-qualification" class="ca-note">
          Standing String now attaches FROM HERE through the registered Groundward XT locality. Inspect its solid extent-frame course above. The inherited trace below retains its original presentation; it does not perform ZIPPERING.
        </p>
        <div class="ca-string-witnesses">
          <details id="ca-standing-string">
            <summary>Standing String</summary>
            <p>
              Inherited seated FROM HERE and Groundward reference. Accepted pull attaches the Standing String to the common Groundward extent frame. ZIPPERING remains a separate securing operation.
            </p>
          </details>
          <details id="ca-regarding-string">
            <summary>Regarding String</summary>
            <p>
              Inspect the same HERE and fixed monitor references through Flat, Dollside or Tunneling. The common extent frame preserves their correspondence; the physical monitor remains fixed.
            </p>
          </details>
        </div>
      </section>
      <div class="ca-toolbar" aria-label="Regarding">
        <button
          :for={
            {value, label} <- [
              {"flat", "Flat Presentationing"},
              {"dollside", "Dollside Regarding"},
              {"tunnel", "Tunneling Regarding"},
              {"within-cab", "WITHIN-CAB Regarding"}
            ]
          }
          id={"ca-view-#{value}"}
          phx-click="appliance:view"
          phx-value-selection={value}
          aria-pressed={to_string(@appliance.view == value)}
        >{label}</button>
      </div>
      <section :if={@appliance.view == "within-cab"} id="ca-within-cab" class="ca-work-surface">
        <h3>{Architecture.name("puffing-tunneling-thing")}</h3>
        <p class="ca-note">XT TOWARD YT · WITHIN-CAB Regarding</p>
        <button
          id="ca-cab-puff"
          type="button"
          class="ca-horn"
          phx-click={
            if @appliance.cab_inspection == :selected,
              do: "appliance:tunnel-puff",
              else: "appliance:cab-puff"
          }
          aria-label={
            if @appliance.cab_inspection == :selected,
              do: "PUFF to furnish tunnel extent",
              else: "PUFF to inspect the wedging"
          }
          aria-controls={if @appliance.cab_inspection, do: "ca-cab-inspection"}
          disabled={!@ready || @appliance.puffed?}
        >
          <svg viewBox="0 0 220 90" aria-hidden="true">
            <path d="M66 37 H111 V58 H66 Z" fill="#a7793f" stroke="#f8d891" stroke-width="2" />
            <path
              d="M107 35 C146 36 173 28 201 11 L201 79 C173 64 146 57 107 60 Z"
              fill="#e8b65f"
              stroke="#ffdda0"
              stroke-width="2"
            />
            <ellipse
              cx="201"
              cy="45"
              rx="10"
              ry="34"
              fill="#7b4727"
              stroke="#ffdda0"
              stroke-width="3"
            />
            <path
              d="M73 37 C62 12 22 9 12 33 C1 58 20 76 47 73 C61 72 71 64 75 57 Z"
              fill="#232b31"
              stroke="#a3b7b9"
              stroke-width="2"
            />
            <path
              d="M21 36 C26 24 41 22 54 27"
              fill="none"
              stroke="#84959a"
              stroke-width="3"
              stroke-linecap="round"
            />
            <text x="151" y="54" text-anchor="middle" class="ca-horn-lettering">PUFF</text>
          </svg>
        </button>
        <p :if={!@ready} class="ca-note">Pull the Toy Box tab to make this control available.</p>
        <div class="ca-toolbar">
          <button id="ca-wedge-next" phx-click="appliance:wedge-next" disabled={!@ready}>Regard next inherited wedging</button>
        </div>
        <p id="ca-tunnel-puff-status" role="status">
          {if @appliance.puffed?,
            do: "PUFFING furnished extent FOR possibility. No acquisition or RE-STEP.",
            else: "Inspect a wedging, select the candidate, then issue PUFFING."}
        </p>
        <div
          :if={@appliance.cab_inspection}
          id="ca-cab-inspection"
          data-wedge={@cab_wedge}
          data-inspection={@appliance.cab_inspection}
        >
          <p role="status">
            {if @appliance.cab_inspection == :selected,
              do:
                "Candidate selected TOWARD the inspected wedging. PUFFING is separately available; selection has acquired no Standing.",
              else:
                "Regarding the recovered SnailBody wedging and tunnel mouth, registered in the common extent frame."}
          </p>
          <div
            id="ca-cab-native"
            phx-hook="ComingAboardNativeReference"
            phx-update="ignore"
            data-reference={@reference}
            data-show-wedge="true"
          >
            <canvas
              width="320"
              height="240"
              class="h-auto w-full"
              role="img"
              aria-label="Native SnailBody Table and tunnel mouth with the inspected wedge outlined"
            ></canvas>
          </div>
          <button
            :if={@appliance.cab_inspection == :regarding}
            id="ca-cab-select"
            type="button"
            class="ca-action"
            phx-click="appliance:cab-select"
          >Select toward this candidate place</button>
        </div>
      </section>
      <div
        id="ca-room-geometry"
        class="ca-room-geometry"
        data-view={@appliance.view}
        data-gallery={@appliance.gallery}
      >
        <div class="ca-locality-ring" aria-hidden="true"></div>
        <div id="ca-flat-offices" class="ca-square-pair">
          <section
            :for={
              {office, i} <-
                Enum.with_index(["Furnishing Traversaling COB", "Traversaling Furnishing COB"])
            }
            id={"ca-office-#{i}"}
            class="ca-office"
          >
            <p class="ca-eyebrow">
              {if i == 0, do: "XT SIDE · LONGHOUSE", else: "TRAVERSALING · ROUNDABOUT"}
            </p>
            <h3>{office}</h3>
            <div
              id={"ca-square-#{i}"}
              class="ca-flat-square"
              data-common-frame={@common_registration.version}
              data-world={Jason.encode!(@common_registration.here)}
              data-cob={@appliance.cob}
              data-here={@appliance.here}
            >
              <svg
                viewBox="0 0 300 300"
                role="img"
                aria-label="Clockwise circuit. Upper-left XT, upper-right YT, lower-right YT, lower-left XT. A and B are separate XT TOWARD YT diagonals."
              >
                <defs>
                  <pattern id={"ca-grid-#{i}"} width="40" height="40" patternUnits="userSpaceOnUse">
                    <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#315258" stroke-width="0.6" />
                  </pattern>
                </defs>
                <rect
                  x="30"
                  y="30"
                  width="240"
                  height="240"
                  fill={"url(#ca-grid-#{i})"}
                  stroke="#82c9bc"
                  stroke-width="2"
                />
                <path
                  d="M30 270 L30 30 L270 30 L270 270 Z"
                  fill="none"
                  stroke="#82c9bc"
                  stroke-width="2"
                />
                <g class="ca-circuit-arrows" aria-hidden="true">
                  <polygon data-edge="top" data-direction="right" points="158,30 145,24 145,36" />
                  <polygon data-edge="right" data-direction="down" points="270,158 276,145 264,145" />
                  <polygon data-edge="bottom" data-direction="left" points="142,270 155,276 155,264" />
                  <polygon data-edge="left" data-direction="up" points="30,142 24,155 36,155" />
                </g>
                <g class="ca-circuit-corners" text-anchor="middle" aria-hidden="true">
                  <text data-corner="upper-left" x="30" y="21">XT</text>
                  <text data-corner="upper-right" x="270" y="21">YT</text>
                  <text data-corner="lower-right" x="270" y="290">YT</text>
                  <text data-corner="lower-left" x="30" y="290">XT</text>
                </g>
                <path
                  id={"ca-diagonal-a-#{i}"}
                  d="M30 270 L270 30"
                  data-bearing="XT TOWARD YT"
                  stroke={if @appliance.diagonal == "A", do: "#f3c77a", else: "#647b82"}
                  stroke-width="3"
                />
                <path
                  id={"ca-diagonal-b-#{i}"}
                  d="M30 30 L270 270"
                  data-bearing="XT TOWARD YT"
                  stroke={if @appliance.diagonal == "B", do: "#f3c77a", else: "#647b82"}
                  stroke-width="3"
                  stroke-dasharray="7 4"
                />
                <circle cx="150" cy="150" r="8" fill="#0c2229" stroke="#f3c77a" />
                <text x="46" y="257" fill="#f3c77a" font-size="15">A</text><text
                  x="46"
                  y="56"
                  fill="#f3c77a"
                  font-size="15"
                >
                  B
                </text>
                <text x="150" y="19" text-anchor="middle" fill="#c8e4dd" font-size="10">
                  XT TOWARD YT
                </text>
                <text x="150" y="290" text-anchor="middle" fill="#c8e4dd" font-size="10">
                  YT TOWARD XT
                </text>
                <text
                  x="12"
                  y="150"
                  text-anchor="middle"
                  transform="rotate(-90 12 150)"
                  fill="#c8e4dd"
                  font-size="10"
                >
                  XT TOWARD XT
                </text>
                <text
                  x="288"
                  y="150"
                  text-anchor="middle"
                  transform="rotate(90 288 150)"
                  fill="#c8e4dd"
                  font-size="10"
                >
                  YT TOWARD YT
                </text>
              </svg>
            </div>
            <div class="ca-square-caption">
              <span>{if i == 0, do: "FROM UPON HERE", else: "TOWARD POCKETING"}</span>
              <strong>{if i == 0,
                do: "XT TO XT · 0—1",
                else:
                  if(@appliance.approach,
                    do: "Door #{@appliance.approach.door} · approached",
                    else: "Inherited HERE"
                  )}</strong>
              <span :if={i == 0 && @selected} class="ca-square-material">{@selected.text}</span>
              <span :if={i == 1 && @appliance.approach} class="ca-square-material">{@appliance.approach.text}</span>
            </div>
            <p class="ca-registration">THIS HERE APPROACHING LANDINGING</p>
          </section>
        </div>
        <div id="ca-table-registration" class="ca-table-registration">
          <div class="ca-table-branches" aria-hidden="true"></div>
          <p>
            Both office HERE squares resolve through the seated Table center and common extent frame.
          </p>
        </div>
        <div id="ca-gallery-plan" class="ca-gallery-plan" data-source="WedgingGeometry.outline/0">
          <svg
            viewBox="0 0 400 400"
            role="img"
            aria-label="Eight Gallery wedges around the seated flat Table. Dashed yellow lines identify its center at the square axle in this plan."
          >
            <circle cx="200" cy="200" r="184" fill="#102b30" stroke="#537f79" stroke-dasharray="3 6" />
            <polygon
              :for={door <- @doors}
              id={"ca-wedge-#{door.id}"}
              points={door.wedge}
              fill={if @appliance.door == door.id, do: "#685330", else: "#14343a"}
              stroke="#6a9e92"
              stroke-width="1"
            />
            <circle cx="200" cy="200" r="98" fill="#0e242c" stroke="#ecc37f" stroke-width="3" />
            <circle cx="200" cy="200" r="77" fill="none" stroke="#61817c" stroke-width="1" />
            <path
              d="M116 200 A84 84 0 0 1 284 200 M137 200 A63 63 0 0 0 263 200"
              fill="none"
              stroke="#a8d4c7"
              stroke-width="2"
            />
            <rect x="176" y="176" width="48" height="48" fill="#264a48" stroke="#a8d4c7" />
            <path
              id="ca-table-center-trace"
              d="M200 0 L168 32 V154 L200 200 L232 154 V32 Z"
              fill="none"
              stroke="#e3c184"
              stroke-width="2"
              stroke-dasharray="4 5"
            />
            <circle cx="200" cy="200" r="4" fill="#e3c184" />
            <text x="200" y="221" text-anchor="middle" fill="#f6e6c5" font-size="12">
              HERE · AXLE
            </text>
            <text x="200" y="244" text-anchor="middle" fill="#f6e6c5" font-size="10">
              RE-SURFACING
            </text>
          </svg>
          <button
            :for={door <- @doors}
            id={"ca-door-#{door.id}"}
            class="ca-door"
            style={"left: #{door.x / 4}%; top: #{door.y / 4}%"}
            phx-click="appliance:door"
            phx-value-door={door.id}
            disabled={!@ready}
            aria-label={"PUFF TOWARD Gallery Door #{door.id}"}
            title={"PUFF TOWARD Gallery Door #{door.id}"}
            aria-pressed={to_string(@appliance.door == door.id)}
          >{door.id}<span :if={Map.has_key?(@appliance.material, door.id)} class="ca-door-dot"></span></button>
        </div>
        <div id="ca-standing-locality" class="ca-standing-locality">
          <span class="ca-eyebrow">CIRCULAR FOOT-HUGGING RUGGING</span><strong>THIS ONE STANDINGING LANDINGING</strong><span>Ordinary computer · Human seated FROM HERE</span>
        </div>
      </div>
      <p class="ca-note">
        Seated Table · flat plan. Gallery Doors 0–7 · PUFF TOWARD an indexed drafting surface.
      </p>
      <div class="ca-toolbar" aria-label="Diagonal appointment">
        <button
          :for={diagonal <- ~w(A B)}
          id={"ca-inspect-diagonal-#{diagonal}"}
          phx-click="appliance:diagonal"
          phx-value-selection={diagonal}
          aria-pressed={to_string(@appliance.diagonal == diagonal)}
        >Inspect diagonal {diagonal}</button>
        <span class="ca-note">SIX × SIX × SIX · crossing does not imply PITTONING</span>
      </div>
      <div
        :if={@appliance.view in ~w(dollside tunnel)}
        id="ca-regarding-native"
        phx-hook="ComingAboardNativeReference"
        phx-update="ignore"
        data-reference={@reference}
      >
        <canvas
          width="640"
          height="240"
          class="h-auto w-full"
          role="img"
          aria-label="Recovered Table passage and Doll pinned-head seam, 45-degree aperture and Glass in their native frames"
        ></canvas>
      </div>
      <p :if={@appliance.view in ~w(dollside tunnel)} id="ca-regarding-witness" class="ca-yellow">
        Recovered native reference · {if @appliance.view == "dollside",
          do:
            "Doll holds the letter bearing at 45° through paired apertures; pinned-head witness is in the native references below.",
          else:
            "Tunneling returns to the originating Groundward frame; the reversible folding witness is below."} The live common-machine correspondence is above; this disclosure retains the original hinge study.
      </p>
      <div class="ca-work-pair">
        <section class="ca-work-surface" id="ca-glass-wall">
          <p class="ca-eyebrow">HUMAN INSCRIPTION · GLASS WALL</p>
          <h3>Gallery Door {@appliance.door} · drafting surface</h3>
          <div class="ca-toolbar">
            <button
              :for={
                {value, label} <- [
                  {"longhouse", "Longhouse Gallery"},
                  {"roundabout", "Roundabout Gallery"}
                ]
              }
              id={"ca-gallery-#{value}"}
              phx-click="appliance:gallery"
              phx-value-selection={value}
              aria-pressed={to_string(@appliance.gallery == value)}
            >{label}</button>
          </div>
          <.form for={@draft_form} id="ca-draft-form" phx-submit="appliance:stage">
            <.input
              field={@draft_form[:text]}
              id="ca-draft-text"
              type="textarea"
              label="Looking THROUGHING THROUGHING Glass"
              placeholder="Stand a provisional inscription FROM HERE…"
              maxlength="2000"
              disabled={!@ready || @selected != nil}
            />
            <button id="ca-stage" class="ca-action" disabled={!@ready || @selected != nil}>Stage on Door {@appliance.door}</button>
          </.form>
          <p class="ca-note">
            Door drafting remains provisional staging. The distinct Slate above operates the inherited Quilling Stitching Needle.
          </p>
          <details id="ca-quilling-order" class="ca-provisional">
            <summary>Human Quilling before Doll Stitching</summary>
            <ol class="list-decimal pl-5">
              <li data-role="human-quilling">
                The Constitutioning Human takes UP the Quilling Stitching Needle and originates the markings.
              </li>
              <li data-role="doll-stitching">
                The non-agentive Co-Situationing Doll subsequently Stitches those same markings UP ON THE ROAD.
              </li>
            </ol>
            <p class="ca-yellow">
              One Human-authored identity now remains on the fixed Flat monitor and supplies Doll Stitching in XT-side Regarding. The Slate–Inkwell–Fountain geometry remains separate from this correspondence.
            </p>
            <a
              class="underline"
              href={~p"/workshop/wedging-geometry#sb-needle-status"}
              target="_blank"
              rel="noopener"
            >Inspect the retained Quilling Stitching Needle rehearsal</a>
          </details>
          <div id="ca-door-drafting-surfaces" class="ca-door-drafts">
            <article
              :for={door <- @doors}
              id={"ca-door-draft-#{door.id}"}
              class={[@appliance.door == door.id && "ca-selected"]}
              data-status={
                if Map.has_key?(@appliance.material, door.id), do: "staged", else: "visible"
              }
            >
              <strong>Door {door.id}</strong>
              <p :if={!Map.has_key?(@appliance.material, door.id)}>Drafting surface · empty</p>
              <div
                :if={record = Map.get(@appliance.material, door.id)}
                id={"ca-material-#{door.id}"}
                data-material={record.id}
                data-origin={record.from}
                data-ship={record.ship}
                data-bearing={record.bearing}
                data-pinned="false"
                data-acquired="false"
              >
                <p>{record.text}</p><small>STAGED · diagonal {record.bearing} · not PINNED</small>
              </div>
            </article>
          </div>
        </section>
        <div class="ca-work-stack">
          <section class="ca-work-surface" id="ca-traversaling-office">
            <p class="ca-eyebrow">THE SAME COB · TRAVERSALING OFFICE</p><h3>Appoint an approach</h3>
            <button
              id="ca-approach"
              class="ca-action"
              phx-click="appliance:approach"
              disabled={!@ready || is_nil(@selected)}
            >Approach Door {@appliance.door} Pocketing</button>
            <div
              id="ca-inherited-standing"
              data-here={@appliance.here}
              data-material={@appliance.approach && @appliance.approach.id}
              data-acquired="false"
              data-gallery={@appliance.gallery}
            >
              <p :if={is_nil(@appliance.approach)}>
                Inherited standing FROM HERE. No Pocketing appointed.
              </p>
              <p :if={@appliance.approach}>
                TOWARD Door {@appliance.approach.door} Pocketing · {@appliance.approach.text}
              </p>
              <p>Resolutioning THROUGH HERE · furnishing office retains FROM UPON HERE.</p>
            </div>
            <p class="ca-note">
              Approaching makes staged material envisionizingmentingable. Acquired Little ROUNDING Footings remain unfurnished.
            </p>
          </section>
          <section
            id="ca-telephone"
            class="ca-work-surface"
            data-line={if @appliance.line_open?, do: "open", else: "hooked"}
          >
            <p class="ca-eyebrow">ONE COB · OLD TELEPHONE BOX</p><h3>Consoling surface</h3>
            <div class="ca-telephone-apparatus">
              <svg
                viewBox="0 0 200 100"
                role="img"
                aria-label="Telephone box, hook, cup on string and mouthpiece"
              >
                <rect x="10" y="10" width="72" height="80" rx="5" fill="#3a3029" stroke="#d9ba85" />
                <circle cx="46" cy="40" r="17" fill="#10282c" stroke="#d9ba85" /><path
                  d="M30 66 H62 M92 24 V42 H106"
                  fill="none"
                  stroke="#d9ba85"
                  stroke-width="3"
                />
                <path
                  d={
                    if @appliance.line_open?,
                      do: "M62 70 Q110 100 156 61",
                      else: "M62 70 Q130 110 115 42"
                  }
                  fill="none"
                  stroke="#a5cfbe"
                  stroke-width="2"
                />
                <path
                  d={
                    if @appliance.line_open?,
                      do: "M146 37 L170 37 L165 62 L151 62 Z",
                      else: "M103 24 L127 24 L122 49 L108 49 Z"
                  }
                  fill="#b9dad0"
                  stroke="#10282c"
                />
                <text x="142" y="91" fill="#d9ba85" font-size="10">mouthpiece</text>
              </svg>
              <button id="ca-cup-hook" class="ca-action" phx-click="appliance:hook" disabled={!@ready}>{if @appliance.line_open?,
                do: "Return cup to hook",
                else: "Take cup off hook"}</button>
            </div>
            <.form for={@inquiry_form} id="ca-inquiry-form" phx-submit="appliance:inquire">
              <.input
                field={@inquiry_form[:text]}
                id="ca-inquiry-text"
                type="textarea"
                label="Mouthpiece · inquiry toward COB"
                placeholder="INQUIRINGMENTING…"
                maxlength="2000"
                disabled={!@ready || !@appliance.line_open?}
              />
              <button
                id="ca-send-inquiry"
                class="ca-action"
                disabled={!@ready || !@appliance.line_open?}
              >Stand inquiry toward COB</button>
            </.form>
            <div
              id="ca-console"
              role="status"
              data-speaking={to_string(@appliance.line_open? && @appliance.outreading != nil)}
            >
              <%= if @appliance.line_open? do %>
                <p :if={@appliance.inquiry}>Human inquiry: {@appliance.inquiry}</p><p>
                  {@appliance.outreading || "Line open · awaiting Human inquiry"}
                </p>
              <% else %>
                <p>Cup on hook · line closed · COB quiet</p>
              <% end %>
            </div>
            <p class="ca-note">
              Rehearsal outreading · placeholder inscription. This input does not stage material.
            </p>
          </section>
        </div>
      </div>
      <details id="ca-provisional-fittings" class="ca-provisional">
        <summary>Inspect provisional fittings and appointmenting</summary>
        <p class="ca-yellow">
          YELLOW · PINNING → ribbon → UP FROM DOWN UNDER → UP OVER ACROSS: material relationships visible for review; operations unfurnished.
        </p>
        <p class="ca-yellow">
          YELLOW · Pointing-able Thing: pointing UP / OUT AROUND ABOUT HERE. Paired sticks await evaluation alongside the separate diagonals and Doll.
        </p>
        <p class="ca-yellow">
          YELLOW · Reseating witness: DOWN → ACROSS → UP / UP → ACROSS → DOWN. OVER ACROSS is relational standing. Monitor remains fixed; PITTONING mechanics unresolved.
        </p>
        <p>
          PENDING UN-BUTTONING departure, corner and return pathway are not yet furnished. RE-ZIPPERING and RE-STEP have no executable shortcut here.
        </p>
        <.form
          for={@config_form}
          id="ca-config-form"
          phx-change="appliance:configure"
          class="ca-config"
        >
          <.input
            field={@config_form[:bugs]}
            type="select"
            label="Lanterning Bugs · both offices"
            options={[1, 2, 3]}
          />
          <.input
            field={@config_form[:restep]}
            type="select"
            label="RE-STEP appointmenting"
            options={[3, 6, 12]}
          />
        </.form>
        <p id="ca-config-status">
          Bugs {@appliance.bugs} · RE-STEP {@appliance.restep} · illuminations {@appliance.illuminations}. Appointmenting does not cap footing accretion.
        </p>
        <p class="ca-note">
          Session-local rehearsal. Reload begins a fresh Toy Box and Tuple Ship registration.
        </p>
      </details>
    </section>
    """
  end
end
