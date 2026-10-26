defmodule PublicSituationMachineTurnZeroWeb.ArchitectureLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Store

  def mount(_, _, socket) do
    {:ok,
     socket
     |> stream_configure(:stations, dom_id: fn s -> "stations-#{s["id"]}" end)
     |> stream_configure(:events, dom_id: fn e -> "events-#{e["id"]}" end)
     |> assign(lab: A.new(), record: nil, message: nil)
     |> refresh()}
  end

  def handle_params(params, _, socket) do
    case params do
      %{"id" => id} ->
        case Store.fetch(id) do
          {:ok, record} ->
            {:noreply,
             socket
             |> assign(record: record, lab: A.restore(record.standing), message: nil)
             |> refresh()}

          _ ->
            {:noreply,
             socket
             |> assign(
               record: nil,
               lab: A.new(),
               message:
                 "This composition is unavailable. Begin a fresh approach under the rail line."
             )
             |> refresh()}
        end

      _ ->
        if connected?(socket) do
          record = Store.create()
          {:noreply, push_patch(socket, to: ~p"/experiments/architecture?id=#{record.id}")}
        else
          {:noreply, socket}
        end
    end
  end

  def handle_event("labor", %{"action" => action}, socket) do
    with record when not is_nil(record) <- socket.assigns.record,
         {:ok, lab} <- A.operate(socket.assigns.lab, action),
         {:ok, saved} <- Store.save(record, lab.standing) do
      {:noreply, socket |> assign(record: saved, lab: lab, message: nil) |> refresh()}
    else
      {:error, %Ecto.Changeset{}} ->
        {:noreply,
         assign(socket,
           record: nil,
           message: "Another window changed this composition. Reload before further labor."
         )}

      _ ->
        {:noreply,
         assign(socket, message: "That labor is not available from the present standing.")}
    end
  end

  def handle_event("regard", %{"station" => station}, socket) do
    case A.operate(socket.assigns.lab, {:regard, station}) do
      {:ok, lab} -> {:noreply, socket |> assign(lab: lab) |> refresh()}
      _ -> {:noreply, socket}
    end
  end

  defp refresh(socket) do
    m = socket.assigns.lab
    legacy = A.legacy?(m)

    socket
    |> assign(
      next: A.next(m),
      legacy?: legacy,
      within?: A.within?(m),
      ancestry: if(legacy, do: [], else: A.local_ancestry(m)),
      station_count: length(Map.get(m.standing, "stations", []))
    )
    |> stream(:stations, Map.get(m.standing, "stations", []), reset: true)
    |> stream(:events, if(legacy, do: [], else: m.standing["events"]), reset: true)
  end

  attr :relation, :map, required: true

  defp stringing(assigns) do
    ~H"""
    <span class="rail-stringing" data-relation={@relation["id"]}>
      <span>{A.name(@relation["subject"])}</span>
      <strong>{@relation["relation"]}</strong>
      <span>{A.name(@relation["object"])}</span>
    </span>
    """
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:architecture_experiment} show_navigation={false}>
      <main id="rail-experiment" class="rail-page" data-within={to_string(@within?)}>
        <div class="rail-edition">
          <.link navigate={~p"/"}>PUBLIC EXPERIMENTS</.link><span>UNDER THE RAIL LINE / 01—04</span>
        </div>
        <section :if={@legacy?} id="round-one-witness" class="rail-witness">
          <h1>Round One · retained witness</h1>
          <p>
            This composition keeps its original Place and Appointmenting ancestry. The revised succession earns Place through TC FROM DOWN UNDER; it begins in a fresh composition.
          </p>
          <details>
            <summary>Inspect original consequential standing</summary><pre>{Jason.encode!(@lab.standing, pretty: true)}</pre>
          </details>
          <.link id="fresh-round" navigate={~p"/experiments/architecture"}>Begin under the rail line
          <.icon name="hero-arrow-right" class="w-4 h-4" /></.link>
        </section>
        <div
          :if={!@legacy?}
          id="rail-appliance"
          class="rail-appliance"
          data-stage={@next.action || "within"}
        >
          <header class="rail-bureaucracy">
            <p class="rail-micro">RAIL LINE / NOTICINGMENTING</p>
            <h2>psm bureaucracy</h2>
            <p :if={@station_count == 0}>
              The rail instrument stands. Its Stationing Localities have yet to accumulate.
            </p>
            <p :if={@station_count > 0 && !@within?}>
              {@station_count} Appointmenting {if @station_count == 1, do: "stands", else: "stand"} inherited. {if A.furnished?(
                                                                                                                     @lab,
                                                                                                                     "place-standing"
                                                                                                                   ),
                                                                                                                   do:
                                                                                                                     "Place stands THERE. You remain FROM HERE.",
                                                                                                                   else:
                                                                                                                     "The spindle winds from what already stands."}
            </p>
            <p :if={@within?}>
              The first four Appointmentings stand. You have come to stand FROM WITHIN This One Place.
            </p>
          </header>
          <div class="rail-mast" aria-hidden="true"></div>
          <div class="rail-turntable" aria-label="Reserved planar turntable">
            <div
              :if={A.furnished?(@lab, "cob-appointed")}
              id="cob"
              class="rail-cob"
              data-appointed="true"
            >
              <span class="rail-cob-top"></span><i></i><i></i><i></i><span class="rail-cob-eye"></span>
              <p>STEWARDLY CO-CAPTAIN COB <span>ALONGSIDE WITH</span></p>
            </div>
            <span :if={!A.furnished?(@lab, "cob-appointed")} class="rail-reserve">PRESENTATIONING SURFACE</span>
          </div>
          <section id="spindle-cabinet" class="rail-cabinet">
            <div class="rail-nameplate">
              <span class="rail-screw" aria-hidden="true"></span><h1>PUBLIC-SITUATION-MACHINE-</h1><span
                class="rail-screw"
                aria-hidden="true"
              ></span>
            </div>
            <div class="rail-machine-body">
              <aside
                id="wayfinding-rail"
                class="rail-wayfinding"
                aria-label="Accumulated Stationing Locality trace"
              >
                <p class="rail-micro">STATIONING<br />LOCALITIES</p>
                <svg
                  class="rail-curve"
                  viewBox="0 0 120 500"
                  preserveAspectRatio="none"
                  aria-hidden="true"
                ><path d="M100 0 C15 120 15 220 50 320 S110 440 60 500" /></svg>
                <ol id="station-trace" phx-update="stream">
                  <li
                    :for={{id, station} <- @streams.stations}
                    id={id}
                    data-regarded={to_string(@lab.regarding == station["id"])}
                  >
                    <button
                      id={"regard-#{station["id"]}"}
                      phx-click="regard"
                      phx-value-station={station["id"]}
                      aria-pressed={to_string(@lab.regarding == station["id"])}
                      aria-controls="in-stringing-deck"
                    >
                      <span class="rail-station-dot" aria-hidden="true"></span><strong>{station[
                        "appointment"
                      ]}</strong><span>{station["for"]}</span>
                    </button>
                  </li>
                </ol>
                <p :if={@station_count == 0} id="empty-trace" class="rail-empty-trace">
                  An open rail.<br />No visited locality yet.
                </p>
              </aside>
              <div class="rail-crossing-column">
                <header class="rail-now">
                  <span class="rail-micro">{if @within?, do: "NOW STANDING", else: "NOW APPROACHING"}</span><h2>
                    {if @within?, do: "FROM WITHIN", else: A.station_name(@next.station)}
                  </h2>
                </header>
                <div
                  id="projectioning-crossing"
                  class="rail-crossing"
                  aria-label="Projectioning Crossing"
                  data-place={to_string(A.furnished?(@lab, "place-standing"))}
                >
                  <div
                    :if={!A.furnished?(@lab, "approach")}
                    id="approach-field"
                    class="rail-open-field"
                  >
                    <span class="rail-approach-line" aria-hidden="true"></span><p>
                      You arrive already standing.
                    </p>
                  </div>
                  <div
                    :if={A.furnished?(@lab, "approach") && !A.furnished?(@lab, "cob-appointed")}
                    id="cob-staging"
                    class="rail-staging-body"
                  >
                    <span class="rail-ghost-cob" aria-hidden="true"></span><p>
                      This Stewardly Co-Captain COB<br /><em>TOWARD Appointmenting</em>
                    </p>
                  </div>
                  <div
                    :if={
                      A.furnished?(@lab, "cob-appointed") && !A.furnished?(@lab, "pointing-appointed")
                    }
                    id="pretend-region"
                    class="rail-pointing"
                  >
                    <div
                      id="pretend-pointing-surface"
                      class="spindle-pointer-surface"
                      phx-hook="PretendPointing"
                      phx-update="ignore"
                      tabindex="0"
                      aria-label="Try pretend pointing with pointer, touch, or arrow keys"
                    >
                      <span class="spindle-pointer-mark" aria-hidden="true"><.icon
                        name="hero-cursor-arrow-rays"
                        class="w-7 h-7"
                      /></span><span>MOVE · TOUCH · ARROW KEYS</span>
                    </div>
                    <p>
                      {if A.furnished?(@lab, "pretend-pointing"),
                        do: "Pretend Pointing Thing stands through ordinary computering.",
                        else: "Ordinary computering TOWARD a Pretend Pointing Thing."}
                    </p><small>The live trace is Regarding; motion does not Appoint.</small>
                  </div>
                  <div
                    :if={
                      A.furnished?(@lab, "pointing-appointed") &&
                        !A.furnished?(@lab, "place-standing")
                    }
                    class="rail-computer-scene"
                  >
                    <span class="rail-pointer-standing" aria-label="Pointingable Thing appointed"><.icon
                      name="hero-cursor-arrow-rays"
                      class="w-7 h-7"
                    /></span>
                    <div
                      class="rail-computer"
                      data-under={to_string(A.furnished?(@lab, "tc-down-under"))}
                    >
                      <div class="rail-computer-screen"><span>TC</span></div><div class="rail-computer-base">
                      </div>
                    </div>
                    <p :if={!A.furnished?(@lab, "tc-down-under")}>
                      Your Terrestrial Computer remains WITH you.<br /><em>TOWARD standing FROM DOWN UNDER</em>
                    </p>
                    <p :if={A.furnished?(@lab, "tc-down-under")}>
                      TC stands FROM DOWN UNDER.<br />The FOR toward Place is available; Place has yet to stand.
                    </p>
                  </div>
                  <div
                    :if={A.furnished?(@lab, "place-standing")}
                    id="this-one-place"
                    class="rail-place"
                    data-inhabited={to_string(@within?)}
                  >
                    <div class="rail-alcove-outline" aria-hidden="true"></div><div
                      id="rugging"
                      class="rail-rugging"
                    >
                      <span></span><span></span><span></span>
                    </div>
                    <div :if={@within?} id="human-within" class="rail-human"><span></span></div>
                    <p class="rail-place-invitation">
                      {if @within?, do: "You may be here.", else: "Somewhere FOR you."}
                    </p>
                    <p id="place-standing-outreading">
                      {if @within?,
                        do: "Standing FROM WITHIN This One Place",
                        else: "Place stands THERE · you remain FROM HERE"}
                    </p>
                    <span :if={!@within?} id="approaching-landinging" class="rail-landinging-there">NEXT APPROACHINGING LANDINGING<br /><small>FROM UPON This Some Other Discrete Piece of Time</small></span>
                  </div>
                </div>
                <div class="rail-crossing-name">PROJECTIONING CROSSING</div>
                <div
                  :if={A.furnished?(@lab, "human-seated") && !@within?}
                  id="moment-passageway"
                  class="rail-passageway"
                >
                  <span>FROM HERE<br /><small>This One Discrete Piece of Time</small></span>
                  <div id="current-local-moment">
                    <strong>{A.name(@lab.standing["relations"]["moment-way-through"]["subject"])}</strong><span>{@lab.standing[
                      "relations"
                    ]["moment-way-through"]["relation"]}</span><.icon
                      name="hero-arrow-long-right"
                      class="w-10 h-5"
                    />
                  </div>
                  <span>TOWARD THERE<br /><small>This Some Other Discrete Piece of Time</small></span>
                </div>
              </div>
              <div class="rail-control-column">
                <span class="rail-micro">HUMAN<br />LABOR</span>
                <div class="rail-lever-slot" aria-hidden="true">
                  <span class={if @within?, do: "rail-lever-arm is-down", else: "rail-lever-arm"}></span>
                </div>
                <button
                  :if={@next.action}
                  id="spindle-labor"
                  class="rail-lever-control"
                  phx-click="labor"
                  phx-value-action={@next.action}
                  disabled={is_nil(@record)}
                  aria-label={@next.title}
                ><.icon
                  name={
                    if @next.action == "step", do: "hero-arrow-long-right", else: "hero-arrow-down"
                  }
                  class="w-7 h-7"
                /><span>{@next.title}</span></button>
                <span :if={@within?} class="rail-stop">AT REST</span>
              </div>
            </div>
            <div
              :if={A.furnished?(@lab, "tc-down-under")}
              id="tc-down-under"
              class="rail-understanding"
            >
              <span class="rail-tc-under" aria-hidden="true"></span><span>This One Terrestrial Computer
              <strong>FROM DOWN UNDER</strong>
              · still WITH you</span>
            </div>
            <div class="rail-cabinet-feet" aria-hidden="true"><span></span><span></span></div>
          </section>
          <section id="present-standing" class="rail-present" aria-label="Human present standing">
            <div id="standinging-landinging" class="rail-present-landinging">
              <span
                :if={!A.furnished?(@lab, "human-seated") || @within?}
                class="rail-human-dot"
                aria-hidden="true"
              ></span><span
                :if={A.furnished?(@lab, "human-seated") && !@within?}
                id="human-seated"
                class="rail-source-seated"
                aria-label="Human seated FOR the new standing, still FROM HERE"
              ></span><div>
                <p id="human-from">
                  {if @within?,
                    do: "FROM THERE / now FROM HERE — UP ON the new Standinging Landinging",
                    else: "FROM HERE — UP ON This Standinging Landinging"}
                </p><small id="present-temporal-purchase">UPON {A.name(
                  @lab.standing["from"]["temporal_purchase"]
                )}</small>
              </div>
            </div>
            <p id="computer-standing">
              Already-standing Human · Ground · Terrestrial Computer alongside WITH you
            </p>
          </section>
          <section :if={@next.action} id="staging-for-standing" class="rail-staging">
            <div class="rail-section-caption">
              <span class="rail-micro">STAGING FOR STANDING</span><span>AVAILABLE WHAT-FOR / NOT YET CONSEQUENTIAL</span>
            </div>
            <h2 id="next-for">{@next.for}</h2>
            <div class="rail-chain-ancestry">
              <span class="rail-chain-label">ALREADY STANDING</span><.stringing
                :for={r <- @ancestry}
                relation={r}
              />
            </div>
            <div class="rail-chain-prospect">
              <span class="rail-chain-label">HUMAN LABOR TOWARD</span><.stringing
                :for={r <- @next.consequences}
                relation={r}
              />
            </div>
          </section>
          <section :if={@within?} id="rail-pass-complete" class="rail-arrival">
            <p class="rail-micro">THE FIRST FOUR APPOINTMENTINGS / INHERITED</p><h2>
              You may be here.
            </h2><p>
              Place was furnished THERE. Seating made passage available. Your STEP came THROUGH This, Our Current Local Moment, OVER ACROSS to the next Landinging.
            </p><p>Now standing FROM WITHIN. We stop before Inner Aperture furnishing.</p>
          </section>
          <section
            id="in-stringing-deck"
            class="rail-deck"
            aria-label="Maintained Semantical In-Stringing-Mentings"
          >
            <header>
              <p class="rail-micro">SEMANTICAL IN-STRINGING-MENTINGS / ON DECK</p><h2>
                What came to stand, and through what.
              </h2><p>
                Local ancestry remains out in the open. Regard a Stationing Locality to pick out its chains; Regarding leaves your FROM unchanged.
              </p>
            </header>
            <div id="standing-events" phx-update="stream">
              <article
                :for={{id, event} <- @streams.events}
                id={id}
                class="rail-event"
                data-regarded={to_string(@lab.regarding == event["station"])}
                data-station={event["station"]}
              >
                <details open>
                  <summary>
                    <span class="rail-event-pin" aria-hidden="true"></span><span>{A.station_name(
                      event["station"]
                    )}<strong>{event["furnishing"]}</strong></span><span class="rail-held-label">STANDS / INHERITED</span>
                  </summary>
                  <div class="rail-chain-ancestry">
                    <span class="rail-chain-label">WHAT STOOD BEFORE</span><.stringing
                      :for={r <- event["ancestry"]}
                      relation={r}
                    />
                  </div>
                  <p class="rail-event-labor">
                    HUMAN LABOR <strong>{event["labor"]}</strong> TOWARD {event["for"]}
                  </p>
                  <div class="rail-chain-held">
                    <span class="rail-chain-label">CONSEQUENTIALLY STOOD</span><.stringing
                      :for={r <- event["semantical_in_stringing_menting"]}
                      relation={r}
                    />
                  </div>
                  <p class="rail-event-from">
                    FROM {A.name(event["from"]["up_on"])}<span :if={
                      event["from"] != event["from_after"]
                    }> → FROM {A.name(event["from_after"]["up_on"])} · FROM WITHIN Place</span>
                  </p>
                </details>
              </article>
            </div>
            <p :if={@station_count == 0 && !A.furnished?(@lab, "approach")} class="rail-deck-empty">
              The first Human labor has yet to occur.
            </p>
          </section>
        </div>
        <p :if={@message} id="spindle-status" class="rail-status" role="status">{@message}</p>
        <.link
          :if={is_nil(@record) && !@legacy?}
          id="fresh-round"
          class="rail-fresh"
          navigate={~p"/experiments/architecture"}
        >Begin a fresh approach</.link>
        <footer class="rail-footer">
          LANDINGING ≠ PLACE ≠ DISCRETE PIECE OF TIME ≠ CURRENT LOCAL MOMENT
        </footer>
      </main>
    </Layouts.app>
    """
  end
end
