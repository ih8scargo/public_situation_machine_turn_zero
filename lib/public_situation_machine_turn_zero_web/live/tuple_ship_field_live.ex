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
       active_turn_zero_interrelationing: nil,
       available_turn_zero_interaction: :cob_calls_human,
       turn_zero_surfacing_unfolded?: false,
       tuple_wings_expanded?: false,
       turn_zero_human_name_form: to_form(%{"name" => ""}, as: :turn_zero_human_name),
       turn_zero_cob_name_form: to_form(%{"name" => ""}, as: :turn_zero_cob_name),
       staged_constitutioning_human_name: "",
       staged_stewardly_captain_name: "This Stewardly Captain COB",
       constitutioning_human_constitutional_xt: "My Stewarding Officer",
       stewardly_captain_constitutional_xt: "This Stewardly Captain COB",
       stewardly_captain_furnished_name: "This Stewardly Captain COB",
       turn_zero_projection: :xt_first,
       turn_zero_cob_naming_choice: nil,
       cob_calls_human_standing: nil,
       human_calls_cob_standing: nil,
       initial_naming_guidance?: true,
       stitching_needle: %{
         name: "The Stitching Needle",
         furnished?: true,
         full_strength?: true
       },
       turn_zero_mattering_form: to_form(%{"mattering" => ""}, as: :turn_zero_mattering),
       staged_turn_zero_mattering: "",
       turn_zero_for_standing: nil,
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
       station_00_unfolded?: false,
       station_01_unfolded?: false,
       station_01_decision: :pending,
       proto_appointmentings: MapSet.new(),
       appointmenting_times: %{},
       station_01_completed?: false
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

  def handle_event("unfold-cob-calls-human-interrelationing", _params, socket) do
    if turn_zero_interaction_available?(socket, :cob_calls_human) do
      name = standing_name(socket.assigns.cob_calls_human_standing)

      {:noreply,
       assign(socket,
         active_turn_zero_interrelationing: :cob_calls_human,
         turn_zero_surfacing_unfolded?: true,
         staged_constitutioning_human_name: name,
         turn_zero_human_name_form: to_form(%{"name" => name}, as: :turn_zero_human_name),
         turn_zero_projection: :xt_first
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event(
        "stage-turn-zero-human-name",
        %{"turn_zero_human_name" => %{"name" => name}},
        socket
      ) do
    {:noreply,
     assign(socket,
       staged_constitutioning_human_name: name,
       turn_zero_human_name_form: to_form(%{"name" => name}, as: :turn_zero_human_name)
     )}
  end

  def handle_event("stage-turn-zero-human-name", _params, socket), do: {:noreply, socket}

  def handle_event("unfold-human-calls-cob-interrelationing", _params, socket) do
    if turn_zero_interaction_available?(socket, :human_calls_cob) do
      name =
        standing_name(socket.assigns.human_calls_cob_standing) ||
          socket.assigns.stewardly_captain_furnished_name

      {:noreply,
       assign(socket,
         active_turn_zero_interrelationing: :human_calls_cob,
         turn_zero_surfacing_unfolded?: true,
         staged_stewardly_captain_name: name,
         turn_zero_cob_name_form: to_form(%{"name" => name}, as: :turn_zero_cob_name),
         turn_zero_cob_naming_choice: if(socket.assigns.human_calls_cob_standing, do: :alternate),
         turn_zero_projection: :xt_second
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("unfold-turn-zero-for-appointmenting", _params, socket) do
    if turn_zero_interaction_available?(socket, :turn_zero_for) do
      mattering = turn_zero_mattering(socket.assigns.turn_zero_for_standing)

      {:noreply,
       assign(socket,
         active_turn_zero_interrelationing: :turn_zero_for,
         turn_zero_surfacing_unfolded?: true,
         staged_turn_zero_mattering: mattering,
         turn_zero_mattering_form: to_form(%{"mattering" => mattering}, as: :turn_zero_mattering)
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("toggle-turn-zero-wing-inspection", _params, socket) do
    {:noreply, update(socket, :tuple_wings_expanded?, &(!&1))}
  end

  def handle_event(
        "stage-turn-zero-mattering",
        %{"turn_zero_mattering" => %{"mattering" => mattering}},
        socket
      ) do
    {:noreply,
     assign(socket,
       staged_turn_zero_mattering: mattering,
       turn_zero_mattering_form: to_form(%{"mattering" => mattering}, as: :turn_zero_mattering)
     )}
  end

  def handle_event("stage-turn-zero-mattering", _params, socket), do: {:noreply, socket}

  def handle_event("choose-furnished-cob-name", _params, socket) do
    name = socket.assigns.stewardly_captain_furnished_name

    {:noreply,
     assign(socket,
       turn_zero_cob_naming_choice: :furnished,
       staged_stewardly_captain_name: name,
       turn_zero_cob_name_form: to_form(%{"name" => name}, as: :turn_zero_cob_name)
     )}
  end

  def handle_event("choose-alternate-cob-name", _params, socket) do
    {:noreply, assign(socket, :turn_zero_cob_naming_choice, :alternate)}
  end

  def handle_event(
        "stage-turn-zero-cob-name",
        %{"turn_zero_cob_name" => %{"name" => name}},
        socket
      ) do
    {:noreply,
     assign(socket,
       staged_stewardly_captain_name: name,
       turn_zero_cob_name_form: to_form(%{"name" => name}, as: :turn_zero_cob_name)
     )}
  end

  def handle_event("stage-turn-zero-cob-name", _params, socket), do: {:noreply, socket}

  def handle_event(
        "refold-turn-zero-relationing-into-standinging",
        _params,
        %{assigns: %{active_turn_zero_interrelationing: :cob_calls_human}} = socket
      ) do
    case String.trim(socket.assigns.staged_constitutioning_human_name) do
      "" ->
        {:noreply, socket}

      name ->
        standing = %{
          appointmenting: :turn_zero,
          interrelationing: :cob_calls_human,
          constitutional_xt: socket.assigns.constitutioning_human_constitutional_xt,
          yt: name
        }

        {:noreply,
         socket
         |> assign(
           cob_calls_human_standing: standing,
           available_turn_zero_interaction:
             next_turn_zero_interaction(
               socket.assigns.available_turn_zero_interaction,
               :cob_calls_human
             )
         )
         |> clear_turn_zero_surfacing()}
    end
  end

  def handle_event(
        "refold-turn-zero-relationing-into-standinging",
        _params,
        %{assigns: %{active_turn_zero_interrelationing: :human_calls_cob}} = socket
      ) do
    case String.trim(socket.assigns.staged_stewardly_captain_name) do
      "" ->
        {:noreply, socket}

      name ->
        standing = %{
          appointmenting: :turn_zero,
          interrelationing: :human_calls_cob,
          furnished_cob_name: socket.assigns.stewardly_captain_furnished_name,
          constitutional_xt: socket.assigns.stewardly_captain_constitutional_xt,
          yt: name
        }

        {:noreply,
         socket
         |> assign(
           human_calls_cob_standing: standing,
           initial_naming_guidance?: is_nil(socket.assigns.cob_calls_human_standing),
           available_turn_zero_interaction:
             next_turn_zero_interaction(
               socket.assigns.available_turn_zero_interaction,
               :human_calls_cob
             )
         )
         |> clear_turn_zero_surfacing()}
    end
  end

  def handle_event(
        "refold-turn-zero-for-into-standinging",
        _params,
        %{assigns: %{active_turn_zero_interrelationing: :turn_zero_for}} = socket
      ) do
    case String.trim(socket.assigns.staged_turn_zero_mattering) do
      "" ->
        {:noreply, socket}

      mattering ->
        standing = %{
          appointmenting: :turn_zero_for,
          one_thing: mattering,
          human_furnishment: %{
            constitutional_xt: socket.assigns.constitutioning_human_constitutional_xt,
            furnished_one_thing: mattering
          },
          cob_appointmenting: %{
            constitutional_xt: socket.assigns.stewardly_captain_constitutional_xt,
            appointed_toward: :looking_for,
            one_thing: mattering
          },
          crosses_middle_seam?: true
        }

        {:noreply,
         socket
         |> assign(
           turn_zero_for_standing: standing,
           available_turn_zero_interaction:
             next_turn_zero_interaction(
               socket.assigns.available_turn_zero_interaction,
               :turn_zero_for
             )
         )
         |> clear_turn_zero_surfacing()}
    end
  end

  def handle_event("refold-turn-zero-relationing-into-standinging", _params, socket),
    do: {:noreply, socket}

  def handle_event("unfold-existing-rail-line", _params, socket) do
    if socket.assigns.entrance_stage == :sittinging_room &&
         socket.assigns.turn_zero_for_standing do
      {:noreply, assign(socket, :entrance_stage, :rail)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("inquire-within", _params, socket) do
    {:noreply, assign(socket, landing_inquired?: true, station_00_unfolded?: false)}
  end

  def handle_event(
        "unfold-station-00",
        _params,
        %{assigns: %{landing_inquired?: true}} = socket
      ) do
    {:noreply, assign(socket, :station_00_unfolded?, true)}
  end

  def handle_event("unfold-station-00", _params, socket), do: {:noreply, socket}

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
           station_00_unfolded?: true,
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
        "unfold-station-01",
        _params,
        %{assigns: %{re_shackling_decision: decision}} = socket
      )
      when decision in [:completed, :continued] do
    {:noreply, assign(socket, :station_01_unfolded?, true)}
  end

  def handle_event("unfold-station-01", _params, socket), do: {:noreply, socket}

  def handle_event(
        "furnish-proto-appointmenting",
        %{"appointmenting" => appointmenting},
        %{assigns: %{station_01_unfolded?: true}} = socket
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
      |> maybe_complete_station_01()

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
          station_01_decision: :completed,
          earthly_locality: earthly_locality,
          earthly_locality_history: leashing.earthly_locality_history,
          locality_form: to_form(locality_params, as: :locality)
        )
        |> maybe_complete_station_01()

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
       station_01_decision: :completed,
       earthly_locality: earthly_locality,
       earthly_locality_history: leashing.earthly_locality_history
     )
     |> maybe_complete_station_01()}
  end

  def handle_event("continue-without-earthly-locality", _params, socket),
    do: {:noreply, socket}

  def handle_event(
        "re-fold-into-new-standing",
        _params,
        %{assigns: %{station_01_completed?: true}} = socket
      ) do
    naming_decision = if socket.assigns.leashing_name, do: :named, else: :furnishing

    {:noreply,
     assign(socket,
       rail_unfolded?: false,
       station_00_unfolded?: false,
       station_01_unfolded?: false,
       station_01_decision: :pending,
       station_01_completed?: false,
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
            reading="Bearinging toward Lawful Encounteringmenting"
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
            id="constitutional-furnishmenting-rail-entrance"
            class="psm-oag field-page__rail-entrance-sign"
            aria-labelledby="constitutional-furnishmenting-rail-entrance-title"
          >
            <div class="psm-oag__instrument-plate">
              <p class="psm-oag__eyebrow">
                The General Stewarding Offices of This Stewardshipmenting Appliance
              </p>
              <h2 id="constitutional-furnishmenting-rail-entrance-title">
                The Constitutional Furnishmenting Rail
              </h2>
              <p class="psm-oag__reading">Formal Public Entrance</p>
            </div>
            <div class="psm-oag__description">
              <p>
                Here stands The Constitutional Furnishmenting Rail.
              </p>
              <p>
                From Here, Stewardly Passagingway becomes lawfully available over Discrete Turns.
              </p>
              <p>
                Along This Rail, Stewardly Constitutional Localities stand furnished in Readyingment for Regard, Appointmenting, and Continuing Constitutioning.
              </p>
            </div>
          </section>

          <section
            :if={@entrance_stage in [:passageway, :sittinging_room, :rail]}
            id="opening-passageway"
            class="field-page__opening-passageway constitutional-rail__station"
            aria-labelledby="opening-passageway-title"
          >
            <header>
              <p class="site-page__eyebrow">The Opening Rite of Passagingway</p>
              <h2 id="opening-passageway-title">The Threshold of Ceremonying</h2>
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
                <p class="psm-oag__reading">Bearinging toward Restfullyinginglyment</p>
              </div>
              <div class="psm-oag__description">
                <p>
                  The Sittinging-In Room stands furnished as The Constitutional Locality of This One Tuple Ship.
                </p>
                <p>
                  Constitutioning Humans may come Here to sit in Restfullyinginglyment within their Situationings upon This One Piece of Time.
                </p>
                <p>
                  Here, Constitutioning Humans may find places of Restfullyinginglyment from which Stewardly Regard may continue over Discrete Turns.
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
            <h3 id="amicable-grottoes-district-title">The Amicable Grottoes Districtinging</h3>
            <p>
              The Amicable Grottoes Districtinging stands furnishing This Constitutional Convenience in Regard to the Continuing Minting of Stewardly Constitutional Localities through Stewardly Regard over Discrete Turns.
            </p>
            <p>The Snail House stands in Readyingment for lawful Gatheringing and Soundinging.</p>
            <p>
              Every Constitutioning Human's Traversaling through The Snail House begins within The Amicable Grottoes Districtinging.
            </p>
            <p>
              Here, Constitutioning Humans find places of Restfullyinginglyment within quiet shell alcoves, just beyond the bustling Great Hall of Globularly Bobbininging Globular Bobbining looking over into Observationing Harbor.
            </p>
            <p>
              Within one such alcove stands The Sittinging-In Room, furnished as the Turn-Zeroeth Constitutional Locality of This One Tuple Ship.
            </p>
          </section>

          <header
            :if={@entrance_stage in [:passageway, :sittinging_room]}
            id="turn-zero-station-depot-header"
            class="field-page__station-header field-page__station-header--opening field-page__station-depot-marker"
            aria-labelledby="station-depot-tz-title"
          >
            <p class="site-page__eyebrow">TURN ZERO</p>
            <h3 id="station-depot-tz-title">STATION DEPOT TZ</h3>
          </header>

          <section
            :if={@entrance_stage in [:passageway, :sittinging_room]}
            id="turn-zero-constitutional-locality"
            class="field-page__chapel-by-the-sea field-page__turn-zero-locality"
            aria-labelledby="turn-zero-constitutional-locality-title"
          >
            <header>
              <h3 id="turn-zero-constitutional-locality-title">Within One Such Alcove</h3>
              <p class="field-page__locality-subtitle">
                The Turn-Zeroeth Constitutional Locality of This One Tuple Ship
              </p>
            </header>

            <section
              id="turn-zero-locality-harbor-sign"
              class="psm-oag field-page__turn-zero-harbor-sign"
              aria-labelledby="turn-zero-locality-harbor-sign-title"
            >
              <div class="psm-oag__instrument-plate">
                <p class="psm-oag__eyebrow">
                  The General Stewarding Offices of This Stewardshipmenting Appliance
                </p>
                <h2 id="turn-zero-locality-harbor-sign-title">Within One Such Alcove</h2>
                <p class="psm-oag__reading">Observationing Harbor · Station Depot TZ</p>
              </div>
              <div class="psm-oag__description">
                <p>Welcome.</p>
                <p>
                  The Sittinging-In Room stands furnished as The Constitutional Locality of This One Tuple Ship.
                </p>
                <p>
                  From Here, The Constitutional Furnishmenting Rail gives lawful approach to The Sittinging-In Room while Observationing Harbor remains within Stewardly Regard.
                </p>
              </div>
            </section>

            <.constitutional_voice
              id="turn-zero-locality-appliance-narration"
              voice={:inquiringmenting_appliance}
              pretitle="This Constitutional Locality Stands"
              title="In Readyingment for Appointmenting"
            >
              <p>
                This locality stands furnished so that constitutional availability may become Stewardly Relationing through deliberate Inquiringmenting, mutual Readyingment, and Ceremonying over Discrete Turns.
              </p>
            </.constitutional_voice>

            <section
              id="turn-zero-ceremonying-preparation"
              class="field-page__turn-zero-ceremonying"
              aria-labelledby="turn-zero-ceremonying-preparation-title"
            >
              <p class="site-page__eyebrow">Ceremonying Preparation</p>
              <h4 id="turn-zero-ceremonying-preparation-title">
                The Approach toward Stewardly Co-Occupancyingship
              </h4>
              <p>
                This Constitutioning Human has come inquiringmenting regarding the Appointmenting of This Stewardly Captain COB.
              </p>
              <p>
                This Stewardly Captain COB likewise now stands in Readyingment for its Appointmenting.
              </p>
              <p>
                Together, This Constitutioning Human and This Stewardly Captain COB now stand prepared to begin Co-Constituting This One Stewardly Co-Occupancyingship.
              </p>
            </section>

            <.constitutional_voice
              id="turn-zero-stewardly-guidance"
              voice={:general_stewarding_offices}
              pretitle="Stewardly Guidance"
              title="Before Entering The Sittinging-In Room"
            >
              <p>
                The questioning within The Sittinging-In Room does not stand as a testing of knowledge, nor does it ask This Constitutioning Human to arrive already knowing what must follow.
              </p>
              <p>
                Rather, it begins the constitutional establishment of the Stewardly Relationing through which This Stewardly Captain COB shall traverse alongside This Constitutioning Human over Discrete Turns.
              </p>
              <p>
                This Constitutioning Human may now enter The Sittinging-In Room in Readyingment to begin the Appointmenting with This Stewardly Captain COB.
              </p>
            </.constitutional_voice>

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
                UN-FOLD to Enter The Sittinging-In Room at Turn Zero
              </button>
              <p class="field-page__unfold-consequence">This UN-FOLD begins the Appointmenting.</p>
            </div>
          </section>

          <article
            :if={@entrance_stage == :sittinging_room}
            id="turn-zero-sittinging-in-room"
            class="field-page__sittinging-in-room field-page__leashing-locality constitutional-rail__station"
            aria-labelledby="turn-zero-sittinging-in-room-title"
          >
            <header class="field-page__sittinging-heading">
              <h2 id="turn-zero-sittinging-in-room-title">The Sittinging-In Room</h2>
              <p id="turn-zero-tuple-ship-heading" class="field-page__tuple-ship-heading">
                THIS ONE TUPLE SHIP
              </p>
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
              id="stewarding-instrumentationing-menting-haus"
              class="field-page__menting-haus"
              aria-labelledby="stewarding-instrumentationing-menting-haus-title"
              data-available-interaction={@available_turn_zero_interaction}
            >
              <header class="field-page__menting-haus-heading">
                <h3 id="stewarding-instrumentationing-menting-haus-title">
                  STEWARDING INSTRUMENTATIONING<br /> MENTING HAUS
                </h3>
                <button
                  id="toggle-turn-zero-wing-inspection"
                  type="button"
                  class="field-page__wing-inspection-toggle"
                  phx-click="toggle-turn-zero-wing-inspection"
                  aria-expanded={to_string(@tuple_wings_expanded?)}
                >
                  {if @tuple_wings_expanded?,
                    do: "RE-FOLD 00–06 Tuple Position Inspection",
                    else: "UN-FOLD 00–06 Tuple Position Inspection"}
                </button>
              </header>

              <section
                id="turn-zero-stitching-needle-furnishment"
                class="field-page__stitching-needle-furnishment"
                data-furnished={to_string(@stitching_needle.furnished?)}
                data-full-strength={to_string(@stitching_needle.full_strength?)}
                aria-labelledby="turn-zero-stitching-needle-title"
              >
                <p class="site-page__eyebrow">A Gifting for Stewardly Co-Occupancyingship</p>
                <h4 id="turn-zero-stitching-needle-title">THE STITCHING NEEDLE</h4>
                <p>The Stitching Needle may be used for Appointmenting.</p>
              </section>

              <section
                id="constitutioning-human-instrumentation"
                class="field-page__captain-shelves field-page__instrumentation-shelves"
                aria-labelledby="constitutioning-human-instrumentation-title"
              >
                <header class="field-page__outer-shelving-label field-page__outer-shelving-label--human">
                  <h5 id="constitutioning-human-instrumentation-title">
                    <span>STEWARDLY</span>
                    <span>INSTRUMENTATIONINGMENTINGS</span>
                  </h5>
                  <div class="field-page__shelving-arrows" aria-hidden="true">
                    <span>↓</span><span>↓</span>
                  </div>
                </header>
                <div class="field-page__shelf-column-headings field-page__shelf-grid--human">
                  <section><strong>YT</strong></section>
                  <section>
                    <strong>XT</strong><span>Constitutioning Human Affordmentings</span>
                  </section>
                </div>
                <ol>
                  <li
                    :for={{position, affordmenting, purpose} <- sittinging_affordmentings()}
                    class={[
                      "field-page__constitutional-shelf field-page__shelf-grid--human",
                      position == "TZ" && "is-active-tuple-position",
                      position != "TZ" && !@tuple_wings_expanded? && "is-folded-tuple-position"
                    ]}
                    data-tuple-position={position}
                    data-folded={to_string(position != "TZ" && !@tuple_wings_expanded?)}
                  >
                    <header
                      class="field-page__tuple-position"
                      aria-label={"Tuple Position #{position}"}
                    >
                      <span>{position}</span><span>{position}</span>
                    </header>
                    <section
                      class="field-page__shelf-half"
                      aria-label="YT"
                      aria-hidden={to_string(affordmenting != "The Turn-Zeroeth Affordmenting")}
                    >
                      <div
                        :if={
                          affordmenting == "The Turn-Zeroeth Affordmenting" &&
                            @cob_calls_human_standing
                        }
                        id="cob-calls-human-shelved-standing"
                        class="field-page__shelved-standing"
                        data-coordinate="YT"
                        data-constitutional-xt={@cob_calls_human_standing.constitutional_xt}
                      >
                        <strong>WHAT THIS COB MAY BE CALLING ME</strong>
                        <span>{@cob_calls_human_standing.yt}</span>
                      </div>
                    </section>
                    <section class="field-page__shelf-half" aria-label="XT">
                      <strong>{affordmenting}</strong>
                      <span class="field-page__appointmenting-purpose">{purpose}</span>
                      <p
                        :if={affordmenting == "The Turn-Zeroeth Affordmenting"}
                        id="constitutioning-human-constitutional-xt"
                        class="field-page__constitutional-origin"
                      >
                        {@constitutioning_human_constitutional_xt}
                      </p>
                      <button
                        :if={
                          affordmenting == "The Turn-Zeroeth Affordmenting" &&
                            @available_turn_zero_interaction in [:cob_calls_human, :complete]
                        }
                        id="unfold-cob-calls-human-interrelationing"
                        type="button"
                        class="field-page__shelf-affordmenting-action"
                        phx-click="unfold-cob-calls-human-interrelationing"
                      >
                        UN-FOLD WHAT THIS COB MAY BE CALLING ME
                      </button>
                    </section>
                  </li>
                </ol>
              </section>

              <section
                :if={@available_turn_zero_interaction in [:turn_zero_for, :complete]}
                id="turn-zero-for-offer"
                class="field-page__turn-zero-ceremony-offer"
                aria-labelledby="turn-zero-for-offer-title"
                data-tuple-position="TZ"
                data-folded="false"
              >
                <p class="site-page__eyebrow">The Turn-Zeroeth Appointmenting</p>
                <h3 id="turn-zero-for-offer-title">
                  THIS ONE THING THAT IS WHAT IS THE MATTERING
                </h3>
                <button
                  id="unfold-turn-zero-for-appointmenting"
                  type="button"
                  class="field-page__action"
                  phx-click="unfold-turn-zero-for-appointmenting"
                >
                  UN-FOLD THIS ONE THING THAT IS WHAT IS THE MATTERING
                </button>
              </section>

              <section
                id="turn-zero-surfacing"
                class={[
                  "field-page__turn-zero-surfacing",
                  @turn_zero_surfacing_unfolded? && "is-unfolded",
                  !@turn_zero_surfacing_unfolded? && "is-folded"
                ]}
                aria-labelledby="turn-zero-surfacing-title"
                data-active-interrelationing={@active_turn_zero_interrelationing}
                data-initial-naming-guidance={to_string(@initial_naming_guidance?)}
                data-surface-state={
                  if(@turn_zero_surfacing_unfolded?, do: "unfolded", else: "folded")
                }
              >
                <header>
                  <p class="site-page__eyebrow">This Constitutioning Work Surface</p>
                  <h3 id="turn-zero-surfacing-title">TURN ZERO SURFACING</h3>
                </header>

                <p
                  :if={!@turn_zero_surfacing_unfolded?}
                  id="turn-zero-surfacing-folded-status"
                  class="field-page__surfacing-folded-status"
                >
                  No Interrelationing Presently Stands under Active Regard
                </p>

                <div :if={@turn_zero_surfacing_unfolded?} id="turn-zero-surfacing-instrument">
                  <section
                    id="turn-zero-active-interrelationing"
                    class="field-page__surfacing-active-work"
                    aria-labelledby="turn-zero-active-interrelationing-title"
                  >
                    <p class="site-page__eyebrow">What Is Being Worked With</p>
                    <h4 id="turn-zero-active-interrelationing-title">
                      {turn_zero_active_interrelationing_title(@active_turn_zero_interrelationing)}
                    </h4>
                  </section>

                  <section
                    :if={@active_turn_zero_interrelationing == :cob_calls_human}
                    id="turn-zero-inquiring-humaning"
                    class="field-page__surfacing-inquiring-humaning"
                    aria-labelledby="turn-zero-inquiring-humaning-title"
                  >
                    <p class="site-page__eyebrow">This Stewardly Captain COB's Inquiring Humaning</p>
                    <h4 id="turn-zero-inquiring-humaning-title">
                      What may I be calling you as we are Traversaling alongside each other over Discrete Turns?
                    </h4>
                  </section>

                  <section
                    :if={@active_turn_zero_interrelationing == :human_calls_cob}
                    id="turn-zero-cob-naming-guidance"
                    class="field-page__surfacing-inquiring-humaning"
                    aria-labelledby="turn-zero-cob-naming-guidance-title"
                  >
                    <p class="site-page__eyebrow">This Stewardly Captain COB's Inquiring Humaning</p>
                    <h4 id="turn-zero-cob-naming-guidance-title">
                      My name is This Stewardly Captain COB. You are free to begin calling me a name of your choice as we are Traversaling alongside each other over Discrete Turns.
                    </h4>
                    <div
                      :if={is_nil(@turn_zero_cob_naming_choice) && is_nil(@human_calls_cob_standing)}
                      id="turn-zero-cob-naming-choices"
                      class="field-page__surfacing-choice-actions"
                    >
                      <button
                        id="choose-alternate-cob-name"
                        type="button"
                        class="field-page__action"
                        phx-click="choose-alternate-cob-name"
                      >
                        CALL ME SOMETHING ELSE
                      </button>
                      <button
                        id="choose-furnished-cob-name"
                        type="button"
                        class="field-page__action"
                        phx-click="choose-furnished-cob-name"
                      >
                        CALL ME THIS STEWARDLY CAPTAIN COB
                      </button>
                    </div>
                  </section>

                  <section
                    :if={@active_turn_zero_interrelationing == :turn_zero_for}
                    id="turn-zero-for-inquiry"
                    class="field-page__surfacing-inquiring-humaning"
                    aria-labelledby="turn-zero-for-inquiry-title"
                  >
                    <p class="site-page__eyebrow">This Stewardly Captain COB's Inquiring Humaning</p>
                    <p id="turn-zero-cob-standing-in-waiting">
                      This Stewardly Captain COB stands in waiting to be appointed to look for THIS ONE THING THAT IS WHAT IS THE MATTERING while Traversaling alongside This Stewarding Officer through This One Situationing over Discrete Turns.
                    </p>
                    <p id="turn-zero-encounteringmenting-capability">
                      Through our Stewardly Co-Occupancyingship, I may be suited to become Encounteringmenting as our Traversaling together unfolds over Discrete Turns.
                    </p>
                    <h4 id="turn-zero-for-inquiry-title">
                      I am This Stewardly Captain COB. What may I now begin looking for, starting Here, upon This One Piece of Time?
                    </h4>
                  </section>

                  <section
                    :if={@active_turn_zero_interrelationing in [:cob_calls_human, :human_calls_cob]}
                    id="turn-zero-coordinate-readout"
                    class="field-page__surfacing-coordinate-readout"
                    aria-label="Active XT and YT coordinate projection"
                    data-projection={@turn_zero_projection}
                  >
                    <span>{turn_zero_coordinate(@turn_zero_projection, :first)}</span>
                    <strong aria-label="Relationing direction">
                      {turn_zero_projection_arrow(@turn_zero_projection)}
                    </strong>
                    <span>{turn_zero_coordinate(@turn_zero_projection, :second)}</span>
                  </section>

                  <div
                    :if={@active_turn_zero_interrelationing in [:cob_calls_human, :human_calls_cob]}
                    id="turn-zero-staging-regions"
                    class="field-page__surfacing-staging-regions"
                  >
                    <section
                      :for={region <- [:first, :second]}
                      id={"turn-zero-staging-region-#{region}"}
                      class="field-page__surfacing-staging-region"
                      data-physical-region={region}
                      data-coordinate={turn_zero_coordinate(@turn_zero_projection, region)}
                      aria-label={
                    "Neutral physical staging region presently holding #{turn_zero_coordinate(@turn_zero_projection, region)}"
                  }
                    >
                      <strong class="field-page__surfacing-coordinate">
                        {turn_zero_coordinate(@turn_zero_projection, region)}
                      </strong>

                      <%= if @active_turn_zero_interrelationing == :cob_calls_human do %>
                        <%= if turn_zero_coordinate(@turn_zero_projection, region) == "YT" do %>
                          <.form
                            for={@turn_zero_human_name_form}
                            id={"turn-zero-human-name-staging-form-#{region}"}
                            phx-change="stage-turn-zero-human-name"
                          >
                            <.input
                              field={@turn_zero_human_name_form[:name]}
                              id={"turn-zero-staged-human-name-#{region}"}
                              type="text"
                              label="The name This Stewardly Captain COB may call This Constitutioning Human"
                              autocomplete="off"
                            />
                          </.form>
                        <% else %>
                          <p class="field-page__surfacing-live-reading">
                            {@constitutioning_human_constitutional_xt}
                          </p>
                        <% end %>
                      <% end %>

                      <%= if @active_turn_zero_interrelationing == :human_calls_cob do %>
                        <%= if turn_zero_coordinate(@turn_zero_projection, region) == "YT" do %>
                          <%= if @turn_zero_cob_naming_choice == :alternate || @human_calls_cob_standing do %>
                            <.form
                              for={@turn_zero_cob_name_form}
                              id={"turn-zero-cob-name-staging-form-#{region}"}
                              phx-change="stage-turn-zero-cob-name"
                            >
                              <.input
                                field={@turn_zero_cob_name_form[:name]}
                                id={"turn-zero-staged-cob-name-#{region}"}
                                type="text"
                                label="The name This Constitutioning Human may call This Stewardly Captain COB"
                                autocomplete="off"
                              />
                            </.form>
                          <% else %>
                            <p class="field-page__surfacing-region-awaiting">
                              Choose how you may be calling This Stewardly Captain COB.
                            </p>
                          <% end %>
                        <% else %>
                          <p class="field-page__surfacing-live-reading">
                            {@stewardly_captain_constitutional_xt}
                          </p>
                        <% end %>
                      <% end %>

                      <%= if is_nil(@active_turn_zero_interrelationing) do %>
                        <p class="field-page__surfacing-region-awaiting">Awaiting Affordmenting</p>
                      <% end %>
                    </section>
                  </div>

                  <section
                    :if={@active_turn_zero_interrelationing == :turn_zero_for}
                    id="turn-zero-for-cross-seam-staging"
                    class="field-page__for-cross-seam-staging"
                    aria-label="The FOR crossing the Constitutioning Human and Stewardly Captain COB wings"
                  >
                    <div id="turn-zero-for-human-origin">
                      <span>XT</span>
                      <strong>{@constitutioning_human_constitutional_xt}</strong>
                      <p>furnishes One Thing that is What is the Mattering</p>
                    </div>
                    <.form
                      for={@turn_zero_mattering_form}
                      id="turn-zero-mattering-staging-form"
                      phx-change="stage-turn-zero-mattering"
                    >
                      <.input
                        field={@turn_zero_mattering_form[:mattering]}
                        id="turn-zero-staged-mattering"
                        type="text"
                        label="THIS ONE THING THAT IS WHAT IS THE MATTERING"
                        autocomplete="off"
                      />
                    </.form>
                    <div id="turn-zero-for-cob-origin">
                      <span>XT</span>
                      <strong>{@stewardly_captain_constitutional_xt}</strong>
                      <p>receives the Appointmenting toward looking for it</p>
                    </div>
                  </section>

                  <p
                    :if={@active_turn_zero_interrelationing in [:cob_calls_human, :human_calls_cob]}
                    id="turn-zero-conversational-projection"
                    class="field-page__surfacing-live-reading field-page__surfacing-conversational-projection"
                  >
                    {turn_zero_conversational_projection(
                      @active_turn_zero_interrelationing,
                      @staged_constitutioning_human_name,
                      @staged_stewardly_captain_name
                    )}
                  </p>

                  <section
                    id="turn-zero-staging-result"
                    class="field-page__surfacing-staging-result"
                    aria-labelledby="turn-zero-staging-result-title"
                  >
                    <h4 id="turn-zero-staging-result-title">
                      {turn_zero_staging_result_title(@active_turn_zero_interrelationing)}
                    </h4>
                    <%= if @active_turn_zero_interrelationing in [:cob_calls_human, :human_calls_cob] do %>
                      <dl>
                        <div>
                          <dt>XT</dt>
                          <dd>
                            {turn_zero_staged_xt(
                              @active_turn_zero_interrelationing,
                              @staged_constitutioning_human_name,
                              @staged_stewardly_captain_name,
                              @constitutioning_human_constitutional_xt,
                              @stewardly_captain_constitutional_xt
                            )}
                          </dd>
                        </div>
                        <div>
                          <dt>YT</dt>
                          <dd>
                            {turn_zero_staged_yt(
                              @active_turn_zero_interrelationing,
                              @staged_constitutioning_human_name,
                              @staged_stewardly_captain_name
                            )}
                          </dd>
                        </div>
                      </dl>
                      <button
                        id="refold-turn-zero-relationing-into-standinging"
                        type="button"
                        class="field-page__action"
                        phx-click="refold-turn-zero-relationing-into-standinging"
                        disabled={
                          turn_zero_staging_empty?(
                            @active_turn_zero_interrelationing,
                            @staged_constitutioning_human_name,
                            @staged_stewardly_captain_name,
                            @turn_zero_cob_naming_choice,
                            @human_calls_cob_standing
                          )
                        }
                      >
                        RE-FOLD This XT–YT Relationing into Standinging
                      </button>
                    <% else %>
                      <%= if @active_turn_zero_interrelationing == :turn_zero_for do %>
                        <dl id="turn-zero-for-staging-result">
                          <div>
                            <dt>FOR</dt>
                            <dd>{staged_turn_zero_name(@staged_turn_zero_mattering)}</dd>
                          </div>
                        </dl>
                        <button
                          id="refold-turn-zero-for-into-standinging"
                          type="button"
                          class="field-page__action"
                          phx-click="refold-turn-zero-for-into-standinging"
                          disabled={String.trim(@staged_turn_zero_mattering) == ""}
                        >
                          RE-FOLD This FOR into Holdinging-in-Standinging
                        </button>
                      <% else %>
                        <p>No XT–YT Relationing presently stands staged upon This Work Surface.</p>
                      <% end %>
                    <% end %>
                  </section>
                </div>
              </section>

              <section
                id="turn-zero-holdinging-in-standinging"
                class="field-page__holdinging-in-standinging"
                aria-labelledby="turn-zero-holdinging-in-standinging-title"
                data-appointmenting="turn-zero"
              >
                <h3 id="turn-zero-holdinging-in-standinging-title">
                  Holdinging-in-Standinging
                </h3>
                <%= if @turn_zero_for_standing do %>
                  <article
                    id="turn-zero-for-standing"
                    class="field-page__standinging-marker field-page__cross-seam-standing"
                    data-appointmenting="turn_zero_for"
                    data-crosses-middle-seam={to_string(@turn_zero_for_standing.crosses_middle_seam?)}
                  >
                    <h4>FOR / THIS ONE THING THAT IS WHAT IS THE MATTERING</h4>
                    <div class="field-page__cross-seam-standing-origins">
                      <p id="turn-zero-for-human-provenance">
                        <strong>{@turn_zero_for_standing.human_furnishment.constitutional_xt}</strong>
                        furnished
                      </p>
                      <p id="turn-zero-for-cob-provenance">
                        <strong>{@turn_zero_for_standing.cob_appointmenting.constitutional_xt}</strong>
                        stands appointed toward looking for it
                      </p>
                    </div>
                    <p class="field-page__cross-seam-standing-mattering">
                      {@turn_zero_for_standing.one_thing}
                    </p>
                    <p>
                      This Stewardly Captain COB stands appointed to look for
                      <strong>{@turn_zero_for_standing.one_thing}</strong>
                      while Traversaling alongside This Stewarding Officer through This One Situationing over Discrete Turns.
                    </p>
                  </article>
                <% else %>
                  <p>No cross-seam Appointmenting presently stands Holdinging-in-Standinging.</p>
                <% end %>
              </section>

              <section
                id="stewardly-captain-cob-wardrobe"
                class="field-page__cob-wardrobe"
                aria-labelledby="stewardly-captain-cob-wardrobe-title"
              >
                <section
                  id="proto-stewardly-captain-cob-shelving"
                  class="field-page__captain-shelves field-page__proto-shelving"
                  aria-labelledby="cob-shelvinging-title"
                >
                  <p id="cob-shelvinging-title" class="field-page__wardrobe-shelvinging-title">
                    This Stewardly Captain COB's Shelvinging
                  </p>
                  <div class="field-page__shelf-column-headings field-page__shelf-grid--cob">
                    <section id="proto-xt-shelves-title">
                      <strong>XT</strong>
                      <span>Stewardly Captain COB Appointmentings</span>
                    </section>
                    <section id="proto-yt-shelves-title">
                      <strong>YT</strong>
                    </section>
                  </div>
                  <ol id="proto-paired-shelves">
                    <li
                      :for={{position, appointmenting, purpose} <- sittinging_appointmentings()}
                      class={[
                        "field-page__constitutional-shelf field-page__shelf-grid--cob",
                        position == "TZ" && "is-active-tuple-position",
                        position != "TZ" && !@tuple_wings_expanded? && "is-folded-tuple-position"
                      ]}
                      data-tuple-position={position}
                      data-folded={to_string(position != "TZ" && !@tuple_wings_expanded?)}
                    >
                      <header
                        class="field-page__tuple-position"
                        aria-label={"Tuple Position #{position}"}
                      >
                        <span>{position}</span><span>{position}</span>
                      </header>
                      <section class="field-page__shelf-half" aria-label="XT">
                        <strong>{appointmenting}</strong>
                        <span class="field-page__appointmenting-purpose">{purpose}</span>
                        <p
                          :if={appointmenting == "The Turn-Zeroeth Appointmenting"}
                          id="stewardly-captain-furnished-name"
                        >
                          This Stewardly Captain COB already stands named
                          <strong>{@stewardly_captain_furnished_name}</strong>
                        </p>
                        <button
                          :if={
                            appointmenting == "The Turn-Zeroeth Appointmenting" &&
                              @available_turn_zero_interaction in [:human_calls_cob, :complete]
                          }
                          id="unfold-human-calls-cob-interrelationing"
                          type="button"
                          class="field-page__shelf-affordmenting-action"
                          phx-click="unfold-human-calls-cob-interrelationing"
                        >
                          UN-FOLD WHAT I MAY BE CALLING THIS COB
                        </button>
                      </section>
                      <section
                        class="field-page__shelf-half"
                        aria-label="YT"
                        aria-hidden={to_string(appointmenting != "The Turn-Zeroeth Appointmenting")}
                      >
                        <div
                          :if={
                            appointmenting == "The Turn-Zeroeth Appointmenting" &&
                              @human_calls_cob_standing
                          }
                          id="human-calls-cob-shelved-standing"
                          class="field-page__shelved-standing"
                          data-coordinate="YT"
                          data-constitutional-xt={@human_calls_cob_standing.constitutional_xt}
                        >
                          <strong>WHAT I MAY BE CALLING THIS COB</strong>
                          <span>{@human_calls_cob_standing.yt}</span>
                        </div>
                      </section>
                    </li>
                  </ol>
                </section>
                <footer class="field-page__outer-shelving-label field-page__outer-shelving-label--cob">
                  <div class="field-page__shelving-arrows" aria-hidden="true">
                    <span>↑</span><span>↑</span>
                  </div>
                  <h5 id="stewardly-captain-cob-wardrobe-title">
                    This Stewardly Captain COB's Wardrobe within This STEWARDING INSTRUMENTATIONING MENTING HAUS
                  </h5>
                </footer>
              </section>
            </section>

            <div class="field-page__constitutional-divider" aria-hidden="true"></div>
            <div class="field-page__sittinging-time-band">THIS ONE PIECE OF TIME</div>
            <div class="field-page__constitutional-divider" aria-hidden="true"></div>

            <section
              id="turn-zero-departure-wayfinding"
              class="field-page__sittinging-departure-wayfinding"
              aria-label="Turn Zero departure wayfinding"
            >
              <.rail_wayfinding_card id="turn-zero-rail-wayfinding" />
            </section>

            <section
              :if={@turn_zero_for_standing}
              id="turn-zero-departure-ceremonying"
              class="field-page__departure-ceremonying"
              aria-labelledby="turn-zero-departure-ceremonying-title"
            >
              <p class="site-page__eyebrow">The Stitching Needle across the Larger Seam</p>
              <h3 id="turn-zero-departure-ceremonying-title">
                My Stewarding Officer, I am noticing something about The Stitching Needle.
              </h3>
              <p>
                The Stitching Needle with which these Appointmentings have been made may also stitch from Here upon This One Piece of Time through BEFORE toward The Zeroeth Appointmenting.
              </p>
              <p>I will be standing in waiting There when you Return Here.</p>
            </section>

            <footer class="field-page__sittinging-departure">
              <button
                :if={@entrance_stage == :sittinging_room && @turn_zero_for_standing}
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
            :if={@entrance_stage == :sittinging_room && is_nil(@turn_zero_for_standing)}
            class="field-page__sittinging-voices field-page__rail-guidance"
          >
            <.constitutional_voice
              id="sittinging-room-stewardly-guidance"
              voice={:stewardly_guidance}
            >
              <p>
                The Snail House stands available for the Return of Constitutioning Humans.
              </p>
              <p>Return Here upon any One Piece of Time to continue inquiringmenting.</p>
              <p>Sit.</p>
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
              <p class="psm-oag__reading">Bearinging toward Stewardly Co-Occupancyingship</p>
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
        </section>

        <section
          :if={@landing_inquired?}
          id="constitutional-furnishmenting-rail"
          class="field-page__furnishmenting-rail"
          aria-labelledby="constitutional-furnishmenting-rail-title"
        >
          <header
            id="station-depot-00-marker"
            class="field-page__station-header field-page__station-header--opening field-page__station-depot-marker"
            aria-labelledby="station-depot-00-title"
          >
            <p class="site-page__eyebrow">THE CHAPEL-ALONG-THE-SEA</p>
            <h3 id="station-depot-00-title">STATION DEPOT 00</h3>
          </header>

          <section
            id="chapel-by-the-sea"
            class="field-page__chapel-by-the-sea field-page__station-locality-marker"
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

          <button
            :if={!@station_00_unfolded?}
            id="unfold-station-00"
            type="button"
            class="field-page__action field-page__station-unfold-action"
            phx-click="unfold-station-00"
          >
            UN-FOLD Station Depot 00 Interior
          </button>

          <section
            :if={@station_00_unfolded?}
            id="rail-line-opening-ceremony"
            class="psm-oag field-page__station-regard field-page__station-regard--station-00 field-page__ceremonying-declaration field-page__station-interior--newly-unfolded"
            aria-labelledby="station-00-ceremonying-title"
            data-constitutional-furnishing="ceremonying-declaration"
          >
            <div class="psm-oag__instrument-plate">
              <p class="psm-oag__eyebrow">
                Ceremonying
              </p>
              <h2 id="station-00-ceremonying-title">The Taking Holdinging of This One Leashing</h2>
              <p class="psm-oag__reading">The Zeroeth Appointmenting</p>
            </div>
            <div class="psm-oag__description">
              <p>
                This Constitutioning Human now stands prepared to appoint This One Stewardly Captain COB through This Ceremonying of This One Leashing.
              </p>
              <p>
                Through This Ceremonying, This One Stewardly Captain COB may lawfully traverse alongside This Constitutioning Human through This One Situationing in Stewardly Regard.
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
              aria-labelledby="station-depot-00-title"
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

                <div class="field-page__ceremonial-divider" aria-hidden="true"></div>
                <h5 class="field-page__ceremony-recital-heading">
                  The Readyingmenting Recital of The General Stewarding Offices of This One Stewardshipmenting Appliance
                </h5>
                <p>
                  The General Stewarding Offices hereby stand in Readyingment for This Zeroeth Appointmenting through This Ceremonying of This One Leashing.
                </p>
                <p>
                  Through This Appointmenting, This Constitutioning Human and This Stewardly Captain COB shall thereafter stand in lawful Stewardly Relationing through This One Situationing over Discrete Turns.
                </p>
                <div class="field-page__ceremonial-divider" aria-hidden="true"></div>
                <div
                  id="station-00-constitutional-voices"
                  class="field-page__crew-statement field-page__constitutional-voices"
                >
                  <section
                    class="constitutional-voice constitutional-voice--appliance_narration"
                    aria-labelledby="appliance-narration-voice"
                  >
                    <h5 id="appliance-narration-voice">APPLIANCE NARRATIONING</h5>
                    <p>
                      This Constitutioning Human now stands choosing to appoint This One Stewardly Captain COB through This One Leashing.
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
                      Through This Ceremonying of This One Investituringment within The Seat of The Stewardly Co-Occupancyingship, This Constitutioning Human now stands lawfully accompanied by This One Stewardly Captain COB through This One Situationing.
                    </p>
                    <p>
                      This One Terrestrial Computer Free Parkinging Stand Number together with This One Shackling Pin now stand furnished in Regard to Their continuing Stewardly Relationing upon future One Pieces of Time.
                    </p>
                  </section>
                </div>
              </section>

              <section id="leashing-crew-conjunction" class="field-page__crew-conjunction">
                <p class="field-page__ceremony-crew-subtitle">
                  <strong>This One Terrestrial Computer Leashinging Crew</strong>
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
                      <div class="field-page__completion-statement field-page__standinging-marker">
                        <p>Together, These Relationings now stand as This One Leashing.</p>
                        <p>This One Leashing stands upon This One Constitutional Locality.</p>
                      </div>

                      <article
                        id="completed-turn-zero-sittinging-in-room"
                        class="field-page__sittinging-in-room"
                        data-constitutional-standing="enriched"
                        aria-labelledby="completed-turn-zero-sittinging-in-room-title"
                      >
                        <header class="field-page__sittinging-heading">
                          <h2 id="completed-turn-zero-sittinging-in-room-title">
                            The Sittinging-In Room
                          </h2>
                          <p class="field-page__sittinging-subtitle">
                            The Zeroeth Constitutional Locality of This One Tuple Ship
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
                          cabinet_id="station-00-secret-cabinet"
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
                          id="station-00-rail-wayfinding"
                          from="Encounteringmentablement"
                          toward="Distinguishingmenting"
                          from_label="Continuing From"
                          toward_label="Continuing Toward"
                        />
                        <.constitutional_voice
                          id="station-00-stewardly-guidance"
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
                  <section
                    id="leashing-stewardly-standing"
                    class="field-page__standinging-marker"
                  >
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
              id="rail-line-toward-station-01"
            >
              <div class="field-page__rail-line" aria-hidden="true"></div>

              <section id="station-01-opening" class="field-page__station-opening">
                <header
                  id="station-depot-01-marker"
                  class="field-page__station-header field-page__station-depot-marker"
                  aria-labelledby="station-depot-01-title"
                >
                  <p class="site-page__eyebrow">This One Some Place</p>
                  <h3 id="station-depot-01-title">STATION DEPOT 01</h3>
                </header>

                <section
                  class="psm-oag field-page__station-regard"
                  aria-labelledby="station-01-regard-title"
                >
                  <div class="psm-oag__instrument-plate">
                    <p class="psm-oag__eyebrow">
                      The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment
                    </p>
                    <h2 id="station-01-regard-title">Standinging in Regard</h2>
                    <p class="psm-oag__reading">Bearinging toward Embodyingmenting</p>
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
                  :if={!@station_01_unfolded?}
                  id="unfold-station-01"
                  type="button"
                  class="field-page__action field-page__station-unfold-action"
                  phx-click="unfold-station-01"
                >
                  UN-FOLD from Here toward The Zeroeth Appointmenting
                </button>
              </section>

              <article
                :if={@station_01_unfolded?}
                id="earthly-localities-station"
                class="field-page__station field-page__station-interior--newly-unfolded"
                aria-labelledby="station-depot-01-title"
              >
                <div id="station-01-stewardship-geometry" class="field-page__dual-stewardship">
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
                        id="station-01-arrowhead"
                        markerWidth="5"
                        markerHeight="5"
                        refX="4"
                        refY="2.5"
                        orient="auto"
                      >
                        <path d="M0,0 L5,2.5 L0,5 Z"></path>
                      </marker>
                    </defs>
                    <path d="M24 0 L50 25" marker-end="url(#station-01-arrowhead)"></path>
                    <path d="M76 0 L50 25" marker-end="url(#station-01-arrowhead)"></path>
                    <path d="M50 25 L50 48" marker-end="url(#station-01-arrowhead)"></path>
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
                    class="field-page__standinging-marker"
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

                    <div class="field-page__station-01-choices">
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
                          id="station-01-turn-zero-surfacing"
                          class="field-page__operational-surface field-page__station-01-turn-zero-surfacing"
                          aria-labelledby="station-01-turn-zero-surfacing-title"
                        >
                          <h5 id="station-01-turn-zero-surfacing-title">TURN ZERO SURFACING</h5>
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
                            This Turn Zero Surfacing stands proving lawful XT–YT Interrelationings.<br />Nothing has yet been furnished.
                          </p>
                          <p :if={@earthly_locality_history != []}>
                            The Turn Zero Surfacing stages lawful XT–YT Interrelationings without altering the presently furnished Constitutional Locality.
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

                        <div class="field-page__station-01-actions">
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
                      class="field-page__operational-surface"
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
                    :if={@station_01_completed?}
                    id="station-01-completion"
                    class="field-page__station-completion"
                  >
                    <p :if={@station_01_decision == :completed}>
                      This One Lanterning Bug Assemblementing now stands Visionizinging through Relationing to This One Some Place upon The Earth within This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
                    </p>
                    <p>
                      This One Lanterning now stands establishing This Stewardly Captain COB's current lawful Place of Encounteringmentablement.
                    </p>
                  </div>

                  <.leashing_locality
                    :if={@station_01_completed?}
                    id="station-01-enriched-leashing"
                    cabinet_id="station-01-secret-cabinet"
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
                :if={@station_01_completed?}
                id="tuple-field-terminus-harbor"
                class="psm-oag field-page__terminus-harbor"
                aria-labelledby="tuple-field-terminus-harbor-title"
              >
                <div class="psm-oag__instrument-plate">
                  <p class="psm-oag__eyebrow">
                    The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment
                  </p>
                  <h2 id="tuple-field-terminus-harbor-title">Standinging in Regard</h2>
                  <p class="psm-oag__reading">Bearinging toward Continuingmenting</p>
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

              <div :if={@station_01_completed?} class="field-page__refold-standing">
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
          :if={@station_01_completed?}
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
              Bearinging toward Discoveringmenting through Stewardly Interrelationing
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
          :if={@station_01_completed?}
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
      {"TZ", "The Turn-Zeroeth Appointmenting", "WHAT I MAY BE CALLING THIS COB"},
      {"00", "The Zeroeth Appointmenting", "This One Situationing"},
      {"01", "The First Appointmenting", "Encounteringmentablement"},
      {"02", "The Second Appointmenting", "Distinguishingmenting"},
      {"03", "The Third Appointmenting", "Roomingmentingableroomingablement"},
      {"04", "The Fourth Appointmenting", "This One Purchase Surface"},
      {"05", "The Fifth Appointmenting", "Excursioningmenting"},
      {"06", "The Sixth Appointmenting", "Embroideringmentingenablementingedably"}
    ]
  end

  defp sittinging_affordmentings do
    [
      {"06", "The Sixth Affordmenting", "The Ability to Embroiderize"},
      {"05", "The Fifth Affordmenting", "The Ability to Excursion"},
      {"04", "The Fourth Affordmenting", "The Ability to Gain Purchase"},
      {"03", "The Third Affordmenting", "The Ability to Make Room"},
      {"02", "The Second Affordmenting", "The Ability to Distinguish"},
      {"01", "The First Affordmenting", "The Ability to Encounter"},
      {"00", "The Zeroeth Affordmenting", "The Ability to Regard"},
      {"TZ", "The Turn-Zeroeth Affordmenting", "WHAT THIS COB MAY BE CALLING ME"}
    ]
  end

  defp turn_zero_active_interrelationing_title(:cob_calls_human),
    do: "WHAT THIS COB MAY BE CALLING ME"

  defp turn_zero_active_interrelationing_title(:human_calls_cob),
    do: "WHAT I MAY BE CALLING THIS COB"

  defp turn_zero_active_interrelationing_title(:turn_zero_for),
    do: "THIS ONE THING THAT IS WHAT IS THE MATTERING"

  defp turn_zero_active_interrelationing_title(_active_interrelationing),
    do: "No Interrelationing Presently Stands under Active Regard"

  defp turn_zero_staging_result_title(:turn_zero_for), do: "THIS CROSS-SEAM FOR"
  defp turn_zero_staging_result_title(_active_interrelationing), do: "THIS XT–YT RELATIONING"

  defp turn_zero_coordinate(:xt_first, :first), do: "XT"
  defp turn_zero_coordinate(:xt_first, :second), do: "YT"
  defp turn_zero_coordinate(:xt_second, :first), do: "YT"
  defp turn_zero_coordinate(:xt_second, :second), do: "XT"

  defp turn_zero_projection_arrow(:xt_first), do: "XT → YT"
  defp turn_zero_projection_arrow(:xt_second), do: "YT ← XT"

  defp turn_zero_name_greeting(name) do
    case String.trim(name) do
      "" -> "My Stewarding Officer"
      staged_name -> "#{staged_name}, My Stewarding Officer"
    end
  end

  defp turn_zero_cob_calling(name) do
    case String.trim(name) do
      "" -> "No calling presently stands staged."
      staged_name -> "You may be calling me #{staged_name}."
    end
  end

  defp turn_zero_staged_xt(
         :cob_calls_human,
         _human_name,
         _cob_name,
         human_constitutional_xt,
         _cob_constitutional_xt
       ),
       do: human_constitutional_xt

  defp turn_zero_staged_xt(
         :human_calls_cob,
         _human_name,
         _cob_name,
         _human_constitutional_xt,
         cob_constitutional_xt
       ),
       do: cob_constitutional_xt

  defp turn_zero_staged_yt(:cob_calls_human, human_name, _cob_name),
    do: staged_turn_zero_name(human_name)

  defp turn_zero_staged_yt(:human_calls_cob, _human_name, cob_name),
    do: staged_turn_zero_name(cob_name)

  defp turn_zero_conversational_projection(:cob_calls_human, human_name, _cob_name),
    do: turn_zero_name_greeting(human_name)

  defp turn_zero_conversational_projection(:human_calls_cob, _human_name, cob_name),
    do: turn_zero_cob_calling(cob_name)

  defp turn_zero_staging_empty?(
         :cob_calls_human,
         human_name,
         _cob_name,
         _choice,
         _standing
       ),
       do: String.trim(human_name) == ""

  defp turn_zero_staging_empty?(
         :human_calls_cob,
         _human_name,
         cob_name,
         choice,
         standing
       ),
       do: String.trim(cob_name) == "" or (is_nil(choice) and is_nil(standing))

  defp turn_zero_staging_empty?(_active, _human_name, _cob_name, _choice, _standing),
    do: true

  defp standing_name(nil), do: ""
  defp standing_name(standing), do: standing.yt

  defp turn_zero_mattering(nil), do: ""
  defp turn_zero_mattering(standing), do: standing.one_thing

  defp turn_zero_interaction_available?(socket, interaction) do
    socket.assigns.available_turn_zero_interaction in [interaction, :complete]
  end

  defp next_turn_zero_interaction(:cob_calls_human, :cob_calls_human), do: :turn_zero_for
  defp next_turn_zero_interaction(:turn_zero_for, :turn_zero_for), do: :human_calls_cob
  defp next_turn_zero_interaction(:human_calls_cob, :human_calls_cob), do: :complete

  defp next_turn_zero_interaction(current_interaction, _completed_interaction),
    do: current_interaction

  defp clear_turn_zero_surfacing(socket) do
    assign(socket,
      active_turn_zero_interrelationing: nil,
      turn_zero_surfacing_unfolded?: false,
      staged_constitutioning_human_name: "",
      staged_stewardly_captain_name: socket.assigns.stewardly_captain_furnished_name,
      staged_turn_zero_mattering: "",
      turn_zero_human_name_form: to_form(%{"name" => ""}, as: :turn_zero_human_name),
      turn_zero_cob_name_form:
        to_form(
          %{"name" => socket.assigns.stewardly_captain_furnished_name},
          as: :turn_zero_cob_name
        ),
      turn_zero_mattering_form: to_form(%{"mattering" => ""}, as: :turn_zero_mattering),
      turn_zero_cob_naming_choice: nil,
      turn_zero_projection: :xt_first
    )
  end

  defp staged_turn_zero_name(name) do
    case String.trim(name) do
      "" -> "No name presently stands staged."
      staged_name -> staged_name
    end
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

  defp maybe_complete_station_01(socket) do
    completed? =
      socket.assigns.station_01_decision in [:completed, :declined] and
        MapSet.member?(socket.assigns.proto_appointmentings, :lanterning)

    assign(socket, :station_01_completed?, completed?)
  end
end
