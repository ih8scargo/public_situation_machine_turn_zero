defmodule PublicSituationMachineTurnZeroWeb.ArchitectureLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.Store

  def mount(_, _, socket),
    do: {:ok, socket |> assign(lab: A.new(), record: nil, message: nil) |> refresh()}

  def handle_params(params, _, socket) do
    case params do
      %{"id" => id} ->
        case Store.fetch(id) do
          {:ok, r} ->
            {:noreply,
             socket |> assign(record: r, lab: A.restore(r.standing), message: nil) |> refresh()}

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
          {:noreply, push_patch(socket, to: ~p"/experiments/architecture?id=#{r.id}")}
        else
          {:noreply, socket}
        end
    end
  end

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

    model =
      if geometry,
        do:
          Map.merge(geometry, %{
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

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:architecture_experiment} show_navigation={false}>
      <main id="elementary-opening" class="elementary-opening">
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
            <p class="opening-eyebrow">
              {cond do
                !@opened? -> "ONE PLANAR FURNISHING"
                !@puffed? -> "WIREFRAME STANDING TOWARD THIS ONE PLACE"
                !@appointed? -> "JANUSITE EXTENT FOR POSSIBILITY"
                true -> "APPOINTED THROUGH BY WAY OF COB"
              end}
            </p>
            <h1>
              {cond do
                !@opened? -> "Stand UP the Toy Box FROM HERE."
                !@puffed? -> "Furnish an extent FOR possibility."
                !@appointed? -> "A bearing THROUGH. Chosen by you."
                true -> "This One Pointing-able Thing."
              end}
            </h1>
          </div>
          <div
            id="opening-geometry"
            phx-hook="ElementaryOpening"
            phx-update="ignore"
            data-model={Jason.encode!(@model)}
            data-ready={to_string(!is_nil(@record))}
          >
            <svg
              id="opening-space"
              viewBox="100 0 600 520"
              aria-label="The same elementary geometry, projected through the chosen Regarding"
              role="img"
            ></svg>
            <p id="regarding-condition" class="opening-condition">REGARDING · planar sheet</p>
          </div>
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
            <p class="opening-eyebrow">PRETENDING STICK FOR POINTING THINGS OUT AROUND ABOUT HERE</p>
            <p :if={!@locked?} class="opening-hint">
              Grasp the stick at the square aperture. Draw it THROUGH, then release for COB to take hold.
            </p>
            <p :if={@locked?} id="stick-locked" class="opening-hint">
              STAGING FOR STANDING · cylinder and COB purchase furnished through your gesture.
            </p>
            <button :if={@locked?} id="cob-up-over" phx-click="cob-up-over">Complete COB’s take-hold</button>
          </section>
          <div :if={@appointed?} id="appointment-noticing" class="appointment-noticing">
            <p>COB stands ALONGSIDE WITH you THROUGH this our current local moment.</p>
            <button
              id="inspect-appointed"
              phx-click="inspect"
              phx-value-relation="pointingable-standing"
            >Regard the appointed bearing and its ancestry</button>
          </div>
          <section :if={@appointed?} id="diorama-instructionings" class="diorama-instructionings">
            <p class="opening-eyebrow">ONE FLOOR–WALL · CO-LABORINGING</p>
            <p id="diorama-operation-notice">
              Grasp the left purchase. Drag upward to pretend PUSH BACK; downward to return.
              Arrow Up / Right opens; Arrow Down / Left closes. Home returns; End opens.
            </p>
            <p>COB PULLS TOWARD YT FROM XT ALONGSIDE WITH your PUSH.</p>
            <p class="opening-hint">The opening makes the inherited standing Regardingable.</p>
            <details id="wedge-instructioning-reserve">
              <summary>Yellow-marked instructionings · first wedge</summary>
              <article
                :for={mark <- PublicSituationMachineTurnZero.Architecture.Diorama.markings()}
                id={"material-" <> mark["id"]}
                data-material-family={mark["family"]}
              >
                <p>{mark["inscription"]}</p><small>{mark["status"]} · {mark["source"]}</small>
              </article>
              <p>
                Provisional: bottom and far faces of the inherited CUBICAL reference are regarded as Floor and Wall.
                Their 90-degree relation persists. Room standing beyond those faces remains unresolved.
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
            <button id="close-locality" phx-click="close-locality" aria-label="Close local reading"><.icon
              name="hero-x-mark"
              class="w-4 h-4"
            /></button>
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
        </section>
        <p :if={@message} id="rehearsal-status" role="status">{@message}</p>
        <.link :if={is_nil(@record)} id="fresh-composition" navigate={~p"/experiments/architecture"}>Begin a fresh opening</.link>
        <footer>REGARDING / STAGING FOR STANDING / ACCOMPLISHED STANDING</footer>
      </main>
    </Layouts.app>
    """
  end
end
