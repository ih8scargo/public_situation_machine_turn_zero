defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  alias PublicSituationMachineTurnZero.ParkingingStandRegistry

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "This Tuple Ship Field",
       parkinging_stand: nil,
       shackling_pin: nil,
       ceremony_time: nil,
       ceremony_completed?: false,
       rail_unfolded?: false,
       naming_decision: :pending,
       leashing_name: nil,
       naming_form: to_form(%{"name" => ""}, as: :leashing),
       re_shackling_form:
         to_form(%{"parkinging_stand" => "", "shackling_pin" => ""}, as: :re_shackling),
       re_shackling_result: nil,
       re_shackling_decision: :pending,
       correspondence_form:
         to_form(%{"channel" => "email", "destination" => ""}, as: :correspondence)
     )}
  end

  @impl true
  def handle_event("unfold-constitutional-rail-line", _params, socket) do
    {:noreply, assign(socket, :rail_unfolded?, true)}
  end

  def handle_event("take-holdinging", _params, %{assigns: %{ceremony_completed?: true}} = socket) do
    {:noreply, socket}
  end

  def handle_event("take-holdinging", _params, %{assigns: %{rail_unfolded?: false}} = socket) do
    {:noreply, socket}
  end

  def handle_event("take-holdinging", _params, socket) do
    shackling_pin = shackling_pin()
    ceremony_time = DateTime.utc_now() |> DateTime.truncate(:second)
    leashing = ParkingingStandRegistry.furnish_leashing(shackling_pin, ceremony_time)

    {:noreply,
     assign(socket,
       parkinging_stand: leashing.parkinging_stand,
       shackling_pin: leashing.shackling_pin,
       ceremony_time: leashing.ceremony_time,
       ceremony_completed?: true
     )}
  end

  def handle_event(
        "begin-furnishing-name",
        _params,
        %{assigns: %{ceremony_completed?: true, naming_decision: :pending}} = socket
      ) do
    {:noreply, assign(socket, :naming_decision, :furnishing)}
  end

  def handle_event("begin-furnishing-name", _params, socket), do: {:noreply, socket}

  def handle_event(
        "furnish-leashing-name",
        %{"leashing" => %{"name" => name}},
        %{assigns: %{ceremony_completed?: true, naming_decision: :furnishing}} = socket
      ) do
    case String.trim(name) do
      "" ->
        {:noreply, assign(socket, :naming_form, to_form(%{"name" => ""}, as: :leashing))}

      furnished_name ->
        {:ok, _leashing} =
          ParkingingStandRegistry.furnish_name(
            socket.assigns.parkinging_stand,
            socket.assigns.shackling_pin,
            furnished_name
          )

        {:noreply,
         assign(socket,
           naming_decision: :named,
           leashing_name: furnished_name,
           naming_form: to_form(%{"name" => furnished_name}, as: :leashing)
         )}
    end
  end

  def handle_event("furnish-leashing-name", _params, socket), do: {:noreply, socket}

  def handle_event(
        "continue-without-name",
        _params,
        %{assigns: %{ceremony_completed?: true, naming_decision: :pending}} = socket
      ) do
    {:noreply, assign(socket, :naming_decision, :declined)}
  end

  def handle_event("continue-without-name", _params, socket), do: {:noreply, socket}

  def handle_event(
        "re-shackle-leashing",
        %{
          "re_shackling" => %{
            "parkinging_stand" => parkinging_stand,
            "shackling_pin" => shackling_pin
          }
        },
        %{assigns: %{naming_decision: naming_decision}} = socket
      )
      when naming_decision in [:named, :declined] do
    parkinging_stand = normalize_parkinging_stand(parkinging_stand)
    shackling_pin = normalize_shackling_pin(shackling_pin)

    case ParkingingStandRegistry.re_shackle(parkinging_stand, shackling_pin) do
      {:ok, leashing} ->
        {:noreply,
         assign(socket,
           parkinging_stand: leashing.parkinging_stand,
           shackling_pin: leashing.shackling_pin,
           ceremony_time: leashing.ceremony_time,
           leashing_name: leashing.name,
           re_shackling_result: leashing,
           re_shackling_decision: :completed,
           re_shackling_form:
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
           re_shackling_result: :error,
           re_shackling_form:
             to_form(
               %{"parkinging_stand" => parkinging_stand, "shackling_pin" => shackling_pin},
               as: :re_shackling
             )
         )}
    end
  end

  def handle_event("re-shackle-leashing", _params, socket), do: {:noreply, socket}

  def handle_event(
        "continue-beyond-re-shackling",
        _params,
        %{assigns: %{naming_decision: naming_decision}} = socket
      )
      when naming_decision in [:named, :declined] do
    {:noreply, assign(socket, :re_shackling_decision, :continued)}
  end

  def handle_event("continue-beyond-re-shackling", _params, socket), do: {:noreply, socket}

  def handle_event(
        "hail-leashing",
        %{"correspondence" => %{"channel" => channel, "destination" => destination}},
        %{assigns: %{re_shackling_decision: decision}} = socket
      )
      when decision in [:completed, :continued] do
    destination = destination |> String.replace(~r/[\r\n]/u, "") |> String.trim()

    if destination == "" do
      {:noreply, socket}
    else
      href = correspondence_href(channel, destination, socket.assigns)
      {:noreply, push_event(socket, "hail_leashing", %{href: href})}
    end
  end

  def handle_event("hail-leashing", _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:tuple_ship_field}>
      <main id="tuple-ship-field-page" class="site-page field-page">
        <Layouts.locality_threshold
          title="This Tuple Ship Field Parkinging Lot"
          id="tuple-ship-field-threshold"
          reading="The Bearinging of Lawful Encounteringmenting"
        >
          <:description>
            <p>You've made it Here.</p>
            <p>
              This Tuple Ship Field Parkinging Lot stands before This Encounteringmenting Wharf.
            </p>
            <p>
              From Here, the Constitutioning Human may reserve This One Terrestrial Computer Free Parkinging Stand.
            </p>
            <p>
              In so doing, the Constitutioning Human takes hold of This One Leashing that Leads toward The Seat of the Stewardly Co-Occupancyingship, thereby entering the Laboringings of Stewardshippery.
            </p>
          </:description>
        </Layouts.locality_threshold>

        <section
          id="constitutional-furnishmenting-rail"
          class="field-page__furnishmenting-rail"
          aria-labelledby="constitutional-furnishmenting-rail-title"
        >
          <header class="field-page__rail-header">
            <p class="site-page__eyebrow">A PUBLIC ENTRY RAIL FOR CONSTITUTIONING HUMANS</p>
            <h2 id="constitutional-furnishmenting-rail-title">
              This Constitutional Furnishmenting Rail Line
            </h2>
            <p>
              This Constitutional Furnishmenting Rail Line stands Constitutioning from its first Station onward while standing in Readiness for Extension through the lawful Appointmenting of future Furnishmenting Stations.
            </p>
          </header>

          <div id="rail-line-opening-ceremony" class="field-page__opening-ceremony">
            <p>
              With Stewardly Regard toward This Constitutioning Human's approaching Constitutional Appointmenting, these Offices of the Appliance now stand in Readiness for the unfoldingment of This Constitutional Furnishmenting Rail Line.
            </p>
            <button
              :if={!@rail_unfolded?}
              id="unfold-constitutional-rail-line"
              type="button"
              class="field-page__action field-page__opening-action"
              phx-click="unfold-constitutional-rail-line"
            >
              Unfold
            </button>
          </div>

          <div :if={@rail_unfolded?} id="constitutional-rail-line-unfolded">
            <div class="field-page__rail-line" aria-hidden="true"></div>

            <article
              id="terrestrial-computer-parkinging-station"
              class="field-page__station"
              aria-labelledby="terrestrial-computer-parkinging-station-title"
            >
              <header class="field-page__station-header">
                <p class="site-page__eyebrow">STATION 01</p>
                <h3 id="terrestrial-computer-parkinging-station-title">
                  This Terrestrial Computer Parkinging Station
                </h3>
              </header>

              <div id="dual-stewardship-geometry" class="field-page__dual-stewardship">
                <div class="field-page__stewardship-headings">
                  <h4 id="constitutioning-stewardship-title">Constitutioning</h4>
                  <h4 id="furnished-through-stewardship-title">Furnished Through</h4>
                </div>

                <div class="field-page__stewardship-pairs">
                  <div class="field-page__stewardship-pair">
                    <div>Office of Manifestmenting Custodianshippery</div>
                    <span aria-hidden="true"></span>
                    <div>Continuity Line Carriageing Administrativation</div>
                  </div>
                  <div class="field-page__stewardship-pair">
                    <div>Division of Holdinging Relationings through Continuity</div>
                    <span aria-hidden="true"></span>
                    <div>Division of Discrete Turn Index Advancementing</div>
                  </div>
                  <div class="field-page__stewardship-pair">
                    <div>Department of Relationingable Custodianshipments</div>
                    <span aria-hidden="true"></span>
                    <div>Department of This Approaching Landingmenting</div>
                  </div>
                  <div class="field-page__stewardship-pair">
                    <div>This One Piece of Time Unitting</div>
                    <span aria-hidden="true"></span>
                    <div>Rail Line Furnishingments Unit</div>
                  </div>
                  <div class="field-page__stewardship-pair field-page__stewardship-pair--materials">
                    <div>This One Free Parkinging Stand Allotmenting</div>
                    <span aria-hidden="true"></span>
                    <div class="field-page__shared-operational-box">
                      <p>House of Parkinging Stand Furnishings</p>
                      <p>House of Shackling Pin Furnishings</p>
                    </div>
                  </div>
                </div>

                <svg
                  id="stewardship-crew-convergence"
                  class="field-page__stewardship-convergence"
                  viewBox="0 0 100 50"
                  preserveAspectRatio="none"
                  aria-hidden="true"
                >
                  <defs>
                    <marker
                      id="stewardship-arrowhead"
                      markerWidth="5"
                      markerHeight="5"
                      refX="4"
                      refY="2.5"
                      orient="auto"
                    >
                      <path d="M0,0 L5,2.5 L0,5 Z"></path>
                    </marker>
                  </defs>
                  <path d="M24 0 L50 25" marker-end="url(#stewardship-arrowhead)"></path>
                  <path d="M76 0 L50 25" marker-end="url(#stewardship-arrowhead)"></path>
                  <path d="M50 25 L50 48" marker-end="url(#stewardship-arrowhead)"></path>
                </svg>
              </div>

              <div id="leashing-crew-conjunction" class="field-page__crew-conjunction">
                <h4>Terrestrial Computer Leashinging Crew</h4>
                <p>This Crew embodies the combined Laboringings of both stewardships.</p>
              </div>

              <div class="field-page__crew-statement">
                <p>
                  When the Constitutioning Human chooses to Take Holdinging of This One Leashing, This One Terrestrial Computer Leashinging Crew fashions This One Leashing.
                </p>
                <p>
                  You will receive a Parkinging Stand Number together with the Shackling Pin that belongs with it. Through This One Leashing, you may later shackle any Terrestrial Computer to This One Free Parkinging Stand.
                </p>
              </div>

              <div class="field-page__interaction">
                <section class="field-page__leash" aria-labelledby="leash-title">
                  <h4 id="leash-title">THIS ONE LEASHING</h4>

                  <%= if @ceremony_completed? do %>
                    <div id="leashing-ceremony-complete" aria-live="polite">
                      <div id="parkinging-credentials" class="field-page__credentials">
                        <div>
                          <span>Parkinging Stand Number</span>
                          <strong id="parkinging-stand" data-value={@parkinging_stand}>
                            {@parkinging_stand}
                          </strong>
                        </div>
                        <div>
                          <span>Shackling Pin</span>
                          <strong id="shackling-pin" data-value={@shackling_pin}>
                            {@shackling_pin}
                          </strong>
                        </div>
                      </div>

                      <div id="leashing-ceremony-time" class="field-page__ceremony-time">
                        <span>This One Piece of Time</span>
                        <time datetime={DateTime.to_iso8601(@ceremony_time)}>
                          {Calendar.strftime(@ceremony_time, "%Y-%m-%d %H:%M:%S UTC")}
                        </time>
                      </div>

                      <div class="field-page__completion-statement">
                        <p>Together these now stand as This One Leashing.</p>
                        <p>This One Leashing stands upon This One Constitutional Locality.</p>
                        <p>This Parkinging Stand Number need not be kept secret.</p>
                        <p>This Shackling Pin should be preserved in a Secret Some Place.</p>
                      </div>

                      <section
                        :if={@naming_decision in [:pending, :furnishing]}
                        id="leashing-naming"
                        class="field-page__naming"
                        aria-labelledby="leashing-naming-title"
                      >
                        <h5 id="leashing-naming-title">
                          If you wish, you may now furnish a Name for This One Leashing.
                        </h5>

                        <div :if={@naming_decision == :pending} class="field-page__naming-choices">
                          <button
                            id="begin-furnishing-leashing-name"
                            type="button"
                            class="field-page__action"
                            phx-click="begin-furnishing-name"
                          >
                            Furnish Name
                          </button>
                          <button
                            id="continue-without-leashing-name"
                            type="button"
                            class="field-page__action"
                            phx-click="continue-without-name"
                          >
                            Continue Without Furnishing a Name
                          </button>
                        </div>

                        <.form
                          :if={@naming_decision == :furnishing}
                          for={@naming_form}
                          id="leashing-name-form"
                          phx-submit="furnish-leashing-name"
                        >
                          <.input
                            field={@naming_form[:name]}
                            type="text"
                            label="Name for This One Leashing"
                            autocomplete="off"
                            maxlength="120"
                            required
                          />
                          <button type="submit" class="field-page__action">Furnish Name</button>
                        </.form>
                      </section>
                    </div>
                  <% else %>
                    <button
                      id="take-holdinging-of-leashing"
                      type="button"
                      class="field-page__action field-page__ceremony-action"
                      phx-click="take-holdinging"
                    >
                      Take Holdinging of This One Leashing
                    </button>
                  <% end %>
                </section>

                <div
                  :if={@naming_decision in [:named, :declined]}
                  id="leashing-ceremony-closing"
                  class="field-page__ceremony-closing"
                >
                  <p :if={@naming_decision == :named} id="furnished-leashing-name">
                    This One Leashing now stands named <strong>{@leashing_name}</strong>.
                  </p>
                  <p>
                    Through the combined Laboringings of This One Crew, This One Leashing comes into lawful beginning.
                  </p>
                </div>
              </div>
            </article>

            <div :if={@naming_decision in [:named, :declined]} id="re-shackling-rail-unfolding">
              <div class="field-page__rail-line" aria-hidden="true"></div>

              <article
                id="re-shackling-practice-station"
                class="field-page__station field-page__re-shackling"
                aria-labelledby="re-shackling-practice-title"
              >
                <header class="field-page__station-header">
                  <p class="site-page__eyebrow">OPTIONAL PRACTICE LOCALITY</p>
                  <h3 id="re-shackling-practice-title">RE-Shackle This One Leashing</h3>
                </header>

                <div class="field-page__crew-statement">
                  <p>
                    This Station allows the Constitutioning Human to practice returning through This One Leashing whenever desired.
                  </p>
                  <p>
                    This is a voluntary practice of lawful return. It is not authentication or account access.
                  </p>
                </div>

                <div class="field-page__interaction">
                  <div class="field-page__re-shackling-choices">
                    <.form
                      for={@re_shackling_form}
                      id="re-shackling-form"
                      phx-submit="re-shackle-leashing"
                    >
                      <.input
                        field={@re_shackling_form[:parkinging_stand]}
                        type="text"
                        label="Parkinging Stand Number"
                        inputmode="numeric"
                        maxlength="12"
                        autocomplete="off"
                        required
                      />
                      <.input
                        field={@re_shackling_form[:shackling_pin]}
                        type="text"
                        label="Shackling Pin"
                        autocomplete="off"
                        required
                      />
                      <button type="submit" class="field-page__action">
                        RE-Shackle This One Leashing
                      </button>
                    </.form>

                    <div class="field-page__continue-option">
                      <p>RE-Shackling is optional.</p>
                      <button
                        id="continue-beyond-re-shackling"
                        type="button"
                        class="field-page__action"
                        phx-click="continue-beyond-re-shackling"
                      >
                        Continue Toward the Next Furnishmenting Station
                      </button>
                    </div>
                  </div>

                  <p
                    :if={@re_shackling_result == :error}
                    id="re-shackling-error"
                    class="field-page__confirmation"
                  >
                    These furnishings do not presently stand together in lawful Relation.
                  </p>

                  <div
                    :if={is_map(@re_shackling_result)}
                    id="re-shackling-success"
                    class="field-page__re-shackling-result"
                  >
                    <dl>
                      <div>
                        <dt>Parkinging Stand Number</dt>
                        <dd>{@re_shackling_result.parkinging_stand}</dd>
                      </div>
                      <div>
                        <dt>This One Piece of Time</dt>
                        <dd>{format_piece_of_time(@re_shackling_result.ceremony_time)}</dd>
                      </div>
                      <div :if={@re_shackling_result.name}>
                        <dt>Name</dt>
                        <dd>{@re_shackling_result.name}</dd>
                      </div>
                      <div :if={@re_shackling_result.earthly_locality}>
                        <dt>Earthly Locality</dt>
                        <dd>{earthly_locality_text(@re_shackling_result.earthly_locality)}</dd>
                      </div>
                    </dl>
                    <p>This One Leashing continues standing in lawful Holding.</p>
                  </div>
                </div>
              </article>
            </div>
          </div>
        </section>

        <div
          :if={@re_shackling_decision in [:completed, :continued]}
          id="tuple-field-after-leashing-ceremony"
        >
          <section
            id="self-correspondencing-crew"
            class="field-page__self-correspondencing field-page__section"
            aria-labelledby="self-correspondencing-title"
          >
            <p class="site-page__eyebrow">OPTIONAL ASSISTANCE</p>
            <h2 id="self-correspondencing-title">This One Self-Correspondencing Crew</h2>
            <p>
              Preserve This One Leashing by sending one Correspondencingment to a Some Place of your choosing.
            </p>
            <p>This One Leashing is not kept through an account.</p>
            <p>It is preserved through lawful Correspondencing.</p>

            <.form
              for={@correspondence_form}
              id="self-correspondencing-form"
              phx-hook=".SelfCorrespondencing"
              phx-submit="hail-leashing"
            >
              <div class="field-page__correspondence-fields">
                <.input
                  field={@correspondence_form[:channel]}
                  type="select"
                  label="Correspondencing Passage"
                  options={[{"Email", "email"}, {"Text message", "text"}]}
                />
                <.input
                  field={@correspondence_form[:destination]}
                  type="text"
                  label="Some Place of your choosing"
                  autocomplete="off"
                  required
                />
              </div>
              <button id="hail-this-one-leashing" type="submit" class="field-page__action">
                Hail This One Leashing
              </button>
            </.form>

            <p>
              Return Here through This One Leashing whenever This Constitutional Furnishmenting Rail Line stands ready to continue.
            </p>
            <p>
              Every future Correspondencing stands beginning through lawful Self-Correspondencing.
            </p>
          </section>

          <section class="field-page__section">
            <h2>
              This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining
            </h2>
            <p>
              By reserving This One Terrestrial Computer Parkinging Stand, you have begun adjoining This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
            </p>
            <p>
              No One Central Authority holds This One Great Free Public Tuple Ship Field together.
            </p>
            <p>
              The Field holds together through The Same General Civilizationalizing Constitutioningable Reasoning Geometry.
            </p>
            <p>
              Within that Geometry, every PUBLIC-SITUATION-MACHINE- together with its Stewardly Captain COB stands as one Tuple Ship—one established Constitutional Locality free to steward its own lawful Continuity Line while remaining able to Correspond with every other.
            </p>
          </section>

          <section class="field-page__section">
            <h2>Every Tuple Ship</h2>
            <p>A Tuple Ship is not merely software.</p>
            <p>It is not merely a record.</p>
            <p>It is not merely a workflow.</p>
            <p>
              It is one established Constitutional Locality where Situationings may continue Holding Over Discrete Turns.
            </p>
            <p>No Tuple Ship stands above another.</p>
            <p>No Tuple Ship replaces another.</p>
            <p>Each stewards what it alone is responsible for stewarding.</p>
            <p>Each remains free to Correspond throughout the Public Field.</p>
          </section>

          <section class="field-page__section">
            <h2>Correspondencing Throughout the Field</h2>
            <p>Once Tuple Ships become Encounteringmentingable, they may begin Correspondencing.</p>
            <p>They need not become identical.</p>
            <p>Neither must they agree.</p>
            <p>Instead they may publish Correspondencingments...</p>
          </section>

          <section class="field-page__section">
            <h2>Furnishing the Public Field</h2>
            <p>The long-term objective of the PUBLIC-SITUATION-MACHINE- is simple.</p>
            <p>Everyone should have free access to one PUBLIC-SITUATION-MACHINE- at a time.</p>
            <p>
              The Public Field grows by making that possible. Individuals should be able to inhabit one PUBLIC-SITUATION-MACHINE- freely, while organizations requiring stewardship of multiple Situationings furnish the shared infrastructure that enables universal access.
            </p>
            <p>
              If you wish to learn more about helping furnish This One Great Free Public Tuple Ship Field, the
              <a
                href="https://www.kickstarter.com/projects/situationmachine/the-public-situation-machine-inhabitationingable-computing"
                target="_blank"
                rel="noreferrer"
              >Kickstarter story</a>
              describes the present public campaign and the constitutional journey now unfolding.
            </p>
            <p>The Propagationing is simple.</p>
            <p>One machine for Every One.</p>
          </section>

          <section class="field-page__section">
            <h2>An Invitation</h2>
            <p>The PUBLIC-SITUATION-MACHINE- is being built as a public appliance.</p>
            <p>
              This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining is therefore not a vision belonging to one organization.
            </p>
            <p>It is an invitation.</p>
            <p>An invitation to steward places.</p>
            <p>To author Situationings.</p>
            <p>To contribute Constitutioningable Reasoning Geometry.</p>
            <p>To publish Correspondencingments.</p>
            <p>
              To participate in the continued furnishing of a civilization whose Constitutional Localities remain free to correspond without surrendering the lawful Continuity Lines that make each one distinct.
            </p>
            <p>This One Great Free Public Tuple Ship Field.</p>
            <p><em>A civilization holding with no center.</em></p>
          </section>
        </div>

        <script :type={Phoenix.LiveView.ColocatedHook} name=".SelfCorrespondencing">
          export default {
            mounted() {
              this.handleEvent("hail_leashing", ({href}) => {
                window.location.href = href
              })
            }
          }
        </script>
      </main>
    </Layouts.app>
    """
  end

  defp shackling_pin do
    16
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(case: :upper)
    |> String.graphemes()
    |> Enum.chunk_every(4)
    |> Enum.map_join(" ", &Enum.join/1)
  end

  defp normalize_parkinging_stand(parkinging_stand) do
    parkinging_stand
    |> String.replace(~r/\D/u, "")
    |> String.pad_leading(12, "0")
  end

  defp normalize_shackling_pin(shackling_pin) do
    shackling_pin
    |> String.replace(~r/\s/u, "")
    |> String.upcase()
    |> String.graphemes()
    |> Enum.chunk_every(4)
    |> Enum.map_join(" ", &Enum.join/1)
  end

  defp correspondence_href(channel, destination, assigns) do
    body =
      """
      Parkinging Stand Number: #{assigns.parkinging_stand}
      Shackling Pin: #{assigns.shackling_pin}
      """
      |> String.trim()

    encoded_body = URI.encode_www_form(body)

    case channel do
      "text" -> "sms:#{URI.encode(destination)}?body=#{encoded_body}"
      _ -> "mailto:#{URI.encode(destination)}?subject=This%20One%20Leashing&body=#{encoded_body}"
    end
  end

  defp format_piece_of_time(%DateTime{} = piece_of_time),
    do: Calendar.strftime(piece_of_time, "%Y-%m-%d %H:%M:%S UTC")

  defp earthly_locality_text(%{country: country, region: region, city: city}) do
    [city, region, country]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join(", ")
  end

  defp earthly_locality_text(locality), do: to_string(locality)
end
