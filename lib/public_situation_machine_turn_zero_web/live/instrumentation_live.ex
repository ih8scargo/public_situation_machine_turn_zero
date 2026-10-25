defmodule PublicSituationMachineTurnZeroWeb.InstrumentationLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.{Instrumentation, Instrumentation.Store}

  def mount(_, _, socket) do
    {:ok,
     assign(socket,
       lab: Instrumentation.new(),
       record: nil,
       message: "Instrumentation Lab One",
       exchange: nil,
       stroke: 0
     )}
  end

  def handle_params(params, _, socket) do
    case params do
      %{"id" => id} ->
        case Store.fetch(id) do
          {:ok, record} ->
            {:noreply,
             assign(socket, record: record, lab: Instrumentation.restore(record.standing))}

          _ ->
            {:noreply,
             assign(socket,
               record: nil,
               message: "Record unavailable. Open /experiments/instrumentation to begin."
             )}
        end

      _ ->
        if connected?(socket) do
          record = Store.create()
          {:noreply, push_patch(socket, to: ~p"/experiments/instrumentation?id=#{record.id}")}
        else
          {:noreply, socket}
        end
    end
  end

  def handle_event("lift", %{"id" => id}, socket), do: operate(socket, {:lift, id})

  def handle_event("operate", %{"op" => name}, socket) do
    op =
      case name do
        "tray" -> :tray
        "pivot" -> :pivot
        "return" -> :return
        "turn" -> :turn
        "select" -> :select
        "align" -> :align
        "over" -> :over
        "seat" -> :seat
        "illuminate" -> :illuminate
        _ -> :invalid
      end

    operate(socket, op)
  end

  def handle_info({:exchange_done, stroke}, socket) do
    {:noreply,
     if(socket.assigns.stroke == stroke, do: assign(socket, exchange: nil), else: socket)}
  end

  defp operate(%{assigns: %{record: nil}} = socket, _), do: {:noreply, socket}

  defp operate(socket, op) do
    old = socket.assigns.lab

    case Instrumentation.operate(old, op) do
      {:ok, lab} ->
        saved =
          if lab.standing == old.standing,
            do: {:ok, socket.assigns.record},
            else: Store.save(socket.assigns.record, lab.standing)

        case saved do
          {:ok, record} ->
            if op == :seat,
              do: Process.send_after(self(), {:exchange_done, socket.assigns.stroke + 1}, 1400)

            {:noreply,
             assign(socket,
               lab: lab,
               record: record,
               exchange: if(op == :seat, do: old.standing["seated"], else: nil),
               stroke: socket.assigns.stroke + if(op == :seat, do: 1, else: 0),
               message:
                 if(op == :seat,
                   do: "#{lab.standing["seated"]["station"]} seated FOR Regarding. FROM holds.",
                   else: "Regarding changes; seating holds."
                 )
             )}

          {:error, _} ->
            {:noreply,
             assign(socket,
               message: "Another instrument changed seating. Reload before continuing."
             )}
        end

      {:error, _} ->
        {:noreply, assign(socket, message: "That operation is not available in this posture.")}
    end
  end

  defp x(id, lab) do
    others = Enum.reject(lab.standing["rail"], &(&1 == lab.origin))

    position =
      cond do
        id == lab.origin -> 300
        id == hd(others) -> 140
        true -> 460
      end

    if lab.reciprocal?, do: 600 - position, else: position
  end

  defp rail_y(id, lab), do: if(x(id, lab) == 300, do: 340, else: 365)

  defp bulb_y(lab, id) do
    cond do
      lab.held == id && lab.over? -> 474
      lab.held == id -> 420
      lab.standing["seated"]["station"] == id -> 565
      true -> rail_y(id, lab) + 70
    end
  end

  defp bulb_x(lab, id) do
    if lab.held == id || lab.standing["seated"]["station"] == id, do: 300, else: x(id, lab)
  end

  defp shown(lab), do: lab.held || lab.standing["seated"]["station"]

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:instrumentation_experiment}>
      <main id="instrumentation-lab" class="instrument-lab">
        <header class="instrument-heading">
          <div>
            <p>EXPERIMENTAL INSTRUMENTATION / 01</p><h1>PUBLIC-SITUATION-MACHINE-</h1>
          </div>
          <.link navigate={~p"/experiments/motor"}>Motor test bench
          <.icon name="hero-arrow-up-right" class="size-4" /></.link>
        </header>
        <section class="instrument-cabinet" aria-label="Little Regarding Diorama">
          <div class="instrument-plate">
            <span>GRAND APERTURE</span><span>FOR REGARDING FROM HERE</span>
          </div>
          <svg
            id="regarding-diorama"
            viewBox="0 0 600 670"
            role="group"
            aria-labelledby="diorama-title diorama-description"
          >
            <title id="diorama-title">This One Little Diorama for Regarding</title>
            <desc id="diorama-description">
              Three already-standing Stationings on individual vertical Strings. The central meridian receives a selected bearing only on the downward stroke.
            </desc>
            <rect x="94" y="20" width="412" height="412" rx="2" class="instrument-aperture" />
            <path
              d="M94 432 L45 590 L555 590 L506 432 M94 20 L55 50 M506 20 L545 50"
              class="instrument-fine"
            />
            <text x="300" y="100" text-anchor="middle" class="instrument-small">
              {if @lab.held, do: "INSPECTIONING", else: "PRESENTLY SEATED"}
            </text>
            <text id="aperture-station" x="300" y="160" text-anchor="middle" class="instrument-letter">
              {shown(@lab)}
            </text>
            <text x="300" y="202" text-anchor="middle" class="instrument-label">
              {Instrumentation.station(@lab, shown(@lab))["label"]}
            </text>
            <text id="aperture-bearing" x="300" y="240" text-anchor="middle" class="instrument-label">
              {if @lab.held,
                do: Instrumentation.bearing(@lab),
                else: @lab.standing["seated"]["bearing"]}
            </text>
            <g :if={@lab.tray?} id="rail-open">
              <path d="M75 305 H525 M75 305 L45 590 M525 305 L555 590" class="instrument-fine" />
              <g id="flat-rail" data-rail={Enum.join(@lab.standing["rail"], ",")}>
                <path d="M140 312 H460" class="instrument-fine" />
                <g
                  :for={station <- Instrumentation.rail(@lab)}
                  id={"flat-#{station["id"]}"}
                  data-station={station["id"]}
                >
                  <circle cx={x(station["id"], @lab)} cy="312" r="4" class="instrument-mark" />
                  <text
                    x={x(station["id"], @lab)}
                    y="295"
                    text-anchor="middle"
                    class="instrument-small"
                  >
                    {station["id"]}
                  </text>
                </g>
              </g>
              <path d="M85 380 Q300 296 515 380" class="instrument-rail" />
              <g id="curved-rail" data-rail={Enum.join(@lab.standing["rail"], ",")}>
                <g
                  :for={station <- Instrumentation.rail(@lab)}
                  id={"bulb-#{station["id"]}"}
                  data-station={station["id"]}
                >
                  <line
                    x1={x(station["id"], @lab)}
                    x2={x(station["id"], @lab)}
                    y1={rail_y(station["id"], @lab)}
                    y2={
                      if bulb_x(@lab, station["id"]) == x(station["id"], @lab),
                        do: bulb_y(@lab, station["id"]) - 38,
                        else: rail_y(station["id"], @lab) + 30
                    }
                    class="instrument-string"
                  />
                  <g
                    :if={!@exchange || @exchange["station"] != station["id"]}
                    transform={"translate(#{bulb_x(@lab, station["id"])},#{bulb_y(@lab, station["id"])})"}
                    class="instrument-bulb"
                  >
                    <a
                      id={"loop-#{station["id"]}"}
                      href="#inspection-controls"
                      phx-click="lift"
                      phx-value-id={station["id"]}
                      aria-label={"Lift #{station["id"]} by its loop"}
                    >
                      <circle cy="-35" r="15" fill="transparent" />
                      <circle cy="-35" r="9" class="instrument-loop" />
                    </a>
                    <circle r="28" class="instrument-orb" />
                    <ellipse
                      rx={if @lab.held == station["id"] && @lab.turn == 1, do: 9, else: 22}
                      ry="28"
                      class="instrument-fine"
                    />
                    <path d="M-27 0 H27" class="instrument-fine" />
                    <text y="6" text-anchor="middle" class="instrument-label">{station["id"]}</text>
                  </g>
                </g>
              </g>
              <g
                :if={@lab.illuminated?}
                id="illuminated-relation"
                data-source={Instrumentation.selected_relation(@lab)["source"]}
                data-target={Instrumentation.selected_relation(@lab)["target"]}
              >
                <path
                  d={"M#{x(Instrumentation.selected_relation(@lab)["source"], @lab)} 312 L#{x(Instrumentation.selected_relation(@lab)["source"], @lab)} 580 L#{x(Instrumentation.selected_relation(@lab)["target"], @lab)} 580 L#{x(Instrumentation.selected_relation(@lab)["target"], @lab)} 365 L300 240"}
                  class="instrument-relation"
                />
              </g>
            </g>
            <g
              id="seating-receiver"
              data-seated={@lab.standing["seated"]["station"]}
              data-bearing={@lab.standing["seated"]["bearing"]}
            >
              <circle cx="300" cy="565" r="58" class="instrument-receiver" />
              <path d="M300 478 V633" class="instrument-meridian" />
              <circle :if={!@lab.tray?} cx="300" cy="565" r="28" class="instrument-orb" />
              <text :if={!@lab.tray?} x="300" y="571" text-anchor="middle" class="instrument-label">
                {@lab.standing["seated"]["station"]}
              </text>
              <path
                :if={@lab.held}
                d={if(@lab.aligned?, do: "M300 445 V499", else: "M319 450 L329 490")}
                class="instrument-bearing"
              />
            </g>
            <g
              :if={@exchange}
              id={"exchange-#{@stroke}"}
              class="instrument-exchange"
              style={"--return-y: #{rail_y(@exchange["station"], @lab) + 70 - 565}px"}
            >
              <circle cx="300" cy="565" r="29" class="instrument-orb" />
              <text x="300" y="571" text-anchor="middle" class="instrument-label">
                {@exchange["station"]}
              </text>
            </g>
            <text x="300" y="655" text-anchor="middle" class="instrument-small">
              CENTRAL SEATING / RE-SEATING · MERIDIAN
            </text>
          </svg>
          <div class="instrument-controls">
            <button
              id="tray-toggle"
              phx-click="operate"
              phx-value-op="tray"
              aria-expanded={to_string(@lab.tray?)}
              disabled={!@record}
            >{if @lab.tray?, do: "Restore Rail tray", else: "Stand Rail tray DOWN"}</button>
            <button
              id="regard-pivot"
              phx-click="operate"
              phx-value-op="pivot"
              aria-pressed={to_string(@lab.reciprocal?)}
              disabled={!@record}
            >Reciprocal Regard</button>
          </div>
          <div :if={@lab.tray?} id="pointing-controls" class="instrument-controls">
            <button
              :for={station <- Instrumentation.rail(@lab)}
              id={"lift-#{station["id"]}"}
              phx-click="lift"
              phx-value-id={station["id"]}
              aria-label={"Catch loop and lift #{station["id"]}: #{station["label"]}"}
            >
              <span aria-hidden="true">♧</span> Lift {station["id"]}
            </button>
          </div>
          <section
            :if={@lab.held}
            id="inspection-controls"
            class="instrument-inspection"
            aria-label="Held Stationing operations"
          >
            <p id="held-bearing">{@lab.held} / {Instrumentation.bearing(@lab)}</p>
            <div class="instrument-controls">
              <button id="bulb-turn" phx-click="operate" phx-value-op="turn">Turn AROUND ABOUT</button>
              <button id="bulb-return" phx-click="operate" phx-value-op="return">Return to Rail</button>
              <button
                :for={
                  {op, label} <- [
                    {"select", "Select bearing"},
                    {"align", "Align to meridian"},
                    {"over", "Stand OVER"},
                    {"seat", "Push DOWN"}
                  ]
                }
                id={"bulb-#{op}"}
                phx-click="operate"
                phx-value-op={op}
                disabled={!Instrumentation.available?(@lab, operation(op))}
              >{label}</button>
              <button
                :if={Instrumentation.selected_relation(@lab) != nil}
                id="relation-illuminate"
                phx-click="operate"
                phx-value-op="illuminate"
                aria-pressed={to_string(@lab.illuminated?)}
              >Regard A → C relation</button>
            </div>
          </section>
          <p id="instrument-status" role="status">{@message}</p>
        </section>
        <footer class="instrument-footing">
          <p id="seating-standing">
            SEATED FOR REGARDING: {@lab.standing["seated"]["station"]} / {@lab.standing["seated"][
              "bearing"
            ]}
          </p>
          <p id="instrument-from">FROM {@lab.standing["from"]} · PUFF 0 · RE-STEP 0</p>
          <p>Save this URL to resume seating. Regard resets on reload.</p>
          <details id="instrument-notes">
            <summary>Laboratory seams / standing relations</summary>
            <p>
              AT a Stationing FOR Regarding remains distinct from FROM WITHIN its inner Pocketing. Temporary Inspectioning is not a second saved seating.
            </p>
            <p>
              A → C: provisional Tensioning fixture stands through Human Place-Square labor. B is independently available. Rail order makes no further dependency claim.
            </p>
          </details>
        </footer>
      </main>
    </Layouts.app>
    """
  end

  defp operation("select"), do: :select
  defp operation("align"), do: :align
  defp operation("over"), do: :over
  defp operation("seat"), do: :seat
end
