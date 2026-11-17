defmodule PublicSituationMachineTurnZeroWeb.StringRibbonLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  alias PublicSituationMachineTurnZero.Workshop.{
    StringRibbon,
    StringRibbonGeometry,
    MaterialRibbon
  }

  def mount(_, _, socket),
    do:
      {:ok,
       assign(socket,
         state: StringRibbon.new(),
         janusite: PublicSituationMachineTurnZero.Workshop.JanusiteInheritance.new(),
         cubical: PublicSituationMachineTurnZero.Workshop.CubicalConstruction.new(),
         bench: MaterialRibbon.new(),
         exploration: PublicSituationMachineTurnZero.Workshop.GeometryExploration.new(),
         error: nil,
         selected: "table",
         motor: PublicSituationMachineTurnZero.Workshop.PairedMotor.new()
       )}

  def handle_event("cubical-inspect", %{"kind" => kind, "revision" => revision} = p, socket) do
    command =
      case kind do
        "facet" ->
          {:facet, p["choice"]}

        "orbit" ->
          case Integer.parse(p["choice"] || "") do
            {n, ""} -> {:orbit, n}
            _ -> :unsupported
          end

        "select" ->
          {:select, p["choice"]}

        "materials" ->
          :materials

        "comparison" ->
          {:comparison, p["choice"]}

        _ ->
          :unsupported
      end

    cubical(socket, revision, command)
  end

  def handle_event("cubical-select", %{"cubical" => p}, socket),
    do: cubical(socket, p["revision"], {:select, p["component"]})

  def handle_event("janusite-inspect", %{"kind" => kind, "choice" => v, "revision" => r}, socket) do
    command =
      case kind do
        "mode" ->
          {:mode, v}

        "view" ->
          {:view, v}

        "footing" ->
          {:footing, v}

        "toggle" ->
          {:toggle,
           Map.get(
             %{"stitches" => :stitches?, "loops" => :loops?, "fixture" => :hypothetical?},
             v
           )}

        _ ->
          :unsupported
      end

    janusite(socket, r, command)
  end

  def handle_event("janusite-author", %{"janusite" => p}, socket),
    do: janusite(socket, p["revision"], {:text, p["text"]})

  def handle_event(
        "explore-staging",
        %{"action" => action, "revision" => revision} = params,
        socket
      ) do
    command =
      case action do
        "pivot" ->
          case Integer.parse(params["angle"] || "") do
            {a, ""} -> {:pivot, a}
            _ -> :unsupported
          end

        "appoint" ->
          :appoint_wedging

        "stage" ->
          :stage

        "retain" ->
          :retain_furnishing

        "acquire" ->
          :acquire_landing

        "scan" ->
          :cob_scan

        "inspect" ->
          {:inspect, params["material"]}

        _ ->
          :unsupported
      end

    explore(socket, revision, {:staging, command})
  end

  def handle_event(
        "explore-command",
        %{"kind" => kind, "choice" => choice, "revision" => revision},
        socket
      ) do
    command =
      case {kind, choice} do
        {"wedge-trial", v} ->
          {:wedge_trial, v}

        {"wedge-side", v} ->
          {:wedge_side, v}

        {"view", v} ->
          {:view, v}

        {"axis", v} ->
          {:axis, v}

        {"hinge", v} ->
          {:hinge, v}

        {"select", v} ->
          {:select, v}

        {"experiment", v} ->
          case Integer.parse(v) do
            {n, ""} -> {:experiment, n}
            _ -> :unsupported
          end

        {"angle", "90"} ->
          {:angle, 90}

        {"action", "continuation-overlay"} ->
          :toggle_continuation_overlay

        {"action", "furnish"} ->
          :furnish_frame

        {"action", "select"} ->
          {:select, "table"}

        {"action", "acquire"} ->
          :acquire_frame

        {"action", "traverse"} ->
          :traverse

        {"action", "coil"} ->
          :propose_coil

        {"action", "ceiling"} ->
          :inspect_ceiling

        {"lab", v} ->
          {:lab,
           Map.get(
             %{
               "encounter" => :encounter,
               "receipt" => :local_receipt,
               "appoint" => :appoint_presence,
               "presence" => :presence,
               "exit" => :exit,
               "restomp" => :restomp,
               "ready" => :state_ready,
               "rezip" => :rezip,
               "next" => :next_furnished,
               "button" => :button_encounter
             },
             v,
             :unsupported
           )}

        _ ->
          :unsupported
      end

    explore(socket, revision, command)
  end

  def handle_event("explore-angle", %{"geometry_angle" => p}, socket) do
    case Integer.parse(p["angle"] || "") do
      {a, ""} -> explore(socket, p["revision"], {:angle, a})
      _ -> {:noreply, socket}
    end
  end

  def handle_event(
        "material-command",
        %{"kind" => kind, "choice" => value, "revision" => revision},
        socket
      ) do
    command =
      case {kind, value} do
        {"view", v} -> {:view, v}
        {"select", v} -> {:select, v}
        {"toggle", "gauges"} -> {:toggle, :gauges?}
        {"toggle", "inscriptions"} -> {:toggle, :inscriptions?}
        {"toggle", "obstacle"} -> {:toggle, :obstacle?}
        {"hand", "-1"} -> {:hand, -1}
        {"hand", "1"} -> {:hand, 1}
        {"fold", "100"} -> {:fold, 1.0}
        _ -> :unsupported
      end

    material_command(socket, revision, command)
  end

  def handle_event("material-fold", %{"material_fold" => p}, socket) do
    case Float.parse(p["q"] || "") do
      {q, ""} -> material_command(socket, p["revision"], {:fold, q / 100})
      _ -> {:noreply, assign(socket, error: "Invalid material fold proposal.")}
    end
  end

  def handle_event("material-inscribe", %{"reference" => p}, socket),
    do: material_command(socket, p["revision"], {:appoint, p["reference"], p["text"]})

  def handle_event("motor", %{"action" => action, "revision" => revision}, socket) do
    commands = %{
      "ground" => :ground,
      "pending" => :pending_un_buttoning,
      "return" => :furnish_return,
      "next" => :next,
      "earlier" => :return_first,
      "start" => {:progress, 0.0},
      "middle" => {:progress, 0.5},
      "end" => {:progress, 1.0}
    }

    with {r, ""} <- Integer.parse(revision),
         {:ok, command} <- Map.fetch(commands, action),
         {:ok, motor} <-
           PublicSituationMachineTurnZero.Workshop.PairedMotor.operate(
             socket.assigns.motor,
             r,
             command
           ) do
      {:noreply, assign(socket, motor: motor, error: nil)}
    else
      _ ->
        {:noreply,
         assign(socket, error: "Motor rehearsal prerequisite missing; no acquisition performed.")}
    end
  end

  def handle_event("inspect-object", %{"id" => id}, socket) do
    if Enum.any?(StringRibbonGeometry.objects(socket.assigns.state), &(&1.id == id)),
      do: {:noreply, assign(socket, selected: id)},
      else: {:noreply, socket}
  end

  def handle_event("inspect", %{"inspection" => p}, socket) do
    with {progress, ""} <- Float.parse(p["progress"] || ""),
         {fold, ""} <- Float.parse(p["fold"] || "") do
      apply_command(
        socket,
        p["revision"],
        {:inspect, p["view"], p["course"], progress / 100, fold / 100}
      )
    else
      _ -> {:noreply, assign(socket, error: "Inspection parameters were not accepted.")}
    end
  end

  def handle_event("furnish", %{"ribbon" => p}, socket),
    do: apply_command(socket, p["revision"], {:provide, p["text"]})

  def handle_event("register", %{"revision" => r}, socket),
    do: apply_command(socket, r, :register)

  def handle_event("take", %{"revision" => r}, socket), do: apply_command(socket, r, :take)
  def handle_event("advance", %{"revision" => r}, socket), do: apply_command(socket, r, :advance)

  def handle_event("bugs", %{"bugs" => p}, socket) do
    case Integer.parse(p["count"] || "") do
      {count, ""} -> apply_command(socket, p["revision"], {:bugs, count})
      _ -> {:noreply, assign(socket, error: "Bug appointmenting must be 1, 2 or 3.")}
    end
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  defp cubical(socket, r, command) do
    with {revision, ""} <- Integer.parse(r || ""),
         {:ok, state} <-
           PublicSituationMachineTurnZero.Workshop.CubicalConstruction.change(
             socket.assigns.cubical,
             revision,
             command
           ) do
      {:noreply, assign(socket, cubical: state)}
    else
      _ ->
        {:noreply,
         assign(socket,
           cubical: %{
             socket.assigns.cubical
             | notice: "Inspection unavailable or stale; geometry and acquisition unchanged."
           }
         )}
    end
  end

  defp janusite(socket, r, command) do
    with {rev, ""} <- Integer.parse(r || ""),
         true <- rev == socket.assigns.exploration.revision,
         {:ok, state} <-
           PublicSituationMachineTurnZero.Workshop.JanusiteInheritance.change(
             socket.assigns.janusite,
             command
           ) do
      exploration = %{socket.assigns.exploration | revision: rev + 1}
      {:noreply, assign(socket, janusite: state, exploration: exploration)}
    else
      _ ->
        {:noreply,
         assign(socket, error: "JANUSITE inspection unavailable or stale. No acquisition.")}
    end
  end

  defp explore(socket, revision, command) do
    with {r, ""} <- Integer.parse(revision || ""),
         {:ok, state} <-
           PublicSituationMachineTurnZero.Workshop.GeometryExploration.operate(
             socket.assigns.exploration,
             r,
             command
           ) do
      {:noreply, assign(socket, exploration: state)}
    else
      _ ->
        {:noreply,
         assign(socket,
           error:
             "Geometry exploration command unavailable or stale; accepted standing unchanged."
         )}
    end
  end

  defp material_command(socket, revision, command) do
    with {r, ""} <- Integer.parse(revision || ""),
         {:ok, bench} <- MaterialRibbon.operate(socket.assigns.bench, r, command) do
      {:noreply, assign(socket, bench: bench, error: nil)}
    else
      _ ->
        {:noreply,
         assign(socket,
           error:
             "Material proposal rejected: unsupported command, stale revision, or session limit (200)."
         )}
    end
  end

  defp apply_command(socket, r, command) do
    with {revision, ""} <- Integer.parse(r || ""),
         {:ok, state} <- StringRibbon.operate(socket.assigns.state, revision, command) do
      {:noreply, assign(socket, state: state, error: nil)}
    else
      _ ->
        {:noreply,
         assign(socket,
           error:
             "No consequence recorded. This action is unavailable, stale, or missing a Human marking."
         )}
    end
  end

  def render(assigns) do
    s = assigns.state
    objects = StringRibbonGeometry.objects(s)

    assigns =
      assign(assigns,
        objects: objects,
        inspected: Enum.find(objects, &(&1.id == assigns.selected)) || hd(objects),
        form: to_form(%{"text" => "", "revision" => s.revision}, as: :ribbon),
        inspection:
          to_form(
            %{
              "view" => s.view,
              "course" => s.course,
              "progress" => round(s.progress * 100),
              "fold" => round(s.fold * 100),
              "revision" => s.revision
            },
            as: :inspection
          ),
        bugs: to_form(%{"count" => s.bugs, "revision" => s.revision}, as: :bugs)
      )

    ~H"""
    <Layouts.app flash={@flash} active_locality={:wedging_geometry} show_navigation={false}>
      <main
        id="string-ribbon-workshop"
        class="sr-workshop"
        data-revision={@state.revision}
        data-material={@state.material && @state.material.id}
        data-source={@state.id}
        data-view={@state.view}
        data-course={@state.course}
        data-progress={@state.progress}
        data-fold={@state.fold}
        data-acquired="false"
      >
        <header class="sr-header">
          <div>
            <p class="sr-eyebrow">PUBLIC-SITUATION-MACHINE- / GEOMETRY WORKSHOP</p><h1>
              String-Ribbon
            </h1><p class="sr-subtitle">One material. Two offices. FROM HERE.</p>
          </div>
          <.link id="sr-coming-aboard" navigate={~p"/workshop/coming-aboard"}>Coming Aboard
          <.icon name="hero-arrow-up-right" class="size-4" /></.link>
        </header>
        <div class="sr-standing">
          <span class="sr-status-dot"></span><span>Human seated FROM HERE · fixed monitor · Table seated · SIX-extent base</span><strong>REHEARSAL / NO ACQUISITION</strong>
        </div>
        <PublicSituationMachineTurnZeroWeb.CubicalConstructionPanel.panel
          state={@cubical}
          janusite={@janusite}
        />
        <PublicSituationMachineTurnZeroWeb.JanusiteInheritancePanel.panel
          state={@janusite}
          revision={@exploration.revision}
        />
        <PublicSituationMachineTurnZeroWeb.GeometryExplorationPanel.panel state={@exploration} />
        <PublicSituationMachineTurnZeroWeb.MaterialRibbonPanel.panel
          bench={@bench}
          motor={@motor}
          cargo={@state.material && @state.material.id}
        />
        <PublicSituationMachineTurnZeroWeb.PairedMotorPanel.panel
          motor={@motor}
          bugs={@state.bugs}
          cargo={@state.material && @state.material.id}
        />
        <section class="sr-toolbar" aria-label="Shared inspection">
          <.form for={@inspection} id="sr-inspection-form" phx-change="inspect">
            <.input field={@inspection[:revision]} type="hidden" />
            <.input
              field={@inspection[:view]}
              type="select"
              label="Regarding"
              options={[
                {"Flat", "flat"},
                {"Tunneling", "tunneling"},
                {"Top", "top"},
                {"Roundabout Gallery", "roundabout"}
              ]}
            />
            <.input
              field={@inspection[:course]}
              type="select"
              label="Course witness"
              options={[
                {"Bounded String-Ribbon", "ribbon"},
                {"Square-locking manifold · provisional", "square-lock"},
                {"XT TO XT rising · provisional", "rising"},
                {"Pocketing FROM SIX · provisional", "pocketing"},
                {"Paired triangles · provisional", "triangles"}
              ]}
            />
            <.input
              field={@inspection[:progress]}
              id="sr-progress"
              type="range"
              label="Trace the furnished course"
              min="0"
              max="100"
              step="5"
            />
            <.input
              field={@inspection[:fold]}
              id="sr-fold"
              type="range"
              label="Traced triangle fold · 0°–90°"
              min="0"
              max="100"
              step="5"
            />
          </.form>
        </section>
        <p :if={@error} id="sr-error" class="sr-error" role="alert">{@error}</p>
        <div class="sr-offices">
          <section
            :for={
              {name, i} <-
                Enum.with_index(["Furnishing Traversaling COB", "Traversaling Furnishing COB"])
            }
            id={"sr-office-#{i}"}
            class="sr-office"
            data-cob={@state.id <> "/COB"}
            data-here={@state.from}
          >
            <div class="sr-office-title">
              <span>0{i + 1}</span><div>
                <p class="sr-eyebrow">
                  {if i == 0, do: "PROVIDES A TURN", else: "TAKES THAT TURN · REHEARSAL"}
                </p><h2>{name}</h2>
              </div>
            </div>
            <div
              id={"sr-square-#{i}"}
              class="sr-square"
              data-frame="coming-aboard-common-machine-v1"
              data-material={@state.material && @state.material.id}
              data-coordinate-source={@state.id}
            >
              <svg
                viewBox="0 0 500 500"
                role="img"
                aria-label={name <> " · same registered geometry and material"}
              >
                <defs>
                  <pattern id={"sr-grid-#{i}"} width="25" height="25" patternUnits="userSpaceOnUse">
                    <path d="M25 0 H0 V25" fill="none" stroke="#dbe1d8" stroke-width="0.5" />
                  </pattern>
                </defs>
                <rect width="500" height="500" fill={"url(#sr-grid-#{i})"} />
                <g
                  :for={{o, n} <- Enum.with_index(@objects)}
                  :if={o.id != "material" || i == 0 || @state.taken?}
                  id={"sr-object-#{i}-#{o.id}"}
                  data-world={Jason.encode!(o.points)}
                  data-trace={Jason.encode!(o.trace)}
                  data-material={o.material}
                  data-status={o.status}
                  aria-labelledby={"sr-inscription-#{o.id}"}
                >
                  <polygon
                    :for={face <- StringRibbonGeometry.faces(o, @state.view)}
                    points={face.drawing}
                    data-front={Jason.encode!(face.world)}
                    data-back={Jason.encode!(face.back_world)}
                    class="sr-ribbon-face"
                  />
                  <polyline
                    points={o.drawing}
                    class={["sr-geometry", "sr-#{o.id}", @inspected.id == o.id && "sr-highlight"]}
                  >
                    <title>{o.name} · {o.office} · {o.status}</title>
                  </polyline>
                  <text x={12 + rem(n, 3) * 164} y={18 + div(n, 3) * 16} class="sr-geometry-key">
                    {n + 1} {String.slice(o.name, 0, 20)}{if String.length(o.name) > 20, do: "…"}
                  </text>
                </g>
                <text
                  :if={i == 1 && @state.material && !@state.taken?}
                  x="250"
                  y="470"
                  text-anchor="middle"
                  class="sr-take-notice"
                >
                  Take the furnished turn to inspect its material.
                </text>
              </svg>
              <span class="sr-square-corner">SIX × SIX · HERE retained</span>
            </div>
            <div class="sr-office-action">
              <%= if i==0 do %>
                <button
                  :if={!@state.registered?}
                  id="sr-register"
                  phx-click="register"
                  phx-value-revision={@state.revision}
                >Register inherited FROM HERE <.icon name="hero-arrow-right" class="size-4" /></button>
                <.form
                  :if={@state.registered? && is_nil(@state.material)}
                  for={@form}
                  id="sr-furnish-form"
                  phx-submit="furnish"
                >
                  <.input field={@form[:revision]} type="hidden" />
                  <.input
                    field={@form[:text]}
                    id="sr-marking"
                    type="text"
                    label="Human marking · one bounded furnishing"
                    placeholder="FROM HERE…"
                    maxlength="160"
                    required
                  />
                  <button id="sr-furnish">Furnish this String-Ribbon
                  <.icon name="hero-arrow-right" class="size-4" /></button>
                </.form>
                <p :if={@state.material} id="sr-provided">
                  Furnished FOR Standing · {@state.material.text}
                </p>
              <% else %>
                <button
                  id="sr-take"
                  phx-click="take"
                  phx-value-revision={@state.revision}
                  disabled={is_nil(@state.material) || @state.taken?}
                >Take the furnished turn for inspection</button>
                <button
                  :if={@state.taken?}
                  id="sr-advance"
                  phx-click="advance"
                  phx-value-revision={@state.revision}
                  disabled={@state.source["active"]["position"] >= 2}
                >Advance inherited rehearsal motion</button>
                <p :if={@state.taken?} id="sr-taken">
                  Same source · motion {@state.source["active"]["position"]}/2 · no completion or acquisition
                </p>
              <% end %>
            </div>
          </section>
        </div>
        <section
          id="sr-material-ledger"
          class="sr-material-ledger"
          data-material={@state.material && @state.material.id}
          data-footings={length(@state.source["footings"])}
        >
          <div>
            <span class="sr-eyebrow">SHARED MATERIAL REGISTER</span><h2>
              {if @state.material, do: @state.material.text, else: "No material furnished yet"}
            </h2>
          </div>
          <dl :if={@state.material}>
            <div>
              <dt>Source / authored identity</dt><dd>{@state.material.id}</dd>
            </div><div>
              <dt>FROM → TOWARD</dt><dd>{@state.material.from} → {@state.material.toward}</dd>
            </div><div>
              <dt>Status</dt><dd>{@state.material.status} · not PINNED · not acquired</dd>
            </div><div>
              <dt>Native source</dt><dd>
                {@state.material.arc} · interval {inspect(@state.material.interval)} · {Float.round(
                  StringRibbonGeometry.length_of(StringRibbon.material_course(@state)),
                  3
                )} comparison extents
              </dd>
            </div>
          </dl>
        </section>
        <details :if={@state.material} id="sr-source-provenance" class="sr-source-provenance">
          <summary>Inspect the provided turn, authored piece and source office records</summary><pre>{Jason.encode!(%{material: @state.material, offices: @state.source["offices"], turn: List.last(@state.source["turns"]), events: @state.source["events"]},pretty: true)}</pre><p>
            The Groundward lead to the native arc is a provisional comparison connector; no metric physical joint or acquired path is claimed.
          </p>
        </details>
        <section
          id="sr-apparatus-offices"
          class="sr-apparatus-offices"
          aria-label="Distinct computering and Projectioning offices"
        >
          <article>
            <h3>Real Terrestrial Computer</h3><p>
              Registered through the fixed monitor. Physical hardware remains OVER ACROSS; no occupied body profile is invented.
            </p>
          </article>
          <article>
            <h3>Main Projectioning Thing</h3><p>
              Fixed monitor TOWARD the seated Human. The visible bearing is a reference, not an optical fit calculation.
            </p>
          </article>
          <article>
            <h3>Pretendinging Terrestrial Computer</h3><p>
              Preserved SnailBody DOWN UNDER source: [−0.65,−2.65,−0.45]…[0.65,−2.25,0.45]. Its body-to-gathered-manifold mounting remains provisional.
            </p>
          </article>
          <article>
            <h3>Pretendinging Projectioning Thing</h3><p>
              Preserved lower-source/receiver relay in Projection and SnailWeaveGeometry. This is a distinct office; no second real computer or new evaluator.
            </p>
          </article>
        </section>
        <section class="sr-inspection-layout">
          <div class="sr-inventory">
            <h2>Inscriptions & bearings</h2><p>
              Every visible furnishing names its office and status. Select one to emphasize it in both squares.
            </p>
            <button
              :for={{o, n} <- Enum.with_index(@objects)}
              id={"sr-inscription-#{o.id}"}
              phx-click="inspect-object"
              phx-value-id={o.id}
              aria-pressed={to_string(@inspected.id == o.id)}
            ><span>{n + 1}</span><strong>{o.name}</strong><small>{o.office} · {o.status}</small></button>
          </div>
          <aside id="sr-inspected" class="sr-inspected">
            <p class="sr-eyebrow">LOCATED WITNESS</p><h2>{@inspected.name}</h2><p>
              {@inspected.office}
            </p><strong>{@inspected.status}</strong><p>
              {length(@inspected.trace)} visible course samples / {length(@inspected.points)} source samples · {Float.round(
                @inspected.length,
                3
              )} comparison extents
            </p>
            <details>
              <summary>Inspect source coordinates and provenance</summary><pre>{Jason.encode!(%{id: @inspected.id,material: @inspected.material,points: @inspected.points},pretty: true)}</pre>
            </details>
            <.form for={@bugs} id="sr-bugs-form" phx-change="bugs">
              <.input field={@bugs[:revision]} type="hidden" /><.input
                field={@bugs[:count]}
                type="select"
                label="Lanterning Bug appointmenting"
                options={[1, 2, 3]}
              />
            </.form>
            <p>
              Presence witness only. No illumination, Footing cap, acquisition, PINNING, RE-STEP or constitutional RE-ZIPPERING is performed.
            </p>
          </aside>
        </section>
        <details id="sr-reconciliation" class="sr-reconciliation">
          <summary>Geometry qualifications & inherited offices</summary>
          <p>
            Earlier SnailWeave names “XT Furnishing COB” and “YT Traversaling COB” are retained in source records. Here they correspond to Furnishing Traversaling COB and Traversaling Furnishing COB. They are offices, not geometrical XT/YT bearings or independent COBs.
          </p>
          <p>
            Square-locking is a two-sided open sheet candidate, not a certified enclosing topology. The rising course and Pocketing course are separate provisional witnesses. Their completion is an inspection extent, never acquisition.
          </p>
          <p>
            The Pocketing reuses the native 1½-revolution helix with provisional entry and return THROUGH Seat. Its proposed enclosure of the Bobbining Thing and wedge/manifold attachment need testing.
          </p>
          <p>
            FOUR/EIGHT inner-aperture reference incidence remains unappointed: no radius, acquired Road deformation, resolving-position count or Gallery Door equivalence is inferred. SIX remains the base registration.
          </p>
          <p>
            The constitutional copper line is the whole emerging tunnel relation, not a separately drawn wire. This ribbon/sheet is a preparatory witness, not constitutional RE-ZIPPERING.
          </p>
          <p>
            Historical axle corner radius ≈0.7071 exceeds the registered Table opening radius ≈0.2571. No fitted bore or occupied joint is claimed. Slate–Inkwell–Fountain incidence is not invented.
          </p>
          <p>
            45° cabinet/Doll steering, 90° THE TOWARD PUBLIC corner and bounded historical 45° aperture course remain distinct. Paired triangles reuse the normalized archway witness as a provisional fold while HERE remains whole.
          </p>
          <p>
            Session-local workshop. Reload begins a new source registration. The third Buildinging integration and public rail-line interface remain unchanged.
          </p>
        </details>
      </main>
    </Layouts.app>
    """
  end
end
