defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  alias PublicSituationMachineTurnZero.ParkingingStandRegistry

  @stages [
    :harbor,
    :snail_house,
    :sittinging_folded,
    :sittinging_unfolded,
    :division,
    :investiturement,
    :parkinging,
    :position_zero,
    :position_one,
    :position_two
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "This Tuple Ship Field",
       rail_stage: :harbor,
       parkinging_stand: nil,
       shackling_pin: nil,
       ceremony_time: nil,
       first_appointmenting:
         to_form(%{"subject" => "", "situationing_kind" => ""}, as: :first_appointmenting)
     )}
  end

  @impl true
  def handle_event("continue-rail", %{"to" => destination}, socket) do
    destination = Enum.find(@stages, &(Atom.to_string(&1) == destination))

    if lawful_next_stage?(socket.assigns.rail_stage, destination) do
      {:noreply, assign(socket, :rail_stage, destination)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("re-fold-sittinging-room", _params, socket) do
    if socket.assigns.rail_stage == :sittinging_unfolded do
      {:noreply, assign(socket, :rail_stage, :snail_house)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("park-terrestrial-computer", _params, socket) do
    if socket.assigns.rail_stage == :parkinging do
      ceremony_time = DateTime.utc_now() |> DateTime.truncate(:second)
      shackling_pin = shackling_pin()
      leashing = ParkingingStandRegistry.furnish_leashing(shackling_pin, ceremony_time)

      {:noreply,
       assign(socket,
         rail_stage: :position_zero,
         parkinging_stand: leashing.parkinging_stand,
         shackling_pin: leashing.shackling_pin,
         ceremony_time: leashing.ceremony_time
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event(
        "complete-first-appointmenting",
        %{
          "first_appointmenting" => %{
            "subject" => subject,
            "situationing_kind" => situationing_kind
          }
        },
        socket
      ) do
    subject = String.trim(subject)
    situationing_kind = String.trim(situationing_kind)

    if socket.assigns.rail_stage == :position_one and subject != "" and situationing_kind != "" do
      {:noreply,
       assign(socket,
         rail_stage: :position_two,
         first_appointmenting:
           to_form(
             %{"subject" => subject, "situationing_kind" => situationing_kind},
             as: :first_appointmenting
           )
       )}
    else
      {:noreply,
       assign(
         socket,
         :first_appointmenting,
         to_form(
           %{"subject" => subject, "situationing_kind" => situationing_kind},
           as: :first_appointmenting
         )
       )}
    end
  end

  def handle_event("complete-first-appointmenting", _params, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:tuple_ship_field}>
      <main id="tuple-ship-field-page" class="site-page field-page constitutional-rail">
        <header class="psm-masthead">
          <p class="psm-masthead__machine-name">PUBLIC-SITUATION-MACHINE-</p>
          <div class="psm-masthead__lower">
            <h1>This Tuple Ship Field</h1>
            <p>General Purpose Situationing Appliance</p>
          </div>
        </header>
        <section
          class="psm-oag constitutional-rail__gauge-marker"
          aria-labelledby="rail-standing-in-regard"
        >
          <div class="psm-oag__instrument-plate">
            <p class="psm-oag__eyebrow">Existing constitutional orientationing</p>
            <h2 id="rail-standing-in-regard">Standinging in Regard</h2>
            <p class="psm-oag__reading">The Bearinging of Lawful Encounteringmenting</p>
          </div>
          <p class="psm-oag__description">
            Oscillationing Airiness Gauge furnishing is reserved for a subsequent build round.
          </p>
        </section>
        <section
          id="harbor-sign"
          class="constitutional-rail__harbor"
          aria-labelledby="harbor-sign-title"
        >
          <p class="site-page__eyebrow">Harbor Sign · Constitutional Approach</p>
          <h1 id="harbor-sign-title">The Constitutional Furnishmenting Rail Line</h1>
          <p class="constitutional-rail__bearing">The Bearinging of Lawful Encounteringmenting</p>
          <p>
            This Sign stands at the Harbor so that every approaching Constitutioning Human may know where lawful Furnishmenting begins and in which direction it unfolds.
          </p>
          <p class="constitutional-rail__guidance">
            Stewardly Guidance: proceed first to the Resonancing Snail House Entrance. No Station precedes that Entrance.
          </p>
          <button
            :if={@rail_stage == :harbor}
            id="enter-resonancing-snail-house"
            type="button"
            class="field-page__action"
            phx-click="continue-rail"
            phx-value-to="snail_house"
          >
            Proceed to the Resonancing Snail House
          </button>
        </section>

        <section
          :if={reached?(@rail_stage, :snail_house)}
          id="resonancing-snail-house-entrance"
          class="constitutional-rail__placement"
          aria-labelledby="resonancing-snail-house-title"
        >
          <.placement_header
            ordinal="Entrance"
            title="Resonancing Snail House Entrance"
            locality="The first destination after the Harbor Sign"
            bearing="The Bearinging of Approaching Restfullyinglyment"
          />
          <p>
            The Snail House receives the arriving pace and carries it inward without haste. Its doorway inherits the Harbor Sign's direction and gives that direction to the first constitutional locality.
          </p>
          <p class="constitutional-rail__guidance">
            Stewardly Guidance: approach the Sittinging-In Room. Entry into the Room is not presumed; it is expressly furnished through UN-FOLD.
          </p>
          <button
            :if={@rail_stage == :snail_house}
            id="approach-sittinging-in-room"
            type="button"
            class="field-page__action"
            phx-click="continue-rail"
            phx-value-to="sittinging_folded"
          >
            Approach the Sittinging-In Room
          </button>
        </section>

        <section
          :if={reached?(@rail_stage, :sittinging_folded)}
          id="sittinging-in-room"
          class="constitutional-rail__placement constitutional-rail__placement--room"
          aria-labelledby="sittinging-in-room-title"
        >
          <.placement_header
            ordinal="First Constitutional Locality"
            title="The Sittinging-In Room"
            locality="Within the Resonancing Snail House"
            bearing="The Bearinging of Restfullyinglyment"
          />
          <p>
            This Room is the first constitutional locality: a bounded place for arriving, resting, and becoming available for Constitutioning before any Division, Investiturement, Parking, or Appointmenting.
          </p>
          <p class="constitutional-rail__guidance">
            Stewardly Guidance: enter through UN-FOLD. Leave through RE-FOLD. What has been received here remains available when the Rail Line unfolds onward.
          </p>
          <div class="constitutional-rail__actions">
            <button
              :if={@rail_stage == :sittinging_folded}
              id="un-fold-sittinging-in-room"
              type="button"
              class="field-page__action"
              phx-click="continue-rail"
              phx-value-to="sittinging_unfolded"
            >
              UN-FOLD
            </button>
            <button
              :if={@rail_stage == :sittinging_unfolded}
              id="re-fold-sittinging-in-room"
              type="button"
              class="field-page__action field-page__action--quiet"
              phx-click="re-fold-sittinging-room"
            >
              RE-FOLD
            </button>
          </div>
          <div
            :if={reached?(@rail_stage, :sittinging_unfolded)}
            id="sittinging-in-room-unfolded"
            class="constitutional-rail__inheritance"
          >
            <strong>Unfolded inheritance</strong>
            <p>
              Restfullyinglyment now accompanies this Constitutioning Human into the Division that follows.
            </p>
            <button
              :if={@rail_stage == :sittinging_unfolded}
              id="continue-to-division"
              type="button"
              class="field-page__action"
              phx-click="continue-rail"
              phx-value-to="division"
            >
              Continue to the Division of Constitutioning Humans
            </button>
          </div>
        </section>

        <section
          :if={reached?(@rail_stage, :division)}
          id="division-of-constitutioning-humans"
          class="constitutional-rail__placement"
          aria-labelledby="division-of-constitutioning-humans-title"
        >
          <.placement_header
            ordinal="Constitutioning Division"
            title="Division of Constitutioning Humans"
            locality="Immediately following the Sittinging-In Room"
            bearing="The Bearinging of Lawful Human Constitutioning"
          />
          <p>
            The Division receives a rested Constitutioning Human and distinguishes the Human's stewardly participation from the Terrestrial Computer that will later be parked.
          </p>
          <p class="constitutional-rail__guidance">
            Stewardly Guidance: continue as a Constitutioning Human toward Investiturement. Parking is not yet available.
          </p>
          <button
            :if={@rail_stage == :division}
            id="continue-to-investiturement"
            type="button"
            class="field-page__action"
            phx-click="continue-rail"
            phx-value-to="investiturement"
          >
            Enter the Investiturement
          </button>
        </section>

        <section
          :if={reached?(@rail_stage, :investiturement)}
          id="stewardly-co-occupancyingship-investiturement"
          class="constitutional-rail__placement constitutional-rail__placement--ceremony"
          aria-labelledby="investiturement-title"
        >
          <.placement_header
            ordinal="Constitutional Ceremony"
            title="Investiturement into the Seat of Stewardly Co-Occupancyingship"
            locality="Between the Division and the Parking-ing Standing-ing Landinging"
            bearing="The Bearinging of Stewardly Co-Occupancyingship"
          />
          <p>
            The Constitutioning Human and This Stewardly Captain COB are received into one stewardly Relationing. The Seat is established before any Terrestrial Computer is parked within it.
          </p>
          <p class="constitutional-rail__guidance">
            Stewardly Guidance: accept co-occupancyingship, then carry this invested Relationing to the Parking-ing Standing-ing Landinging.
          </p>
          <button
            :if={@rail_stage == :investiturement}
            id="accept-stewardly-investiturement"
            type="button"
            class="field-page__action"
            phx-click="continue-rail"
            phx-value-to="parkinging"
          >
            Accept Investiturement and Continue
          </button>
        </section>

        <section
          :if={reached?(@rail_stage, :parkinging)}
          id="parkinging-standinging-landinging"
          class="constitutional-rail__placement"
          aria-labelledby="parkinging-standinging-landinging-title"
        >
          <.placement_header
            ordinal="Landinging"
            title="Parking-ing Standing-ing Landinging"
            locality="Following Investiturement and preceding Position Zero"
            bearing="The Bearinging of Terrestrial Computer Standing"
          />
          <p>
            The invested stewardly Relationing now furnishes one lawful place in which to park this Terrestrial Computer. Parking follows Investiturement and carries its co-occupancyingship forward.
          </p>
          <p class="constitutional-rail__guidance">
            Stewardly Guidance: park this Terrestrial Computer to receive the Parking-ing Stand and Shackling Pin that will accompany the Zeroeth Appointmenting.
          </p>
          <button
            :if={@rail_stage == :parkinging}
            id="park-terrestrial-computer"
            type="button"
            class="field-page__action"
            phx-click="park-terrestrial-computer"
          >
            Park This Terrestrial Computer
          </button>
          <dl
            :if={@parkinging_stand}
            id="parkinging-furnishings"
            class="constitutional-rail__furnishings"
          >
            <div>
              <dt>Parking-ing Stand</dt><dd id="parkinging-stand">{@parkinging_stand}</dd>
            </div>
            <div>
              <dt>Shackling Pin</dt><dd id="shackling-pin">{@shackling_pin}</dd>
            </div>
            <div>
              <dt>Piece of Time</dt><dd>{format_piece_of_time(@ceremony_time)}</dd>
            </div>
          </dl>
        </section>

        <section
          :if={reached?(@rail_stage, :position_zero)}
          id="position-zero-traversaling-station"
          class="constitutional-rail__placement constitutional-rail__placement--station"
          aria-labelledby="position-zero-title"
        >
          <.placement_header
            ordinal="Position Zero · Zeroeth Appointmenting"
            title="Position Zero Traversaling Station"
            locality="The first Traversaling Station after Parking"
            bearing="Along the Seat of Stewardly Co-Occupancyingship"
          />
          <p>
            The Zeroeth Appointmenting establishes the Seat of Stewardly Co-Occupancyingship as this Rail Line's first Standing. Constitutioning Human, Stewardly Captain COB, and parked Terrestrial Computer now stand lawfully Along together.
          </p>
          <p class="constitutional-rail__guidance">
            Stewardly Guidance: carry this Seat intact into the First Appointmenting.
          </p>
          <button
            :if={@rail_stage == :position_zero}
            id="complete-zeroeth-appointmenting"
            type="button"
            class="field-page__action"
            phx-click="continue-rail"
            phx-value-to="position_one"
          >
            Establish the Seat
          </button>
        </section>

        <section
          :if={reached?(@rail_stage, :position_one)}
          id="position-one-traversaling-station"
          class="constitutional-rail__placement constitutional-rail__placement--station"
          aria-labelledby="position-one-title"
        >
          <.placement_header
            ordinal="Position One · First Appointmenting"
            title="Position One Traversaling Station"
            locality="Along from Position Zero"
            bearing="Along"
          />
          <p>
            The First Appointmenting establishes who or what is being situationed, the kind of Situationing, and their lawful direction Along the Rail Line.
          </p>
          <.form
            :if={@rail_stage == :position_one}
            for={@first_appointmenting}
            id="first-appointmenting-form"
            phx-submit="complete-first-appointmenting"
          >
            <.input
              field={@first_appointmenting[:subject]}
              type="text"
              label="This One Someone or This One Something"
              required
            />
            <.input
              field={@first_appointmenting[:situationing_kind]}
              type="text"
              label="The kind of Situationing"
              required
            />
            <p class="constitutional-rail__fixed-affordment">
              <strong>Traversaling bearing:</strong> Along
            </p>
            <button id="complete-first-appointmenting" type="submit" class="field-page__action">
              Establish the First Appointmenting
            </button>
          </.form>
          <div
            :if={@rail_stage == :position_two}
            id="first-appointmenting-inheritance"
            class="constitutional-rail__inheritance"
          >
            <p>
              <strong>This One Someone or This One Something:</strong> {@first_appointmenting[
                :subject
              ].value}
            </p>
            <p>
              <strong>The kind of Situationing:</strong> {@first_appointmenting[:situationing_kind].value}
            </p>
            <p><strong>Bearing:</strong> Along</p>
          </div>
        </section>

        <section
          :if={reached?(@rail_stage, :position_two)}
          id="position-two-soundinging-bell-station"
          class="constitutional-rail__placement constitutional-rail__placement--station constitutional-rail__placement--terminus"
          aria-labelledby="position-two-title"
        >
          <.placement_header
            ordinal="Position Two · Second Appointmenting"
            title="Sounding-ing Bell Station / Across"
            locality="Across the Along inherited from Position One"
            bearing="Across"
          />
          <p>
            The Second Appointmenting establishes Across: a Projectioning Cross through which Position One may be regarded without leaving its Along.
          </p>
          <div
            id="projectioning-cross"
            class="constitutional-rail__cross"
            role="img"
            aria-label="Projectioning Cross, Along and Across"
          >
            <span class="constitutional-rail__cross-along">Along</span>
            <span class="constitutional-rail__cross-across">Across</span>
          </div>
          <section id="three-traversaling-shoes" aria-labelledby="three-traversaling-shoes-title">
            <h3 id="three-traversaling-shoes-title">The Three Traversaling Shoes</h3>
            <div class="constitutional-rail__shoes">
              <article id="traversaling-shoe-before">
                <strong>Before Shoe</strong><p>Regards what was inherited into this crossing.</p>
              </article>
              <article id="traversaling-shoe-here">
                <strong>Here Shoe</strong><p>Stands at the present Sounding-ing Bell.</p>
              </article>
              <article id="traversaling-shoe-next">
                <strong>Next Shoe</strong><p>
                  Holds readiness without advancing beyond Position Two.
                </p>
              </article>
            </div>
          </section>
          <p class="constitutional-rail__guidance">
            Stewardly Guidance: sound Across while keeping Along inherited. This build round ends here.
          </p>
        </section>

        <aside
          :if={reached?(@rail_stage, :position_two)}
          id="subsequent-build-rounds"
          class="constitutional-rail__future"
          aria-labelledby="subsequent-build-rounds-title"
        >
          <p class="site-page__eyebrow">Explicit continuation markers · not implemented</p>
          <h2 id="subsequent-build-rounds-title">Subsequent Constitutional Furnishmenting</h2>
          <ul>
            <li id="re-stepping-room-placeholder">RE-Stepping Room — subsequent build round</li>
            <li id="observationing-mintinging-annex-placeholder">
              Observationing Mintinging Annex — subsequent build round
            </li>
            <li id="refolding-localities-placeholder">
              Refolding localities — subsequent build round
            </li>
            <li id="oscillationing-airiness-gauge-placeholder">
              Oscillationing Airiness Gauge — subsequent build round
            </li>
            <li id="turn-index-navigation-placeholder">
              Turn Index navigation — subsequent build round
            </li>
            <li id="correspondencing-placeholder">Correspondencing — subsequent build round</li>
            <li id="later-appointmentings-placeholder">
              Later Appointmentings — subsequent build round
            </li>
          </ul>
        </aside>
      </main>
    </Layouts.app>
    """
  end

  attr :ordinal, :string, required: true
  attr :title, :string, required: true
  attr :locality, :string, required: true
  attr :bearing, :string, required: true

  defp placement_header(assigns) do
    ~H"""
    <header class="constitutional-rail__placement-header">
      <p class="site-page__eyebrow">{@ordinal}</p>
      <h2 id={header_id(@title)}>{@title}</h2>
      <dl>
        <div>
          <dt>Constitutional locality</dt><dd>{@locality}</dd>
        </div>
        <div>
          <dt>Standinging under</dt><dd>{@bearing}</dd>
        </div>
      </dl>
    </header>
    """
  end

  defp reached?(current, expected) do
    stage_index(current) >= stage_index(expected)
  end

  defp lawful_next_stage?(current, destination) do
    stage_index(destination) == stage_index(current) + 1
  end

  defp stage_index(stage), do: Enum.find_index(@stages, &(&1 == stage)) || -1

  defp header_id(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, "-")
    |> String.trim("-")
    |> Kernel.<>("-title")
  end

  defp shackling_pin do
    :crypto.strong_rand_bytes(6)
    |> Base.url_encode64(padding: false)
    |> String.upcase()
  end

  defp format_piece_of_time(nil), do: ""

  defp format_piece_of_time(piece_of_time) do
    Calendar.strftime(piece_of_time, "%Y-%m-%d %H:%M:%S UTC")
  end
end
