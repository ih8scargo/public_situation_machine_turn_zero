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
       pet_name_history: [],
       pet_name_refurbishing?: false,
       naming_form: to_form(%{"name" => ""}, as: :leashing),
       re_shackling_form:
         to_form(%{"parkinging_stand" => "", "shackling_pin" => ""}, as: :re_shackling),
       re_shackling_result: nil,
       re_shackling_decision: :pending,
       correspondence_form:
         to_form(%{"channel" => "email", "destination" => ""}, as: :correspondence),
       locality_form: to_form(%{"country" => "", "region" => "", "city" => ""}, as: :locality),
       countries: country_options(),
       regions: [],
       cities: [],
       station_02_unfolded?: false,
       station_02_decision: :pending,
       proto_appointmentings: MapSet.new(),
       station_02_completed?: false
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
        {:ok, leashing} =
          ParkingingStandRegistry.furnish_pet_name(
            socket.assigns.parkinging_stand,
            socket.assigns.shackling_pin,
            furnished_name,
            DateTime.utc_now() |> DateTime.truncate(:second)
          )

        {:noreply,
         assign(socket,
           naming_decision: :named,
           leashing_name: furnished_name,
           pet_name_history: leashing.pet_name_history,
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

  def handle_event("begin-refurbishing-pet-name", _params, socket) do
    {:noreply,
     assign(socket,
       pet_name_refurbishing?: true,
       naming_form: to_form(%{"name" => ""}, as: :leashing)
     )}
  end

  def handle_event(
        "refurbish-pet-name",
        %{"leashing" => %{"name" => name}},
        %{assigns: %{naming_decision: :named}} = socket
      ) do
    case String.trim(name) do
      "" ->
        {:noreply, socket}

      pet_name ->
        {:ok, leashing} =
          ParkingingStandRegistry.furnish_pet_name(
            socket.assigns.parkinging_stand,
            socket.assigns.shackling_pin,
            pet_name,
            DateTime.utc_now() |> DateTime.truncate(:second)
          )

        {:noreply,
         assign(socket,
           leashing_name: pet_name,
           pet_name_history: leashing.pet_name_history,
           pet_name_refurbishing?: false,
           naming_form: to_form(%{"name" => pet_name}, as: :leashing)
         )}
    end
  end

  def handle_event("refurbish-pet-name", _params, socket), do: {:noreply, socket}

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
           pet_name_history: leashing.pet_name_history,
           proto_appointmentings: leashing.appointmentings |> Map.keys() |> MapSet.new(),
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

  def handle_event(
        "correspondence-changed",
        %{"correspondence" => correspondence_params},
        %{assigns: %{re_shackling_decision: decision}} = socket
      )
      when decision in [:completed, :continued] do
    {:noreply,
     assign(socket, :correspondence_form, to_form(correspondence_params, as: :correspondence))}
  end

  def handle_event("correspondence-changed", _params, socket), do: {:noreply, socket}

  def handle_event(
        "unfold-station-02",
        _params,
        %{assigns: %{re_shackling_decision: decision}} = socket
      )
      when decision in [:completed, :continued] do
    {:noreply, assign(socket, :station_02_unfolded?, true)}
  end

  def handle_event("unfold-station-02", _params, socket), do: {:noreply, socket}

  def handle_event(
        "furnish-proto-appointmenting",
        %{"appointmenting" => appointmenting},
        %{assigns: %{station_02_unfolded?: true}} = socket
      )
      when appointmenting in ["lanterning", "sounding_bell"] do
    appointmenting = String.to_existing_atom(appointmenting)

    {:ok, _leashing} =
      ParkingingStandRegistry.furnish_appointmenting(
        socket.assigns.parkinging_stand,
        socket.assigns.shackling_pin,
        appointmenting,
        DateTime.utc_now() |> DateTime.truncate(:second)
      )

    socket =
      socket
      |> assign(
        :proto_appointmentings,
        MapSet.put(socket.assigns.proto_appointmentings, appointmenting)
      )
      |> maybe_complete_station_02()

    {:noreply, socket}
  end

  def handle_event("furnish-proto-appointmenting", _params, socket), do: {:noreply, socket}

  def handle_event(
        "locality-changed",
        %{"locality" => locality_params},
        %{assigns: %{re_shackling_decision: decision}} = socket
      )
      when decision in [:completed, :continued] do
    country = Map.get(locality_params, "country", "")
    prior_country = socket.assigns.locality_form[:country].value

    locality_params =
      if country != prior_country do
        Map.merge(locality_params, %{"region" => "", "city" => ""})
      else
        locality_params
      end

    region = Map.get(locality_params, "region", "")
    prior_region = socket.assigns.locality_form[:region].value

    locality_params =
      if region != prior_region,
        do: Map.put(locality_params, "city", ""),
        else: locality_params

    {:noreply,
     assign(socket,
       locality_form: to_form(locality_params, as: :locality),
       regions: region_options(country),
       cities: city_options(country, Map.get(locality_params, "region", ""))
     )}
  end

  def handle_event("locality-changed", _params, socket), do: {:noreply, socket}

  def handle_event(
        "furnish-earthly-locality",
        %{"locality" => locality_params},
        %{assigns: %{re_shackling_decision: decision}} = socket
      )
      when decision in [:completed, :continued] do
    country = Map.get(locality_params, "country", "")

    if country == "" do
      {:noreply, assign(socket, :locality_form, to_form(locality_params, as: :locality))}
    else
      earthly_locality = %{
        country: option_label(socket.assigns.countries, country),
        region: option_label(socket.assigns.regions, Map.get(locality_params, "region", "")),
        city: Map.get(locality_params, "city", "")
      }

      {:ok, _leashing} =
        ParkingingStandRegistry.furnish_earthly_locality(
          socket.assigns.parkinging_stand,
          socket.assigns.shackling_pin,
          earthly_locality
        )

      socket =
        socket
        |> assign(
          station_02_decision: :completed,
          locality_form: to_form(locality_params, as: :locality)
        )
        |> maybe_complete_station_02()

      {:noreply, socket}
    end
  end

  def handle_event("furnish-earthly-locality", _params, socket), do: {:noreply, socket}

  def handle_event(
        "continue-without-earthly-locality",
        _params,
        %{assigns: %{re_shackling_decision: decision}} = socket
      )
      when decision in [:completed, :continued] do
    {:noreply,
     socket
     |> assign(:station_02_decision, :declined)
     |> maybe_complete_station_02()}
  end

  def handle_event("continue-without-earthly-locality", _params, socket),
    do: {:noreply, socket}

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
              In so doing, the Constitutioning Human takes hold of This One Leashing.
            </p>
            <p>
              Here begins the Traversaling toward The Seat of the Stewardly Co-Occupancyingship.
            </p>
            <p>
              Through this Traversaling, the Continuitying Laboringings of Stewardshippery may begin standing in Holding.
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
              This Constitutional Furnishmenting Rail Line stands Constitutioning from its first Station onward while standing in Readiness for Extension through the lawful Appointmenting of future Furnishmenting Stations Commencementing Here.
            </p>
          </header>

          <header class="field-page__station-header field-page__station-header--opening">
            <p class="site-page__eyebrow">STATION 01</p>
            <h3 id="terrestrial-computer-parkinging-station-title">
              This Terrestrial Computer Free Parkinging Station
            </h3>
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
            <article
              id="terrestrial-computer-parkinging-station"
              class="field-page__station"
              aria-labelledby="terrestrial-computer-parkinging-station-title"
            >
              <div id="dual-stewardship-geometry" class="field-page__dual-stewardship">
                <svg
                  id="stewardship-rail-split"
                  class="field-page__stewardship-split"
                  viewBox="0 0 100 50"
                  preserveAspectRatio="none"
                  aria-hidden="true"
                >
                  <path d="M50 0 L50 16"></path>
                  <path d="M50 16 L24 48"></path>
                  <path d="M50 16 L76 48"></path>
                </svg>

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
                <p>
                  This One Crew stands inhabitationing Their Combined Laboringings through These Interrelationing Officerly Stewardships.
                </p>
              </div>

              <div
                id="station-01-constitutional-voices"
                class="field-page__crew-statement field-page__constitutional-voices"
              >
                <section aria-labelledby="appliance-narration-voice">
                  <h5 id="appliance-narration-voice">Appliance Narration</h5>
                  <p>
                    The Constitutioning Human now chooses to Take Holdinging of This One Leashing.
                  </p>
                </section>
                <section aria-labelledby="institutional-action-voice">
                  <h5 id="institutional-action-voice">Institutional Action</h5>
                  <p>
                    <em>This One Terrestrial Computer Leashinging Crew now fashions This One Leashing.</em>
                  </p>
                </section>
                <section aria-labelledby="crew-voice">
                  <h5 id="crew-voice">Crew Voice</h5>
                  <p>
                    You will receive This One Terrestrial Computer Parkinging Stand Number together with This One Shackling Pin that belongs with it.
                  </p>
                  <p>
                    Through This One Leashing, you may later shackle any Terrestrial Computer to This One Free Parkinging Stand.
                  </p>
                </section>
              </div>

              <div class="field-page__interaction">
                <section class="field-page__leash" aria-labelledby="leash-title">
                  <h4 id="leash-title">THIS ONE LEASHING</h4>

                  <%= if @ceremony_completed? do %>
                    <div id="leashing-ceremony-complete" aria-live="polite">
                      <div
                        id="parkinging-credentials"
                        class="field-page__credentials"
                        phx-hook=".CopyFurnishing"
                      >
                        <div>
                          <span>This One Terrestrial Computer Parkinging Stand Number</span>
                          <strong id="parkinging-stand" data-value={@parkinging_stand}>
                            {@parkinging_stand}
                          </strong>
                          <button type="button" data-copy={@parkinging_stand}>Copy</button>
                        </div>
                        <div>
                          <span>This One Shackling Pin</span>
                          <strong id="shackling-pin" data-value={@shackling_pin}>
                            {@shackling_pin}
                          </strong>
                          <button type="button" data-copy={@shackling_pin}>Copy</button>
                        </div>
                        <p data-copy-status aria-live="polite"></p>
                      </div>

                      <div id="leashing-ceremony-time" class="field-page__ceremony-time">
                        <span>This One Piece of Time</span>
                        <time datetime={DateTime.to_iso8601(@ceremony_time)}>
                          {Calendar.strftime(@ceremony_time, "%Y-%m-%d %H:%M:%S UTC")}
                        </time>
                      </div>

                      <div class="field-page__completion-statement">
                        <p>Together, These Relationings now stand as This One Leashing.</p>
                        <p>This One Leashing stands upon This One Constitutional Locality.</p>
                        <p>
                          This One Terrestrial Computer Parkinging Stand Number need not be kept secret.
                        </p>
                        <p>This One Shackling Pin should be preserved in a Secret Some Place.</p>
                      </div>

                      <section
                        :if={@naming_decision in [:pending, :furnishing]}
                        id="leashing-naming"
                        class="field-page__naming"
                        aria-labelledby="leashing-naming-title"
                      >
                        <h5 id="leashing-naming-title">
                          Give This One Leashing a Pet Name
                        </h5>

                        <div :if={@naming_decision == :pending} class="field-page__naming-choices">
                          <button
                            id="begin-furnishing-leashing-name"
                            type="button"
                            class="field-page__action"
                            phx-click="begin-furnishing-name"
                          >
                            Give This One Pet Name
                          </button>
                          <button
                            id="continue-without-leashing-name"
                            type="button"
                            class="field-page__action"
                            phx-click="continue-without-name"
                          >
                            Continue Without Giving This One Pet Name
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
                            label="This One Pet Name for This One Leashing"
                            autocomplete="off"
                            maxlength="120"
                            required
                          />
                          <button type="submit" class="field-page__action">Give This One Pet Name</button>
                        </.form>
                      </section>

                      <section
                        :if={@naming_decision == :named}
                        id="pet-name-continuity-line"
                        class="field-page__pet-name-history"
                      >
                        <h5>This One Pet Name Continuity Line</h5>
                        <p>This One Pet Name belongs to the Constitutioning Human.</p>
                        <p>
                          It may be held in an Open Place, a Secret Some Place, or any Some Place in between.
                        </p>
                        <ol>
                          <li :for={entry <- @pet_name_history}>
                            <strong>{entry.name}</strong>
                            <time datetime={DateTime.to_iso8601(entry.furnished_at)}>
                              {format_piece_of_time(entry.furnished_at)}
                            </time>
                          </li>
                        </ol>

                        <button
                          :if={!@pet_name_refurbishing?}
                          id="begin-refurbishing-pet-name"
                          type="button"
                          class="field-page__action"
                          phx-click="begin-refurbishing-pet-name"
                        >
                          RE-Furbish This One Pet Name
                        </button>

                        <.form
                          :if={@pet_name_refurbishing?}
                          for={@naming_form}
                          id="refurbish-pet-name-form"
                          phx-submit="refurbish-pet-name"
                        >
                          <.input
                            field={@naming_form[:name]}
                            type="text"
                            label="New This One Pet Name"
                            maxlength="120"
                            required
                          />
                          <button type="submit" class="field-page__action">
                            RE-Furbish This One Pet Name
                          </button>
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
                    Through the combined Laboringings of This One Crew, This One Leashingmenting comes into Lawful Beginning.
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
                    Through This Station, the Constitutioning Human may practice returning to This One Great Free Public Tuple Ship Field Parkinging Lot through This One Leashing whenever desired.
                  </p>
                  <p>
                    This is a voluntary practice of lawful Return. It is not authentication or account access.
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
                        label="This One Terrestrial Computer Parkinging Stand Number"
                        inputmode="numeric"
                        maxlength="12"
                        autocomplete="off"
                        required
                      />
                      <.input
                        field={@re_shackling_form[:shackling_pin]}
                        type="text"
                        label="This One Shackling Pin"
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
                    phx-hook=".CopyFurnishing"
                  >
                    <dl>
                      <div>
                        <dt>This One Terrestrial Computer Parkinging Stand Number</dt>
                        <dd>
                          {@re_shackling_result.parkinging_stand}
                          <button type="button" data-copy={@re_shackling_result.parkinging_stand}>
                            Copy
                          </button>
                        </dd>
                      </div>
                      <div>
                        <dt>This One Shackling Pin</dt>
                        <dd>
                          {@shackling_pin}
                          <button type="button" data-copy={@shackling_pin}>Copy</button>
                        </dd>
                      </div>
                      <div>
                        <dt>This One Piece of Time</dt>
                        <dd>{format_piece_of_time(@re_shackling_result.ceremony_time)}</dd>
                      </div>
                      <div :if={@re_shackling_result.name}>
                        <dt>This One Pet Name</dt>
                        <dd>{@re_shackling_result.name}</dd>
                      </div>
                      <div :if={@re_shackling_result.earthly_locality}>
                        <dt>Earthly Locality</dt>
                        <dd>{earthly_locality_text(@re_shackling_result.earthly_locality)}</dd>
                      </div>
                    </dl>
                    <span data-copy-status aria-live="polite"></span>
                    <p>This One Leashing continues standing in lawful Holding.</p>
                  </div>
                </div>
              </article>
            </div>
          </div>
        </section>

        <div
          :if={@re_shackling_decision in [:completed, :continued]}
          id="rail-line-after-station-01"
        >
          <section
            id="self-correspondencing-crew"
            class="field-page__self-correspondencing field-page__section"
            aria-labelledby="self-correspondencing-title"
          >
            <p class="site-page__eyebrow">OPTIONAL SELF-CORRESPONDENCING</p>
            <h2 id="self-correspondencing-title">Take This One Leashing With You</h2>
            <p>
              Dispatch One Correspondencingment bearing This One Leashing to a Some Place of your choosing.
            </p>
            <p>This One Leashing is not kept through an account.</p>
            <p>It is exercised through lawful Correspondencing.</p>

            <.form
              for={@correspondence_form}
              id="self-correspondencing-form"
              phx-hook=".SelfCorrespondencing"
              phx-change="correspondence-changed"
              phx-submit="hail-leashing"
            >
              <div class="field-page__correspondence-fields">
                <.input
                  field={@correspondence_form[:channel]}
                  type="select"
                  label="Correspondencing Passageway"
                  options={[{"Email", "email"}, {"Text message", "text"}]}
                />
                <.input
                  field={@correspondence_form[:destination]}
                  type="text"
                  label="Some Place of your choosing"
                  placeholder={correspondence_placeholder(@correspondence_form[:channel].value)}
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

          <div class="field-page__rail-line" aria-hidden="true"></div>

          <section id="station-02-opening" class="field-page__station-opening">
            <header class="field-page__station-header">
              <p class="site-page__eyebrow">STATION 02</p>
              <h3 id="earthly-localities-station-title">This One Place</h3>
            </header>

            <section
              class="psm-oag field-page__station-regard"
              aria-labelledby="station-02-regard-title"
            >
              <div class="psm-oag__instrument-plate">
                <p class="psm-oag__eyebrow">
                  The Same General Civilizationalizing Constitutioningable Reasoning Geometry
                </p>
                <h2 id="station-02-regard-title">Standinging in Regard</h2>
                <p class="psm-oag__reading">The Bearinging of This One Place</p>
              </div>
              <div class="psm-oag__description">
                <p>This One Place stands approaching Stewardly Regard.</p>
                <p>One Lanterning Appointmenting may now become available.</p>
                <p>
                  The Rail Line stands ready to unfold toward another constitutional beginning.
                </p>
              </div>
            </section>

            <button
              :if={!@station_02_unfolded?}
              id="unfold-station-02"
              type="button"
              class="field-page__action field-page__station-unfold-action"
              phx-click="unfold-station-02"
            >
              Unfold
            </button>
          </section>

          <article
            :if={@station_02_unfolded?}
            id="earthly-localities-station"
            class="field-page__station"
            aria-labelledby="earthly-localities-station-title"
          >
            <div id="station-02-stewardship-geometry" class="field-page__dual-stewardship">
              <div class="field-page__stewardship-headings">
                <h4>Constitutioning</h4>
                <h4>Furnished Through</h4>
              </div>

              <div class="field-page__stewardship-pairs">
                <div class="field-page__stewardship-pair">
                  <div>Office of Bearingings</div>
                  <span aria-hidden="true"></span>
                  <div>Continuity Line Carriageing Administrativation</div>
                </div>
                <div class="field-page__stewardship-pair">
                  <div>Bearinging Field Division</div>
                  <span aria-hidden="true"></span>
                  <div>Division of Discrete Turn Index Advancementing</div>
                </div>
                <div class="field-page__stewardship-pair">
                  <div>Department of Embodying Inhabitationing Localities</div>
                  <span aria-hidden="true"></span>
                  <div>Department of This Approaching Landingmenting</div>
                </div>
                <div class="field-page__stewardship-pair">
                  <div>Membrane-Oriented Constitutional Locality — Unit Title in Preparation</div>
                  <span aria-hidden="true"></span>
                  <div>Rail Line Furnishingments Unit</div>
                </div>
                <div class="field-page__stewardship-pair">
                  <div>This One Place Observationmintingmenting</div>
                  <span aria-hidden="true"></span>
                  <div>House of Slumbering Lanterning Bug Colonial Bunk House Furnishings</div>
                </div>
              </div>

              <svg
                class="field-page__stewardship-convergence"
                viewBox="0 0 100 50"
                preserveAspectRatio="none"
                aria-hidden="true"
              >
                <defs>
                  <marker
                    id="station-02-arrowhead"
                    markerWidth="5"
                    markerHeight="5"
                    refX="4"
                    refY="2.5"
                    orient="auto"
                  >
                    <path d="M0,0 L5,2.5 L0,5 Z"></path>
                  </marker>
                </defs>
                <path d="M24 0 L50 25" marker-end="url(#station-02-arrowhead)"></path>
                <path d="M76 0 L50 25" marker-end="url(#station-02-arrowhead)"></path>
                <path d="M50 25 L50 48" marker-end="url(#station-02-arrowhead)"></path>
              </svg>
            </div>

            <div id="this-one-place-crew" class="field-page__crew-conjunction">
              <h4>This One Place Crew</h4>
              <p>This Crew stands ready to help This One Place come gently into Regard.</p>
            </div>

            <div class="field-page__crew-statement">
              <p>
                This One Place Crew furnishes Stewardly Observationings of where upon The Earth Constitutioning Humans stand inhabitationing.
              </p>
              <p>
                This One Great Free Public Tuple Ship Field may begin encounteringmenting itself through these Observationings.
              </p>
              <p>The Constitutioning Human is invited to furnish This One Place.</p>
              <p>
                A broad Earthly Locality is enough.
              </p>
              <p>No precise location is requested.</p>
              <p>
                Future Observationings may help the Public Tuple Ship Field become Visionizingable upon The Earth.
              </p>
            </div>

            <div class="field-page__interaction">
              <header class="field-page__appointmenting-header">
                <p class="site-page__eyebrow">ONE LANTERNING APPOINTMENTING</p>
                <h4>Lanterning Bug Appointmenting</h4>
                <p>
                  The House of Slumbering Lanterning Bug Colonial Bunk House Furnishings stands ready to furnish one Lanterning Bug Appointmenting.
                </p>
              </header>

              <div
                :if={@station_02_decision == :pending}
                class="field-page__station-02-choices"
              >
                <.form
                  for={@locality_form}
                  id="earthly-locality-form"
                  phx-change="locality-changed"
                  phx-submit="furnish-earthly-locality"
                >
                  <div class="field-page__locality-grid">
                    <.input
                      field={@locality_form[:country]}
                      type="select"
                      label="Country"
                      prompt="Choose a country"
                      options={@countries}
                    />
                    <.input
                      field={@locality_form[:region]}
                      type="select"
                      label="Region / State / Province"
                      prompt="Choose a region"
                      options={@regions}
                      disabled={@regions == []}
                    />
                    <.input
                      field={@locality_form[:city]}
                      type="select"
                      label="City / Locality"
                      prompt="Choose a city or locality"
                      options={@cities}
                      disabled={@cities == []}
                    />
                  </div>
                  <button type="submit" class="field-page__action">
                    Furnish This One Place
                  </button>
                </.form>

                <button
                  id="continue-without-earthly-locality"
                  type="button"
                  class="field-page__action"
                  phx-click="continue-without-earthly-locality"
                >
                  Continue Without Furnishing an Earthly Locality
                </button>
              </div>

              <section
                id="proto-encounteringmenting-appointmentings"
                class="field-page__proto-appointmentings"
                aria-labelledby="proto-appointmentings-title"
              >
                <header>
                  <p class="site-page__eyebrow">PROTO ENCOUNTERINGMENTING</p>
                  <h4 id="proto-appointmentings-title">Two Independent Appointmentings</h4>
                  <p>Neither Appointmenting depends upon the other.</p>
                  <p>Neither Appointmenting creates communication.</p>
                </header>

                <div class="field-page__proto-appointmenting-grid">
                  <article id="lanterning-appointmenting">
                    <p>APPOINTMENTING A</p>
                    <h5>Lanterning upon</h5>
                    <strong>This One Free Parkinging Stand</strong>
                    <button
                      :if={!MapSet.member?(@proto_appointmentings, :lanterning)}
                      type="button"
                      class="field-page__action"
                      phx-click="furnish-proto-appointmenting"
                      phx-value-appointmenting="lanterning"
                    >
                      Begin This Appointmenting
                    </button>
                    <p
                      :if={MapSet.member?(@proto_appointmentings, :lanterning)}
                      class="field-page__confirmation"
                    >
                      This Appointmenting now stands in lawful beginning.
                    </p>
                  </article>

                  <article id="sounding-bell-appointmenting">
                    <p>APPOINTMENTING B</p>
                    <h5>Observationing-Class-is-in-Sessioning Soundinging Bell</h5>
                    <strong>upon This One Pet Name</strong>
                    <button
                      :if={!MapSet.member?(@proto_appointmentings, :sounding_bell)}
                      type="button"
                      class="field-page__action"
                      phx-click="furnish-proto-appointmenting"
                      phx-value-appointmenting="sounding_bell"
                    >
                      Begin This Appointmenting
                    </button>
                    <p
                      :if={MapSet.member?(@proto_appointmentings, :sounding_bell)}
                      class="field-page__confirmation"
                    >
                      This Appointmenting now stands in lawful beginning.
                    </p>
                  </article>
                </div>
              </section>

              <div
                :if={@station_02_completed?}
                id="station-02-completion"
                class="field-page__station-completion"
              >
                <p :if={@station_02_decision == :completed}>
                  This One Place now stands in lawful Placement upon The Earth.
                </p>
                <p>
                  This One Lanterning now stands illuminationing the way toward This Encounteringmenting Wharf from This One Free Terrestrial Computer Parkinging Stand.
                </p>
              </div>
            </div>
          </article>

          <div
            :if={@station_02_completed?}
            id="rail-line-extension-readiness"
            class="field-page__extension-readiness"
          >
            <h2>
              This Constitutional Furnishmenting Rail Line has reached its present Constitutional Terminusmenting.
            </h2>
            <p>This Constitutional Furnishmenting Rail Line stands ready for further Extension.</p>
            <p>Future Stations may come into lawful Unfoldingment.</p>
          </div>

          <section
            :if={@station_02_completed?}
            id="tuple-field-terminus-harbor"
            class="psm-oag field-page__terminus-harbor"
            aria-labelledby="tuple-field-terminus-harbor-title"
          >
            <div class="psm-oag__instrument-plate">
              <p class="psm-oag__eyebrow">
                The Same General Civilizationalizing Constitutioningable Reasoning Geometry
              </p>
              <h2 id="tuple-field-terminus-harbor-title">Standinging in Regard</h2>
              <p class="psm-oag__reading">The Bearinging of Lawful Encounteringmenting</p>
            </div>
            <div class="psm-oag__description">
              <p>You now stand at the present Constitutional Terminusmenting.</p>
              <p>This Constitutional Furnishmenting Rail Line continues Holdinging behind you.</p>
              <p>
                Before you, This One Great Free Public Tuple Ship Field stands available for Stewardly Regard as future Stations may come into lawful Unfoldingment.
              </p>
            </div>
          </section>

          <div
            :if={@station_02_completed?}
            id="tuple-field-after-leashing-ceremony"
          >
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

        <script :type={Phoenix.LiveView.ColocatedHook} name=".CopyFurnishing">
          export default {
            mounted() {
              this.el.addEventListener("click", async (event) => {
                const button = event.target.closest("[data-copy]")
                if (!button) return

                const status = this.el.querySelector("[data-copy-status]")

                try {
                  await navigator.clipboard.writeText(button.dataset.copy)
                  if (status) status.textContent = "Copied."
                } catch (_error) {
                  if (status) status.textContent = "Copy unavailable."
                }
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
    pet_name_block =
      if assigns.leashing_name,
        do: "\n\nThis One Pet Name:\n#{assigns.leashing_name}",
        else: ""

    body =
      """
      Self-Correspondencingment Dispatched from
      The PUBLIC-SITUATION-MACHINE-

      This One Leashing

      This One Leashing stands hailing to This One Some Place at your request so that it may stand here in Readiness for future Stewardly Laboringings of Continuitying.

      This One Terrestrial Computer Parkinging Stand Number:
      #{assigns.parkinging_stand}

      This One Shackling Pin:
      #{assigns.shackling_pin}

      This One Piece of Time:
      #{format_piece_of_time(assigns.ceremony_time)}#{pet_name_block}

      This One Leashing is not kept through an account.

      It is exercised through lawful Correspondencing.

      Return Here through This One Leashing whenever This Constitutional Furnishmenting Rail Line stands ready to continue.
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

  defp country_options do
    Place.get_countries()
    |> Enum.sort_by(& &1.name)
    |> Enum.map(&{&1.name, &1.iso2})
  end

  defp region_options(""), do: []

  defp region_options(country) do
    Place.get_states(country_code: country)
    |> Enum.sort_by(& &1.name)
    |> Enum.map(&{&1.name, &1.state_code})
  end

  defp city_options("", _region), do: []

  defp city_options(country, "") do
    if region_options(country) == [] do
      Place.get_cities(country_code: country)
      |> city_option_list()
    else
      []
    end
  end

  defp city_options(country, region) do
    Place.get_cities(country_code: country, state_code: region)
    |> city_option_list()
  end

  defp city_option_list(cities) do
    cities
    |> Enum.sort_by(& &1.name)
    |> Enum.map(&{&1.name, &1.name})
  end

  defp option_label(_options, ""), do: ""

  defp option_label(options, value) do
    case Enum.find(options, fn {_label, option_value} -> option_value == value end) do
      {label, _value} -> label
      nil -> value
    end
  end

  defp correspondence_placeholder("text"), do: "(000) 000-0000"

  defp correspondence_placeholder(_channel),
    do: "ThisStewardlyCaptainCOB@ThisOneEmailAddress.com"

  defp maybe_complete_station_02(socket) do
    completed? =
      socket.assigns.station_02_decision in [:completed, :declined] and
        MapSet.member?(socket.assigns.proto_appointmentings, :lanterning) and
        MapSet.member?(socket.assigns.proto_appointmentings, :sounding_bell)

    assign(socket, :station_02_completed?, completed?)
  end
end
