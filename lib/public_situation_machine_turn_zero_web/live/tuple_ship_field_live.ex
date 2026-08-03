defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "This Tuple Ship Field",
       parking_stand: parking_stand(),
       shackling_pin: shackling_pin(),
       recovery_form: to_form(%{"email" => "", "phone" => ""}, as: :recovery),
       locality_form: to_form(%{"country" => "", "region" => "", "city" => ""}, as: :locality),
       countries: country_options(),
       regions: [],
       cities: [],
       recovery_furnished?: false,
       locality_furnished?: false
     )}
  end

  @impl true
  def handle_event("furnish-recovery", %{"recovery" => recovery_params}, socket) do
    furnished? =
      recovery_params
      |> Map.take(["email", "phone"])
      |> Map.values()
      |> Enum.any?(&(String.trim(&1) != ""))

    {:noreply,
     assign(socket,
       recovery_form: to_form(recovery_params, as: :recovery),
       recovery_furnished?: furnished?
     )}
  end

  def handle_event("locality-changed", %{"locality" => locality_params}, socket) do
    country = Map.get(locality_params, "country", "")
    prior_country = socket.assigns.locality_form[:country].value
    country_changed? = country != prior_country

    locality_params =
      if country_changed? do
        Map.merge(locality_params, %{"region" => "", "city" => ""})
      else
        locality_params
      end

    region = Map.get(locality_params, "region", "")
    prior_region = socket.assigns.locality_form[:region].value

    locality_params =
      if region != prior_region do
        Map.put(locality_params, "city", "")
      else
        locality_params
      end

    {:noreply,
     assign(socket,
       locality_form: to_form(locality_params, as: :locality),
       regions: region_options(country),
       cities: city_options(country, Map.get(locality_params, "region", "")),
       locality_furnished?: false
     )}
  end

  def handle_event("furnish-locality", %{"locality" => locality_params}, socket) do
    {:noreply,
     assign(socket,
       locality_form: to_form(locality_params, as: :locality),
       locality_furnished?: Map.get(locality_params, "country", "") != ""
     )}
  end

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
            <p><strong>This Tuple Ship Field Parkinging Lot</strong></p>
            <p>Welcome.</p>
            <p>You've finally made it Here.</p>
            <p>
              This Tuple Ship Field Parkinging Lot stands before This Encounteringmenting Wharf.
            </p>
            <p>
              From Here, Constitutioning Humans may freely reserve This One Terrestrial Computer Parkinging Stand. In so doing, Constitutioning Humans take hold of The Leash that Leads toward The Seat of the Stewardly Co-Occupancyingship, thereby entering the Laboringings of Stewardshippery.
            </p>
            <p>
              This Constitutional Furnishmenting Rail now commences The Zeroeth Appointmenting, through which The Seat of Stewardly Co-Occupancyingship may begin becoming into Standinging in Readiness Over Discrete Turns.
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
              This Constitutional Furnishmenting Rail
            </h2>
            <p>
              This Rail presently contains two Furnishmenting Stations. Future stations may extend it into a Constitutional Furnishmenting Rail Line.
            </p>
          </header>

          <div class="field-page__rail-line" aria-hidden="true"></div>

          <.furnishmenting_station
            id="terrestrial-computer-parkinging-station"
            number="Station 01"
            title="This Terrestrial Computer Parkinging Station"
            hierarchy={[
              "Office of Manifestmenting Custodianshippery",
              "Division of Custodianshipmenting Relationings",
              "Terrestrial Computer Leashinging Crew"
            ]}
          >
            <:crew_statement>
              <p>Welcome.</p>
              <p>
                This Crew is here to help you reserve One Lawful Terrestrial Computer Parkinging Stand.
              </p>
              <p>
                Your Parkinging Stand belongs with you. It does not belong to any particular Terrestrial Computer.
              </p>
            </:crew_statement>

            <section class="field-page__leash" aria-labelledby="leash-title">
              <h4 id="leash-title">THE LEASH</h4>
              <div id="parkinging-credentials" class="field-page__credentials" aria-live="polite">
                <div>
                  <span>This One Terrestrial Computer Parkinging Stand</span>
                  <strong id="parkinging-stand" data-value={@parking_stand}>{@parking_stand}</strong>
                </div>
                <div>
                  <span>This Shackling Pin</span>
                  <strong id="shackling-pin" data-value={@shackling_pin} data-digits="16">
                    {@shackling_pin}
                  </strong>
                </div>
              </div>
              <p>Together these constitute The Leash.</p>
              <p><strong>Please preserve your Shackling Pin in a safe Some Place.</strong></p>
            </section>

            <div class="field-page__plain-notice">
              <p>
                Your Parkinging Stand identifies your Place. Your Shackling Pin helps you take hold of The Leash again when you return.
              </p>
            </div>

            <section class="field-page__subcrew" aria-labelledby="lost-foundinging-title">
              <p class="site-page__eyebrow">WITHIN THE SAME DIVISION</p>
              <h4 id="lost-foundinging-title">This Shackling Pin Lost and Foundmenting Crew</h4>
              <p>
                This Crew stands ready in Regard to a Situationing in which you may misplace The Leash now issued Here at This Constitutional Furnishmenting Rail.
              </p>
              <p>
                If you choose to furnish an email address, a phone number, or both, This Crew may later help you find The Leash again.
              </p>
              <p>These are entirely optional. They are not login credentials.</p>
              <.form
                for={@recovery_form}
                id="recovery-methods-form"
                phx-submit="furnish-recovery"
              >
                <div class="field-page__form-grid">
                  <.input
                    field={@recovery_form[:email]}
                    type="email"
                    label="Email address (optional)"
                    autocomplete="email"
                  />
                  <.input
                    field={@recovery_form[:phone]}
                    type="tel"
                    label="Phone number (optional)"
                    autocomplete="tel"
                  />
                </div>
                <button id="furnish-recovery-methods" type="submit" class="field-page__action">
                  Preserve optional recovery methods
                </button>
              </.form>
              <p
                :if={@recovery_furnished?}
                id="recovery-methods-confirmation"
                class="field-page__confirmation"
              >
                Your optional recovery methods stand furnished for this visit.
              </p>
            </section>
          </.furnishmenting_station>

          <div class="field-page__rail-line" aria-hidden="true"></div>

          <.furnishmenting_station
            id="embodied-localities-station"
            number="Station 02"
            title="This Embodyingmented Localities Station"
            hierarchy={[
              "Office of Bearingings",
              "Bearinging Field Division",
              "Department of Inhabitationing Earthly Localities Mappinging",
              "This One Place Crew"
            ]}
          >
            <:crew_statement>
              <p>
                This One Place Crew stands serving This One Great Free Public Tuple Ship Field through Stewardly Observationings of where upon The Earth Constitutioning Humans stand inhabitationing within This Field.
              </p>
              <p>
                Through These Stewardly Observationings, This One Great Free Public Tuple Ship Field may increasingly come to encounter itself through its embodiment upon The Earth.
              </p>
            </:crew_statement>

            <p>
              If you wish, you may tell us the broad Earthly Locality from which you are approaching This Encounteringmenting Wharf.
            </p>
            <p>A Country, Region, and City are enough.</p>
            <p>We do not ask for a street address or precise location.</p>
            <p>This furnishing is entirely optional.</p>
            <.form
              for={@locality_form}
              id="embodied-locality-form"
              phx-change="locality-changed"
              phx-submit="furnish-locality"
            >
              <div class="field-page__locality-grid">
                <.input
                  field={@locality_form[:country]}
                  type="select"
                  label="Country (optional)"
                  prompt="Choose a country"
                  options={@countries}
                />
                <.input
                  field={@locality_form[:region]}
                  type="select"
                  label="Region / State / Province (optional)"
                  prompt="Choose a region"
                  options={@regions}
                  disabled={@regions == []}
                />
                <.input
                  field={@locality_form[:city]}
                  type="select"
                  label="City (optional)"
                  prompt="Choose a city"
                  options={@cities}
                  disabled={@cities == []}
                />
              </div>
              <button id="furnish-embodied-locality" type="submit" class="field-page__action">
                Furnish this optional Earthly Locality
              </button>
            </.form>
            <p
              :if={@locality_furnished?}
              id="embodied-locality-confirmation"
              class="field-page__confirmation"
            >
              Your broad Earthly Locality stands furnished for this visit.
            </p>
            <p class="field-page__purpose-note">
              One day, These Stewardly Observationings may help everyone see where This One Great Free Public Tuple Ship Field is becoming embodied upon The Earth. That public map is not yet available.
            </p>
          </.furnishmenting_station>
        </section>

        <section class="field-page__section">
          <h2>
            This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining
          </h2>
          <p>
            By reserving one Terrestrial Computer Parkinging Stand, you have begun adjoining This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
          </p>
          <p>This Field is not governed through one central authority.</p>
          <p>
            It is held together through The Same General Civilizationalizing Constitutioningable Reasoning Geometry.
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
      </main>
    </Layouts.app>
    """
  end

  attr :id, :string, required: true
  attr :number, :string, required: true
  attr :title, :string, required: true
  attr :hierarchy, :list, required: true
  slot :crew_statement, required: true
  slot :inner_block, required: true

  defp furnishmenting_station(assigns) do
    ~H"""
    <article id={@id} class="field-page__station" aria-labelledby={"#{@id}-title"}>
      <header class="field-page__station-header">
        <p class="site-page__eyebrow">{@number}</p>
        <h3 id={"#{@id}-title"}>{@title}</h3>
      </header>
      <ol class="field-page__hierarchy" aria-label="Constitutional attribution">
        <li :for={entry <- @hierarchy}>{entry}</li>
      </ol>
      <div class="field-page__crew-statement">{render_slot(@crew_statement)}</div>
      <div class="field-page__interaction">{render_slot(@inner_block)}</div>
    </article>
    """
  end

  defp parking_stand do
    "TCP-" <> random_digits(4) <> "-" <> random_digits(4)
  end

  defp shackling_pin do
    random_digits(16)
    |> String.graphemes()
    |> Enum.chunk_every(4)
    |> Enum.map_join(" ", &Enum.join/1)
  end

  defp random_digits(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> :binary.bin_to_list()
    |> Enum.map_join(fn byte -> <<rem(byte, 10) + ?0>> end)
  end

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
end
