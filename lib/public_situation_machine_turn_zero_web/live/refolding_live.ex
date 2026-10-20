defmodule PublicSituationMachineTurnZeroWeb.RefoldingLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.Refolding.{MemoryStore, Proof}

  @impl true
  def mount(params, _session, socket) do
    key =
      case params["by"] do
        key when is_binary(key) and byte_size(key) == 32 -> key
        _ -> Base.url_encode64(:crypto.strong_rand_bytes(24), padding: false)
      end

    socket =
      socket
      |> assign(:key, key)
      |> present(Proof.return(MemoryStore, key))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    if params["by"] == socket.assigns.key do
      {:noreply, socket}
    else
      {:noreply, push_patch(socket, to: ~p"/experiments/refolding?by=#{socket.assigns.key}")}
    end
  end

  @impl true
  def handle_event("refold", _, socket) do
    {:noreply, present(socket, Proof.refold(socket.assigns.proof))}
  end

  def handle_event("return", _, socket) do
    {:noreply, present(socket, Proof.return(MemoryStore, socket.assigns.key))}
  end

  def handle_event(action, params, socket) do
    proof =
      Proof.gesture(
        MemoryStore,
        socket.assigns.key,
        socket.assigns.proof,
        action,
        params["target"]
      )

    {:noreply, present(socket, proof)}
  end

  defp present(socket, proof) do
    socket
    |> assign(:proof, proof)
    |> stream(:landings, Proof.catalogue() |> Map.values() |> Enum.sort_by(& &1.id), reset: true)
    |> stream(:continuity, Proof.continuity(proof), reset: true)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:refolding}>
      <main id="refolding-proof" class="mx-auto max-w-5xl px-5 py-10 text-stone-900 sm:px-8 sm:py-14">
        <p class="text-xs font-semibold uppercase tracking-[0.25em] text-teal-700">
          Experimental · Pass One Refinement
        </p>
        <h1 class="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">
          Standing ahead of operationing.
        </h1>
        <p class="mt-4 max-w-2xl text-stone-600">
          Regard → Approach → Seating → STEP → Furnishingmenting → ZIPPERING.
          TOWARD becomes FROM only through ZIPPERING.
        </p>

        <section class="my-8 rounded-2xl border border-teal-200 bg-teal-50 p-6" aria-live="polite">
          <p class="text-xs font-semibold tracking-widest text-teal-800">FROM HERE</p>
          <h2
            id="standing-from"
            data-standing={@proof.standing.from}
            class="mt-2 text-3xl font-semibold"
          >
            {@proof.standing.from}
          </h2>
          <p id="consequence" class="mt-2 text-sm text-stone-600">
            {operation(@proof.standing.consequence.operation)}
          </p>
          <p
            :if={@proof.standing.material[@proof.standing.from]}
            id="standing-material"
            class="mt-4 font-medium"
          >
            Standing material · {@proof.standing.material[@proof.standing.from]}
          </p>
        </section>

        <section
          id="continuity"
          class="mb-8 border-y border-stone-200 py-5"
          aria-labelledby="continuity-title"
        >
          <h2
            id="continuity-title"
            class="text-xs font-semibold uppercase tracking-widest text-stone-500"
          >
            The Continuity Line
          </h2>
          <ol
            id="continuity-line"
            phx-update="stream"
            class="mt-4 flex flex-wrap items-center gap-x-3 gap-y-3"
          >
            <li
              :for={{id, node} <- @streams.continuity}
              id={id}
              data-scope={node.scope}
              data-kind={node.kind}
              data-standing={node.standing}
              class={[
                "text-sm before:mr-3 before:text-stone-400 before:content-['→'] first:before:hidden",
                node.scope == :consequential && "font-semibold text-teal-900",
                node.scope == :ephemeral && "text-stone-500"
              ]}
            >
              {node.text}
            </li>
          </ol>
          <p class="mt-4 text-xs text-stone-500">
            Consequential Standing in teal. Current apparatus relations in grey.
          </p>
        </section>

        <%= if @proof.apparatus do %>
          <section aria-label="Stand in Regard" class="mb-5">
            <p class="mb-3 text-sm text-stone-600">Stand in Regard FROM HERE toward:</p>
            <div id="regardable-landings" phx-update="stream" class="flex flex-wrap gap-3">
              <div :for={{id, landing} <- @streams.landings} id={id}>
                <.gesture
                  id={"regard-#{String.downcase(landing.id)}"}
                  action="regard"
                  target={landing.id}
                >
                  STAND IN REGARD · {landing.id}
                </.gesture>
              </div>
            </div>
          </section>

          <.caterpillar proof={@proof} />

          <button
            id="refold"
            phx-click="refold"
            class="mt-8 cursor-pointer rounded-lg bg-stone-900 px-5 py-3 text-white transition hover:bg-teal-800 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-teal-700"
          >
            RE-FOLD
          </button>
          <p class="mt-3 text-sm text-stone-500">
            Fold the apparatus. Consequential Standing continues to stand.
          </p>
        <% else %>
          <section id="folded" class="rounded-2xl border border-stone-200 p-8">
            <h2 class="text-xl font-medium">The apparatus is folded.</h2>
            <p class="mt-2 text-stone-600">
              {@proof.standing.from} continues to stand FROM.
              Return BY-WAY-OF that Standing to Regard its material again.
            </p>
            <button
              id="return"
              phx-click="return"
              class="mt-6 cursor-pointer rounded-lg bg-teal-800 px-5 py-3 text-white transition hover:bg-teal-700 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-teal-700"
            >
              RETURN TOWARD STANDING
            </button>
          </section>
        <% end %>
        <p class="mt-10 text-xs text-stone-500">
          Pass-one memory lasts for this application run. Keep this URL as your BY-WAY-OF.
        </p>
      </main>
    </Layouts.app>
    """
  end

  attr :proof, :map, required: true

  def caterpillar(assigns) do
    assigns =
      assigns
      |> assign(:standing, Proof.furnished(assigns.proof))
      |> assign(:apparatus, assigns.proof.apparatus)
      |> assign(:material, Proof.material(assigns.proof))

    ~H"""
    <section
      id="caterpillar"
      data-standing={@standing.id}
      class="rounded-2xl border border-stone-200 bg-white p-5 sm:p-7"
    >
      <p class="max-w-2xl text-xs font-semibold uppercase leading-relaxed tracking-widest text-stone-500">
        RE-FURNISHINGMENTINGABLE CATERPILLAR TUNNELING ACCORDIONATIONING SEGMENTATIONING
      </p>
      <p class="mt-2 text-xs font-semibold tracking-widest text-teal-700">100% JANUSITE</p>
      <p id="apparatus-origin" data-standing={@apparatus.from} class="mt-5 text-sm text-stone-500">
        Apparatus furnished FROM {@apparatus.from} · BY-WAY-OF Standing
      </p>
      <p class="mt-5 text-xs tracking-widest text-stone-500">REGARDING FROM HERE TOWARD</p>
      <h2 id="regarding" data-standing={@standing.id} class="mt-2 text-2xl font-medium">
        {@standing.id}
      </h2>
      <p class="mt-2 text-stone-600">{@standing.description}</p>

      <p
        id="apparatus-posture"
        data-regarding={@apparatus.regarding}
        data-segment={@apparatus.segment}
        class="my-5 border-l-2 border-teal-600 pl-4 text-sm text-stone-600"
      >
        Segmentationing {@apparatus.segment + 1} / {@standing.segments}
      </p>

      <dl class="space-y-4 border-t border-stone-100 pt-5 text-sm">
        <div>
          <dt class="text-xs tracking-widest text-stone-500">THIS NEXT APPROACHINGING LANDINGING</dt>
          <dd id="approached" data-standing={@apparatus.approached} class="mt-1">
            {@apparatus.approached || "Not yet approached."}
          </dd>
        </div>
        <div :if={@apparatus.seated} id="seated-relation" data-standing={@apparatus.seated}>
          <dt class="font-semibold text-teal-800">STANDING TOWARD {@apparatus.seated}</dt>
          <dd class="mt-1 text-stone-600">
            THIS NEXT APPROACHINGING LANDINGING stands seated TOWARD your FROM HERE.
            Its material has not been brought here.
          </dd>
        </div>
        <div :if={@apparatus.stepped} id="step-relation" data-standing={@apparatus.stepped}>
          <dt class="font-semibold text-teal-800">STEP TOWARD {@apparatus.stepped}</dt>
          <dd class="mt-1 text-stone-600">
            The stepped relation stands. FROM remains {@apparatus.from}.
          </dd>
        </div>
        <div :if={@material} id="regarded-material">
          <dt class="text-xs tracking-widest text-stone-500">MATERIAL FROM THERE</dt>
          <dd class="mt-1 font-medium">{@material}</dd>
        </div>
        <div :if={@apparatus.furnishing} id="worked-material">
          <dt class="font-semibold text-teal-800">FURNISHINGMENTING</dt>
          <dd class="mt-1 text-stone-600">
            {@apparatus.furnishing.material} furnished in the stepped relation. Awaiting ZIPPERING.
          </dd>
        </div>
      </dl>

      <div class="mt-7 flex flex-wrap gap-2">
        <.gesture
          id="approach"
          action="approach"
          target={@standing.id}
          disabled={not Proof.allowed?(@proof, "approach", @standing.id)}
        >
          APPROACH
        </.gesture>
        <.gesture
          id="traverse"
          action="traverse"
          target={@standing.id}
          disabled={not Proof.allowed?(@proof, "traverse", @standing.id)}
        >
          Traversal Segmentationing
        </.gesture>
        <.gesture
          id="seat"
          action="seat"
          target={@standing.id}
          disabled={not Proof.allowed?(@proof, "seat", @standing.id)}
        >
          SEATING
        </.gesture>
        <.gesture
          id="step"
          action="step"
          target={@standing.id}
          disabled={not Proof.allowed?(@proof, "step", @standing.id)}
        >
          STEP TOWARD
        </.gesture>
        <.gesture
          id="furnish-material"
          action="furnish"
          target={@standing.id}
          disabled={not Proof.allowed?(@proof, "furnish", @standing.id)}
        >
          FURNISH {@standing.material || "MATERIAL"}
        </.gesture>
        <.gesture
          id="zipper"
          action="zipper"
          target={@standing.id}
          disabled={not Proof.allowed?(@proof, "zipper", @standing.id)}
        >
          ZIPPERING
        </.gesture>
      </div>
    </section>
    """
  end

  attr :id, :string, required: true
  attr :action, :string, required: true
  attr :target, :string, required: true
  attr :disabled, :boolean, default: false
  slot :inner_block, required: true

  defp gesture(assigns) do
    ~H"""
    <button
      id={@id}
      phx-click={@action}
      phx-value-target={@target}
      disabled={@disabled}
      class="cursor-pointer rounded-lg border border-stone-300 px-4 py-2.5 text-sm font-medium transition hover:border-teal-700 hover:bg-teal-50 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-teal-700 disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:border-stone-300 disabled:hover:bg-transparent"
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp operation(:initial), do: "Initial Standing"
  defp operation(:zippering), do: "Consequentialized through ZIPPERING · already standing"
end
