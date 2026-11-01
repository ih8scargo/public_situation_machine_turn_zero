defmodule PublicSituationMachineTurnZeroWeb.ArchitectureLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Store

  def mount(_, _, socket),
    do:
      {:ok,
       socket
       |> assign(
         lab: A.new(),
         record: nil,
         message: nil,
         early?: true,
         refurbished?: true,
         inaugural?: false,
         geometry?: true,
         guide_open?: false
       )
       |> refresh()}

  def handle_params(params, _, socket) do
    early? = params["mode"] != "retained"
    refurbished? = params["mode"] not in ["early", "retained"]

    socket =
      assign(socket,
        early?: early?,
        refurbished?: refurbished?,
        inaugural?: params["mode"] in ["appliance", "inaugural"],
        geometry?:
          params["mode"] not in ["companion", "appliance", "inaugural", "early", "retained"],
        guide_open?:
          if(socket.assigns.early? != early?, do: !early?, else: socket.assigns.guide_open?)
      )

    case params do
      %{"id" => id} ->
        case Store.fetch(id) do
          {:ok, r} ->
            {:noreply,
             socket
             |> assign(
               record: r,
               lab: A.restore(r.standing),
               geometry?: socket.assigns.geometry? && !A.legacy?(A.restore(r.standing)),
               message: nil
             )
             |> refresh()}

          _ ->
            {:noreply,
             socket
             |> assign(
               record: nil,
               lab: A.new(),
               message: "This composition is unavailable. Begin a fresh opening."
             )
             |> refresh()}
        end

      _ ->
        if connected?(socket) do
          r = Store.create()

          {:noreply,
           push_patch(socket,
             to: ~p"/experiments/architecture?id=#{r.id}&mode=#{params["mode"] || "geometry"}"
           )}
        else
          {:noreply, socket}
        end
    end
  end

  def handle_event("crossing-rehearsal", params, %{assigns: %{geometry?: true}} = socket),
    do: consequence(socket, {:crossing_rehearsal, params})

  def handle_event(_, _, %{assigns: %{geometry?: true}} = socket),
    do: {:reply, %{accepted: false}, socket}

  def handle_event("ordinary-guide", %{"open" => open}, socket) when is_boolean(open),
    do: {:reply, %{accepted: true}, assign(socket, :guide_open?, open)}

  def handle_event("inspect", %{"relation" => id}, socket) do
    case A.operate(socket.assigns.lab, {:inspect, id}) do
      {:ok, lab} -> {:noreply, socket |> assign(:lab, lab) |> refresh()}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("close-locality", _, socket) do
    lab = %{socket.assigns.lab | regarding: %{socket.assigns.lab.regarding | inspected: nil}}
    {:noreply, socket |> assign(:lab, lab) |> refresh()}
  end

  def handle_event("abandon-purchase", _, socket) do
    {:ok, lab} = A.operate(socket.assigns.lab, :abandon_purchase)
    {:reply, %{accepted: true}, assign(socket, :lab, lab)}
  end

  def handle_event("take-purchase", _, socket) do
    case A.operate(socket.assigns.lab, :take_purchase) do
      {:ok, lab} ->
        {:reply, %{accepted: true, token: lab.pulling.token}, assign(socket, :lab, lab)}

      _ ->
        {:reply, %{accepted: false}, socket}
    end
  end

  def handle_event("pull", %{"token" => token}, socket) do
    case A.operate(socket.assigns.lab, {:pull, token}) do
      {:ok, lab} -> {:reply, %{accepted: true}, assign(socket, :lab, lab)}
      _ -> {:reply, %{accepted: false}, socket}
    end
  end

  def handle_event(event, %{"token" => token} = params, socket)
      when event in ["release-pull", "cancel-pull"] do
    m = socket.assigns.lab

    if event == "release-pull" && match?(%{token: ^token, moved?: true}, m.pulling) do
      consequence(socket, {:opening_pull, params["measurements"] || %{}})
    else
      case A.operate(m, {:cancel_pull, token}) do
        {:ok, lab} -> {:reply, %{accepted: true}, assign(socket, :lab, lab)}
        _ -> {:reply, %{accepted: false}, socket}
      end
    end
  end

  def handle_event("stage-feed", params, socket) do
    case A.operate(socket.assigns.lab, {:opening_feed, params}) do
      {:ok, lab} -> {:reply, %{accepted: true}, socket |> assign(:lab, lab) |> refresh()}
      _ -> {:reply, %{accepted: false}, socket}
    end
  end

  def handle_event("second-puff", _, %{assigns: %{early?: false}} = socket),
    do: consequence(socket, :second_puff)

  def handle_event("second-puff", _, socket), do: {:reply, %{accepted: false}, socket}

  def handle_event("diorama-operation", params, %{assigns: %{early?: false}} = socket),
    do: consequence(socket, {:diorama_operation, params})

  def handle_event("traversal-rehearsal", params, %{assigns: %{refurbished?: true}} = socket) do
    if socket.assigns.inaugural? &&
         !PublicSituationMachineTurnZero.Architecture.Inaugural.model(socket.assigns.lab)[
           "across"
         ] do
      {:reply, %{accepted: false}, socket}
    else
      consequence(socket, {:traversal_rehearsal, params})
    end
  end

  def handle_event("inaugural", params, %{assigns: %{inaugural?: true}} = socket),
    do: consequence(socket, {:inaugural, params})

  def handle_event("puff", _, socket), do: consequence(socket, :puff)
  def handle_event("cob-up-over", _, socket), do: consequence(socket, :opening_appoint)
  def handle_event(_, _, socket), do: {:reply, %{accepted: false}, socket}

  defp consequence(socket, op) do
    with record when not is_nil(record) <- socket.assigns.record,
         {:ok, lab} <- A.operate(socket.assigns.lab, op),
         {:ok, saved} <- Store.save(record, lab.standing) do
      {:reply, %{accepted: true},
       socket |> assign(record: saved, lab: %{lab | pulling: nil}, message: nil) |> refresh()}
    else
      {:error, %Ecto.Changeset{}} ->
        {:ok, saved} = Store.fetch(socket.assigns.record.id)

        {:reply, %{accepted: false},
         socket
         |> assign(
           record: saved,
           lab: A.restore(saved.standing),
           message: "The held standing has been resumed."
         )
         |> refresh()}

      _ ->
        {:reply, %{accepted: false}, socket}
    end
  end

  defp refresh(socket) do
    m = socket.assigns.lab
    geometry = m.standing["opening_geometry"]
    traversal = PublicSituationMachineTurnZero.Architecture.TraversalCourse.model(m)
    floor = if(traversal, do: traversal["course"]["floor_y"], else: -1.2)

    model =
      if geometry,
        do:
          Map.merge(geometry, %{
            "early" => socket.assigns.early?,
            "refurbished" => socket.assigns.refurbished?,
            "traversal" => traversal,
            "crossing_rehearsal" =>
              PublicSituationMachineTurnZero.Architecture.CrossingRehearsal.model(m),
            "inaugural" =>
              if(socket.assigns.inaugural?,
                do: PublicSituationMachineTurnZero.Architecture.Inaugural.model(m)
              ),
            "cutaway" =>
              PublicSituationMachineTurnZero.Architecture.ApplianceCutaway.model(floor),
            "projection_body" =>
              PublicSituationMachineTurnZero.Architecture.ProjectionBody.model(m),
            "inscription_surfaces" =>
              PublicSituationMachineTurnZero.Architecture.Inscriptioning.retained(m.standing),
            "inspected_relation" => m.regarding.inspected,
            "rugging" => PublicSituationMachineTurnZero.Architecture.Rugging.presentation(m),
            "locked" => m.opening_stage,
            "accomplished" => A.complete?(m),
            "diorama" => PublicSituationMachineTurnZero.Architecture.Diorama.presentation(m)
          }),
        else: %{}

    assign(socket,
      legacy?: A.legacy?(m),
      opened?: A.opened?(m),
      puffed?: A.puffed?(m),
      appointed?: A.complete?(m),
      model: model,
      locked?: !is_nil(m.opening_stage),
      held: if(m.regarding.inspected, do: m.standing["relations"][m.regarding.inspected])
    )
  end

  def render(%{geometry?: true} = assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:architecture_experiment} show_navigation={false}>
      <main class="crossing-page">
        <p :if={@message} id="rehearsal-status">
          {@message}
          <.link id="fresh-composition" navigate={~p"/experiments/architecture"}>Begin a fresh geometry rehearsal</.link>
        </p>
        <header>
          <p>PUBLIC-SITUATION-MACHINE- / GEOMETRY REHEARSAL</p><h1>
            Paired apertures · one inaugural approach
          </h1><p>
            YOUR VERY OWN SITUATIONING DOLLHOUSE FROM HERE · PULL TO STAND OPEN THE TOY BOX FROM HERE
          </p>
        </header>
        <section
          id="crossing-rehearsal"
          phx-hook="CrossingRehearsal"
          phx-update="ignore"
          data-model={Jason.encode!(@model["crossing_rehearsal"])}
          data-ready={to_string(!is_nil(@record))}
        >
          <div class="crossing-face">
            <div class="steering-purchase">
              <strong>PULL THE STEERING WHEEL TOWARD YOU TO SEAT YOUR MONITOR WITHIN THE PUBLIC-SITUATION-MACHINE-.</strong><p>
                Projected seating only. The actual monitor stays where it is.
              </p>
              <button
                id="crossing-wheel"
                type="button"
                aria-label="Pull steering wheel: drag downward; arrows also rehearse the pull"
              >↕</button>
              <.input
                id="crossing-pull"
                name="crossing-pull"
                type="range"
                min="0"
                max="1"
                step="0.01"
                value="0"
                class="crossing-range"
                aria-label="Paired-aperture steering pull"
              />
            </div>
            <svg
              id="crossing-scene"
              viewBox="0 0 1100 1000"
              role="img"
              aria-label="One fixed geometric model shown in the selected planar section"
            ></svg>
          </div>
          <aside class="crossing-instruments">
            <strong>REGARDING SLICES · GEOMETRY STAYS FIXED</strong>
            <.input
              id="crossing-slice"
              name="crossing-slice"
              type="select"
              value="all"
              options={[
                {"All references", "all"},
                {"Monitor plane", "monitor"},
                {"Inner aperture", "inner"},
                {"Projected cabinet face", "cabinet"},
                {"Doll-side aperture", "doll"},
                {"Pinned-head SEAM", "seam"},
                {"Groundward reference", "ground"},
                {"Far side of monitor", "far"}
              ]}
            />
            <label for="crossing-yaw">Turn Regarding AROUND ABOUT central axis</label><.input
              id="crossing-yaw"
              name="crossing-yaw"
              type="range"
              min="-180"
              max="180"
              step="1"
              value="-30"
              class="crossing-range"
            />
            <div class="crossing-view-buttons">
              <button id="crossing-front" type="button">Frontal</button><button
                id="crossing-oblique"
                type="button"
              >Oblique</button><button id="crossing-ground" type="button">Groundward</button><button
                id="crossing-side"
                type="button"
              >Side section</button>
            </div>
            <button id="crossing-find-seam" type="button">Regard ALONG THROUGH the SEAM</button><p id="crossing-seam-notice">
              At the pinned head: Looking THROUGHING THROUGHING Glass. Choose its slice; no view moves automatically.
            </p>
            <label for="crossing-feed">Offer Pretendinging Stick THROUGH the pinned-head aperture</label><.input
              id="crossing-feed"
              name="crossing-feed"
              type="range"
              min="0"
              max="1"
              step="0.01"
              value="0"
              class="crossing-range"
            />
            <button id="crossing-receive" type="button">COB takes hold · appoint Pointing-able Thing</button>
            <output id="crossing-status" aria-live="polite"></output><pre id="crossing-coordinates"></pre>
            <p>
              HYPOTHESIS: paired hinges share the pinned-head axis. Their midpoint planes coincide; complementary angles alone do not prove a mechanical crossing. Craft seating is unresolved.
            </p>
            <p id="crossing-doll-duty"></p><p>
              25 indexed references: THE / PUBLIC / SITUATION / MACHINE — 3 / 6 / 9 / 7. Proposed 5 × 5 square, SIX depth units; not a physical JANUSITE fold.
            </p>
          </aside>
        </section>
        <footer>
          STOP AT RECEPTION · no further PUFFING, traversal or consequential departure in this rehearsal.
        </footer>
      </main>
    </Layouts.app>
    """
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:architecture_experiment} show_navigation={false}>
      <main
        id="elementary-opening"
        class={[
          "elementary-opening",
          @early? && "projection-appliance",
          @refurbished? && "refurbished-appliance"
        ]}
      >
        <header>
          <.link navigate={~p"/"}>PUBLIC-SITUATION-MACHINE-</.link><span>ELEMENTARY OPENING / FROM HERE</span>
        </header>
        <section :if={@legacy?} id="earlier-witness">
          <h1>This standing keeps its own ancestry.</h1>
          <details>
            <summary>Inspect retained witness</summary><pre>{Jason.encode!(@lab.standing, pretty: true)}</pre>
          </details>
          <.link id="fresh-rehearsal" navigate={~p"/experiments/architecture"}>Begin the elementary opening</.link>
        </section>
        <section :if={!@legacy?} id="opening-work">
          <div class="elementary-intro">
            <p class="opening-eyebrow">HUMAN-DIRECTED REGARDING · FROM HERE</p>
            <h1>ONE APPLIANCE · FOR PROJECTIONING</h1>
          </div>
          <div
            id="opening-geometry"
            phx-hook="ElementaryOpening"
            phx-update="ignore"
            data-model={Jason.encode!(@model)}
            data-ready={to_string(!is_nil(@record))}
          >
            <div id="projection-stage" class="projection-stage">
              <svg
                id="opening-space"
                viewBox="-250 -390 1300 1300"
                aria-label="The same elementary geometry, projected through the chosen Regarding"
                role="group"
              ></svg>
              <article
                :if={@early?}
                id="projection-reading"
                class="projection-reading"
                hidden
                aria-label="Inspectable provisional geometric relations"
              >
              </article>
              <article
                id="xt-surface-reading"
                class="xt-surface-reading"
                hidden
                aria-label="Flat presentation of retained XT-axle inscription"
              >
              </article>
              <aside :if={@refurbished?} id="cob-encounter" class="cob-encounter" hidden>
                <strong id="cob-next-notice"></strong>
                <p id="cob-next-instruction"></p>
                <button id="take-hold-cob" type="button">Take hold of COB</button>
                <button id="appoint-traversal-course" type="button" hidden>Appoint offered NAV course</button>
                <div id="cob-handoff-controls" hidden>
                  <label for="cob-handoff-depth">Hand the stick THROUGH →</label>
                  <.input
                    id="cob-handoff-depth"
                    name="handoff-depth"
                    type="range"
                    min="0"
                    max="100"
                    step="1"
                    value="0"
                    class="crossing-range"
                  />
                  <button id="complete-cob-handoff" type="button" disabled>Let COB take hold</button>
                </div>
              </aside>
            </div>
            <div id="appliance-cab" class="appliance-cab">
              <div :if={@refurbished?} class="cab-heading">
                <span>PUBLIC-SITUATION-MACHINE-</span><strong>COB / HUMAN-FACING CAB</strong>
              </div>
              <nav
                :if={@early?}
                id="early-appliance-tools"
                class="early-appliance-tools"
                aria-label="Projectioning and COB rehearsal purchases"
              >
                <button :if={@refurbished?} id="regard-front" type="button">Front</button>
                <button :if={@refurbished?} id="regard-left" type="button">Left approach</button>
                <button :if={@refurbished?} id="regard-right" type="button">Right approach</button>
                <button :if={@refurbished?} id="regard-back" type="button">Back cutaway</button>
                <button :if={@refurbished?} id="pointing-flick-cab" type="button">Flick</button>
                <button id="regard-groundward" type="button">Groundward</button>
                <button id="regard-upside" type="button">Field Upside</button>
                <button id="regard-through-cob" type="button">THROUGH COB</button>
                <button id="reset-cob-rehearsal" type="button">Reset course position</button>
                <button id="human-quarter-rehearsal" type="button">Human 90°</button>
                <button id="skate-forward" type="button">Skate +</button>
                <button id="skate-pause" type="button">Pause</button>
                <button id="skate-reverse" type="button">Skate −</button>
                <.input
                  id="resolution-target"
                  type="select"
                  name="resolution-target"
                  aria-label="Point THROUGH BY COB toward a geometric target"
                  value=""
                  class="min-w-0 max-w-full rounded border border-[#9aa990] bg-[#f4f5ed] px-2 py-1 text-sm"
                  prompt="Point THROUGH BY COB…"
                  options={
                    Enum.map(@model["projection_body"]["targets"] || [], &{&1["id"], &1["id"]})
                  }
                />
              </nav>
              <div class="regarding-approach" aria-label="Human-directed approach controls">
                <button id="regarding-zoom-out" type="button" aria-label="Regard from farther away">−</button>
                <button id="regarding-zoom-reset" type="button">Whole extent</button>
                <button
                  id="regarding-zoom-in"
                  type="button"
                  aria-label="Approach the projected apparatus"
                >+</button>
              </div>
              <section :if={@inaugural?} id="inaugural-instruments" class="inaugural-instruments">
                <strong>INHERITED INAUGURAL APPROACH</strong>
                <output id="inaugural-status" aria-live="polite"></output>
                <button id="inaugural-first-puff" type="button">First PUFFING · receive compact HERE WITHIN</button>
                <button id="inaugural-second-puff" type="button">Second PUFFING · receive ACROSS extent</button>
                <button id="inaugural-third-puff" type="button">Third PUFFING · receive OVER ACROSS possibility</button>
                <button id="inspect-inaugural-reference" type="button">Observationing Annex · inspect references</button>
                <button id="inspect-cabinet-seat" type="button">Cabinet Seat · existing Co-Situationing Doll</button>
                <article id="cabinet-seat-reading" hidden></article>
                <p>
                  Cab NAVIGATIONING and COB TRAVERSALING remain distinct. Human monitor distance: 24 model units; not a physical measurement.
                </p>
              </section>
              <section
                :if={@refurbished?}
                id="mouse-treadmill-panel"
                class="mouse-treadmill-panel"
                hidden
              >
                <button id="take-cob-regarding" type="button">TAKE HOLD OF COB’S REGARDING</button>
                <button id="release-cob-regarding" type="button" hidden>Release Regarding · observe externally</button>
                <p class="treadmill-caption">
                  MOUSE TREADMILL · press and hold a region. Release or leave it to coast.
                </p>
                <div
                  id="mouse-treadmill"
                  class="mouse-treadmill"
                  role="group"
                  aria-label="Circular traversal purchase surface, separate from Regarding steering"
                >
                  <button
                    :for={
                      {id, label} <- [
                        {"rest", "REST"},
                        {"gentle", "GENTLE"},
                        {"working", "WORKING"},
                        {"strong", "STRONG"},
                        {"brake", "SLOW"}
                      ]
                    }
                    id={"treadmill-#{id}"}
                    data-treadmill-purchase={id}
                    type="button"
                    aria-pressed="false"
                  >{label}</button>
                </div>
                <output id="treadmill-response" aria-live="off"></output>
                <button id="cob-immediate-stop" type="button">STOP NOW</button>
                <button id="cob-reverse-drive" type="button" aria-pressed="false">Forward / reverse drive</button>
                <label for="cob-lateral-steering">Steer COB within the furnished tacks</label>
                <.input
                  id="cob-lateral-steering"
                  name="cob-steering"
                  type="range"
                  min="-1"
                  max="1"
                  step="0.05"
                  value="0"
                  class="crossing-range"
                />
                <output id="stopping-sheet-status" aria-live="polite"></output>
                <button id="grasp-stopping-sheet" type="button" disabled>Take stopping purchase · BANK sheet</button>
                <button id="release-stopping-sheet" type="button" disabled>Release sheet purchase</button>
                <article id="course-sign-reading" class="course-sign-reading" hidden></article>
                <details id="treadmill-experiment">
                  <summary>Purchase settings / inspection</summary>
                  <p>
                    120 ms detent. Gentle 0.45, working 0.9, strong 1.5 units/s²; slow 1.8; release coasts down at 0.28. Maximum speed 2.4 units/s. Hold Space or Enter as an alternative.
                  </p>
                  <label for="treadmill-strength">Accelerating purchase multiplier</label>
                  <.input
                    id="treadmill-strength"
                    name="purchase-strength"
                    type="range"
                    min="0.5"
                    max="1.5"
                    step="0.1"
                    value="1"
                    class="crossing-range"
                  />
                </details>
                <p id="regarding-wheel-reserve">
                  REGARDING STEERING · four-square purchases retained in the Diorama; separate wheel locality reserved.
                </p>
              </section>
              <section :if={@refurbished?} id="traversal-instruments" class="traversal-instruments">
                <label for="crossing-width">Projectioning Crossing width</label>
                <.input
                  id="crossing-width"
                  type="range"
                  name="crossing-width"
                  value="3.2"
                  min="1.8"
                  max="4.0"
                  step="0.1"
                  class="crossing-range"
                  aria-label="Resize the square Projectioning Crossing"
                />
                <output id="traversal-status" aria-live="polite">Flick course available after appointment</output>
                <output id="janusite-quantity">JANUSITE · base course proposed</output>
                <div class="road-issuance">
                  <button id="appoint-road-continuation" type="button">Appoint return loop</button>
                  <button id="issue-janusite" type="button">Issue JANUSITE</button>
                </div>
                <button
                  id="toggle-top-down"
                  type="button"
                  aria-controls="top-down-outreading"
                  aria-expanded="true"
                >Top-down Outreading</button>
                <div id="top-down-outreading" class="top-down-outreading">
                  <svg
                    id="course-map"
                    viewBox="0 0 240 260"
                    role="img"
                    aria-label="Top-down view of the same furnished course, Flick, COB and seat marker"
                  ></svg>
                </div>
                <div class="course-notice-controls">
                  <button id="inspect-course-sign" type="button">Inspect next notice</button>
                  <button id="reverse-course-sign" type="button">Notice reverse</button>
                </div>
                <button id="toggle-resolution-traces" type="button">Resolutioning traces</button>
              </section>
            </div>
            <p id="regarding-condition" class="opening-condition">REGARDING · planar sheet</p>
          </div>
          <section
            id="operation-guide"
            class="operation-guide-reserve"
            aria-label="Ordinary operation guide and inspection metadata"
          >
            <details
              id="ordinary-operation-details"
              open={@guide_open?}
              data-guide-open={to_string(@guide_open?)}
            >
              <summary>Ordinary operation guide and retained architectural witnesses</summary>
              <.link
                :if={@record && @early?}
                navigate={~p"/experiments/architecture?id=#{@record.id}&mode=retained"}
              >Regard retained drawer rehearsal</.link>
              <p class="opening-eyebrow">
                ORDINARY OPERATION GUIDE · RETAINED MATERIAL IS WITHIN THE APPARATUS
              </p>
              <p id="carpet-operation-hint" class="opening-hint">
                Magic Carpet: drag upward to unroll; Shift-drag to align. Arrow keys adjust; Page Up seats the square.
              </p>
              <p class="opening-hint">
                Grasp a bottom handle to turn the page. Arrow keys turn a focused handle.
              </p>
              <p :if={!@opened?} id="pull-invitation" class="opening-hint">
                Take the hollow square tab and pull. Keyboard: Enter, arrow, Enter.
              </p>
              <div :if={@opened? && !@puffed?} id="opening-bellows" class="elementary-bellows">
                <button
                  id="puffing-squeeze"
                  phx-click="puff"
                  aria-label="Squeeze THIS ONE BIG BELLOWING THING"
                ><span aria-hidden="true">≡</span>Squeeze</button>
                <p>THIS ONE BIG BELLOWING THING · TOWARD extent FOR possibility</p>
              </div>
              <section :if={@puffed? && !@appointed?} id="stick-furnishing" class="stick-furnishing">
                <p class="opening-eyebrow">
                  PRETENDING STICK FOR POINTING THINGS OUT AROUND ABOUT HERE
                </p>
                <p :if={!@locked?} class="opening-hint">
                  Grasp the stick at the square aperture. Draw it THROUGH, then release for COB to take hold.
                </p>
                <p :if={@locked?} id="stick-locked" class="opening-hint">
                  STAGING FOR STANDING · cylinder and COB purchase furnished through your gesture.
                </p>
                <button :if={@locked?} id="cob-up-over" phx-click="cob-up-over">Complete COB’s take-hold</button>
              </section>
              <div :if={@appointed?} id="appointment-noticing" class="appointment-noticing">
                <p>Inspect the retained appointment on its furnished XT-axle surface.</p>
                <button
                  id="inspect-appointed"
                  phx-click="inspect"
                  phx-value-relation="pointingable-standing"
                >Regard the appointed bearing and its ancestry</button>
              </div>
              <section :if={@appointed?} id="diorama-instructionings" class="diorama-instructionings">
                <p id="diorama-operation-notice" class="opening-hint">
                  Compose yellow CH at the XT edge and green COB at the bottom. Arrows explore; Enter takes purchase.
                  PUSH BACK: drag upward or use arrows, Home / End. Complete the rail to seat LOCK; release at its return.
                  Flick at the Pointing-able handle to change Regarding.
                </p>
                <details id="wedge-instructioning-reserve">
                  <summary>Instructioning reserve · inherited material</summary>
                  <article
                    :for={mark <- PublicSituationMachineTurnZero.Architecture.Diorama.markings()}
                    id={"material-" <> mark["id"]}
                    data-material-family={mark["family"]}
                  >
                    <p>{mark["inscription"]}</p><small>{mark["status"]} · {mark["source"]}</small>
                  </article>
                  <p>
                    Ground-side Pretending corresponds with one Field-side Rugging surface.
                    Its aperture-derived hinge, growth and seating remain experimental. The aperture stays UP OVER the Floor.
                    The earlier yellow fold is retired; COB's drawer course reveals the complementary Gallery Wall.
                  </p>
                  <button
                    id="inspect-wedge-ancestry"
                    phx-click="inspect"
                    phx-value-relation="opening-accomplished"
                  >Regard the inherited wireframe ancestry</button>
                </details>
              </section>
              <aside
                :if={@held}
                id="held-reading"
                class="elementary-reading"
                data-held-relation={@lab.regarding.inspected}
              >
                <button
                  id="close-locality"
                  phx-click="close-locality"
                  aria-label="Close local reading"
                ><.icon
                  name="hero-x-mark"
                  class="w-4 h-4"
                /></button>
                <p class="opening-eyebrow">INSPECTION METADATA · RETAINED SURFACE ANCESTRY</p>
                <p>
                  {A.name(@held["subject"])}
                  <strong>{@held["relation"]}</strong> {A.name(@held["object"])}.
                </p>
                <small>Through {@held["provenance"]}</small>
                <button
                  :if={@held["reference_geometry"]}
                  id="follow-reference"
                  phx-click="inspect"
                  phx-value-relation={@held["reference_geometry"]}
                >Through the inherited square aperture</button>
                <button
                  :if={@held["through_by_way_of"]}
                  id="follow-predecessor"
                  phx-click="inspect"
                  phx-value-relation={@held["through_by_way_of"]}
                >Through the prior standing</button>
              </aside>
            </details>
          </section>
        </section>
        <p :if={@message} id="rehearsal-status" role="status">{@message}</p>
        <.link :if={is_nil(@record)} id="fresh-composition" navigate={~p"/experiments/architecture"}>Begin a fresh opening</.link>
        <footer>REGARDING / STAGING FOR STANDING / ACCOMPLISHED STANDING</footer>
      </main>
    </Layouts.app>
    """
  end
end
