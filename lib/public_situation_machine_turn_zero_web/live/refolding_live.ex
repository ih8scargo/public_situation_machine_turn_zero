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

    {:ok, assign(socket, key: key, proof: Proof.return(MemoryStore, key))}
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
    {:noreply, assign(socket, :proof, Proof.refold(socket.assigns.proof))}
  end

  def handle_event("return", _, socket) do
    {:noreply, assign(socket, :proof, Proof.return(MemoryStore, socket.assigns.key))}
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

    {:noreply, assign(socket, :proof, proof)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:refolding}>
      <main id="refolding-proof" class="mx-auto max-w-4xl px-6 py-12 text-stone-900">
        <p class="text-xs font-semibold uppercase tracking-[0.25em] text-teal-700">
          Experimental · Pass One
        </p>
        <h1 class="mt-3 text-4xl font-semibold tracking-tight">Standing ahead of operationing.</h1>
        <p class="mt-4 max-w-2xl text-stone-600">
          TOWARD ≠ FROM. Regarding and Segmentationing do not change what stands.
        </p>
        <section class="my-8 rounded-2xl border border-teal-200 bg-teal-50 p-6" aria-live="polite">
          <p class="text-xs tracking-widest text-teal-800">CONSEQUENTIAL STANDING · FROM</p>
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
          <p :if={@proof.standing.material[@proof.standing.from]} id="standing-material" class="mt-4">
            Material: {@proof.standing.material[@proof.standing.from]}
          </p>
        </section>

        <%= if @proof.apparatus do %>
          <.caterpillar
            standing={Proof.furnished(@proof)}
            apparatus={@proof.apparatus}
            material={Proof.material(@proof)}
          />
          <div class="mt-6 flex flex-wrap gap-3">
            <.gesture id="furnish-enzo" action="furnish" target="ENZO">Furnish ENZO TOWARD</.gesture>
            <.gesture id="furnish-huckleberry" action="furnish" target="HUCKLEBERRY">
              Furnish HUCKLEBERRY TOWARD
            </.gesture>
            <.gesture
              id="furnish-material"
              action="material"
              disabled={@proof.standing.from != "HUCKLEBERRY"}
            >
              Furnish a small leaf at HUCKLEBERRY
            </.gesture>
          </div>
          <button
            id="refold"
            phx-click="refold"
            class="mt-8 rounded-lg bg-stone-900 px-5 py-3 text-white transition hover:bg-teal-800"
          >
            RE-FOLD
          </button>
        <% else %>
          <section id="folded" class="rounded-2xl border border-stone-200 p-8">
            <h2 class="text-xl font-medium">The apparatus is folded.</h2>
            <p class="mt-2 text-stone-600">
              Return BY-WAY-OF the last consequential Standing and its material.
            </p>
            <button
              id="return"
              phx-click="return"
              class="mt-6 rounded-lg bg-teal-800 px-5 py-3 text-white transition hover:bg-teal-700"
            >
              Return TOWARD Standing
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

  attr :standing, :map, required: true
  attr :apparatus, :map, required: true
  attr :material, :any, default: nil

  def caterpillar(assigns) do
    ~H"""
    <section
      id="caterpillar"
      data-standing={@standing.id}
      class="rounded-2xl border border-stone-200 p-6"
    >
      <p class="text-xs uppercase tracking-widest text-stone-500">
        Reusable Caterpillar Accordion Segmentationing
      </p>
      <h2 class="mt-3 text-2xl font-medium">TOWARD {@standing.id}</h2>
      <p class="mt-2 text-stone-600">{@standing.description}</p>
      <p
        id="apparatus-posture"
        data-regarding={@apparatus.regarding}
        data-segment={@apparatus.segment}
        class="my-4 border-l-2 border-teal-600 pl-4"
      >
        Regarding {@apparatus.regarding} · Segmentationing {@apparatus.segment + 1} / {@standing.segments}
      </p>
      <p :if={@apparatus.approached} id="approached">Approached: {@apparatus.approached}</p>
      <p :if={@material} id="regarded-material" class="my-4 font-medium">{@material}</p>
      <div class="mt-5 flex flex-wrap gap-2">
        <.gesture id="regard" action="regard" target={@standing.id}>Regard</.gesture>
        <.gesture id="approach" action="approach" target={@standing.id}>Approach</.gesture>
        <.gesture id="traverse" action="traverse" target={@standing.id}>
          Traversal Segmentationing
        </.gesture>
        <.gesture id="zipper" action="zipper" target={@standing.id}>ZIPPERING</.gesture>
        <.gesture id="rezipper" action="rezipper" target={@standing.id}>RE-ZIPPERING</.gesture>
      </div>
    </section>
    """
  end

  attr :id, :string, required: true
  attr :action, :string, required: true
  attr :target, :string, default: nil
  attr :disabled, :boolean, default: false
  slot :inner_block, required: true

  defp gesture(assigns) do
    ~H"""
    <button
      id={@id}
      phx-click={@action}
      phx-value-target={@target}
      disabled={@disabled}
      class="rounded-lg border border-stone-300 px-4 py-2 text-sm font-medium transition hover:border-teal-700 hover:bg-teal-50 disabled:cursor-not-allowed disabled:opacity-40"
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp operation(:initial), do: "Initial Standing"
  defp operation(:zippering), do: "Consequentialized through ZIPPERING"
  defp operation(:rezippering), do: "Consequentialized through RE-ZIPPERING"
end
