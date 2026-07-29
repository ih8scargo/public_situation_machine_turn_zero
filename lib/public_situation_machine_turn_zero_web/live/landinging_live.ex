defmodule PublicSituationMachineTurnZeroWeb.LandingingLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  alias PublicSituationMachineTurnZero.Correspondencingments

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "This Landinging Page",
       featured_correspondencingment: Correspondencingments.featured()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <main id="landinging-page" class="site-page">
        <header class="site-page__header">
          <p class="site-page__eyebrow">PUBLIC-SITUATION-MACHINE-</p>
          <p class="site-page__subtitle">General Purpose Situationing Appliance</p>
          <h1>This Landinging Page</h1>
        </header>

        <section id="arriving-correspondencing" class="site-panel">
          <p class="site-page__eyebrow">PRESENTLY SOUNDINGING</p>
          <h2>Arrivinging Correspondencing</h2>
          <%= if @featured_correspondencingment do %>
            <article id="featured-correspondencingment" class="correspondencingment-card">
              <p>Correspondencingment No. {@featured_correspondencingment.number}</p>
              <h3>{@featured_correspondencingment.title}</h3>
              <div class="correspondencingment-card__body">
                <p>{@featured_correspondencingment.summary}</p>
                <p :for={paragraph <- @featured_correspondencingment.body}>{paragraph}</p>
              </div>
            </article>
          <% else %>
            <p>Correspondencingment forthcoming.</p>
          <% end %>
        </section>

        <section id="holding-correspondencingments" class="site-panel">
          <h2>Correspondencingments in Holdinging</h2>
          <p>Correspondencingments presently standing in public Regard.</p>
          <.link navigate={~p"/correspondencingments"} class="site-action">
            Regard within This Holdinging
          </.link>
        </section>
      </main>
    </Layouts.app>
    """
  end
end
