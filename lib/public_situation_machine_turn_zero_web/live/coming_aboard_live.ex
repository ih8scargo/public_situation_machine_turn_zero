defmodule PublicSituationMachineTurnZeroWeb.ComingAboardLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  import PublicSituationMachineTurnZeroWeb.SnailWeavePanel, only: [gallery_wall: 1]

  # These standings witness an ordered relation. They carry no physical coordinates.
  @standings [
    {"zero", "ZERO",
     "The seated CH and ordinary Terrestrial Computer stand together upon Ground."},
    {"pittoning", "PITTONING",
     "PITTONING holds the relation from the CH’s HERE cubical standing to the fixed NEXT cubical frame OVER ACROSS."},
    {"six", "Six-extent upper reference",
     "The upper reference lets the CH regard COB progress TOWARD the cubical frame OVER ACROSS."},
    {"source", "Retain a rehearsal ribbon",
     "The sample string begins with the seated CH at the ordinary keyboard, in the TWO–THREE locality."},
    {"ground", "Witness passage THROUGH Ground",
     "The same sample string must pass THROUGH Ground before Projectioning OVER ACROSS."},
    {"issuance", "Inspect YT line issuance from the post",
     "The post issues the YT line. The sample retains its seated CH source and Ground passage."}
  ]

  @furnishing "Furnishing Traversaling"
  @traversaling "Traversaling Furnishing"
  @material "coming-aboard-sample"
  @last_step length(@standings) - 1

  def mount(_, _, socket) do
    {:ok, assign(socket, step: 0, screen_mode: "single", office: @furnishing, inspection: nil)}
  end

  def handle_event("furnish", %{"from" => from}, socket) do
    step = socket.assigns.step

    if from == Integer.to_string(step) and step < @last_step do
      {:noreply, assign(socket, :step, step + 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("back", _, socket),
    do: {:noreply, update(socket, :step, &max(&1 - 1, 0))}

  def handle_event("layout", %{"mode" => mode}, socket) when mode in ~w(single paired),
    do: {:noreply, assign(socket, :screen_mode, mode)}

  def handle_event("office", %{"name" => office}, socket)
      when office in [@furnishing, @traversaling],
      do: {:noreply, assign(socket, :office, office)}

  def handle_event("inspect", %{"relation" => relation}, socket)
      when relation in ~w(crossing provenance registration),
      do: {:noreply, assign(socket, :inspection, relation)}

  def render(assigns) do
    standings = Enum.take(@standings, assigns.step + 1)
    furnished = MapSet.new(standings, &elem(&1, 0))

    assigns =
      assign(assigns,
        standings: standings,
        furnished: furnished,
        next: Enum.at(@standings, assigns.step + 1),
        offices: [@furnishing, @traversaling],
        screens:
          if(assigns.screen_mode == "paired",
            do: [@furnishing, @traversaling],
            else: [assigns.office]
          ),
        material: if("source" in furnished, do: @material)
      )

    ~H"""
    <Layouts.app flash={@flash} active_locality={:wedging_geometry} show_navigation={false}>
      <main id="wedging-workshop" class="min-h-screen bg-slate-950 px-5 py-8 text-slate-100">
        <section id="coming-aboard" data-step={@step} class="mx-auto max-w-6xl space-y-4">
          <.link navigate={~p"/workshop/wedging-geometry"} class="text-sm text-teal-300 underline">
            Wedging Geometry Workshop
          </.link>
          <h1 class="text-3xl font-semibold">Coming-Aboard Geometry Rehearsal</h1>
          <p>Begin at ZERO with one Constitutioning Human at the ordinary computer.</p>

          <div class="wgr-views" role="group" aria-label="Screen arrangement">
            <button
              id="ca-single"
              phx-click="layout"
              phx-value-mode="single"
              aria-pressed={to_string(@screen_mode == "single")}
            >
              One split screen
            </button>
            <button
              id="ca-paired"
              phx-click="layout"
              phx-value-mode="paired"
              aria-pressed={to_string(@screen_mode == "paired")}
            >
              Two synchronized screens
            </button>
          </div>
          <div
            :if={@screen_mode == "single"}
            class="wgr-views"
            role="group"
            aria-label="Office across both bearings"
          >
            <button
              :for={{office, index} <- Enum.with_index(@offices)}
              id={"ca-office-#{index}"}
              phx-click="office"
              phx-value-name={office}
              aria-pressed={to_string(@office == office)}
            >
              {office}
            </button>
          </div>

          <div class="wgr-views" role="group" aria-label="Rehearsal controls">
            <button id="ca-back" phx-click="back" disabled={@step == 0}>Previous standing</button>
            <button
              id="ca-furnish"
              phx-click="furnish"
              phx-value-from={@step}
              disabled={is_nil(@next)}
            >
              {if @next, do: elem(@next, 1), else: "Rehearsal boundary reached"}
            </button>
          </div>

          <div id="ca-screens" class={["grid gap-4", @screen_mode == "paired" && "lg:grid-cols-2"]}>
            <section
              :for={{office, index} <- Enum.with_index(@screens)}
              id={"ca-screen-#{index}"}
              data-view="flat"
              data-office={office}
              data-step={@step}
            >
              <h2 class="font-semibold">{office} · Longhouse Gallery Wall</h2>
              <.gallery_wall id={"ca-wall-#{index}"}>
                <:membrane>
                  <button
                    id={"ca-membrane-#{index}"}
                    type="button"
                    class="ca-membrane"
                    phx-click="inspect"
                    phx-value-relation="crossing"
                    aria-controls="ca-inspection"
                    aria-pressed={to_string(@inspection == "crossing")}
                  >Projectioning Crossing</button>
                </:membrane>
                <:xt>
                  <div class="px-4 py-[30px]" data-bearing="XT">
                    <h3 class="font-semibold text-teal-200">XT · FROM HERE</h3>
                    <span id={"ca-here-#{index}"}>THIS HERE APPROACHING LANDINGING</span>
                  </div>
                </:xt>
                <:yt>
                  <div data-bearing="YT">
                    <h3 class="font-semibold text-teal-200">YT · TOWARD OVER ACROSS</h3>
                    <span id={"ca-next-#{index}"}>THIS NEXT APPROACHING LANDINGING</span>
                    <span :if={"issuance" in @furnished} class="mt-3 block">YT line · issues from the post</span>
                  </div>
                </:yt>
              </.gallery_wall>
              <p :if={office == hd(@offices)}>
                What can the CH furnish FROM HERE? {if @next,
                  do: elem(@next, 1),
                  else: "This rehearsal stops at the issuing relation."}
              </p>
              <p :if={office != hd(@offices)}>
                What does the standing relation let the CH inspect? {elem(List.last(@standings), 2)}
              </p>
            </section>
          </div>

          <div class="wgr-views" role="group" aria-label="Inspect the current standing">
            <button
              id="ca-crossing"
              phx-click="inspect"
              phx-value-relation="crossing"
              aria-pressed={to_string(@inspection == "crossing")}
            >Inspect Projectioning Crossing</button>
            <button
              id="ca-provenance"
              phx-click="inspect"
              phx-value-relation="provenance"
              aria-pressed={to_string(@inspection == "provenance")}
            >Inspect provenance</button>
            <button
              id="ca-registration"
              phx-click="inspect"
              phx-value-relation="registration"
              aria-pressed={to_string(@inspection == "registration")}
            >Inspect UNREGISTERED geometry</button>
          </div>
          <section id="ca-inspection" aria-live="polite">
            <div :if={@inspection == "crossing"} id="ca-crossing-reading">
              <p>
                The Gallery Wall center line presents the Projectioning Crossing between XT and YT. Both offices regard these same bearings.
              </p>
              <p :if={"pittoning" in @furnished}>
                PITTONING holds HERE and NEXT in fixed relation, with XT TO XT retained as the local reference.
              </p>
              <p :if={"six" in @furnished}>
                Six extents supply the upper reference for regarding COB progress TOWARD the NEXT frame.
              </p>
            </div>
            <div
              :if={@inspection == "provenance"}
              id="ca-provenance-reading"
              data-material={@material}
            >
              <p :if={!@material}>
                The sample string enters the rehearsal at the seated CH source standing.
              </p>
              <p :if={@material}>
                Rehearsal sample “FROM HERE” · {@material} · CH at the ordinary keyboard, TWO–THREE.
              </p>
              <p :if={"ground" in @furnished} id="ca-ground-passage" data-material={@material}>
                THROUGH Ground · same sample {@material} · physical route UNREGISTERED.
              </p>
              <p :if={"issuance" in @furnished} id="ca-yt-issuance">
                YT line issuance · from the post · endpoints and attachment UNREGISTERED.
              </p>
            </div>
            <div :if={@inspection == "registration"} id="ca-registration-reading">
              <ul class="list-disc pl-5">
                <li>
                  UNREGISTERED · common CH, Seat, Ground and monitor frame and monitor UN-FOLDING transform
                </li>
                <li>
                  UNREGISTERED · physical Crossing points, PITTONING purchase and fixed NEXT frame geometry
                </li>
                <li>UNREGISTERED · six-extent reference endpoints and metric in the shared frame</li>
                <li>
                  UNREGISTERED · Ground passage route and clearance, YT post endpoints and material attachment
                </li>
              </ul>
            </div>
          </section>

          <ol
            id="ca-standings"
            class="space-y-2 border-t border-slate-600 pt-4"
            aria-label="Furnished standings"
          >
            <li :for={{id, title, relation} <- @standings} id={"ca-standing-#{id}"}>
              <strong>{title}</strong> · {relation}
            </li>
          </ol>
          <p :if={is_nil(@next)} id="ca-stop" role="status">
            Bounded witness ends at YT line issuance. Physical passage, staging and RE-STEP remain pending.
          </p>
        </section>
      </main>
    </Layouts.app>
    """
  end
end
