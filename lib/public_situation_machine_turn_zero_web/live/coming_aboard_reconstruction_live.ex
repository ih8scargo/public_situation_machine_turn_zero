defmodule PublicSituationMachineTurnZeroWeb.ComingAboardReconstructionLive do
  # Historical/trial presentation: no revised Seat ONE/Table THREE fit or protected acquisition is implied.
  # Reconcile against docs/architecture/geometry/README.md and impact-ledger.md before changing geometry.
  use PublicSituationMachineTurnZeroWeb, :live_view

  import PublicSituationMachineTurnZeroWeb.ComingAboardPanel, only: [appliance: 1]

  alias PublicSituationMachineTurnZero.Workshop.ComingAboardAppliance

  alias PublicSituationMachineTurnZero.Architecture.CrossingRehearsal
  alias PublicSituationMachineTurnZero.Workshop.SnailBody

  @stock "bearing-archway-here-square"
  @home "HOME FROM HERE"

  def mount(_, _, socket) do
    body = SnailBody.model(SnailBody.new())

    wedge = Enum.find(body.surfaces, &(&1.kind == "wedging"))

    reference = %{
      panels: CrossingRehearsal.operating_reference(),
      wedge: wedge,
      surfaces: Enum.filter(body.surfaces, &(&1.kind in ["table", "tunnel"])),
      lines: Enum.filter(body.lines, &(&1.id in ["spindle", "tunnel-mouth", "THROUGH-ALONG"]))
    }

    {:ok,
     assign(socket,
       appliance: ComingAboardAppliance.new(),
       pose: :held,
       regarding: :flat,
       purchase: nil,
       confirmed: false,
       reference: Jason.encode!(reference),
       cab_wedge: wedge.id
     )}
  end

  def handle_event("take-purchase", _, %{assigns: %{pose: :held, purchase: nil}} = socket) do
    token = Ecto.UUID.generate()
    {:reply, %{accepted: true, token: token}, assign(socket, purchase: {token, false})}
  end

  def handle_event("pull", %{"token" => token}, %{assigns: %{purchase: {token, _}}} = socket),
    do: {:reply, %{accepted: true}, assign(socket, purchase: {token, true})}

  def handle_event(
        "release-pull",
        %{"token" => token, "measurements" => %{"dx" => dx, "dy" => dy}},
        %{assigns: %{purchase: {token, true}, pose: :held}} = socket
      )
      when is_number(dx) and is_number(dy) and (dx != 0 or dy != 0),
      do:
        {:reply, %{accepted: true},
         assign(socket,
           pose: :loosened,
           purchase: nil,
           appliance: ComingAboardAppliance.open(socket.assigns.appliance, dx, dy)
         )}

  def handle_event(event, %{"token" => token}, %{assigns: %{purchase: {token, _}}} = socket)
      when event in ["cancel-pull", "release-pull"],
      do: {:reply, %{accepted: event == "cancel-pull"}, assign(socket, purchase: nil)}

  def handle_event("abandon-purchase", _, socket),
    do: {:reply, %{accepted: true}, assign(socket, purchase: nil)}

  def handle_event("puff", _, %{assigns: %{pose: pose}} = socket) when pose != :held,
    do: {:noreply, assign(socket, confirmed: true)}

  def handle_event("curve", _, %{assigns: %{pose: :loosened}} = socket),
    do: {:noreply, assign(socket, pose: :curved)}

  def handle_event("fold", _, %{assigns: %{pose: :curved}} = socket),
    do: {:noreply, assign(socket, pose: :folded, regarding: :tunnel)}

  def handle_event("flat", _, socket),
    do: {:noreply, assign(socket, regarding: :flat)}

  def handle_event("regard", _, %{assigns: %{pose: :folded}} = socket),
    do: {:noreply, assign(socket, regarding: :tunnel)}

  def handle_event("unfold", _, %{assigns: %{pose: :folded, regarding: :flat}} = socket),
    do: {:noreply, assign(socket, pose: :curved)}

  def handle_event("uncurve", _, %{assigns: %{pose: :curved}} = socket),
    do: {:noreply, assign(socket, pose: :loosened)}

  def handle_event("appliance:" <> operation, params, socket) do
    appliance =
      if socket.assigns.pose != :held or
           operation in ~w(view gallery diagonal configure machine-view road-regard inspect-part) do
        ComingAboardAppliance.operate(socket.assigns.appliance, operation, params)
      else
        socket.assigns.appliance
      end

    {:noreply, assign(socket, :appliance, appliance)}
  end

  def handle_event(_, _, socket), do: {:reply, %{accepted: false}, socket}

  def render(assigns) do
    assigns = assign(assigns, home: @home, stock: @stock)

    ~H"""
    <Layouts.app flash={@flash} active_locality={:wedging_geometry} show_navigation={false}>
      <main class="min-h-screen bg-slate-950 px-5 py-8 text-slate-100">
        <article
          id="coming-aboard"
          data-from={@home}
          data-pose={@pose}
          data-regarding={@regarding}
          class="mx-auto max-w-5xl space-y-6"
        >
          <header class="space-y-2">
            <p class="text-sm tracking-widest text-teal-300">PUBLIC-SITUATION-MACHINE-</p>
            <h1 class="text-4xl font-semibold">Coming Aboard</h1>
            <p>One HOME FROM HERE · approaching the ordinary computer</p>
          </header>

          <section
            :if={@pose == :held}
            aria-label="Toy Box"
            class="rounded-xl border border-slate-700 bg-slate-900 p-6"
          >
            <h2 id="ca-invitation" class="text-xl font-semibold">
              PULL TO STAND OPEN THE TOY BOX FROM HERE.
            </h2>
            <p id="ca-pull-help" class="mt-2 text-sm text-slate-300">
              Drag and release the tab. With a keyboard, press Space, an arrow key, then Space again.
            </p>
            <div
              id="ca-pull"
              phx-hook="PullingRing"
              phx-update="ignore"
              data-disabled="false"
              class="mt-4"
            >
              <button
                id="pulling-ring"
                type="button"
                aria-describedby="ca-pull-help"
                class="touch-none cursor-grab rounded-md bg-teal-300 px-5 py-3 font-semibold text-slate-950 active:cursor-grabbing"
              >
                Toy Box tab
              </button>
              <p class="opening-pull-live mt-3 text-sm text-slate-300" aria-live="polite"></p>
            </div>
          </section>

          <.appliance
            appliance={@appliance}
            ready={@pose != :held}
            reference={@reference}
            cab_wedge={@cab_wedge}
          />

          <section id="ca-table" class="space-y-4 rounded-xl border border-slate-700 bg-slate-900 p-5">
            <div>
              <h2
                :if={@regarding == :tunnel}
                id="ca-tunnel"
                data-stock={@stock}
                class="mb-2 text-2xl font-semibold"
              >
                Tunneling Regarding <span class="text-sm text-amber-200">· YELLOW</span>
              </h2>
              <h2 class="text-xl font-semibold">RE-SURFACING Table</h2>
              <p class="text-sm text-slate-300">
                Working locality THROUGH which WEDGING and FASHIONING are resolutioned.
              </p>
            </div>
            <div
              id="ca-composition"
              phx-hook="ComingAboardComposition"
              phx-update="ignore"
              data-pose={@pose}
              data-regarding={@regarding}
              data-source={@stock}
              data-reference={@reference}
            >
              <canvas
                id="ca-stock"
                width="640"
                height="350"
                class="h-auto w-full rounded-lg bg-slate-950"
                role="img"
                aria-label="Square and diagonal with moving XT TOWARD YT hold, curving XT TOWARD XT line, and inward triangular flap"
              ></canvas>
              <details class="mt-3 text-sm text-slate-300">
                <summary>Inspect the native Table, tunnel and Doll references</summary>
                <canvas
                  id="ca-native-reference"
                  width="640"
                  height="240"
                  class="mt-2 h-auto w-full rounded-lg bg-slate-950"
                  role="img"
                  aria-label="Separate native drawings of the Snail Table and through passage, and the pinned Doll at 45 degrees"
                ></canvas>
                <p>
                  YELLOW · The Snail Table annulus, spindle and through passage share their native frame. The pinned Doll and Glass share the paired-aperture frame. Their registration to the folding stock is open.
                </p>
              </details>
            </div>
            <p id="ca-pose-status" role="status" class="text-sm text-amber-200">
              <%= case @pose do %>
                <% :held -> %>
                  XT TOWARD YT hold · flat stock
                <% :loosened -> %>
                  XT TOWARD YT hold loosened
                <% :curved -> %>
                  YELLOW · XT TOWARD XT curved UP through six extent marks
                <% :folded -> %>
                  YELLOW · 90° inward flap with the lower-right triangle retained
              <% end %>
            </p>
            <div :if={@pose != :held} class="flex flex-wrap gap-3">
              <.control :if={@pose == :loosened} id="ca-curve" event="curve">
                Curve XT TOWARD XT UP
              </.control>
              <.control :if={@pose == :curved} id="ca-fold" event="fold">
                Fold inward along the diagonal
              </.control>
              <.control :if={@regarding == :tunnel} id="ca-flat" event="flat">
                Return to Flat Presentationing
              </.control>
              <.control :if={@pose == :folded && @regarding == :flat} id="ca-regard" event="regard">
                Regard the composed tunnel
              </.control>
              <.control :if={@pose == :folded && @regarding == :flat} id="ca-unfold" event="unfold">
                Reverse inward fold
              </.control>
              <.control :if={@pose == :curved} id="ca-uncurve" event="uncurve">
                Reverse curve
              </.control>
            </div>
          </section>

          <section :if={@pose != :held} id="ca-appointments" class="grid gap-4 sm:grid-cols-2">
            <div class="rounded-lg border border-slate-700 p-4">
              <h2 class="font-semibold">COB · ALONG THROUGH</h2>
              <p
                id="ca-cob"
                data-appointed="true"
                data-confirmed={to_string(@confirmed)}
                class="text-sm text-slate-300"
              >
                <%= if @confirmed do %>
                  Appointment confirmed through PUFFING. Human ALONGSIDE WITH COB UPON the Traversaling Seat.
                <% else %>
                  Appointed through the Toy Box pull.
                <% end %>
              </p>
              <.control :if={!@confirmed} id="ca-puff" event="puff">Confirm through PUFFING</.control>
            </div>
            <div class="rounded-lg border border-slate-700 p-4">
              <h2 class="font-semibold">Doll · UPSTANDING OVER ACROSS FROM HERE</h2>
              <p class="text-sm text-slate-300">
                YELLOW · pinned-head 45° aperture rehearsal. Pointing-able Thing and Quilling Stitching Needle retain their own ancestry.
              </p>
            </div>
          </section>

          <details
            id="ca-ancestry"
            class="space-y-2 border-t border-slate-700 pt-4"
            data-stock={@stock}
          >
            <summary>Material ancestry and qualifications</summary>
            <a
              href={~p"/images/coming-aboard/archway.png"}
              target="_blank"
              rel="noopener"
              class="text-teal-300 underline"
            >
              Open the original annotated drawing
            </a>
            <p id="ca-pocketing">
              Original FROM · HOME FROM HERE. Pocketing TOWARD awaits appointment.
            </p>
            <p>
              GREEN · original HERE square, diagonal, 90° inward instruction and retained lower-right stock in the bearing archway drawing.
            </p>
            <p>
              YELLOW · traced hinge registration, the bend and SIX metric, and common Ground, Doll, Seat and Crossing registration.
            </p>
            <p>
              YELLOW · JANUSITE ribbon continuity through the triangle and square, central cylinder and Gallery door interface, four corner folds, and Pocketing TOWARD remain in the Quarry. This stock keeps its original FROM bearing.
            </p>
            <p>
              YELLOW · upper-right triangular push UP TOWARD XT TOWARD YT. Rail navigation awaits witnessed DISASSEMBLING and REASSEMBLING.
            </p>
            <p>
              Reseating rehearsal: UP → ACROSS → DOWN, reciprocal to DOWN → ACROSS → UP. Retained stock does not confer acquired standing.
            </p>
          </details>
          <.link navigate={~p"/workshop/engineering-quarry"} class="text-sm text-teal-300 underline">
            Engineering Quarry
          </.link>
        </article>
      </main>
    </Layouts.app>
    """
  end

  attr :id, :string, required: true
  attr :event, :string, required: true
  slot :inner_block, required: true

  defp control(assigns) do
    ~H"""
    <button
      id={@id}
      type="button"
      phx-click={@event}
      class="mt-2 rounded-md border border-teal-400 px-3 py-2 text-sm text-teal-100 hover:bg-teal-950"
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
