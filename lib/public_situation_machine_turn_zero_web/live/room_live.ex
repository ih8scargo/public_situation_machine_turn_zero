defmodule PublicSituationMachineTurnZeroWeb.RoomLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.Architecture, as: Lab
  alias PublicSituationMachineTurnZero.Architecture.{Store, Room}

  def mount(_, _, socket) do
    {:ok,
     assign(socket,
       lab: Lab.new(),
       room: %Room{},
       record: nil,
       on?: true,
       reset: 0,
       wheel: 0.0,
       message: nil
     )}
  end

  def handle_params(params, _, socket) do
    case params do
      %{"id" => id} ->
        case Store.fetch(id) do
          {:ok, record} ->
            {:noreply,
             assign(socket,
               record: record,
               lab: Lab.restore(record.standing),
               room: %Room{},
               on?: true,
               wheel: 0.0,
               reset: socket.assigns.reset + 1,
               message: nil
             )}

          _ ->
            {:noreply,
             assign(socket,
               record: nil,
               on?: false,
               reset: socket.assigns.reset + 1,
               message:
                 "Saved standing unavailable. Open the Groundworking or Tunnel test entry again."
             )}
        end

      _ ->
        if connected?(socket) do
          record =
            if socket.assigns.live_action == :tunnel,
              do: Store.create_tunnel_fixture(),
              else: Store.create()

          path =
            if socket.assigns.live_action == :tunnel,
              do: ~p"/experiments/architecture/tunnel?id=#{record.id}",
              else: ~p"/experiments/architecture?id=#{record.id}"

          {:noreply, push_patch(socket, to: path)}
        else
          {:noreply, socket}
        end
    end
  end

  def handle_event("enter-room", _, socket) do
    if usable?(socket) && !Lab.stepped?(socket.assigns.lab),
      do: {:noreply, assign(socket, room: Room.enter(socket.assigns.room))},
      else: {:noreply, socket}
  end

  def handle_event("leave-room", _, socket),
    do: {:noreply, assign(socket, room: %Room{}, reset: socket.assigns.reset + 1)}

  def handle_event("wheel", %{"angle" => angle}, socket) when is_number(angle) do
    if usable?(socket),
      do: {:noreply, assign(socket, wheel: angle - :math.floor(angle / 360) * 360)},
      else: {:noreply, socket}
  end

  def handle_event("pointer", params, socket) do
    operation =
      case params do
        %{"op" => "draw"} -> :draw
        %{"op" => "hold"} -> :hold
        %{"op" => "release"} -> :release
        %{"op" => "turn", "angle" => n} when is_number(n) -> {:turn, n}
        _ -> :invalid
      end

    if usable?(socket) && !Lab.stepped?(socket.assigns.lab) do
      case Room.pointer(socket.assigns.room, operation) do
        {:ok, room} -> {:reply, %{accepted: true}, assign(socket, room: room)}
        _ -> {:reply, %{accepted: false}, socket}
      end
    else
      {:reply, %{accepted: false}, socket}
    end
  end

  def handle_event("appoint-pointer", _, socket) do
    if usable?(socket) && !Lab.stepped?(socket.assigns.lab) &&
         Room.appointable?(socket.assigns.room) do
      case Lab.operate(socket.assigns.lab, :calibrate) do
        {:ok, lab} ->
          lab =
            put_in(
              lab.standing["relations"]["pointing-calibrated"]["provenance"],
              "Human explicitly appointed the Pointing-able relation FROM Groundworking after taking hold, turning and releasing in the sparse room. No TC Appointmenting or passage."
            )

          case Store.save(socket.assigns.record, lab.standing) do
            {:ok, record} ->
              {:noreply,
               assign(socket,
                 record: record,
                 lab: lab,
                 message: "Pointing-able relation appointed."
               )}

            _ ->
              {:noreply,
               assign(socket,
                 message: "Another instrument changed Standing. Reload before appointing."
               )}
          end

        _ ->
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("nav-motion", %{"position" => position, "across" => across}, socket)
      when is_number(position) and is_number(across) do
    if usable?(socket) && Lab.stepped?(socket.assigns.lab),
      do: {:noreply, assign(socket, room: Room.motion(socket.assigns.room, position, across))},
      else: {:noreply, socket}
  end

  def handle_event("sheet", params, socket) do
    room = socket.assigns.room

    result =
      case params do
        %{"op" => "resolve", "id" => id} ->
          Room.resolve(room, socket.assigns.lab, id)

        %{"op" => "regard", "direction" => direction} ->
          Room.look(room, direction)

        %{"op" => "calibrate", "scale" => scale} when is_number(scale) ->
          Room.calibrate(room, scale)

        %{"op" => "catch", "id" => id, "corner" => corner} ->
          Room.catch_corner(room, socket.assigns.lab, id, corner)

        %{"op" => "draw", "amount" => n} when is_number(n) ->
          Room.draw(room, n)

        %{"op" => "square"} ->
          Room.square(room)

        %{"op" => "relinquish"} ->
          {:ok, Room.relinquish(room)}

        _ ->
          {:error, :invalid}
      end

    case {usable?(socket) && Lab.stepped?(socket.assigns.lab), result} do
      {true, {:ok, next}} ->
        {:reply,
         %{
           accepted: true,
           sheet: next.sheet,
           corners: next.corners,
           tension: next.tension,
           regard: next.regard,
           sweep: next.sweep,
           scale: next.readable_scale
         }, assign(socket, room: next)}

      _ ->
        {:reply, %{accepted: false}, socket}
    end
  end

  def handle_event("projection", _, socket),
    do:
      {:noreply,
       assign(socket, on?: !socket.assigns.on?, room: %Room{}, reset: socket.assigns.reset + 1)}

  defp usable?(socket), do: socket.assigns.record != nil && socket.assigns.on?

  defp scene_data(assigns) do
    %{
      tunnel: Lab.stepped?(assigns.lab),
      entered: assigns.room.entered?,
      wheel: assigns.wheel,
      reset: assigns.reset,
      calibrated: Lab.furnished?(assigns.lab, "pointing-calibrated"),
      sheets:
        if(Lab.stepped?(assigns.lab),
          do:
            Enum.map(Room.sheets(assigns.lab), fn item ->
              Map.put(item, "context", Room.context(assigns.lab, item["id"]))
            end),
          else: []
        ),
      from: assigns.lab.standing["from"],
      bearing: assigns.lab.standing["tunnels"]["ZEROETH-ONE"],
      courseLength: 6,
      context: if(Lab.stepped?(assigns.lab), do: Room.context(assigns.lab, nil), else: nil),
      provenance:
        if(Lab.stepped?(assigns.lab),
          do:
            assigns.lab.standing["relations"]
            |> Map.values()
            |> Enum.filter(&(&1["origin"] == "ZEROETH")),
          else: []
        )
    }
    |> Jason.encode!()
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:architecture_experiment} show_navigation={false}>
      <main id="quiet-appliance" class="quiet-page">
        <header class="quiet-terrestrial">
          <span>PUBLIC-SITUATION-MACHINE-</span><nav aria-label="Separate prototype surfaces">
            <.link
              :if={@record}
              id="engineering-link"
              navigate={~p"/experiments/architecture/engineering?id=#{@record.id}"}
            >Engineering surface</.link><.link
              :if={!Lab.stepped?(@lab)}
              id="tunnel-fixture-link"
              navigate={~p"/experiments/architecture/tunnel"}
            >Separate Tunnel test</.link><.link
              :if={Lab.stepped?(@lab)}
              navigate={~p"/experiments/architecture"}
            >Groundworking entry</.link>
          </nav>
        </header>
        <section id="quiet-cabinet" class="quiet-cabinet" aria-label="Little Diorama locality">
          <header class="quiet-nameplate">
            <h1>{if Lab.stepped?(@lab), do: "ALONG THROUGH", else: "GROUNDWORKING"}</h1><span>{if Lab.stepped?(
                                                                                                    @lab
                                                                                                  ),
                                                                                                  do:
                                                                                                    "FIRST-PASSAGE TEST STANDING",
                                                                                                  else:
                                                                                                    "ONE PRESENT APPOINTMENTING"}</span>
          </header>
          <div
            :if={@on?}
            id="quiet-stage"
            data-aperture="grand"
            data-regard={@room.regard}
            data-inner-material={@room.sheet || ""}
            data-from={@lab.standing["from"]}
            phx-hook="QuietLocality"
            phx-update="ignore"
            data-scene={scene_data(assigns)}
            data-entered={to_string(@room.entered?)}
            class="quiet-stage"
            tabindex="0"
            aria-label={
              if Lab.stepped?(@lab), do: "Navigable sheet Tunnel", else: "Groundworking Diorama"
            }
          >
            <svg
              id="quiet-space"
              viewBox="0 0 1000 680"
              preserveAspectRatio="none"
              role="group"
              aria-labelledby="quiet-scene-title"
            >
              <title id="quiet-scene-title">
                {if Lab.stepped?(@lab),
                  do: "One elbow tube, two Rails and a separate navigational tack lattice",
                  else: "A sparse little room: Ground, a circle and THIS ONE CO-BOBBING THING"}
              </title>
              <defs>
                <linearGradient id="quiet-ground" x2=".2" y2="1">
                  <stop stop-color="#a6ac91" /><stop offset="1" stop-color="#e9e2cc" />
                </linearGradient><radialGradient id="quiet-wall">
                  <stop stop-color="#b3b99e" /><stop offset="1" stop-color="#ece8d6" />
                </radialGradient><radialGradient id="quiet-blob" cx="30%" cy="20%">
                  <stop stop-color="#8d9a7e" /><stop offset="1" stop-color="#344933" />
                </radialGradient>
              </defs>
              <rect width="1000" height="680" fill="url(#quiet-wall)" />
              <g data-part="roundabout">
                <path d="M80 425 Q500 150 920 425" class="quiet-gallery" /><ellipse
                  cx="500"
                  cy="490"
                  rx="420"
                  ry="140"
                  fill="url(#quiet-ground)"
                /><path d="M80 425 Q500 690 920 425" class="quiet-gallery-lip" />
              </g>
              <g data-part="room" display="none">
                <path d="M0 0 H1000 V505 Q500 420 0 505Z" fill="#e7e3d0" /><path
                  d="M0 505 Q500 420 1000 505 V680 H0Z"
                  fill="url(#quiet-ground)"
                /><path d="M120 0 V488 M880 0 V488" class="quiet-room-bearing" /><g
                  data-room-target="circle"
                  role="button"
                  tabindex="0"
                  aria-label="Take hold through the central circle"
                >
                  <ellipse cx="500" cy="482" rx="42" ry="18" class="quiet-circle" />
                </g>
              </g>
              <g data-part="tunnel" display="none">
                <path d="M-100 -100 Q960 -100 925 290 Q810 350 620 355" class="quiet-tube-shell" /><path
                  d="M-100 80 Q850 10 825 290"
                  class="quiet-tube-seam"
                /><path
                  d="M-100 725 Q905 690 925 290 L800 290 Q780 470 -100 570 Z"
                  fill="url(#quiet-ground)"
                /><path d="M-80 595 Q830 540 838 285" class="quiet-rail" /><path
                  d="M-70 710 Q950 660 950 290"
                  class="quiet-rail"
                /><path d="M845 285 A50 67 0 0 1 945 285" class="quiet-receiver" /><g
                  data-part="tacks"
                  aria-label="Navigational motion lattice; not provenance, Rail, Road or PITTONING"
                >
                </g><g data-part="sheet-attachments"></g><g data-part="provenance"></g>
              </g>
              <g data-part="pointing-tool" display="none">
                <path d="M0 0 L138 -38" stroke="#8b704b" stroke-width="9" stroke-linecap="round" /><path
                  d="M138 -38 L158 -50 L148 -27Z"
                  fill="#d3c293"
                  stroke="#7c6643"
                  stroke-width="2"
                />
              </g>
              <g data-part="bobbing" id="quiet-bobbing" transform="translate(500 550)">
                <g class="toy-bobbing-breath">
                  <path
                    d="M-42 0 Q-26 -35 4 -31 Q33 -28 43 3 Q28 32 -5 30 Q-34 26 -42 0Z"
                    fill="url(#quiet-blob)"
                    stroke="#344932"
                    stroke-width="2"
                  />
                </g><g data-part="points">
                  <circle cx="-34" cy="-23" r="5" /><circle cx="34" cy="-23" r="5" /><circle
                    cx="34"
                    cy="23"
                    r="5"
                  /><circle cx="-34" cy="23" r="5" />
                </g>
              </g>
            </svg>
            <button
              data-part="appointment"
              id="pointing-appointment"
              class="quiet-appointment"
              phx-click="enter-room"
            >APPOINTINGMENTING<br />THIS ONE POINTING-ABLE THING<span>Approach →</span></button>
            <div data-part="sheets" class="quiet-sheets"></div>
            <template data-part="sheet-template">
              <article
                class="quiet-sheet"
                role="button"
                tabindex="0"
                aria-label="Take this sheet through the Inner Aperture"
              >
                <svg
                  class="quiet-sheet-cloth"
                  viewBox="0 0 400 360"
                  preserveAspectRatio="none"
                  aria-hidden="true"
                ><path d="M8 8 Q200 28 392 8 L384 340 Q200 362 16 340Z" /></svg>
                <div class="quiet-sheet-writing" tabindex="0">
                  <h2></h2><div class="quiet-sheet-text"></div>
                </div>
              </article>
            </template>
            <section
              data-part="context"
              class="quiet-context-sweep"
              hidden
              aria-label="XT associated standing"
            >
              <div class="quiet-context-leaf" tabindex="0"></div>
            </section>
            <div
              id="inner-aperture"
              data-part="inner-aperture"
              data-aperture="inner"
              class="quiet-inner-aperture"
              hidden
              tabindex="0"
              role="group"
              aria-label="Inner Aperture. Hold and sweep left for XT context, right for YT material, up for bearing, down for FROM. Escape relinquishes. Plus or minus adjusts bounded readable scale."
            >
              <svg
                viewBox="0 0 400 400"
                role="group"
                aria-label="Stable square-capable resolutioning members"
              >
                <g
                  data-inner-grip="true"
                  tabindex="0"
                  role="button"
                  aria-label="Hold the Inner Aperture and sweep to Regard"
                >
                  <path d="M35 145 V35 H145" /><path d="M255 35 H365 V145" /><path d="M365 255 V365 H255" /><path d="M145 365 H35 V255" />
                  <circle cx="200" cy="200" r="145" class="quiet-inner-ring" />
                </g>
                <circle
                  data-inner-release="true"
                  cx="200"
                  cy="200"
                  r="22"
                  tabindex="0"
                  role="button"
                  aria-label="Relinquish this resolution and resume NAV"
                  class="quiet-inner-release"
                />
              </svg>
            </div>
            <svg
              data-part="bearing-regard"
              class="quiet-bearing-regard"
              viewBox="0 0 1000 680"
              preserveAspectRatio="none"
              aria-hidden="true"
            ><path d="M180 150 Q805 80 885 230" /><text
              data-part="bearing-inscription"
              x="420"
              y="116"
            >
            </text></svg>
            <div
              data-part="regard-purchase"
              class="quiet-regard-purchase"
              tabindex="0"
              role="group"
              aria-label="Bobbing Regard purchase. Hold and sweep UP toward bearing, DOWN toward FROM, XT toward context, YT toward material. Alt and arrow keys provide the same Regard."
            >
            </div>
            <div data-part="nav" class="quiet-nav" hidden>
              <button id="hold-nav-back" data-nav="back" aria-label="Hold NAV backward">← Hold BACK</button><button
                data-nav="left"
                aria-label="Hold ACROSS left"
              >↤</button><button
                id="hold-nav-forward"
                data-nav="forward"
                aria-label="Hold NAV forward"
              >Hold ALONG →</button><button data-nav="right" aria-label="Hold ACROSS right">↦</button>
            </div>
            <p data-part="gesture-hint" class="quiet-gesture-hint"></p>
            <p data-part="motion-reading" class="quiet-motion-reading" aria-live="off"></p>
          </div>
          <div :if={!@on?} id="quiet-projection-off" class="quiet-off">PROJECTIONING-ER OFF</div>
          <div class="quiet-instruments">
            <div
              :if={!Lab.stepped?(@lab) && !@room.entered? && @on?}
              id="quiet-wheel"
              phx-hook="RegardingWheel"
              phx-update="ignore"
              data-angle={@wheel}
              data-disabled={to_string(!@record)}
              class="quiet-wheel"
            >
              <svg
                viewBox="0 0 200 200"
                role="slider"
                tabindex="0"
                aria-label="Free Wheeling Free Turning Thing for Regarding"
                aria-valuemin="0"
                aria-valuemax="359"
                aria-valuenow={round(@wheel)}
              ><circle cx="100" cy="100" r="86" class="toy-wheel-rim" /><g data-wheel-rotor="true">
                <path
                  d="M100 18 V182 M18 100 H182 M42 42 L158 158 M42 158 L158 42"
                  class="toy-wheel-spokes"
                /><circle cx="100" cy="20" r="10" class="toy-wheel-handle" />
              </g><circle cx="100" cy="100" r="20" class="toy-wheel-hub" /></svg>
            </div>
            <button :if={@room.entered? && @on?} id="return-roundabout" phx-click="leave-room">← Back toward Roundabout Regard</button>
            <button
              :if={@on? && Room.appointable?(@room) && !Lab.furnished?(@lab, "pointing-calibrated")}
              id="appoint-pointer"
              phx-click="appoint-pointer"
            >Appoint this Pointing-able relation</button>
            <span
              :if={@room.entered? && Lab.furnished?(@lab, "pointing-calibrated")}
              id="pointer-appointed"
            >Pointing-able relation stands.</span>
            <button id="quiet-projection-toggle" phx-click="projection" disabled={!@record}>Projectioning-er {if @on?,
              do: "OFF",
              else: "ON"}</button>
          </div>
          <p :if={@message} id="quiet-status" role="status">{@message}</p>
        </section>
      </main>
    </Layouts.app>
    """
  end
end
