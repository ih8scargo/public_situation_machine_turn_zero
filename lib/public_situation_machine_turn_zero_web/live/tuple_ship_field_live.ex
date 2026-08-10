defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  alias PublicSituationMachineTurnZero.ParkingingStandRegistry

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "This Tuple Ship Field",
       entrance_stage: :station_house,
       sittinging_cabinets: MapSet.new(),
       parkinging_stand: nil,
       shackling_pin: nil,
       ceremony_time: nil,
       ceremony_completed?: false,
       landing_inquired?: false,
       reception_form:
         to_form(%{"parkinging_stand" => "", "shackling_pin" => ""}, as: :reception),
       reception_result: nil,
       rail_unfolded?: false,
       zeroeth_mattering: nil,
       zeroeth_mattering_form: to_form(%{"mattering" => ""}, as: :zeroeth_inquiry),
       naming_decision: :furnishing,
       leashing_name: nil,
       earthly_locality: nil,
       earthly_locality_history: [],
       pet_name_history: [],
       pet_name_refurbishing?: false,
       naming_form: to_form(%{"name" => ""}, as: :leashing),
       re_shackling_form:
         to_form(%{"parkinging_stand" => "", "shackling_pin" => ""}, as: :re_shackling),
       re_shackling_result: nil,
       re_shackling_decision: :pending,
       correspondence_form:
         to_form(%{"channel" => "email", "destination" => ""}, as: :correspondence),
       locality_form:
         to_form(
           %{"country" => "", "region" => "", "city" => "", "visionizing_scope" => "region"},
           as: :locality
         ),
       countries: country_options(),
       regions: [],
       cities: [],
       station_02_unfolded?: false,
       station_02_decision: :pending,
       proto_appointmentings: MapSet.new(),
       appointmenting_times: %{},
       station_02_completed?: false
     )}
  end

  @impl true
  def handle_event("enter-opening-passageway", _params, socket) do
    {:noreply, assign(socket, :entrance_stage, :passageway)}
  end

  def handle_event("unfold-sittinging-in-room", _params, socket) do
    if socket.assigns.entrance_stage == :passageway do
      {:noreply, assign(socket, :entrance_stage, :sittinging_room)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("toggle-sittinging-cabinet", %{"cabinet" => cabinet}, socket)
      when cabinet in ["xt", "yt"] do
    cabinet = if cabinet == "xt", do: :xt, else: :yt

    {:noreply,
     update(socket, :sittinging_cabinets, fn cabinets ->
       if MapSet.member?(cabinets, cabinet),
         do: MapSet.delete(cabinets, cabinet),
         else: MapSet.put(cabinets, cabinet)
     end)}
  end

  def handle_event("unfold-existing-rail-line", _params, socket) do
    if socket.assigns.entrance_stage == :sittinging_room do
      {:noreply, assign(socket, :entrance_stage, :rail)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("inquire-within", _params, socket) do
    {:noreply, assign(socket, :landing_inquired?, true)}
  end

  @impl true
  def handle_event(
        "unfold-constitutional-rail-line",
        %{"zeroeth_inquiry" => %{"mattering" => mattering}},
        socket
      ) do
    case String.trim(mattering) do
      "" ->
        {:noreply, socket}

      received_mattering ->
        {:noreply,
         assign(socket,
           rail_unfolded?: true,
           zeroeth_mattering: received_mattering,
           zeroeth_mattering_form:
             to_form(%{"mattering" => received_mattering}, as: :zeroeth_inquiry)
         )}
    end
  end

  def handle_event("unfold-constitutional-rail-line", _params, socket),
    do: {:noreply, socket}

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
       ceremony_completed?: true,
       naming_decision: :furnishing
     )}
  end

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
           re_shackling_decision: :continued,
           leashing_name: furnished_name,
           pet_name_history: leashing.pet_name_history,
           naming_form: to_form(%{"name" => furnished_name}, as: :leashing)
         )}
    end
  end

  def handle_event("furnish-leashing-name", _params, socket), do: {:noreply, socket}

  def handle_event(
        "reconstruct-constitutional-locality",
        %{
          "reception" => %{
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
        naming_decision = if leashing.name, do: :named, else: :furnishing

        {:noreply,
         assign(socket,
           landing_inquired?: true,
           rail_unfolded?: true,
           reception_result: :reconstructed,
           parkinging_stand: leashing.parkinging_stand,
           shackling_pin: leashing.shackling_pin,
           ceremony_time: leashing.ceremony_time,
           ceremony_completed?: true,
           naming_decision: naming_decision,
           leashing_name: leashing.name,
           naming_form: to_form(%{"name" => leashing.name || ""}, as: :leashing),
           pet_name_history: leashing.pet_name_history,
           earthly_locality: leashing.earthly_locality,
           earthly_locality_history: leashing.earthly_locality_history,
           proto_appointmentings: leashing.appointmentings |> Map.keys() |> MapSet.new(),
           appointmenting_times: leashing.appointmentings,
           re_shackling_decision: if(leashing.name, do: :continued, else: :pending)
         )}

      :error ->
        {:noreply,
         assign(socket,
           reception_result: :error,
           reception_form:
             to_form(
               %{"parkinging_stand" => parkinging_stand, "shackling_pin" => shackling_pin},
               as: :reception
             )
         )}
    end
  end

  def handle_event("reconstruct-constitutional-locality", _params, socket),
    do: {:noreply, socket}

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
        %{assigns: %{naming_decision: :named}} = socket
      ) do
    parkinging_stand = ParkingingStandRegistry.normalize_parkinging_stand(parkinging_stand)
    shackling_pin = ParkingingStandRegistry.normalize_shackling_pin(shackling_pin)

    case ParkingingStandRegistry.re_shackle(parkinging_stand, shackling_pin) do
      {:ok, leashing} ->
        naming_decision = if leashing.name, do: :named, else: :furnishing

        socket =
          socket
          |> assign(
            parkinging_stand: leashing.parkinging_stand,
            shackling_pin: leashing.shackling_pin,
            ceremony_time: leashing.ceremony_time,
            ceremony_completed?: true,
            naming_decision: naming_decision,
            leashing_name: leashing.name,
            naming_form: to_form(%{"name" => leashing.name || ""}, as: :leashing),
            earthly_locality: leashing.earthly_locality,
            earthly_locality_history: leashing.earthly_locality_history,
            pet_name_history: leashing.pet_name_history,
            proto_appointmentings: leashing.appointmentings |> Map.keys() |> MapSet.new(),
            appointmenting_times: leashing.appointmentings,
            re_shackling_result: :returned,
            re_shackling_decision: if(leashing.name, do: :completed, else: :pending),
            re_shackling_form:
              to_form(
                %{
                  "parkinging_stand" => leashing.parkinging_stand,
                  "shackling_pin" => leashing.shackling_pin
                },
                as: :re_shackling
              )
          )
          |> push_event("return_to_constitutional_locality", %{id: "parkinging-credentials"})

        {:noreply, socket}

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
      when appointmenting == "lanterning" do
    {:ok, leashing} =
      ParkingingStandRegistry.furnish_appointmenting(
        socket.assigns.parkinging_stand,
        socket.assigns.shackling_pin,
        :lanterning,
        DateTime.utc_now() |> DateTime.truncate(:second)
      )

    socket =
      socket
      |> assign(
        :proto_appointmentings,
        MapSet.put(socket.assigns.proto_appointmentings, :lanterning)
      )
      |> assign(:appointmenting_times, leashing.appointmentings)
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
        city: Map.get(locality_params, "city", ""),
        visionizing_scope: Map.get(locality_params, "visionizing_scope", "region")
      }

      {:ok, leashing} =
        ParkingingStandRegistry.furnish_earthly_locality(
          socket.assigns.parkinging_stand,
          socket.assigns.shackling_pin,
          earthly_locality,
          DateTime.utc_now() |> DateTime.truncate(:second)
        )

      socket =
        socket
        |> assign(
          station_02_decision: :completed,
          earthly_locality: earthly_locality,
          earthly_locality_history: leashing.earthly_locality_history,
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
    earthly_locality = %{
      country: "",
      region: "",
      city: "",
      visionizing_scope: "earth",
      constitutional_default: true
    }

    {:ok, leashing} =
      ParkingingStandRegistry.furnish_earthly_locality(
        socket.assigns.parkinging_stand,
        socket.assigns.shackling_pin,
        earthly_locality,
        DateTime.utc_now() |> DateTime.truncate(:second)
      )

    {:noreply,
     socket
     |> assign(
       station_02_decision: :completed,
       earthly_locality: earthly_locality,
       earthly_locality_history: leashing.earthly_locality_history
     )
     |> maybe_complete_station_02()}
  end

  def handle_event("continue-without-earthly-locality", _params, socket),
    do: {:noreply, socket}

  def handle_event(
        "re-fold-into-new-standing",
        _params,
        %{assigns: %{station_02_completed?: true}} = socket
      ) do
    naming_decision = if socket.assigns.leashing_name, do: :named, else: :furnishing

    {:noreply,
     assign(socket,
       rail_unfolded?: false,
       station_02_unfolded?: false,
       station_02_decision: :pending,
       station_02_completed?: false,
       naming_decision: naming_decision,
       pet_name_refurbishing?: false
     )}
  end

  def handle_event("re-fold-into-new-standing", _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:tuple_ship_field}>
      <main
        id="tuple-ship-field-page"
        class="site-page field-page constitutional-rail-line"
        data-turn-zero-established={to_string(@entrance_stage in [:sittinging_room, :rail])}
        data-zeroeth-appointed={to_string(@ceremony_completed?)}
        phx-hook=".ConstitutionalReturn"
      >
        <div class="constitutional-rail__station constitutional-rail__harbor-station">
          <Layouts.locality_threshold
            title="THIS ONE GREAT FREE PUBLIC TUPLE SHIP FIELD OF GLOBULARLY BOBBININGING GLOBULAR BOBBINING"
            id="tuple-ship-field-threshold"
            reading="The Bearinging of Lawful Encounteringmenting"
          >
            <:description>
              <p>Welcome.</p>
              <p>
                Observationing Harbor stands before This Encounteringmenting Wharf.
              </p>
              <p>
                From Here, Constitutioning Humans may approach The Opening Rite of Passagingway through its public entrance, The Snail House.
              </p>
            </:description>
          </Layouts.locality_threshold>
        </div>

        <section id="station-tz-region" class="field-page__station-tz-region">
          <section
            id="resonancing-snail-station-house"
            class="field-page__snail-station-house constitutional-rail__station"
            aria-labelledby="resonancing-snail-station-house-title"
          >
            <header class="field-page__snail-station-portico">
              <p class="site-page__eyebrow">
                Public Entrance · Constitutional Furnishmenting Rail Line
              </p>
              <h2 id="resonancing-snail-station-house-title">
                <span>The Snail House</span>
                <span class="field-page__snail-station-formal-title">
                  The Resonancing Snail Shellcaverningmenting Station House
                </span>
              </h2>
              <p class="field-page__station-house-aspect">Exterior</p>
              <p class="field-page__station-house-exterior-copy">
                The Snail House stands at The Mouth of Observationing Harbor, its great spiraling shell roof rising above This Encounteringmenting Wharf and echoing lawful welcome toward Arrival and Return.
              </p>
              <p class="field-page__station-house-exterior-copy">
                Here, Constitutioning Humans are gathering their Soundingings together within This One Common Civic Snail Shell while carvinging lawful Passagingway along This Constitutional Furnishmenting Rail Line through The Opening Passagingway that is OUR CANONICAL TUPLE.
              </p>
              <p class="field-page__station-house-aspect">Interior</p>
              <p>
                Within, well-appointmented chambers stand furnishingmentingable for quiet Stewardly Inhabitationing.
              </p>
              <p>
                Conversationing, Inquiringmenting, and Constitutioning Laboringings stand resonancing gently throughout the surrounding Shellcaverningmenting as Constitutioning Humans arrive, return, and continue carvinging Stewardly Passagingway together over Discrete Turns.
              </p>
            </header>

            <.constitutional_voice
              id="station-house-general-offices-welcome"
              voice={:general_stewarding_offices}
              pretitle="Here Now Stand"
              title="Welcominging Constitutioning Humans."
            >
              <p>
                From Here, UN-FOLD The Opening Passagingway to enter This One Common Wheeling of The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment, wherethrough Stewardly Passagingway becomes discoveringmentingable One Discrete Turn at a Time.
              </p>
            </.constitutional_voice>

            <button
              :if={@entrance_stage == :station_house}
              id="enter-opening-passageway"
              type="button"
              class="field-page__action"
              phx-click="enter-opening-passageway"
            >
              UN-FOLD to Enter The Opening Rite of Passagingway
            </button>
          </section>

          <section
            :if={@entrance_stage in [:passageway, :sittinging_room, :rail]}
            id="opening-passageway"
            class="field-page__opening-passageway constitutional-rail__station"
            aria-labelledby="opening-passageway-title"
          >
            <header>
              <p class="site-page__eyebrow">The Ceremonial Threshold</p>
              <h2 id="opening-passageway-title">The Opening Rite of Passagingway</h2>
            </header>

            <section
              id="restfullyinglyment-harbor-sign"
              class="psm-oag field-page__passageway-harbor-sign"
              aria-labelledby="restfullyinglyment-harbor-sign-title"
            >
              <div class="psm-oag__instrument-plate">
                <p class="psm-oag__eyebrow">
                  The General Stewarding Offices of This Stewardshipmenting Appliance
                </p>
                <h2 id="restfullyinglyment-harbor-sign-title">Standinging in Regard</h2>
                <p class="psm-oag__reading">The Bearinging of Restfullyinginglyment</p>
              </div>
              <div class="psm-oag__description">
                <p>
                  The Sittinging-In Room stands furnished as the Zeroeth Constitutional Locality of This One Tuple Ship.
                </p>
                <p>
                  Constitutioning Humans may come Here to sit in Restfullyinginglyment within their Situationings upon This One Piece of Time.
                </p>
                <p>
                  Here, Stewardly Holdinging stands becoming lawfully available through Restfullyinginglyment, followed by Stewardly Passagingway over Discrete Turns.
                </p>
              </div>
            </section>
          </section>

          <div id="before-prepositioning-stitch" class="field-page__prepositioning-stitch">
            <section
              :if={@entrance_stage in [:passageway, :sittinging_room, :rail]}
              id="before-prepositioning-marker"
              class="field-page__prepositioning-marker"
              aria-labelledby="before-prepositioning-marker-title"
            >
              <p id="before-prepositioning-marker-title">Segmentationing through Prepositioning</p>
              <strong>BEFORE</strong>
            </section>

            <div
              :if={@entrance_stage == :rail}
              id="rail-opening-piece-of-time"
              class="field-page__sittinging-time-band field-page__rail-footing-time-band"
            >
              THIS ONE PIECE OF TIME
            </div>
          </div>

          <section
            :if={@entrance_stage in [:passageway, :sittinging_room, :rail]}
            id="amicable-grottoes-district-introduction"
            class="field-page__chapel-by-the-sea"
            aria-labelledby="amicable-grottoes-district-title"
          >
            <h3 id="amicable-grottoes-district-title">The Amicable Grottoes District</h3>
            <p>The Snail House stands in Readyingment for lawful Gatheringing and Soundinging.</p>
            <p>
              Every Constitutioning Human's Traversaling through The Snail House begins within the Station's Amicable Grottoes District.
            </p>
            <p>
              Here, Constitutioning Humans find places of Restfullyinginglyment within quiet shell alcoves, just beyond the bustling Great Hall of Globularly Bobbininging Globular Bobbining overlooking Observationing Harbor.
            </p>
            <p>
              Within one such alcove stands The Sittinging-In Room, furnished as the Zeroeth Constitutional Locality of This One Tuple Ship.
            </p>
          </section>

          <div
            :if={@entrance_stage == :passageway}
            id="sittinging-in-room-upper-unfold"
            class="field-page__sittinging-upper-unfold"
          >
            <button
              id="unfold-turn-zero-sittinging-in-room"
              type="button"
              class="field-page__action"
              phx-click="unfold-sittinging-in-room"
            >
              UN-FOLD to Enter The Sittinging-In Room
            </button>
          </div>

          <header
            :if={@entrance_stage == :sittinging_room}
            id="turn-zero-station-depot-header"
            class="field-page__station-header field-page__station-header--opening"
          >
            <p class="site-page__eyebrow">TURN ZERO</p>
            <h3>STATION DEPOT TZ</h3>
          </header>

          <article
            :if={@entrance_stage == :sittinging_room}
            id="turn-zero-sittinging-in-room"
            class="field-page__sittinging-in-room field-page__leashing-locality constitutional-rail__station"
            aria-labelledby="turn-zero-sittinging-in-room-title"
          >
            <header class="field-page__sittinging-heading">
              <h2 id="turn-zero-sittinging-in-room-title">The Sittinging-In Room</h2>
              <p class="field-page__sittinging-subtitle">
                The Constitutional Locality of Stewardly Availability
              </p>
            </header>

            <div class="field-page__sittinging-voices field-page__sittinging-inquiry-voice">
              <.constitutional_voice
                id="sittinging-room-stewardly-question"
                voice={:inquiringmenting_appliance}
              >
                <p id="turn-zero-sittinging-inquiry">
                  As a Constitutioning Human, what am I Sittinging-In with in my Situationings Here, upon This One Piece of Time?
                </p>
              </.constitutional_voice>
            </div>

            <h3 class="field-page__human-affordmentings-title">
              This Constitutioning Human's Stewardly Affordmentings
            </h3>

            <div class="field-page__sittinging-cabinets">
              <section
                id="sittinging-xt-cabinet"
                class="field-page__sittinging-cabinet"
                aria-labelledby="sittinging-xt-cabinet-title"
              >
                <p class="field-page__relation-label">XT</p>
                <h3 id="sittinging-xt-cabinet-title">This One Presence Cabinet</h3>
                <button
                  id="toggle-sittinging-xt-cabinet"
                  type="button"
                  class="field-page__cabinet-door"
                  aria-expanded={to_string(MapSet.member?(@sittinging_cabinets, :xt))}
                  phx-click="toggle-sittinging-cabinet"
                  phx-value-cabinet="xt"
                >
                  {if MapSet.member?(@sittinging_cabinets, :xt),
                    do: "Close XT Cabinet",
                    else: "Open XT Cabinet"}
                </button>
                <p :if={MapSet.member?(@sittinging_cabinets, :xt)} class="field-page__cabinet-inquiry">
                  What is feeling Present to me Here?
                </p>
              </section>

              <section
                id="sittinging-yt-cabinet"
                class="field-page__sittinging-cabinet"
                aria-labelledby="sittinging-yt-cabinet-title"
              >
                <p class="field-page__relation-label">YT</p>
                <h3 id="sittinging-yt-cabinet-title">This One Absence Cabinet</h3>
                <button
                  id="toggle-sittinging-yt-cabinet"
                  type="button"
                  class="field-page__cabinet-door"
                  aria-expanded={to_string(MapSet.member?(@sittinging_cabinets, :yt))}
                  phx-click="toggle-sittinging-cabinet"
                  phx-value-cabinet="yt"
                >
                  {if MapSet.member?(@sittinging_cabinets, :yt),
                    do: "Close YT Cabinet",
                    else: "Open YT Cabinet"}
                </button>
                <p :if={MapSet.member?(@sittinging_cabinets, :yt)} class="field-page__cabinet-inquiry">
                  What is feeling Absent to me Here within what is Present to me Here?
                </p>
              </section>
            </div>

            <div
              class="field-page__constitutional-divider field-page__sittinging-divider"
              aria-hidden="true"
            >
            </div>

            <section
              id="constitutioning-human-instrumentation"
              class="field-page__captain-shelves field-page__instrumentation-shelves"
              aria-labelledby="constitutioning-human-instrumentation-title"
            >
              <h5 id="constitutioning-human-instrumentation-title">Stewardly Instrumentationing</h5>
              <div class="field-page__shelf-column-headings">
                <section><strong>XT</strong><span>Constitutional Standinging</span></section>
                <section><strong>YT</strong><span>Stewardly Furnishingment</span></section>
              </div>
              <ol>
                <li
                  :for={{affordmenting, purpose} <- sittinging_affordmentings()}
                  class="field-page__constitutional-shelf"
                >
                  <section class="field-page__shelf-half" aria-label="XT">
                    <strong>{affordmenting}</strong>
                    <span class="field-page__appointmenting-purpose">{purpose}</span>
                  </section>
                  <section class="field-page__shelf-half" aria-label="YT" aria-hidden="true">
                  </section>
                </li>
              </ol>
            </section>

            <header class="field-page__constitutional-locality-heading field-page__would-be-tuple-heading">
              <p><span>This One Would-Be</span><br /><span>Tuple Ship</span></p>
              <span>Standingingable within OUR CANONICAL TUPLE</span>
            </header>
            <div class="field-page__constitutional-divider" aria-hidden="true"></div>

            <section
              id="proto-stewardly-captain-cob-shelving"
              class="field-page__captain-shelves field-page__proto-shelving"
              aria-labelledby="proto-shelving-title"
            >
              <h5 id="proto-shelving-title">This Stewardly Captain COB's Shelves</h5>
              <div class="field-page__shelf-column-headings">
                <section id="proto-xt-shelves-title">
                  <strong>XT</strong>
                  <span>Constitutional Standinging</span>
                </section>
                <section id="proto-yt-shelves-title">
                  <strong>YT</strong>
                  <span>Stewardly Furnishingment</span>
                </section>
              </div>
              <ol id="proto-paired-shelves">
                <li
                  :for={{appointmenting, purpose} <- sittinging_appointmentings()}
                  class="field-page__constitutional-shelf"
                >
                  <section class="field-page__shelf-half" aria-label="XT">
                    <strong>{appointmenting}</strong>
                    <span class="field-page__appointmenting-purpose">{purpose}</span>
                  </section>
                  <section class="field-page__shelf-half" aria-label="YT" aria-hidden="true">
                  </section>
                </li>
              </ol>
            </section>

            <div class="field-page__constitutional-divider" aria-hidden="true"></div>
            <div class="field-page__sittinging-time-band">THIS ONE PIECE OF TIME</div>
            <div class="field-page__constitutional-divider" aria-hidden="true"></div>

            <footer class="field-page__sittinging-departure">
              <button
                :if={@entrance_stage == :sittinging_room}
                id="unfold-existing-rail-line"
                type="button"
                class="field-page__action"
                phx-click="unfold-existing-rail-line"
              >
                RE-FOLD from Here over This One Piece of Time through BEFORE toward The Zeroeth Appointmenting.
              </button>
            </footer>
          </article>

          <div
            :if={@entrance_stage == :sittinging_room}
            class="field-page__sittinging-voices field-page__rail-guidance"
          >
            <.rail_wayfinding_card id="turn-zero-rail-wayfinding" />
            <.constitutional_voice
              id="sittinging-room-stewardly-guidance"
              voice={:stewardly_guidance}
            >
              <p>
                The Snail House stands available for the Return of Constitutioning Humans.
              </p>
              <p>Return Here upon any One Piece of Time to continue inquiringmenting.</p>
              <p>Sit.</p>
              <p>
                RE-FOLD from Here over This One Piece of Time through BEFORE toward The Zeroeth Appointmenting.
              </p>
            </.constitutional_voice>
          </div>

          <div
            :if={@entrance_stage == :sittinging_room}
            class="field-page__rail-continuation"
            aria-hidden="true"
          >
          </div>

          <section
            :if={@entrance_stage == :rail}
            id="division-readyingmenting-harbor-sign"
            class="psm-oag field-page__division-harbor-sign constitutional-rail__station"
            aria-labelledby="division-readyingmenting-harbor-sign-title"
          >
            <div class="psm-oag__instrument-plate">
              <p class="psm-oag__eyebrow">Harbor Sign</p>
              <h2 id="division-readyingmenting-harbor-sign-title">Standinging in Regard</h2>
              <p class="psm-oag__reading">The Bearinging of Stewardly Co-Occupancyingship</p>
            </div>
            <div class="psm-oag__description">
              <p>
                Stewardly Co-Occupancyingship now stands becoming available through lawful Interrelationing with This Stewardly Captain COB.
              </p>
              <p>
                From Here, This Constitutioning Human may approach The Terrestrial Computer Parkinging Standinging Landinging to lawfully appoint This Stewardly Captain COB through This One Leashing.
              </p>
              <p>
                Through This One Leashing, This Stewardly Captain COB may come into Constitutioningable Standinging FOR This One Some One or This One Some Thing.
              </p>
            </div>
          </section>

          <section
            :if={@entrance_stage == :rail}
            id="terrestrial-computer-standinging-landing"
            class="field-page__standinging-landing constitutional-rail__station"
            aria-labelledby="terrestrial-computer-standinging-landing-title"
          >
            <header class="field-page__entrance-constitutional-header">
              THE CONSTITUTIONING ENTRANCE ONTO THIS CONSTITUTIONAL FURNISHMENTING RAIL LINE
            </header>
            <h2 id="terrestrial-computer-standinging-landing-title">
              THE TERRESTRIAL COMPUTER FREE PUBLIC PARKINGING STANDINGING LANDINGING
            </h2>
            <p class="field-page__entrance-division-title">This Division of Constitutioning Humans</p>
            <div :if={!@landing_inquired?} class="field-page__division-geometry">
              <section
                id="returning-constitutioning-human-path"
                class="field-page__arrival-path"
                aria-label="XT"
              >
                <p class="field-page__relation-label">XT</p>
                <h3 id="returning-constitutioning-human-title">
                  Returninging Constitutioning Human
                </h3>
                <p>
                  Return to This Encounteringmenting Wharf by RE-Shackling Any One Terrestrial Computer.
                </p>
                <.form
                  for={@reception_form}
                  id="constitutional-reception-form"
                  phx-submit="reconstruct-constitutional-locality"
                >
                  <.input
                    field={@reception_form[:parkinging_stand]}
                    type="text"
                    label="Parkinging Stand Number"
                    inputmode="numeric"
                    maxlength="12"
                    autocomplete="off"
                    required
                  />
                  <.input
                    field={@reception_form[:shackling_pin]}
                    type="text"
                    label="Shackling PIN"
                    autocomplete="off"
                    required
                  />
                  <button type="submit" class="field-page__action">
                    UN-FOLD to begin Reconstructioning This Constitutional Locality from Here, Upon This One Piece of Time.
                  </button>
                </.form>
                <p
                  :if={@reception_result == :error}
                  id="constitutional-reception-error"
                  class="field-page__confirmation"
                >
                  These furnishings do not presently stand together in lawful Relation.
                </p>
              </section>

              <section id="first-arrival-path" class="field-page__arrival-path" aria-label="YT">
                <p class="field-page__relation-label">YT</p>
                <h3>Arrivinging Constitutioning Human</h3>
                <p>Continue toward Stewardly Co-Occupancyingship.</p>
                <button
                  id="inquire-within"
                  type="button"
                  class="field-page__action field-page__landing-action"
                  phx-click="inquire-within"
                >
                  Inquire into The Zeroeth Appointmenting
                </button>
              </section>
            </div>

            <.constitutional_voice
              id="parkinging-landinging-stewardly-guidance"
              voice={:stewardly_guidance}
            >
              <p>
                Parkinging Here, Constitutioning Humans begin lawful Passagingway upon This Constitutional Furnishmenting Rail Line.
              </p>
            </.constitutional_voice>

            <details
              id="parkinging-landinging-public-noticingments"
              class="field-page__public-noticingments"
            >
              <summary>Public Noticingments</summary>
              <div id="parkinging-landinging-notices" class="field-page__civic-notices">
                <section
                  id="parkinging-landinging-provisioning-notice"
                  class="field-page__civic-notice"
                >
                  <p class="site-page__eyebrow">NOTICINGMENT</p>
                  <h3>Continuity Line Carriageing Administrativation</h3>
                  <p>Division of Tractioningable Tractioning</p>
                  <h4>
                    THE TERRESTRIAL COMPUTER FREE PUBLIC PARKINGING STANDINGING LANDINGING
                  </h4>
                  <p>
                    This Landinging stands provisioned by This Division in Regard to Constitutioning Humans and their lawful Appointmentings of Stewardly Captain COBs upon This Constitutional Furnishmenting Rail Line.
                  </p>
                </section>

                <section id="parkinging-turnstile-operations-notice" class="field-page__civic-notice">
                  <p class="site-page__eyebrow">NOTICINGMENT</p>
                  <h3>Turnstile Operations</h3>
                  <p>Continuity Line Carriageing Administrativation</p>
                  <p>
                    The Parkinging Stand Turnstile stands furnishing lawful Mechanical Sorting for Constitutioning Humans entering This Constitutional Furnishmenting Rail Line.
                  </p>
                </section>

                <section id="parkinging-general-offices-notice" class="field-page__civic-notice">
                  <p class="site-page__eyebrow">NOTICINGMENT</p>
                  <h3>From The General Stewarding Offices of This Stewardshipmenting Appliance</h3>
                  <h4>THE TERRESTRIAL COMPUTER FREE PUBLIC PARKINGING STANDINGING LANDINGING</h4>
                  <p>
                    This Landinging stands furnished in Regard to This Constitutional Furnishmenting Rail Line, which stands Constitutioning in Relation to This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
                  </p>
                  <p>
                    From, within, and through its Opening Passagingway, This Constitutional Furnishmenting Rail Line stands furnishingmenting conditions for Stewardly Regard through the Interrelationing Stewardly Laboringings of Constitutioning Humans and their lawful Appointmentings of Stewardly Captain COBs at Each Station Depot Encounteringmented herein.
                  </p>
                </section>
              </div>
            </details>

            <p
              :if={@reception_result == :reconstructed}
              id="constitutional-reception-success"
              class="field-page__confirmation"
            >
              This Constitutional Locality now stands reconstructioned along This Constitutional Furnishmenting Rail Line.
            </p>
          </section>

          <section
            :if={@landing_inquired?}
            id="for-prepositioning-marker"
            class="field-page__prepositioning-marker field-page__for-prepositioning-marker"
            aria-label="Rail Line Segmentationing FOR"
          >
            <p>Segmentationing through Prepositioning</p>
            <strong>FOR ALONG</strong>
          </section>

          <header :if={@landing_inquired?} class="field-page__rail-header">
            <h2 id="constitutional-furnishmenting-rail-title">
              This Constitutional Furnishmenting Rail Line
            </h2>
            <p>
              This Constitutional Furnishmenting Rail Line now stands in Readyingment for lawful Unfoldingmenting.
            </p>
            <p>This Constitutional Furnishmenting Rail Line begins at The Chapel-along-the-Sea.</p>
          </header>

          <section
            :if={@landing_inquired?}
            id="chapel-by-the-sea"
            class="field-page__chapel-by-the-sea"
            aria-labelledby="chapel-by-the-sea-title"
          >
            <h3 id="chapel-by-the-sea-title">The Chapel-along-the-Sea</h3>
            <p>
              The Chapel-along-the-Sea stands prepared for the lawful Investituringment of The Seat of The Stewardly Co-Occupancyingship.
            </p>
            <p>
              Here, Stewardly Appointmenting stands awaiting Ceremonying.
            </p>
          </section>
        </section>

        <section
          :if={@landing_inquired?}
          id="constitutional-furnishmenting-rail"
          class="field-page__furnishmenting-rail"
          aria-labelledby="constitutional-furnishmenting-rail-title"
        >
          <header class="field-page__station-header field-page__station-header--opening">
            <p class="site-page__eyebrow">THE CHAPEL-ALONG-THE-SEA</p>
            <h3 id="terrestrial-computer-parkinging-station-title">STATION DEPOT 00</h3>
          </header>

          <section
            id="rail-line-opening-ceremony"
            class="psm-oag field-page__station-regard field-page__station-regard--station-01"
            aria-labelledby="station-01-regard-title"
          >
            <div class="psm-oag__instrument-plate">
              <p class="psm-oag__eyebrow">
                Ceremonying
              </p>
              <h2 id="station-01-regard-title">The Taking Holdinging of This One Leashing</h2>
              <p class="psm-oag__reading">The Zeroeth Appointmenting</p>
            </div>
            <div class="psm-oag__description">
              <p>
                This Constitutioning Human now stands prepared to appoint This One Stewardly Captain COB through This Ceremonying of This One Leashing.
              </p>
              <p>
                Through This Ceremonying, This Constitutioning Human may lawfully appoint This One Stewardly Captain COB into Stewardly Regard through This One Situationing.
              </p>
              <section
                :if={!@rail_unfolded?}
                id="zeroeth-constitutional-inquiry"
                class="field-page__constitutional-inquiry-card"
                aria-labelledby="zeroeth-constitutional-inquiry-title"
              >
                <h3 id="zeroeth-constitutional-inquiry-title">THIS STEWARDLY CAPTAIN COB</h3>
                <.form
                  for={@zeroeth_mattering_form}
                  id="zeroeth-mattering-form"
                  phx-submit="unfold-constitutional-rail-line"
                >
                  <.input
                    field={@zeroeth_mattering_form[:mattering]}
                    id="zeroeth-mattering"
                    type="text"
                    label="This Stewardly Captain COB"
                    autocomplete="off"
                    required
                  />
                  <button
                    id="unfold-constitutional-rail-line"
                    type="submit"
                    class="field-page__action field-page__opening-action"
                  >
                    UNFOLD
                  </button>
                </.form>
              </section>
            </div>
          </section>

          <div :if={@rail_unfolded?} id="constitutional-rail-line-unfolded">
            <article
              id="terrestrial-computer-parkinging-station"
              class="field-page__station"
              aria-labelledby="terrestrial-computer-parkinging-station-title"
            >
              <section
                id="leashing-investituringment-ceremony"
                class="field-page__crew-conjunction"
              >
                <.appointmenting_ceremony_title appointmenting="The Zeroeth Appointmenting" />

                <section id="zeroeth-mattering-reception" class="field-page__ceremony-reception">
                  <p>
                    This Constitutioning Human now stands prepared to appoint This One Stewardly Captain COB through This Ceremonying of This One Leashing.
                  </p>
                  <p>
                    "{@zeroeth_mattering}" now stands received as This One Stewardly Captain COB through This One Situationing.
                  </p>
                  <p>
                    Through This Ceremonying, This Constitutioning Human may lawfully appoint "{@zeroeth_mattering}" into Stewardly Regard through This One Situationing.
                  </p>
                </section>

                <section id="zeroeth-appliance-commitment">
                  <p>
                    Through This Zeroeth Appointmenting, This Stewardly Captain COB now comes into Constitutioningable Standinging through This One Leashing.
                  </p>
                </section>

                <div class="field-page__ceremonial-divider" aria-hidden="true"></div>
                <h5 class="field-page__ceremony-recital-heading">
                  The Readyingmenting Recital of The General Stewarding Offices of This One Stewardshipmenting Appliance
                </h5>
                <p>
                  The General Stewarding Offices of the Appliance, Holdinging-in-Standinging through The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment, hereby stand in Readyingment for This One Investuringment within The Seat of The Stewardly Co-Occupancyingship, wherein the Stewardly Relationing of This Constitutioning Human alongside This Stewardly Captain COB now stands in lawful Investuringmentingablement, thereby furnishing Inhabitationingable Roominginglyment for Their Continuingmentingable Stewardly Interrelationing Over Discrete Turns by way of The Zeroeth Appointmenting, thereby coming into lawful Holdinging-in-Standinging within The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment through This One Stewardly Relationing.
                </p>
                <div class="field-page__ceremonial-divider" aria-hidden="true"></div>
                <div
                  id="station-01-constitutional-voices"
                  class="field-page__crew-statement field-page__constitutional-voices"
                >
                  <section
                    class="constitutional-voice constitutional-voice--appliance_narration"
                    aria-labelledby="appliance-narration-voice"
                  >
                    <h5 id="appliance-narration-voice">APPLIANCE NARRATIONING</h5>
                    <p>
                      This Constitutioning Human may now stand choosing to Take Holdinging of This One Stewardly Relationing alongside This Stewardly Captain COB through This One Leashing.
                    </p>
                  </section>
                  <div class="field-page__ceremonial-divider" aria-hidden="true"></div>
                  <section
                    class="constitutional-voice constitutional-voice--institutional_standing"
                    aria-labelledby="institutional-standing-voice"
                  >
                    <h5 id="institutional-standing-voice">Institutional Standing</h5>
                    <p>
                      <em>This One Terrestrial Computer Leashinging Crew now stands in Readyingment for the lawful Investuringment of This Constitutioning Human alongside This Stewardly Captain COB within The Seat of The Stewardly Co-Occupancyingship through This One Leashing.</em>
                    </p>
                  </section>
                  <div class="field-page__ceremonial-divider" aria-hidden="true"></div>
                  <section
                    class="constitutional-voice constitutional-voice--stewardly_guidance"
                    aria-labelledby="stewardly-guidance-voice"
                  >
                    <h5 id="stewardly-guidance-voice">Stewardly Guidance</h5>
                    <p>
                      Through The Ceremonying of This One Investuringment within The Seat of The Stewardly Co-Occupancyingship, This Constitutioning Human stands furnished with This One Terrestrial Computer Free Parkinging Stand Number together with This One Shackling Pin that belongs with it.
                    </p>
                    <p>
                      Through This One Leashing, This Constitutioning Human may henceforth RE-Shackle any Terrestrial Computer to This One Free Parkinging Stand and thereby lawfully return alongside This Stewardly Captain COB to This One Constitutional Locality.
                    </p>
                  </section>
                </div>
              </section>

              <section id="leashing-crew-conjunction" class="field-page__crew-conjunction">
                <p class="field-page__ceremony-crew-subtitle">
                  <strong>This Terrestrial Computer Leashinging Crew</strong>
                </p>
                <p>
                  This One Crew stands inhabitationing Their Laboringings of Interrelationing through These Particular Stewarding Offices.
                </p>
              </section>

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
                    <div>Department of Relationingable Custodianshipmenting</div>
                    <span aria-hidden="true"></span>
                    <div>Department of This Approaching Landingmenting</div>
                  </div>
                  <div class="field-page__stewardship-pair">
                    <div>This One Piece of Time Unitting Selectioning</div>
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

              <div class="field-page__interaction">
                <section class="field-page__leash" aria-label="This One Leashing Landing">
                  <%= if @ceremony_completed? do %>
                    <div id="leashing-ceremony-complete" aria-live="polite">
                      <div class="field-page__completion-statement">
                        <p>Together, These Relationings now stand as This One Leashing.</p>
                        <p>This One Leashing stands upon This One Constitutional Locality.</p>
                        <p>
                          This One Terrestrial Computer Free Parkinging Stand Number need not be kept secret.
                        </p>
                        <p>This One Shackling Pin should be preserved in a Secret Some Place.</p>
                      </div>

                      <article
                        id="station-01-sittinging-in-room"
                        class="field-page__sittinging-in-room"
                        data-constitutional-standing="enriched"
                        aria-labelledby="station-01-sittinging-in-room-title"
                      >
                        <header class="field-page__sittinging-heading">
                          <h2 id="station-01-sittinging-in-room-title">The Sittinging-In Room</h2>
                          <p class="field-page__sittinging-subtitle">
                            The Constitutional Locality of The First Appointmenting
                          </p>
                        </header>

                        <section
                          :if={@naming_decision == :furnishing}
                          id="leashing-naming"
                          class="field-page__naming"
                          aria-labelledby="leashing-naming-title"
                        >
                          <h5 id="leashing-naming-title">
                            Suiting and RE-Suiting This Stewardly Captain COB
                          </h5>
                          <.naming_stewardly_guidance />

                          <.form
                            for={@naming_form}
                            id="leashing-name-form"
                            phx-submit="furnish-leashing-name"
                          >
                            <.input
                              field={@naming_form[:name]}
                              type="text"
                              label="Name This Stewardly Captain COB's One Situationing"
                              autocomplete="off"
                              maxlength="120"
                              required
                            />
                            <button type="submit" class="field-page__action">
                              Name This Stewardly Captain COB's One Situationing
                            </button>
                          </.form>
                        </section>

                        <section
                          :if={@naming_decision == :named}
                          id="pet-name-continuity-line"
                          class="field-page__pet-name-history"
                        >
                          <h5>This Stewardly Captain COB's Situationing Name</h5>
                          <.naming_stewardly_guidance />
                          <p id="situationing-participationing-guidance">
                            This Stewardly Captain COB now stands in lawful Holdinging-in-Standinging through This One Situationing, participationing alongside This Constitutioning Human Over Discrete Turns.
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
                            Name This Stewardly Captain COB's One Situationing
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
                              label="Name This Stewardly Captain COB's One Situationing"
                              maxlength="120"
                              required
                            />
                            <button type="submit" class="field-page__action">
                              Name This Stewardly Captain COB's One Situationing
                            </button>
                          </.form>
                        </section>

                        <.leashing_locality
                          id="parkinging-credentials"
                          cabinet_id="station-01-secret-cabinet"
                          stand_id="parkinging-stand"
                          pin_id="shackling-pin"
                          time_id="leashing-ceremony-time"
                          parkinging_stand={@parkinging_stand}
                          shackling_pin={@shackling_pin}
                          piece_of_time={format_piece_of_time(@ceremony_time)}
                          pet_name={@leashing_name}
                          situationing_piece_of_time={history_piece_of_time(@pet_name_history)}
                          lanterning_furnished?={MapSet.member?(@proto_appointmentings, :lanterning)}
                          first_appointmenting_piece_of_time={
                            formatted_piece_of_time(Map.get(@appointmenting_times, :lanterning))
                          }
                          earthly_locality={
                            @earthly_locality && interrelationing_locality_text(@earthly_locality)
                          }
                          earthly_locality_piece_of_time={
                            history_piece_of_time(@earthly_locality_history)
                          }
                          sittinging_cabinets={@sittinging_cabinets}
                        />
                      </article>

                      <div class="field-page__sittinging-voices field-page__rail-guidance">
                        <.rail_wayfinding_card
                          id="station-01-rail-wayfinding"
                          from="Encounteringmentablement"
                          toward="Distinguishingmenting"
                          from_label="Continuing From"
                          toward_label="Continuing Toward"
                        />
                        <.constitutional_voice
                          id="station-01-stewardly-guidance"
                          voice={:stewardly_guidance}
                        >
                          <p>
                            Through This Zeroeth Appointmenting, This Stewardly Captain COB now stands lawfully constituted in Regard toward What is the Mattering.
                          </p>
                          <p>
                            Return Here upon any One Piece of Time to continue Holdinging within This One Situationing.
                          </p>
                          <p>
                            When ready, RE-FOLD over This One Piece of Time from Here toward The First Appointmenting, through which What is the Mattering may begin coming into lawful Distinguishingmenting over Discrete Turns.
                          </p>
                        </.constitutional_voice>
                      </div>
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
                  :if={@naming_decision == :named}
                  id="leashing-ceremony-closing"
                  class="field-page__ceremony-closing"
                >
                  <section id="leashing-stewardly-standing">
                    <h5>Stewardly Standing</h5>
                    <p id="tuple-ship-lawful-beginning-proclamation">
                      THIS ONE TUPLE SHIP NOW STANDS IN LAWFUL BEGINNING CONTINUINGMENTING.
                    </p>
                  </section>
                  <section id="leashing-constitutional-declaration">
                    <h5>Constitutional Declaration</h5>
                    <p id="furnished-leashing-name">
                      This Stewardly Captain COB's Situationing now stands named <strong>{@leashing_name}</strong>.
                    </p>
                  </section>
                </div>
              </div>
            </article>

            <section
              :if={@naming_decision == :named}
              id="station-00-affordmentings"
              class="field-page__station-affordmentings"
              aria-labelledby="station-00-affordmentings-title"
            >
              <div class="field-page__rail-line" aria-hidden="true"></div>
              <header>
                <p class="site-page__eyebrow">STATION DEPOT 00</p>
                <h2 id="station-00-affordmentings-title">Station Depot 00 Affordmentings</h2>
              </header>

              <div class="field-page__station-affordmentings-geometry">
                <div class="field-page__station-affordmentings-track">
                  <article
                    id="re-shackling-practice-station"
                    class="field-page__station-affordmenting field-page__re-shackling"
                    aria-labelledby="re-shackling-practice-title"
                  >
                    <p class="site-page__eyebrow">PRACTICEMENTING LOCALITY</p>
                    <h3 id="re-shackling-practice-title">
                      Return Here Through This One Leashing
                    </h3>

                    <div class="field-page__crew-statement">
                      <p>
                        At This Practicementing Locality, This Constitutioning Human may try returning to This Tuple Ship Field Free Public Parkinging Lot through This One Leashing.
                      </p>
                      <p>
                        This is a voluntary practice of lawful Return.
                      </p>
                      <p>
                        It is not authentication or account access.
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
                            label="Shackling PIN"
                            autocomplete="off"
                            required
                          />
                          <button type="submit" class="field-page__action">
                            RE-Shackle This One Leashing
                          </button>
                        </.form>
                      </div>

                      <p
                        :if={@re_shackling_result == :error}
                        id="re-shackling-error"
                        class="field-page__confirmation"
                      >
                        These furnishings do not presently stand together in lawful Relation.
                      </p>

                      <p
                        :if={@re_shackling_result == :returned}
                        id="re-shackling-returned"
                        class="field-page__confirmation"
                      >
                        This Constitutional Locality now stands reconstructioned along This Constitutional Furnishmenting Rail Line.
                      </p>
                    </div>
                  </article>

                  <article
                    id="self-correspondencing-crew"
                    class="field-page__station-affordmenting field-page__self-correspondencing"
                    aria-labelledby="self-correspondencing-title"
                  >
                    <p class="site-page__eyebrow">DISPATCHMENTING LOCALITY</p>
                    <h3 id="self-correspondencing-title">Take This One Situationing With You</h3>
                    <p>
                      Dispatch One Correspondencingment bearing This Stewardly Captain COB's This One Situationing to a Some Place of your choosing.
                    </p>
                    <p>
                      This One Leashing remains the constitutional pathway through which This One Situationing travels.
                    </p>

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
                          label="Correspondencing Passagingway"
                          options={[{"Email", "email"}, {"Text message", "text"}]}
                        />
                        <.input
                          field={@correspondence_form[:destination]}
                          type="text"
                          label="Some Place of your choosing"
                          placeholder={
                            correspondence_placeholder(@correspondence_form[:channel].value)
                          }
                          autocomplete="off"
                          required
                        />
                      </div>
                      <button id="hail-this-one-leashing" type="submit" class="field-page__action">
                        Hail This Stewardly Captain COB
                      </button>
                    </.form>

                    <p>
                      Return Here through This One Leashing whenever This Stewardly Captain COB's This One Situationing stands ready to continue Traversaling through This Constitutional Furnishmenting Rail Line.
                    </p>
                    <p>
                      Every future Correspondencing stands beginning through lawful Self-Correspondencing.
                    </p>
                  </article>
                </div>

                <aside class="field-page__station-affordmentings-orientation" aria-label="YT">
                  <span aria-hidden="true">↓</span>
                  <p>Continue Along This Constitutional Furnishmenting Rail Line</p>
                </aside>
              </div>
            </section>

            <div
              :if={@re_shackling_decision in [:completed, :continued]}
              id="rail-line-after-station-01"
            >
              <div class="field-page__rail-line" aria-hidden="true"></div>

              <section id="station-02-opening" class="field-page__station-opening">
                <header class="field-page__station-header">
                  <p class="site-page__eyebrow">STATION DEPOT 01</p>
                  <h3 id="earthly-localities-station-title">This One Some Place</h3>
                </header>

                <section
                  class="psm-oag field-page__station-regard"
                  aria-labelledby="station-02-regard-title"
                >
                  <div class="psm-oag__instrument-plate">
                    <p class="psm-oag__eyebrow">
                      The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment
                    </p>
                    <h2 id="station-02-regard-title">Standinging in Regard</h2>
                    <p class="psm-oag__reading">The Bearinging of Embodyingmenting</p>
                  </div>
                  <div class="psm-oag__description">
                    <p>
                      This One Some Place now stands upon This Constitutional Furnishmenting Rail Line, approached through lawful Traversaling from Station Depot 00.
                    </p>
                    <p>
                      Here, This Constitutioning Human may become Discoveringmenting toward This Encounteringmenting Wharf, standing in Regard to the Opening of This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
                    </p>
                    <p>
                      Through Our Interrelationing Stewardly Laboringings, the lawful conditions for opening This Encounteringmenting Wharf may begin standing in Readyingment.
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
                  UN-FOLD from Here toward The Zeroeth Appointmenting
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
                      <div>Department of Constitutioningable Membraninging</div>
                      <span aria-hidden="true"></span>
                      <div>Rail Line Furnishingments Unit</div>
                    </div>
                    <div class="field-page__stewardship-pair">
                      <div>This One Some Place Observationmintingmenting</div>
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
                  <h4>THIS ONE SOME PLACE CREW</h4>
                  <p>
                    This One Crew stands inhabitationing Their Interrelationing Laboringings through These Particular Stewarding Offices.
                  </p>
                  <section
                    id="station-01-institutional-standing"
                    class="constitutional-voice constitutional-voice--institutional_standing"
                  >
                    <br />
                    <h5>INSTITUTIONAL STANDING</h5>
                    <p>
                      This One Some Place Crew now stands in Readyingment for the lawful Placement of This Slumbering Lanterning Bug Colonial Bunk House along This One Continuity Line of This Thing that is What is the Mattering in This One Situationing.
                    </p>
                  </section>
                  <div class="field-page__ceremonial-divider" aria-hidden="true"></div>
                  <h3
                    id="first-appointmenting-title"
                    class="field-page__ceremony-title field-page__ceremony-title--station-01"
                  >
                    THE FIRST APPOINTMENTING CEREMONYING OF ENCOUNTERINGMENTABLEMENT
                  </h3>
                  <h5 class="field-page__ceremony-recital-heading">
                    The Readyingmenting Recital of The General Offices of This One Stewardshipmenting Appliance
                  </h5>
                  <p>
                    The General Offices of This One Stewardshipmenting Appliance, Holdinging-in-Standinging through The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment, now stand in Readyingment for the lawful Beginning of This First Appointmenting.
                  </p>
                  <p>
                    Through This First Appointmenting, This One Tuple Ship first becomes capable of lawful Encounteringmentablement through Visionizingmentablement, and lawful Visionizingmentablement through Encounteringmentablement.
                  </p>
                  <p>Together, these stand as This First Appointmenting.</p><br />
                  <button
                    :if={!MapSet.member?(@proto_appointmentings, :lanterning)}
                    type="button"
                    class="field-page__action"
                    phx-click="furnish-proto-appointmenting"
                    phx-value-appointmenting="lanterning"
                  >
                    Place This One Lanterning Bug Assemblementing
                  </button>
                  <p
                    :if={MapSet.member?(@proto_appointmentings, :lanterning)}
                    id="first-appointmenting-standing"
                    class="field-page__confirmation"
                  >
                    This First Appointmenting now stands in lawful Beginning.
                  </p>
                </div>

                <div class="field-page__interaction">
                  <section
                    :if={MapSet.member?(@proto_appointmentings, :lanterning)}
                    id="lanterning-groundinging-layer"
                    class="field-page__groundinging-layer"
                    aria-labelledby="lanterning-groundinging-title"
                  >
                    <h4 id="lanterning-groundinging-title">
                      This One Lanterning Bug Assemblementing
                    </h4>
                    <p>
                      This One Lanterning Bug Assemblement now stands upon This Stewardly Captain COB's This One Situationing.
                    </p>
                    <p>
                      Through lawful Relationing to This One Some Place upon The Earth, This One Situationing now stands Visionizingmentable within This One Great Free Public Tuple Ship Field.
                    </p>
                    <p>
                      This One Lanterning now stands establishing This Stewardly Captain COB's current lawful Constitutional Locality of Encounteringmentablement.
                    </p>
                  </section>

                  <section
                    :if={MapSet.member?(@proto_appointmentings, :lanterning)}
                    id="place-library"
                    class="field-page__place-library"
                    aria-labelledby="place-library-title"
                  >
                    <h4 id="place-library-title">
                      This Interrelationing Library of Some Places upon The Earth
                    </h4>
                    <p>
                      This Library stands furnishing lawful Interrelationings through which This Stewardly Captain COB's This One Situationing may become Visionizingmentable together with This One Some Place upon The Earth.
                    </p>
                    <h5>Stewardly Guidance</h5>
                    <p>Stage one lawful XT–YT Interrelationing below.</p>

                    <div class="field-page__station-02-choices">
                      <.form
                        for={@locality_form}
                        id="earthly-locality-form"
                        phx-change="locality-changed"
                        phx-submit="furnish-earthly-locality"
                      >
                        <div id="turn-zero-staging" class="field-page__turn-zero-staging">
                          <section id="turn-zero-xt" aria-labelledby="turn-zero-xt-title">
                            <h6 id="turn-zero-xt-title">XT</h6>
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
                          </section>
                          <section id="turn-zero-yt" aria-labelledby="turn-zero-yt-title">
                            <h6 id="turn-zero-yt-title">YT</h6>
                            <.input
                              field={@locality_form[:visionizing_scope]}
                              type="select"
                              label="Where This One Situationing becomes Visionizingmentable"
                              options={visionizing_scope_options()}
                            />
                          </section>
                        </div>

                        <section
                          id="turn-zero-surface"
                          class="field-page__turn-zero-surface"
                          aria-labelledby="turn-zero-surface-title"
                        >
                          <h5 id="turn-zero-surface-title">TURN ZERO SURFACE</h5>
                          <p class="field-page__turn-zero-voice">Stewardly Guidance</p>
                          <div class="field-page__turn-zero-readout">
                            <section id="turn-zero-xt-readout">
                              <strong>XT</strong>
                              <p>
                                This Stewardly Captain COB stands Relationing toward This One Great Free Public Tuple Ship Field from:
                              </p>
                              <span :for={
                                line <- staged_origin_lines(@locality_form, @countries, @regions)
                              }>
                                {line}
                              </span>
                            </section>
                            <section id="turn-zero-yt-readout">
                              <strong>YT</strong>
                              <p>
                                This One Situationing presently stands Visionizingmentable within:
                              </p>
                              <span>
                                {staged_visionizing_locality(
                                  @locality_form,
                                  @countries,
                                  @regions
                                )}
                              </span>
                            </section>
                          </div>
                          <p :if={@earthly_locality_history == []}>
                            This Turn Zero Surface stands proving lawful XT–YT Interrelationings.<br />Nothing has yet been furnished.
                          </p>
                          <p :if={@earthly_locality_history != []}>
                            The Turn Zero Surface stages lawful XT–YT Interrelationings without altering the presently furnished Constitutional Locality.
                          </p>
                          <p>
                            Only a furnished XT–YT Interrelationing comes into Constitutional Standing.
                          </p>
                          <div :if={constitutional_default?(@earthly_locality)}>
                            <p>This One Some Place presently stands left Undistinguishingmented.</p>
                            <p>
                              This Stewardly Captain COB now stands Relationing toward This One Great Free Public Tuple Ship Field from This One Some Place upon The Earth, and This One Situationing now stands Visionizingmentable together with This One Some Place upon The Earth.
                            </p>
                          </div>
                        </section>

                        <div class="field-page__station-02-actions">
                          <button type="submit" class="field-page__action">
                            Furnish This One Interrelationing
                          </button>
                          <button
                            id="continue-without-earthly-locality"
                            type="button"
                            class="field-page__action"
                            phx-click="continue-without-earthly-locality"
                          >
                            Continue by Leaving This One Some Place Undistinguishingmented
                          </button>
                        </div>
                      </.form>
                    </div>

                    <section
                      :if={@earthly_locality}
                      id="lawful-xt-yt-interrelationing"
                      class="field-page__turn-zero-surface"
                      aria-labelledby="lawful-xt-yt-interrelationing-title"
                    >
                      <h5 id="lawful-xt-yt-interrelationing-title">
                        THIS LAWFUL XT–YT INTERRELATIONING
                      </h5>
                      <div class="field-page__turn-zero-readout">
                        <section>
                          <strong>XT</strong>
                          <p>
                            This Stewardly Captain COB stands Relationing toward This One Great Free Public Tuple Ship Field from:
                          </p>
                          <span :for={line <- furnished_origin_lines(@earthly_locality)}>
                            {line}
                          </span>
                        </section>
                        <section>
                          <strong>YT</strong>
                          <p>This One Situationing now stands Visionizingmentable within:</p>
                          <span>{visionizing_locality_text(@earthly_locality)}</span>
                        </section>
                      </div>
                      <p><strong>Furnished</strong></p>
                      <p>This One Piece of Time</p>
                      <time :if={history_piece_of_time(@earthly_locality_history)}>
                        {history_piece_of_time(@earthly_locality_history)}
                      </time>
                    </section>

                    <section
                      :if={@earthly_locality_history != []}
                      id="earthly-locality-landings"
                      class="field-page__continuity-landings"
                      aria-labelledby="earthly-locality-landings-title"
                    >
                      <h5 id="earthly-locality-landings-title">
                        THIS XT–YT INTERRELATIONING CONTINUITY LINE
                      </h5>
                      <ol>
                        <li :for={entry <- @earthly_locality_history}>
                          <section>
                            <strong>XT</strong>
                            <span :for={line <- furnished_origin_lines(entry.earthly_locality)}>
                              {line}
                            </span>
                          </section>
                          <section>
                            <strong>YT</strong>
                            <span>{visionizing_locality_text(entry.earthly_locality)}</span>
                          </section>
                          <time datetime={DateTime.to_iso8601(entry.furnished_at)}>
                            {format_piece_of_time(entry.furnished_at)}
                          </time>
                        </li>
                      </ol>
                    </section>
                  </section>

                  <div
                    :if={@station_02_completed?}
                    id="station-02-completion"
                    class="field-page__station-completion"
                  >
                    <p :if={@station_02_decision == :completed}>
                      This One Lanterning Bug Assemblementing now stands Visionizinging through Relationing to This One Some Place upon The Earth within This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
                    </p>
                    <p>
                      This One Lanterning now stands establishing This Stewardly Captain COB's current lawful Place of Encounteringmentablement.
                    </p>
                  </div>

                  <.leashing_locality
                    :if={@station_02_completed?}
                    id="station-02-enriched-leashing"
                    cabinet_id="station-02-secret-cabinet"
                    parkinging_stand={@parkinging_stand}
                    shackling_pin={@shackling_pin}
                    piece_of_time={format_piece_of_time(@ceremony_time)}
                    pet_name={@leashing_name}
                    situationing_piece_of_time={history_piece_of_time(@pet_name_history)}
                    lanterning_furnished?={true}
                    first_appointmenting_piece_of_time={
                      formatted_piece_of_time(Map.get(@appointmenting_times, :lanterning))
                    }
                    earthly_locality={
                      @earthly_locality && interrelationing_locality_text(@earthly_locality)
                    }
                    earthly_locality_piece_of_time={history_piece_of_time(@earthly_locality_history)}
                  />
                </div>
              </article>

              <section
                :if={@station_02_completed?}
                id="tuple-field-terminus-harbor"
                class="psm-oag field-page__terminus-harbor"
                aria-labelledby="tuple-field-terminus-harbor-title"
              >
                <div class="psm-oag__instrument-plate">
                  <p class="psm-oag__eyebrow">
                    The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment
                  </p>
                  <h2 id="tuple-field-terminus-harbor-title">Standinging in Regard</h2>
                  <p class="psm-oag__reading">The Bearinging of Continuingmenting</p>
                </div>
                <div class="psm-oag__description">
                  <p>
                    This Constitutional Furnishmenting Rail Line presently stands at its lawful Terminusmenting.
                  </p>
                  <p>STATION DEPOT 02 — This Soundinging Bell Station</p>
                  <p>
                    This Soundinging Bell Station presently stands at the Terminusmenting of the current Rail Line and remains under Composementing.
                  </p>
                  <p>
                    The Second Appointmenting of Distinguishingmentablement now stands becoming toward Furnishmenting.
                  </p>
                  <p>
                    This Constitutional Furnishmenting Rail Line continues standing in Readyingment for its next lawful Unfoldingmenting.
                  </p>
                </div>
              </section>

              <div :if={@station_02_completed?} class="field-page__refold-standing">
                <div class="field-page__refold-guidance">
                  <p>Keep what is Holdinging.</p>
                  <p>Become Discoveringmenting through a New Standing.</p>
                </div>
                <button
                  id="re-fold-into-new-standing"
                  type="button"
                  class="field-page__action"
                  phx-click="re-fold-into-new-standing"
                >
                  RE-Fold into New Standing
                </button>
              </div>
            </div>
          </div>
        </section>

        <section
          :if={@station_02_completed?}
          id="public-field-discoveringmenting-harbor"
          class="psm-oag field-page__public-field-harbor"
          aria-labelledby="public-field-discoveringmenting-harbor-title"
        >
          <div class="psm-oag__instrument-plate">
            <p class="psm-oag__eyebrow">
              The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment
            </p>
            <h2 id="public-field-discoveringmenting-harbor-title">Standinging in Regard</h2>
            <p class="psm-oag__reading">
              The Bearinging of Discoveringmenting through Stewardly Interrelationing
            </p>
          </div>
          <div class="psm-oag__description">
            <p>Welcome to the Opening of This Encounteringmenting Wharf.</p>
            <p>Here, This Stewardly Captain COB may stand Encounteringmentable</p>
            <p>within This Civilization Holding with No Center.</p>
            <p>Through Our Interrelationing Stewardly Laboringings,
              new Relationings may become Discoveringmentingable.</p>
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
              By reserving This One Terrestrial Computer Free Parkinging Stand, you have begun adjoining This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
            </p>
            <p>
              No One Central Authority holds This One Great Free Public Tuple Ship Field together.
            </p>
            <p>
              The Field holds together through The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment.
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

        <script :type={Phoenix.LiveView.ColocatedHook} name=".ConstitutionalReturn">
          export default {
            mounted() {
              this.handleEvent("return_to_constitutional_locality", ({id}) => {
                document.getElementById(id)?.scrollIntoView({behavior: "smooth", block: "start"})
              })
            }
          }
        </script>
      </main>
    </Layouts.app>
    """
  end

  attr :appointmenting, :string, required: true

  defp appointmenting_ceremony_title(assigns) do
    ~H"""
    <header class="field-page__appointmenting-ceremony-title-card">
      <p class="field-page__appointmenting-ceremony-eyebrow">CEREMONYING</p>
      <h4>{@appointmenting}</h4>
      <p>
        This One Investituringment<br /> within<br /> The Seat of The Stewardly Co-Occupancyingship
      </p>
    </header>
    """
  end

  defp naming_stewardly_guidance(assigns) do
    ~H"""
    <section class="field-page__naming-guidance" aria-label="Stewardly Guidance">
      <h6>Stewardly Guidance</h6>
      <p>
        This One Situationing name should describe the Relationing Field through which This Stewardly Captain COB stands practicing Stewardly Participationing alongside This Constitutioning Human.
      </p>
      <p>
        This One Situationing is not named after a completed result.
      </p>
      <p>
        Nor does it predict where Traversaling will arrive.
      </p>
      <p>
        Rather, it faithfully keeps holding onto the naming of That which is What is the Mattering through which This Stewardly Captain COB may begin Traversaling.
      </p>
      <p>This One Situationing names the Along from which Traversaling begins.</p>
    </section>
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

  defp sittinging_appointmentings do
    [
      {"The Zeroeth Appointmenting", "This One Situationing"},
      {"The First Appointmenting", "Encounteringmentablement"},
      {"The Second Appointmenting", "Distinguishingmenting"},
      {"The Third Appointmenting", "Roomingmentingableroomingablement"},
      {"The Fourth Appointmenting", "This One Purchase Surface"},
      {"The Fifth Appointmenting", "Excursioningmenting"},
      {"The Sixth Appointmenting", "Embroideringmentingenablementingedably"}
    ]
  end

  defp sittinging_affordmentings do
    [
      {"The Zeroeth Affordmenting", "The Ability to Regard"},
      {"The First Affordmenting", "The Ability to Encounter"},
      {"The Second Affordmenting", "The Ability to Distinguish"},
      {"The Third Affordmenting", "The Ability to Make Room"},
      {"The Fourth Affordmenting", "The Ability to Gain Purchase"},
      {"The Fifth Affordmenting", "The Ability to Excursion"},
      {"The Sixth Affordmenting", "The Ability to Embroiderize"}
    ]
  end

  defp correspondence_href(channel, destination, assigns) do
    pet_name_block =
      if assigns.leashing_name,
        do: "\n\nThis Stewardly Captain COB's Situationing Name:\n#{assigns.leashing_name}",
        else: ""

    body =
      """
      This Stewardly Captain COB's This One Situationing

      This Stewardly Captain COB's This One Situationing now stands lawfully dispatched toward This One Some Place at your request.

      This One Leashing remains the constitutional pathway through which This One Situationing travels.

      This One Terrestrial Computer Free Parkinging Stand Number:
      #{assigns.parkinging_stand}

      This One Shackling PIN:
      #{assigns.shackling_pin}

      This One Piece of Time:
      #{format_piece_of_time(assigns.ceremony_time)}#{pet_name_block}

      This One Situationing is not kept through an account.

      It is carried through lawful Correspondencing by way of This One Leashing.

      Return Here through This One Leashing whenever This Stewardly Captain COB's This One Situationing stands ready to continue Traversaling through This Constitutional Furnishmenting Rail Line.

      situationmachine.systems
      """
      |> String.trim()

    encoded_body = URI.encode_www_form(body)

    case channel do
      "text" ->
        "sms:#{URI.encode(destination)}?body=#{encoded_body}"

      _ ->
        "mailto:#{URI.encode(destination)}?subject=This%20One%20Situationing&body=#{encoded_body}"
    end
  end

  defp format_piece_of_time(%DateTime{} = piece_of_time),
    do: Calendar.strftime(piece_of_time, "%Y-%m-%d %H:%M:%S UTC")

  defp formatted_piece_of_time(%DateTime{} = piece_of_time),
    do: format_piece_of_time(piece_of_time)

  defp formatted_piece_of_time(_piece_of_time), do: nil

  defp history_piece_of_time([%{furnished_at: furnished_at} | _history]),
    do: formatted_piece_of_time(furnished_at)

  defp history_piece_of_time(_history), do: nil

  defp earthly_locality_text(%{constitutional_default: true}),
    do: "This One Some Place upon The Earth"

  defp earthly_locality_text(%{country: country, region: region, city: city}) do
    [city, region, country]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join(", ")
  end

  defp earthly_locality_text(locality), do: to_string(locality)

  defp interrelationing_locality_text(%{constitutional_default: true}),
    do:
      "This One Some Place presently stands left Undistinguishingmented. This Stewardly Captain COB now stands Relationing toward This One Great Free Public Tuple Ship Field from This One Some Place upon The Earth, and This One Situationing now stands Visionizingmentable together with This One Some Place upon The Earth."

  defp interrelationing_locality_text(locality) do
    origin = locality |> furnished_origin_lines() |> Enum.join(", ")
    visionizing_locality = visionizing_locality_text(locality)

    "Visionizingmenting from #{origin}. Encounteringmentingable within #{visionizing_locality}."
  end

  defp constitutional_default?(%{constitutional_default: true}), do: true
  defp constitutional_default?(_locality), do: false

  defp furnished_origin_lines(%{constitutional_default: true}),
    do: ["This One Some Place upon The Earth"]

  defp furnished_origin_lines(%{country: country, region: region, city: city}) do
    case Enum.reject([city, region, country], &(&1 in [nil, ""])) do
      [] -> ["This One Some Place upon The Earth"]
      lines -> lines
    end
  end

  defp visionizing_locality_text(%{visionizing_scope: "city", city: city}) when city != "",
    do: city

  defp visionizing_locality_text(%{visionizing_scope: "region", region: region})
       when region != "",
       do: region

  defp visionizing_locality_text(%{visionizing_scope: "country", country: country})
       when country != "",
       do: country

  defp visionizing_locality_text(%{visionizing_scope: "earth"}), do: "The Whole Earth"
  defp visionizing_locality_text(locality), do: earthly_locality_text(locality)

  defp visionizing_scope_options do
    [
      {"This City", "city"},
      {"This Region", "region"},
      {"This Country", "country"},
      {"The Whole Earth", "earth"}
    ]
  end

  defp staged_origin_lines(form, countries, regions) do
    city = form[:city].value
    region = option_label(regions, form[:region].value || "")
    country = option_label(countries, form[:country].value || "")

    case Enum.reject([city, region, country], &(&1 in [nil, ""])) do
      [] -> ["This One Some Place upon The Earth"]
      lines -> lines
    end
  end

  defp staged_visionizing_locality(form, countries, regions) do
    case form[:visionizing_scope].value || "region" do
      "city" -> blank_as(form[:city].value || "", "This City")
      "region" -> option_label(regions, form[:region].value || "") |> blank_as("This Region")
      "country" -> option_label(countries, form[:country].value || "") |> blank_as("This Country")
      "earth" -> "The Whole Earth"
    end
  end

  defp blank_as("", fallback), do: fallback
  defp blank_as(value, _fallback), do: value

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
        MapSet.member?(socket.assigns.proto_appointmentings, :lanterning)

    assign(socket, :station_02_completed?, completed?)
  end
end
