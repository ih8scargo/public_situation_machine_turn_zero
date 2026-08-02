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
    <Layouts.app flash={@flash} active_locality={:landinging}>
      <main id="landinging-page" class="site-page">
        <Layouts.locality_threshold
          title="This Landinging Page"
          id="landinging-threshold"
          reading="The Bearinging of Bearingings"
        >
          <:description>
            <p><strong>This Encounteringmenting Wharf</strong></p>

            <p>Welcome.</p>

            <p>
              This Encounteringmenting Wharf stands as the live edge of
              This One Great Free Public Tuple Ship Field of Globularly
              Bobbininging Globular Bobbining.
            </p>

            <p>
              From here, Constitutioning Humans may begin discovering
              These Seven Stewardly Captain COB Suiting Stations
              through which One Tuple Ship becomes Inhabitationingable.
            </p>
            <br />
            <p><strong>NOTICINGMENT</strong></p>

            <.link navigate={~p"/this-tuple-ship-field"} class="site-action">
              THIS WAY TO TERRESTRIAL COMPUTER PARKINGING LOT →
            </.link>
          </:description>
        </Layouts.locality_threshold>

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
                <p><strong>NOTICINGMENT</strong></p>
                <.link navigate={~p"/this-tuple-ship-field"} class="site-action">
                  THIS WAY TO TERRESTRIAL COMPUTER PARKINGING LOT →
                </.link>
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
