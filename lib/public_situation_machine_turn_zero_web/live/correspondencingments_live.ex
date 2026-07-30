defmodule PublicSituationMachineTurnZeroWeb.CorrespondencingmentsLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  alias PublicSituationMachineTurnZero.Correspondencingments

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Correspondencingments")
     |> stream_configure(:correspondencingments,
       dom_id: fn correspondencingment ->
         "correspondencingment-#{correspondencingment.number}"
       end
     )
     |> stream(:correspondencingments, Correspondencingments.list())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:correspondencingments}>
      <main id="correspondencingments-page" class="site-page">
        <header class="site-page__header">
          <p class="site-page__eyebrow">PUBLIC-SITUATION-MACHINE-</p>
          <p class="site-page__subtitle">General Purpose Situationing Appliance</p>
          <h1>Correspondencingments</h1>
          <p class="site-page__orientation">Twople-Ship-to-Twople-Ship</p>
          <p class="site-page__orientation">Correspondencing from the Edge of the Field</p>
        </header>

        <section
          id="correspondencingments"
          phx-update="stream"
          class="correspondencingment-list"
          aria-label="Correspondencingments"
        >
          <p id="correspondencingments-empty" class="hidden only:block">
            Correspondencingments forthcoming.
          </p>
          <article
            :for={{id, correspondencingment} <- @streams.correspondencingments}
            id={id}
            class="correspondencingment-card"
          >
            <p>Correspondencingment No. {correspondencingment.number}</p>
            <h2>{correspondencingment.title}</h2>
            <time datetime={Date.to_iso8601(correspondencingment.publication_date)}>
              {Calendar.strftime(correspondencingment.publication_date, "%B %-d, %Y")}
            </time>
            <p>{correspondencingment.summary}</p>
            <div class="correspondencingment-card__body">
              <p :for={paragraph <- correspondencingment.body}>{paragraph}</p>
            </div>
          </article>
        </section>
      </main>
    </Layouts.app>
    """
  end
end
