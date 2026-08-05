defmodule PublicSituationMachineTurnZeroWeb.LandingingLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  alias PublicSituationMachineTurnZero.Correspondencingments
  alias PublicSituationMachineTurnZero.ParkingingStandRegistry

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "This Landinging Page",
       featured_correspondencingment: Correspondencingments.featured(),
       holding_correspondencingment: Correspondencingments.get(1),
       landing_re_shackling_form:
         to_form(%{"parkinging_stand" => "", "shackling_pin" => ""}, as: :re_shackling),
       landing_re_shackling_result: nil
     )}
  end

  @impl true
  def handle_event(
        "landing-re-shackle-leashing",
        %{
          "re_shackling" => %{
            "parkinging_stand" => parkinging_stand,
            "shackling_pin" => shackling_pin
          }
        },
        socket
      ) do
    parkinging_stand = ParkingingStandRegistry.normalize_parkinging_stand(parkinging_stand)
    shackling_pin = ParkingingStandRegistry.normalize_shackling_pin(shackling_pin)

    case ParkingingStandRegistry.re_shackle(parkinging_stand, shackling_pin) do
      {:ok, leashing} ->
        {:noreply,
         assign(socket,
           landing_re_shackling_result: leashing,
           landing_re_shackling_form:
             to_form(
               %{
                 "parkinging_stand" => leashing.parkinging_stand,
                 "shackling_pin" => leashing.shackling_pin
               },
               as: :re_shackling
             )
         )}

      :error ->
        {:noreply,
         assign(socket,
           landing_re_shackling_result: :error,
           landing_re_shackling_form:
             to_form(
               %{"parkinging_stand" => parkinging_stand, "shackling_pin" => shackling_pin},
               as: :re_shackling
             )
         )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:landinging}>
      <main id="landinging-page" class="site-page">
        <Layouts.locality_threshold
          title="This Approaching Landinging Page"
          id="landinging-threshold"
          reading="The Bearinging of Bearingings"
        >
          <:description>
            <p>Welcome.</p>
            <p>
              This Approaching Landinging Page stands before This Encounteringmenting Wharf.
            </p>
            <p>
              Here, This Constitutioning Human may begin situating through the PUBLIC-SITUATION-MACHINE-.
            </p>
          </:description>
        </Layouts.locality_threshold>

        <section
          id="landinging-re-shackling"
          class="landinging-re-shackling"
          aria-labelledby="landinging-re-shackling-title"
        >
          <p class="site-page__eyebrow">RETURNING CONSTITUTIONAL LOCALITY</p>
          <h2 id="landinging-re-shackling-title">RE-Shackle This One Leashing</h2>
          <p>If This Constitutioning Human already stands stewarding This One Leashing,</p>
          <p>This One Leashing may now be RE-Shackled to any One Terrestrial Computer.</p>

          <.form
            for={@landing_re_shackling_form}
            id="landinging-re-shackling-form"
            phx-submit="landing-re-shackle-leashing"
          >
            <.input
              field={@landing_re_shackling_form[:parkinging_stand]}
              type="text"
              label="This One Parkinging Stand Number"
              inputmode="numeric"
              maxlength="12"
              autocomplete="off"
              required
            />
            <.input
              field={@landing_re_shackling_form[:shackling_pin]}
              type="text"
              label="This One Shackling Pin"
              autocomplete="off"
              required
            />
            <button type="submit" class="field-page__action">
              RE-Shackle This One Leashing
            </button>
          </.form>

          <p
            :if={@landing_re_shackling_result == :error}
            id="landinging-re-shackling-error"
            class="field-page__confirmation"
          >
            These furnishings do not presently stand together in lawful Relation.
          </p>

          <section
            :if={is_map(@landing_re_shackling_result)}
            id="landinging-re-shackling-standing"
            class="field-page__enriched-leashing"
            phx-hook=".CopyFurnishing"
            aria-labelledby="landinging-re-shackling-standing-title"
          >
            <h3 id="landinging-re-shackling-standing-title">This One Leashing</h3>
            <dl>
              <div>
                <dt>This One Terrestrial Computer Free Parkinging Stand</dt>
                <dd>{@landing_re_shackling_result.parkinging_stand}</dd>
              </div>
              <div>
                <dt>This One Piece of Time</dt>
                <dd>{format_piece_of_time(@landing_re_shackling_result.ceremony_time)}</dd>
              </div>
              <div :if={@landing_re_shackling_result.name}>
                <dt>This One Pet Name</dt>
                <dd>{@landing_re_shackling_result.name}</dd>
              </div>
              <div :if={Map.has_key?(@landing_re_shackling_result.appointmentings, :lanterning)}>
                <dt>This One Lanterning Bug Assemblementing</dt>
                <dd>This First Appointmenting stands furnished.</dd>
              </div>
              <div :if={@landing_re_shackling_result.earthly_locality}>
                <dt>This One Earthly Locality</dt>
                <dd>{earthly_locality_text(@landing_re_shackling_result.earthly_locality)}</dd>
              </div>
            </dl>
            <div class="field-page__secret-cabinet field-page__secret-cabinet--enriched">
              <details id="landinging-secret-cabinet">
                <summary>▸ This One Secret Cabinet</summary>
                <div class="field-page__secret-cabinet-interior">
                  <span>This One Shackling Pin</span>
                  <strong>{@landing_re_shackling_result.shackling_pin}</strong>
                </div>
              </details>
              <button type="button" data-copy={@landing_re_shackling_result.shackling_pin}>
                Copy Shackling Pin
              </button>
            </div>
            <p data-copy-status aria-live="polite"></p>
          </section>
        </section>

        <section id="arriving-correspondencing" class="site-panel">
          <p class="site-page__eyebrow">PRESENTLY SOUNDINGING</p>
          <h2>Arrivinging Correspondencing</h2>
          <%= if @featured_correspondencingment do %>
            <article id="featured-correspondencingment" class="correspondencingment-card">
              <p>Correspondencingment No. {@featured_correspondencingment.number}</p>
              <h3>{@featured_correspondencingment.title}</h3>
              <div class="correspondencingment-card__body">
                <p>{@featured_correspondencingment.summary}</p>
                <div :if={@featured_correspondencingment.video_id} class="video-embed">
                  <iframe
                    src={"https://www.youtube-nocookie.com/embed/#{@featured_correspondencingment.video_id}"}
                    title={@featured_correspondencingment.title}
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                    allowfullscreen
                  ></iframe>
                </div>
              </div>
            </article>
          <% else %>
            <p>Correspondencingment forthcoming.</p>
          <% end %>
        </section>

        <section id="holding-correspondencingments" class="site-panel">
          <h2>Correspondencingments in Holdinging</h2>
          <article :if={@holding_correspondencingment} class="correspondencingment-card">
            <p>Correspondencingment No. {@holding_correspondencingment.number}</p>
            <h3>{@holding_correspondencingment.title}</h3>
            <div class="correspondencingment-card__body">
              <p>{@holding_correspondencingment.summary}</p>
              <p :for={paragraph <- Enum.take(@holding_correspondencingment.body, 3)}>
                {paragraph}
              </p>
            </div>
            <.link
              navigate={~p"/correspondencingments#correspondencingment-1"}
              class="site-action"
            >
              Regard within This Holdinging
            </.link>
          </article>
        </section>
      </main>
    </Layouts.app>
    """
  end

  defp format_piece_of_time(%DateTime{} = piece_of_time),
    do: Calendar.strftime(piece_of_time, "%Y-%m-%d %H:%M:%S UTC")

  defp earthly_locality_text(%{country: country, region: region, city: city}) do
    [city, region, country]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join(", ")
  end
end
