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
        <Layouts.locality_threshold
          title="Correspondencingments"
          id="correspondencingments-threshold"
          reading="The Bearinging of Lawful Correspondencing"
        >
          <:description>
            <p>Here,</p>
            <p>Correspondencingments</p>
            <p>arrive from the Edge of the Field.</p>
            <p>Through Stewardly Interrelationing,</p>
            <p>new Discoveringmentings</p>
            <p>may enter Public Regard.</p>
          </:description>
        </Layouts.locality_threshold>

        <header
          id="correspondencingments-publication-title"
          class="field-page__rail-header correspondencingments-publication"
        >
          <h2>
            <span>Twople-Ship-to-Twople-Ship</span>
            <span>Correspondencingments from the Edge of the Field</span>
          </h2>
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
            <div :if={correspondencingment.video_id} class="video-embed">
              <iframe
                src={"https://www.youtube-nocookie.com/embed/#{correspondencingment.video_id}"}
                title={correspondencingment.title}
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowfullscreen
              ></iframe>
            </div>
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
