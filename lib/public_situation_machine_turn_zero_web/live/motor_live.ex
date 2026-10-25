defmodule PublicSituationMachineTurnZeroWeb.MotorLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.{Motor, Motor.Store}

  def mount(_, _, socket) do
    {:ok,
     socket |> assign(record: nil, motor: Motor.new(), message: "Laboratory only") |> refresh()}
  end

  def handle_params(params, _, socket) do
    case params do
      %{"id" => id} ->
        case Store.fetch(id) do
          {:ok, record} ->
            {:noreply,
             socket |> assign(record: record, motor: Motor.restore(record.standing)) |> refresh()}

          _ ->
            {:noreply,
             assign(socket,
               message: "Laboratory record not found. Open /experiments/motor to begin."
             )}
        end

      _ ->
        if connected?(socket) do
          record = Store.create()
          {:noreply, push_patch(socket, to: ~p"/experiments/motor?id=#{record.id}")}
        else
          {:noreply, socket}
        end
    end
  end

  def handle_event("operation", %{"op" => op}, socket) do
    operation =
      case op do
        "fixture" -> :fixture
        "puff" -> :puff
        "point" -> :point
        "select" -> :select
        "re-seat" -> :re_seat
        "nav-step" -> {:nav_step, 1.0}
        "re-step" -> :re_step
        _ -> :invalid
      end

    apply_operation(socket, operation)
  end

  def handle_event("pivot", %{"id" => id}, socket), do: apply_operation(socket, {:pivot, id})

  def handle_event("inscribe", %{"labor" => %{"id" => id, "text" => text}}, socket),
    do: apply_operation(socket, {:in_string, id, text})

  def handle_event("rate", %{"pace" => %{"rate" => rate}}, socket) do
    case Float.parse(rate) do
      {value, ""} ->
        apply_operation(socket, {:rate, value})

      _ ->
        {:noreply,
         assign(socket, message: "Enter a rate from 0.05 to 100 laboratory units/second.")}
    end
  end

  defp apply_operation(%{assigns: %{record: nil}} = socket, _),
    do: {:noreply, assign(socket, message: "Waiting for a durable laboratory record.")}

  defp apply_operation(socket, operation) do
    case Motor.operate(socket.assigns.motor, operation) do
      {:ok, motor} ->
        result =
          if motor.standing == socket.assigns.motor.standing,
            do: {:ok, socket.assigns.record},
            else: Store.save(socket.assigns.record, motor.standing)

        case result do
          {:ok, record} ->
            {:noreply,
             socket
             |> assign(record: record, motor: motor, message: "Operation accepted")
             |> refresh()}

          {:error, _} ->
            {:noreply,
             assign(socket,
               message: "Another cockpit changed Standing. Reload before continuing."
             )}
        end

      {:error, reason} ->
        {:noreply, assign(socket, message: "Unavailable: #{reason}")}
    end
  end

  defp refresh(socket) do
    motor = socket.assigns.motor

    extents =
      Enum.map(motor.standing["extents"], fn {id, extent} ->
        %{id: id, extent: extent, pivot?: Motor.available?(motor, {:pivot, id})}
      end)

    socket
    |> assign(
      projection: Motor.projection(motor),
      availability: Motor.availability(motor),
      can_inscribe?: Motor.can_inscribe?(motor),
      labor: to_form(%{"id" => motor.standing["from"], "text" => ""}, as: :labor),
      pace: to_form(%{"rate" => to_string(motor.rate)}, as: :pace)
    )
    |> stream(:extents, extents, reset: true)
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:motor_experiment}>
      <main id="motor-lab" class="mx-auto max-w-5xl space-y-6 p-6 font-mono">
        <h1 class="text-2xl font-bold">EXPERIMENT / Constitutional motor laboratory</h1>
        <p>
          Temporary engineering instruments. Save this URL to resume Standing; Regarding resets on reload.
        </p>
        <p id="motor-status" role="status">{@message}</p>
        <div class="flex flex-wrap gap-3">
          <button
            :for={
              {op, label} <- [
                {"puff", "PUFF"},
                {"fixture", "REGISTER LAB-Y FIXTURE"},
                {"point", "POINT"},
                {"select", "SELECT"},
                {"re-seat", "RE-SEAT"},
                {"nav-step", "NAV-STEP"},
                {"re-step", "RE-STEP"}
              ]
            }
            id={"motor-#{op}"}
            phx-click="operation"
            phx-value-op={op}
            disabled={is_nil(@record) || !@availability[op]}
            class="border px-3 py-2 hover:bg-stone-200 focus-visible:outline-2 disabled:opacity-40"
          >{label}</button>
        </div>
        <div class="grid gap-6 md:grid-cols-2">
          <section class="space-y-3">
            <h2>Registered possibilities and standing</h2>
            <p id="motor-next">
              THIS NEXT PUFF-FURNISHED POSSIBILITY: {get_in(@motor.standing, ["next", "toward"]) ||
                "—"}
            </p>
            <p id="motor-restep-availability">
              RE-STEP: {if @availability["re-step"], do: "AVAILABLE", else: "UNAVAILABLE"}
            </p>
            <div id="motor-extents" phx-update="stream">
              <article :for={{dom_id, item} <- @streams.extents} id={dom_id} class="my-2 border p-3">
                <strong>{item.id}</strong>
                FROM ancestry: {item.extent["parent"] || "initial"}
                <p>
                  Kind: {item.extent["kind"]} · WHAT-FOR / OCCUPANCYING: {item.extent["what_for"] ||
                    "NONE"}
                </p>
                <button
                  :if={item.pivot?}
                  id={"motor-pivot-#{item.id}"}
                  phx-click="pivot"
                  phx-value-id={item.id}
                  class="border px-2 py-1"
                >PIVOT toward {item.id}</button>
              </article>
            </div>
            <.form for={@labor} id="motor-inscription" phx-submit="inscribe">
              <p>IN-STRINGING-MENT FROM WITHIN {@motor.standing["from"]}</p>
              <.input field={@labor[:id]} type="hidden" />
              <.input
                field={@labor[:text]}
                label="Human IN-STRINGING-MENT (at least one character)"
                required
                disabled={!@can_inscribe?}
              />
              <button
                id="motor-in-string"
                disabled={!@can_inscribe? || is_nil(@record)}
                class="border p-2 disabled:opacity-40"
              >IN-STRINGING-MENT</button>
            </.form>
            <.form for={@pace} id="motor-pace" phx-change="rate" phx-submit="rate">
              <.input
                field={@pace[:rate]}
                type="number"
                min="0.05"
                max="100"
                step="0.05"
                label="Laboratory NAV rate: 0.05–100 units/sec; ordinary reference 5"
              />
            </.form>
          </section>
          <section class="space-y-3">
            <h2>Square Projectioning Crossing / approach Regard</h2>
            <svg
              id="motor-projection"
              viewBox="-50 -10 100 120"
              role="img"
              aria-label="Curved approach and current Regard progress"
              class="aspect-square w-full border bg-stone-100"
            >
              <rect x="-45" y="-5" width="90" height="110" fill="none" stroke="gray" />
              <g :if={@projection.approach}>
                <path d={@projection.path} fill="none" stroke="black" />
                <text
                  :for={marker <- @projection.markers}
                  x={elem(marker.position, 0) + 3}
                  y={elem(marker.position, 1)}
                  font-size="4"
                >
                  MARK {marker.at}
                </text>
                <circle
                  cx={elem(@projection.position, 0)}
                  cy={elem(@projection.position, 1)}
                  r="3"
                  fill="red"
                />
              </g>
              <text x="-40" y="3" font-size="4">FROM {@projection.from}</text>
              <text x="-40" y="103" font-size="4">TOWARD {@projection.toward || "—"}</text>
            </svg>
            <dl id="motor-diagnostics" class="space-y-2 break-words border p-3">
              <dt>CURRENT FROM</dt><dd id="motor-from">{@motor.standing["from"]}</dd>
              <dt>RE-STEP TARGET / BY-WAY-OF</dt><dd id="motor-passage-target">
                {inspect(@projection.re_step)}
              </dd>
              <dt>CURRENT REGARDING</dt><dd>{@motor.bearing || "—"}</dd>
              <dt>POINTED / SELECTED</dt><dd>{@motor.pointed || "—"} / {@motor.selected || "—"}</dd>
              <dt>RE-SEATED LANDINGING</dt><dd>{inspect(@projection.approach)}</dd>
              <dt>NAV-STEP PROGRESS / RATE</dt><dd id="motor-progress">
                {@motor.progress} / {@motor.rate}
              </dd>
              <dt>MARKERS PASSED THROUGH REGARD</dt><dd>{inspect(@projection.passed_markers)}</dd>
              <dt>LAWFUL PASSAGE ANCESTRY</dt><dd>{inspect(@motor.standing["passages"])}</dd>
            </dl>
          </section>
        </div>
        <p>
          Each NAV-STEP integrates one laboratory second at the chosen rate. RE-STEP is a separate operation.
        </p>
      </main>
    </Layouts.app>
    """
  end
end
