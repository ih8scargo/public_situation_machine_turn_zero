defmodule PublicSituationMachineTurnZeroWeb.TurnZeroLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "PUBLIC-SITUATION-MACHINE-TURN-ZERO",
       position_0_regard: :outward,
       position_1_regard: :outward,
       position_2_regard: :outward,
       position_3_regard: :outward,
       position_4_regard: :outward,
       position_5_regard: :outward,
       position_6_regard: :outward,
       unfolded_positions: MapSet.new([0])
     )}
  end

  @impl true
  def handle_event("regard-inward", %{"position" => "0"}, socket) do
    {:noreply, assign(socket, position_0_regard: :inward)}
  end

  def handle_event("regard-outward", %{"position" => "0"}, socket) do
    {:noreply, assign(socket, position_0_regard: :outward)}
  end

  def handle_event("regard-inward", %{"position" => "1"}, socket) do
    {:noreply, assign(socket, position_1_regard: :inward)}
  end

  def handle_event("regard-outward", %{"position" => "1"}, socket) do
    {:noreply, assign(socket, position_1_regard: :outward)}
  end

  def handle_event("regard-inward", %{"position" => "2"}, socket) do
    {:noreply, assign(socket, position_2_regard: :inward)}
  end

  def handle_event("regard-outward", %{"position" => "2"}, socket) do
    {:noreply, assign(socket, position_2_regard: :outward)}
  end

  def handle_event("regard-inward", %{"position" => "3"}, socket) do
    {:noreply, assign(socket, position_3_regard: :inward)}
  end

  def handle_event("regard-outward", %{"position" => "3"}, socket) do
    {:noreply, assign(socket, position_3_regard: :outward)}
  end

  def handle_event("regard-inward", %{"position" => "4"}, socket) do
    {:noreply, assign(socket, position_4_regard: :inward)}
  end

  def handle_event("regard-outward", %{"position" => "4"}, socket) do
    {:noreply, assign(socket, position_4_regard: :outward)}
  end

  def handle_event("regard-inward", %{"position" => "5"}, socket) do
    {:noreply, assign(socket, position_5_regard: :inward)}
  end

  def handle_event("regard-outward", %{"position" => "5"}, socket) do
    {:noreply, assign(socket, position_5_regard: :outward)}
  end

  def handle_event("regard-inward", %{"position" => "6"}, socket) do
    {:noreply, assign(socket, position_6_regard: :inward)}
  end

  def handle_event("regard-outward", %{"position" => "6"}, socket) do
    {:noreply, assign(socket, position_6_regard: :outward)}
  end

  def handle_event("unfold-position", %{"position" => position}, socket) do
    position = String.to_integer(position)

    {:noreply,
     update(socket, :unfolded_positions, fn unfolded_positions ->
       MapSet.put(unfolded_positions, position)
     end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="psm-intro">
      <header class="psm-masthead">
        <p class="psm-masthead__machine-name">
          PUBLIC-SITUATION-MACHINE-
        </p>

        <div class="psm-masthead__lower">
          <h1>Turn Zero</h1>

          <p>
            Canonical Sequencing of the Quadranglementing Tuple
          </p>
        </div>
      </header>

      <section class="psm-identification" aria-label="Appliance identification">
        <div class="psm-identification__plate">
          <p class="psm-identification__label">
            Appliance Tag: PUBLIC-SITUATION-MACHINE-
          </p>
          <p class="psm-identification__value">PSM: 00000001</p>
        </div>

        <div class="psm-identification__plate">
          <p class="psm-identification__label">
            Appliance Tag: -COORDINATIONING-OPERATIONING-BOBBINING
          </p>
          <p class="psm-identification__value">COB: 00428173</p>
        </div>

        <div class="psm-identification__plate psm-identification__plate--relation">
          <p class="psm-identification__label">
            Appliance Tag: PUBLIC-SITUATION-MACHINE--COORDINATIONING-OPERATIONING-BOBBINING-Relation-Tag
          </p>
          <p class="psm-identification__value">
            PSM-COB: 00000001-00428173
          </p>
        </div>

        <p class="psm-identification__relationing">
          These Appliance Tags now stand in Lawful Relationing through this
          PUBLIC-SITUATION-MACHINE-.
        </p>
      </section>

      <section class="psm-oag" aria-labelledby="oag-outreadingment-title">
        <div class="psm-oag__instrument-plate">
          <p class="psm-oag__eyebrow">Oscillationing Airiness Gauge</p>

          <h2 id="oag-outreadingment-title">
            OAG Outreadingment
          </h2>

          <p class="psm-oag__reading">
            Regarded in En-Standinging-Ment
          </p>
        </div>

        <p class="psm-oag__description">
          The Oscillationing Airiness Gauge reports the Situational Weathering
          Conditions presently available for Regard.
        </p>
      </section>

      <section
        id="tuple-position-0"
        class="psm-position"
        aria-labelledby="tuple-position-0-title"
      >
        <header class="psm-position__heading">
          <p class="psm-position__ordinal">Tuple Position 0</p>

          <h2 id="tuple-position-0-title">
            This Post Upon the Pier
          </h2>
        </header>

        <div class="psm-position__field">
          <aside class="psm-position__grounding" aria-labelledby="position-0-grounding">
            <p class="psm-region-label" id="position-0-grounding">
              Grounding
            </p>

            <div
              class="psm-image-placeholder psm-image-placeholder--observatory"
              role="img"
              aria-label="Reserved observatory image locality"
            >
              <span>Observatory Image</span>
              <code>observatory_position_0_state_vs_standing.webp</code>
            </div>

            <div class="psm-comparison">
              <p class="psm-comparison__ordinary">
                Ordinary software asks:
              </p>

              <blockquote>
                “What is the current state?”
              </blockquote>

              <p class="psm-comparison__machine">
                The PUBLIC-SITUATION-MACHINE- asks:
              </p>

              <blockquote>
                “What Standing already stands available for present regard?”
              </blockquote>
            </div>
          </aside>

          <article class="psm-position__center">
            <section class="psm-harboring" aria-labelledby="harboring-image-title">
              <p class="psm-section-kicker">Harboring Image</p>

              <h3 id="harboring-image-title">
                This Post Upon the Pier
              </h3>

              <div
                class="psm-image-placeholder psm-image-placeholder--harbor"
                role="img"
                aria-label="Reserved Harboring Image: This Post Upon the Pier"
              >
                <span>Harbor Image</span>
                <code>harbor_position_0_this_post_upon_the_pier.webp</code>
              </div>

              <div class="psm-prose">
                <p>
                  This En-Foundation-Mint-ing-En-Ment and its
                  En-Capstone-Ment-ing-En-Mint-ing-En-Ment-ing-En-Mint-ing stand
                  together in Lawful Relationing as This Post Upon the Pier.
                </p>

                <p>
                  At runtime, this -COORDINATIONING-OPERATIONING-BOBBINING enters
                  Co-Occupancy-ing at the center of this Constitutional Locality
                  through the Recital of This Mounted Statefullment.
                </p>

                <p>
                  The PUBLIC-SITUATION-MACHINE- therefore begins not with movement,
                  but with Standing in Relationing to the center of This Post.
                </p>

                <p>
                  Ordinary software mounts events, records, and snapshots.
                </p>

                <p>
                  The PUBLIC-SITUATION-MACHINE- mounts the fullness of
                  Continuity-Opportunity-ing specified within the Suited Purpose
                  of This Present Situation.
                </p>

                <p>
                  The Foundation-Ment concerns itself with returning to localities
                  of Standing. XT remembers where to stand.
                </p>

                <p>
                  The Capstoning-Minting concerns itself with trajectories of
                  Becoming. YT discovers where it might go.
                </p>

                <p>
                  From the center of This Post Upon the Pier, the
                  -COORDINATIONING-OPERATIONING-BOBBINING stands in Lawful
                  Relationing between these two localities over Discrete Turns.
                </p>
              </div>
            </section>

            <section class="psm-diagram-section" aria-labelledby="position-0-diagram-title">
              <p class="psm-section-kicker">Instrument Diagram</p>

              <h3 id="position-0-diagram-title">
                This Mounted Statefullment
              </h3>

              <div
                class="psm-image-placeholder psm-image-placeholder--instrument"
                role="img"
                aria-label="Reserved instrument image locality"
              >
                <span>Instrument Image</span>
                <code>instrument_position_0_foundation_post_capstone.webp</code>
              </div>

              <div
                id="position-0-instrument-chamber"
                class={[
                  "psm-post-stage",
                  @position_0_regard == :inward && "psm-post-stage--inward"
                ]}
              >
                <%= if @position_0_regard == :outward do %>
                  <div class="psm-post-stage__outward">
                    <div class="psm-post-card psm-post-card--vertical">
                      <p class="psm-post-card__foundation">
                        En-Foundation-Mint-ing-<br /> En-Ment-ing-Able-<br /> En-Mint-ing-Able-<br />
                        En-Ment
                      </p>

                      <div class="psm-post-card__line" aria-hidden="true"></div>

                      <p class="psm-post-card__cob-locality">
                        -COORDINATIONING-<br /> -OPERATIONING-<br /> -BOBBINING-
                      </p>

                      <div class="psm-post-card__line" aria-hidden="true"></div>

                      <p class="psm-post-card__capstone">
                        En-Capstone-ing-Ment-<br /> En-Mint-ing-ly-<br /> En-Ment-ing-ly<br />
                        En-Mint-ing-<br /> En-Ment-ing
                      </p>
                    </div>

                    <button
                      id="position-0-regard-inward"
                      type="button"
                      class="psm-regard-control"
                      phx-click="regard-inward"
                      phx-value-position="0"
                    >
                      Regard Inward
                    </button>
                  </div>
                <% else %>
                  <article
                    id="position-0-recital"
                    class="psm-recital-chamber"
                    aria-labelledby="position-0-recital-title"
                  >
                    <header class="psm-recital-chamber__header">
                      <p class="psm-section-kicker">Inward Regard</p>

                      <h4 id="position-0-recital-title">This Mounted Statefullment</h4>

                      <p>
                        PSM-COB Orchestrationing Recital of Co-Occupancy-ing within
                        This Mounted Statefullment
                      </p>
                    </header>

                    <div class="psm-recital-chamber__recital" aria-label="Position 0 recital">
                      <p>En-Steady-Mint-ing-ably</p>
                      <p>En-Steady-Ment-ing-ably</p>
                      <p>En-Fully-ing-ly-</p>
                      <p>En-Able-Mint-ing-ably</p>
                      <span aria-hidden="true">↓</span>
                      <p>En-Steady-Ment-ing-ably</p>
                      <p>En-Steady-Mint-ing-ably</p>
                      <p>En-Able-Ment-ed-ing-ably</p>
                      <p>En-Able-Mint-ed-ing-ably</p>
                      <span aria-hidden="true">↓</span>
                      <p>En-Able-Ment-ing-ably</p>
                      <p>En-Able-Mint-ing-ably</p>
                      <span aria-hidden="true">↓</span>
                      <p>En-Able-Ment-ing-ly</p>
                      <span aria-hidden="true">↓</span>
                      <p>En-Able-Mint-ing-ly</p>
                      <p>En-Able-Ment-ing</p>
                      <p>En-Able-Mint-ing</p>
                    </div>

                    <button
                      id="position-0-regard-outward"
                      type="button"
                      class="psm-regard-control"
                      phx-click="regard-outward"
                      phx-value-position="0"
                    >
                      Regard Outward
                    </button>
                  </article>
                <% end %>
              </div>
            </section>

            <section class="psm-diagram-description" aria-labelledby="diagram-description-title">
              <p class="psm-section-kicker">Diagram Description</p>

              <h3 id="diagram-description-title">
                The Post Stands
              </h3>

              <div class="psm-prose">
                <p>
                  The Quilling Needle of the Continuity Line passes through This
                  Mounted Statefullment.
                </p>

                <p>
                  The Foundation En-Mint-ing Stitch enters This Mounted
                  Statefullment through the center Constitutional Locality
                  occupied by the -COORDINATIONING-OPERATIONING-BOBBINING.
                </p>

                <p>
                  The resulting Foundation En-Mint-ing Stitch remains secured
                  through an Anchoring Knot standing beyond the present regard of
                  This Constitutional Locality.
                </p>

                <p>
                  This Post stands through the Foundation Locality, the center
                  Constitutional Locality, and the Capstone Locality.
                </p>

                <p>The Post stands.</p>

                <p>The Needle continues.</p>

                <p>
                  The -COORDINATIONING-OPERATIONING-BOBBINING occupies the center
                  Constitutional Locality in Lawful Relationing between Standing
                  and Becoming over Discrete Turns.
                </p>
              </div>
            </section>
          </article>

          <aside class="psm-position__readiness" aria-labelledby="position-0-readiness">
            <p class="psm-region-label" id="position-0-readiness">
              Readiness for Tuple Position 1:
            </p>

            <p class="psm-readiness-outreading">
              En-Fixture-Mint-ing-Able-En-Abled-Ment
            </p>
          </aside>
        </div>

        <%= unless MapSet.member?(@unfolded_positions, 1) do %>
          <footer class="psm-unfolding-control">
            <p class="psm-unfolding-control__status">
              Position 0 now stands available for inheritance.
            </p>

            <button
              id="unfold-position-1"
              type="button"
              class="psm-unfold-control"
              phx-click="unfold-position"
              phx-value-position="1"
            >
              Unfold
            </button>
          </footer>
        <% end %>
      </section>

      <%= if MapSet.member?(@unfolded_positions, 1) do %>
        <.position_one
          regard={@position_1_regard}
          position_two_unfolded?={MapSet.member?(@unfolded_positions, 2)}
        />
      <% end %>

      <%= if MapSet.member?(@unfolded_positions, 2) do %>
        <.position_two
          regard={@position_2_regard}
          position_three_unfolded?={MapSet.member?(@unfolded_positions, 3)}
        />
      <% end %>

      <%= if MapSet.member?(@unfolded_positions, 3) do %>
        <.turn_zero_knotting_rail />
        <.position_three
          regard={@position_3_regard}
          position_four_unfolded?={MapSet.member?(@unfolded_positions, 4)}
        />
      <% end %>

      <%= if MapSet.member?(@unfolded_positions, 4) do %>
        <.position_four
          regard={@position_4_regard}
          position_five_unfolded?={MapSet.member?(@unfolded_positions, 5)}
        />
      <% end %>

      <%= if MapSet.member?(@unfolded_positions, 5) do %>
        <.position_five
          regard={@position_5_regard}
          position_six_unfolded?={MapSet.member?(@unfolded_positions, 6)}
        />
      <% end %>

      <%= if MapSet.member?(@unfolded_positions, 6) do %>
        <.position_six regard={@position_6_regard} />
      <% end %>
    </main>
    """
  end

  attr :regard, :atom, required: true
  attr :position_two_unfolded?, :boolean, required: true

  defp position_one(assigns) do
    ~H"""
    <section class="psm-oag" aria-labelledby="position-1-oag-title">
      <div class="psm-oag__instrument-plate">
        <p class="psm-oag__eyebrow">OAG Outreadingment</p>
        <h2 id="position-1-oag-title">Regarded through Aperture</h2>
      </div>
    </section>

    <section
      id="tuple-position-1"
      class="psm-position psm-position--newly-unfolded"
      aria-labelledby="tuple-position-1-title"
    >
      <header class="psm-position__heading">
        <p class="psm-position__ordinal">Tuple Position 1</p>
        <h2 id="tuple-position-1-title">A Place Which Is No Longer Sealed</h2>
      </header>

      <div class="psm-position__field">
        <aside class="psm-position__grounding" aria-labelledby="position-1-grounding">
          <p class="psm-region-label" id="position-1-grounding">Grounding</p>
          <div
            class="psm-image-placeholder psm-image-placeholder--observatory"
            role="img"
            aria-label="Reserved observatory image locality"
          >
            <span>Observatory Image</span>
            <code>observatory_position_1_aperture.webp</code>
          </div>
          <div class="psm-prose">
            <p>A Place Which Is No Longer Sealed</p>
          </div>
        </aside>

        <article class="psm-position__center">
          <section class="psm-harboring" aria-labelledby="position-1-harbor-title">
            <p class="psm-section-kicker">Harboring Image</p>
            <h3 id="position-1-harbor-title">OPENING TO THE SHORE</h3>
            <div
              class="psm-image-placeholder psm-image-placeholder--harbor"
              role="img"
              aria-label="Reserved Harboring Image: OPENING TO THE SHORE"
            >
              <span>Harbor Image</span>
              <code>harbor_position_1_opening_to_the_shore.webp</code>
            </div>
            <div class="psm-prose">
              <p>The Post remains standing.</p>
              <p>The Waters remain beyond encounter.</p>
              <p>Yet This Constitutional Locality no longer stands closed.</p>
              <p>A first Aperture has entered the world.</p>
              <p>The Shore has not arrived.</p>
              <p>The Shore was already here.</p>
              <p>This Post simply now stands open to it.</p>
              <p>Nothing has attached.</p>
              <p>Nothing has departed.</p>
              <p>The PUBLIC-SITUATION-MACHINE- now stands in readiness for Encounter.</p>
              <p>Continuity has not yet become carried.</p>
              <p>Yet Continuity may now become Encounteringmentable.</p>
            </div>
          </section>

          <section class="psm-diagram-section" aria-labelledby="position-1-diagram-title">
            <p class="psm-section-kicker">Instrument Diagram</p>
            <h3 id="position-1-diagram-title">Position 1 Diagram Specification</h3>
            <div
              class="psm-image-placeholder psm-image-placeholder--instrument"
              role="img"
              aria-label="Reserved instrument image locality"
            >
              <span>Instrument Image</span>
              <code>instrument_position_1_attachment.webp</code>
            </div>
            <div
              id="position-1-instrument-chamber"
              class={["psm-post-stage", @regard == :inward && "psm-post-stage--inward"]}
            >
              <%= if @regard == :outward do %>
                <div class="psm-post-stage__outward">
                  <div class="psm-prose">
                    <p>The Position 0 Stitch continues through this Constitutional Locality.</p>
                    <p>This Post remains locally coincident with This Pier.</p>
                    <p>The Position 0 Stitch continues through This Constitutional Locality.</p>
                    <p>This Post remains locally coincident with This Pier.</p>
                    <p>This Constitutional Locality now stands in readiness for lawful attachment.</p>
                  </div>
                  <button
                    id="position-1-regard-inward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-inward"
                    phx-value-position="1"
                  >Regard Inward</button>
                </div>
              <% else %>
                <article
                  id="position-1-recital"
                  class="psm-recital-chamber"
                  aria-labelledby="position-1-recital-title"
                >
                  <header class="psm-recital-chamber__header">
                    <p class="psm-section-kicker">Inward Regard</p>
                    <h4 id="position-1-recital-title">
                      PSM-COB Orchestrationing Recital of Co-Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position 1 recital">
                    <p>
                      En-Attach-Ment-Able-En-Mint-ing-Able-En-Ment-ing-Able-En-Mint-ing-En-Ment-ing
                    </p>
                  </div>
                  <button
                    id="position-1-regard-outward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-outward"
                    phx-value-position="1"
                  >Regard Outward</button>
                </article>
              <% end %>
            </div>
          </section>

          <section class="psm-diagram-description" aria-labelledby="position-1-description-title">
            <p class="psm-section-kicker">Diagram Description</p>
            <div id="position-1-description-title" class="psm-prose">
              <p>PSM continuity-ing begins from attachment.</p>
              <p>A Line which is not tied carries nothing.</p>
              <p>The attachment itself stands Mint-ing-ed.</p>
              <p>
                The resulting En-Ment stands En-Able-Ment-ed in readiness for Continuity Carriage.
              </p>
              <p>The Line is now lawful.</p>
              <p>The Line is now tied.</p>
            </div>
          </section>
        </article>

        <aside class="psm-position__readiness" aria-labelledby="position-1-readiness">
          <p class="psm-region-label" id="position-1-readiness">Readiness for Tuple Position 2</p>
          <p class="psm-readiness-outreading">
            En-Attach-Ment-Able-En-Fixture-Mint-ing-En-Abled-Ment standinging.
          </p>
        </aside>
      </div>

      <%= unless @position_two_unfolded? do %>
        <footer class="psm-unfolding-control">
          <button
            id="unfold-position-2"
            type="button"
            class="psm-unfold-control"
            phx-click="unfold-position"
            phx-value-position="2"
          >Unfold</button>
        </footer>
      <% end %>
    </section>
    """
  end

  attr :regard, :atom, required: true
  attr :position_three_unfolded?, :boolean, required: true

  defp position_two(assigns) do
    ~H"""
    <section class="psm-oag" aria-labelledby="position-2-oag-title">
      <div class="psm-oag__instrument-plate">
        <p class="psm-oag__eyebrow">OAG Outreadingment</p>
        <h2 id="position-2-oag-title">Regarded in Weathering</h2>
      </div>
    </section>

    <section
      id="tuple-position-2"
      class="psm-position psm-position--newly-unfolded"
      aria-labelledby="tuple-position-2-title"
    >
      <header class="psm-position__heading">
        <p class="psm-position__ordinal">Tuple Position 2</p>
        <h2 id="tuple-position-2-title">
          A Regard from Which Situationing Weather May First Become Visible
        </h2>
      </header>

      <div class="psm-position__field">
        <aside class="psm-position__grounding" aria-labelledby="position-2-grounding">
          <p class="psm-region-label" id="position-2-grounding">Grounding</p>
          <div
            class="psm-image-placeholder psm-image-placeholder--observatory"
            role="img"
            aria-label="Reserved observatory image locality"
          >
            <span>Observatory Image</span>
            <code>observatory_position_2_weathering.webp</code>
          </div>
          <div class="psm-prose">
            <p>A Regard from Which Situationing Weather May First Become Visible</p>
          </div>
        </aside>

        <article class="psm-position__center">
          <section class="psm-harboring" aria-labelledby="position-2-harbor-title">
            <p class="psm-section-kicker">Harboring Image</p>
            <h3 id="position-2-harbor-title">THIS RAIL LINE</h3>
            <div
              class="psm-image-placeholder psm-image-placeholder--harbor"
              role="img"
              aria-label="Reserved Harboring Image: THIS RAIL LINE"
            >
              <span>Harbor Image</span>
              <code>harbor_position_2_this_rail_line.webp</code>
            </div>
            <div class="psm-prose">
              <p>This Tied Tide Line now acquires orientationing.</p>
              <p>The PUBLIC-SITUATION-MACHINE first becomes capable of distinguishing:</p>
              <p>XT</p><p>from</p><p>YT</p>
              <p>XT remembers where to stand.</p>
              <p>YT discovers where it might go.</p>
              <p>
                The Rail Line therefore furnishes the first Regard from which Situationing Weather may become visible.
              </p>
              <p>Posture first becomes possible.</p>
              <p>Weather first becomes possible.</p>
              <p>Drift first becomes possible.</p>
            </div>
          </section>

          <section class="psm-diagram-section" aria-labelledby="position-2-diagram-title">
            <p class="psm-section-kicker">Instrument Diagram</p>
            <h3 id="position-2-diagram-title">Position 2 Diagram Specification</h3>
            <div
              class="psm-image-placeholder psm-image-placeholder--instrument"
              role="img"
              aria-label="Reserved instrument image locality"
            >
              <span>Instrument Image</span>
              <code>instrument_position_2_orientationing.webp</code>
            </div>
            <div
              id="position-2-instrument-chamber"
              class={["psm-post-stage", @regard == :inward && "psm-post-stage--inward"]}
            >
              <%= if @regard == :outward do %>
                <div class="psm-post-stage__outward">
                  <div class="psm-prose">
                    <p>This Line remains attached to This Post.</p>
                    <p>This Post remains locally coincident with This Pier.</p>
                    <p>This Planar Crossing now furnishes orientationing between XT and YT.</p>
                    <p>XT Shore and YT Waters now stand available to this Continuity Line.</p>
                  </div>
                  <button
                    id="position-2-regard-inward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-inward"
                    phx-value-position="2"
                  >Regard Inward</button>
                </div>
              <% else %>
                <article
                  id="position-2-recital"
                  class="psm-recital-chamber"
                  aria-labelledby="position-2-recital-title"
                >
                  <header class="psm-recital-chamber__header">
                    <p class="psm-section-kicker">Inward Regard</p>
                    <h4 id="position-2-recital-title">
                      PSM-COB Orchestrationing Recital of Co-Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position 2 recital">
                    <p>En-Steady-Ment-ing-ly-En-Abled-Mint-ing-Ment-ing</p><p>of</p><p>
                      En-Drift-Ment-Mint-ing
                    </p><p>of</p><p>En-Steady-Ment-ing-ly-En-Able-ing-Mint-ing-Ment-ing</p><p>of</p><p>
                      En-Drift-Ment-Mint-ing
                    </p><p>of</p><p>En-Steady-Ment-ing-ly-En-Mint-ing-Ment-ing</p>
                  </div>
                  <button
                    id="position-2-regard-outward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-outward"
                    phx-value-position="2"
                  >Regard Outward</button>
                </article>
              <% end %>
            </div>
          </section>

          <section class="psm-diagram-description" aria-labelledby="position-2-description-title">
            <p class="psm-section-kicker">Diagram Description</p>
            <div id="position-2-description-title" class="psm-prose">
              <p>PSM continuity-ing first acquires Posture.</p>
              <p>Posture determines the Regard from which This Thing may encounter the world.</p>
              <p>Posture may become Situationing Weather.</p>
              <p>The Rail Line stands as the first lawful infrastructure of Weathering.</p>
            </div>
          </section>
        </article>

        <aside class="psm-position__readiness" aria-labelledby="position-2-readiness">
          <p class="psm-region-label" id="position-2-readiness">Readiness for Tuple Position 3</p>
          <p class="psm-readiness-outreading">
            En-Quadranglement-Mint-ing-Able-En-Abled-Ment standinging.
          </p>
        </aside>
      </div>

      <%= unless @position_three_unfolded? do %>
        <footer class="psm-unfolding-control">
          <p class="psm-unfolding-control__status">
            The planar Projection Cross now stands available for passage.
          </p>

          <button
            id="unfold-position-3"
            type="button"
            class="psm-unfold-control"
            phx-click="unfold-position"
            phx-value-position="3"
          >
            Unfold
          </button>
        </footer>
      <% end %>
    </section>
    """
  end

  defp turn_zero_knotting_rail(assigns) do
    ~H"""
    <section
      id="turn-zero-knotting-rail"
      class="psm-knotting-rail"
      aria-labelledby="turn-zero-knotting-rail-title"
    >
      <header class="psm-knotting-rail__header">
        <p class="psm-position__ordinal">Turn Zero</p>

        <h2 id="turn-zero-knotting-rail-title">
          The Knotting Rail
        </h2>

        <p>
          Passage through the planar Projection Cross toward volumetric Lawful
          Quadranglement.
        </p>
      </header>

      <div class="psm-tunnel" aria-label="Projection Cross passage">
        <div class="psm-tunnel__entry" aria-hidden="true">
          <span class="psm-tunnel__vertical-axis"></span>
          <span class="psm-tunnel__cross-axis"></span>
          <span class="psm-tunnel__center"></span>
        </div>

        <div class="psm-tunnel__depth" aria-hidden="true">
          <span class="psm-tunnel__wall psm-tunnel__wall--left"></span>
          <span class="psm-tunnel__wall psm-tunnel__wall--right"></span>
          <span class="psm-tunnel__ceiling"></span>
          <span class="psm-tunnel__floor"></span>

          <span class="psm-tunnel__depth-axis psm-tunnel__depth-axis--left"></span>
          <span class="psm-tunnel__depth-axis psm-tunnel__depth-axis--right"></span>
        </div>

        <div class="psm-tunnel__exit" aria-hidden="true">
          <span class="psm-tunnel__exit-vertical"></span>
          <span class="psm-tunnel__exit-horizontal"></span>
          <span class="psm-tunnel__exit-volume"></span>
        </div>

        <div class="psm-knotting-rail__understructure">
          <span class="psm-knotting-rail__stitch" aria-hidden="true"></span>

          <div>
            <p>Knotting Rail</p>
            <p>Inherited Stitching beyond present Regard</p>
          </div>
        </div>
      </div>

      <p class="psm-knotting-rail__note">
        The Tongue at the Threshold remains constitutioningfully present beneath the
        passage and is not depicted within this Intro Site geometry.
      </p>
    </section>
    """
  end

  attr :regard, :atom, required: true
  attr :position_four_unfolded?, :boolean, required: true

  defp position_three(assigns) do
    ~H"""
    <section class="psm-oag" aria-labelledby="position-3-oag-title">
      <div class="psm-oag__instrument-plate">
        <p class="psm-oag__eyebrow">OAG Outreadingment</p>
        <h2 id="position-3-oag-title">Regarded in Relationing</h2>
      </div>

      <p class="psm-oag__description">
        The Oscillationing Airiness Gauge reports the Situational Weathering
        Conditions presently available for Regard.
      </p>
    </section>

    <section
      id="tuple-position-3"
      class="psm-position psm-position--quadranglement psm-position--newly-unfolded"
      aria-labelledby="tuple-position-3-title"
    >
      <header class="psm-position__heading">
        <p class="psm-position__ordinal">Tuple Position 3</p>

        <h2 id="tuple-position-3-title">
          A Geometry through Which Relation May Become Visible
        </h2>
      </header>

      <div class="psm-position__field psm-position__field--quadranglement">
        <aside class="psm-position__grounding" aria-labelledby="position-3-grounding">
          <p class="psm-region-label" id="position-3-grounding">XT Grounding</p>

          <div
            class="psm-image-placeholder psm-image-placeholder--observatory"
            role="img"
            aria-label="Reserved Position 3 observatory image locality"
          >
            <span>Observatory Image</span>
            <code>observatory_position_3_relationing.webp</code>
          </div>

          <div class="psm-prose">
            <p>
              Placement-in-Relation now stands toward prior
              Placement-in-Relation.
            </p>

            <p>XT remembers where to stand.</p>
          </div>
        </aside>

        <article class="psm-position__center">
          <section class="psm-harboring" aria-labelledby="position-3-harbor-title">
            <p class="psm-section-kicker">Harboring Image</p>

            <h3 id="position-3-harbor-title">
              THIS TRACK-RAIL-LINE-RAIL-TRACK
            </h3>

            <div
              class="psm-image-placeholder psm-image-placeholder--harbor"
              role="img"
              aria-label="Reserved Harboring Image: THIS TRACK-RAIL-LINE-RAIL-TRACK"
            >
              <span>Harbor Image</span>
              <code>harbor_position_3_track_rail_line_rail_track.webp</code>
            </div>

            <div class="psm-prose">
              <p>
                The PUBLIC-SITUATION-MACHINE- now becomes capable of
                Placement-in-Relation.
              </p>

              <p>The Rail Line acquires reciprocal orientation.</p>

              <p>
                The sweep between XT Shore and YT Waters now becomes visible.
              </p>

              <p>
                The Lawful Quadranglement now stands available to this
                PUBLIC-SITUATION-MACHINE-.
              </p>

              <p>
                Passageway and Perspective now stand constitutionally present
                within this harbor geometry.
              </p>

              <p>
                Neither Passageway nor Perspective yet stands foregrounded.
              </p>

              <p>The geometry itself stands foregrounded.</p>
            </div>
          </section>

          <section class="psm-diagram-section" aria-labelledby="position-3-diagram-title">
            <p class="psm-section-kicker">Instrument Diagram</p>

            <h3 id="position-3-diagram-title">
              Projectioning Crossing PITON
            </h3>

            <div
              class="psm-image-placeholder psm-image-placeholder--instrument"
              role="img"
              aria-label="Reserved Position 3 instrument image locality"
            >
              <span>Instrument Image</span>
              <code>instrument_position_3_projectioning_crossing_piton.webp</code>
            </div>

            <div
              id="position-3-instrument-chamber"
              class={[
                "psm-quadranglement-stage",
                @regard == :inward && "psm-quadranglement-stage--inward"
              ]}
            >
              <%= if @regard == :outward do %>
                <div class="psm-quadranglement-stage__outward">
                  <div
                    class="psm-projectioning-crossing-piton"
                    aria-label="Volumetric Projectioning Crossing PITON"
                  >
                    <p class="psm-piton-label psm-piton-label--foundation">
                      Foundation
                    </p>

                    <p class="psm-piton-label psm-piton-label--xt">
                      XT Shore
                    </p>

                    <div class="psm-piton-volume" aria-hidden="true">
                      <span class="psm-piton-volume__vertical"></span>
                      <span class="psm-piton-volume__horizontal"></span>
                      <span class="psm-piton-volume__depth psm-piton-volume__depth--a"></span>
                      <span class="psm-piton-volume__depth psm-piton-volume__depth--b"></span>
                      <span class="psm-piton-volume__center"></span>
                    </div>

                    <p class="psm-piton-label psm-piton-label--yt">
                      YT Waters
                    </p>

                    <p class="psm-piton-label psm-piton-label--capstone">
                      Capstone
                    </p>

                    <span class="psm-track-curve psm-track-curve--left" aria-hidden="true"></span>
                    <span class="psm-track-curve psm-track-curve--right" aria-hidden="true"></span>
                  </div>

                  <button
                    id="position-3-regard-inward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-inward"
                    phx-value-position="3"
                  >
                    Regard Inward
                  </button>
                </div>
              <% else %>
                <article
                  id="position-3-recital"
                  class="psm-recital-chamber"
                  aria-labelledby="position-3-recital-title"
                >
                  <header class="psm-recital-chamber__header">
                    <p class="psm-section-kicker">Inward Regard</p>

                    <h4 id="position-3-recital-title">
                      PSM-COB Orchestrationing Recital of Co-Occupancy-ing within
                      This Mounted Statefullment
                    </h4>
                  </header>

                  <div class="psm-recital-chamber__recital" aria-label="Position 3 recital">
                    <p>Em-Place-Ment-of-En-Relation-ing-Mint-ing-Ment</p>
                  </div>

                  <button
                    id="position-3-regard-outward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-outward"
                    phx-value-position="3"
                  >
                    Regard Outward
                  </button>
                </article>
              <% end %>
            </div>
          </section>

          <section class="psm-diagram-description" aria-labelledby="position-3-description-title">
            <p class="psm-section-kicker">Diagram Description</p>

            <div id="position-3-description-title" class="psm-prose">
              <p>
                The sweep stands as Placement-in-Relation geometry.
              </p>

              <p>The angle stands between XT Shore and YT Waters.</p>

              <p>
                The Track Rail Line Rail Track stands as the first
                distinguishable geometry of this PUBLIC-SITUATION-MACHINE-.
              </p>

              <p>
                The PUBLIC-SITUATION-MACHINE- first becomes capable of
                distinguishing:
              </p>

              <p class="psm-diagram-declaration">
                This Thing in Relation to That Thing
              </p>

              <p>The distinction itself now acquires shape.</p>
            </div>
          </section>
        </article>

        <aside class="psm-position__readiness" aria-labelledby="position-3-readiness">
          <p class="psm-region-label" id="position-3-readiness">
            Readiness for Position 4
          </p>

          <p class="psm-readiness-outreading">
            En-Distinguish-Mint-ing-Able-En-Ment-ing-Able-En-Lining-Mint-ing-Ment
            standinging.
          </p>
        </aside>
      </div>

      <%= unless @position_four_unfolded? do %>
        <footer class="psm-unfolding-control">
          <p class="psm-unfolding-control__status">
            Position 3 now stands available for inheritance.
          </p>

          <button
            id="unfold-position-4"
            type="button"
            class="psm-unfold-control"
            phx-click="unfold-position"
            phx-value-position="4"
          >
            Unfold
          </button>
        </footer>
      <% end %>
    </section>
    """
  end

  attr :regard, :atom, required: true
  attr :position_five_unfolded?, :boolean, required: true

  defp position_four(assigns) do
    ~H"""
    <section class="psm-oag" aria-labelledby="position-4-oag-title">
      <div class="psm-oag__instrument-plate">
        <p class="psm-oag__eyebrow">OAG Outreadingment</p>
        <h2 id="position-4-oag-title">Regarded in Distinguishingment</h2>
      </div>
    </section>

    <section
      id="tuple-position-4"
      class="psm-position psm-position--perspective psm-position--newly-unfolded"
      aria-labelledby="tuple-position-4-title"
    >
      <header class="psm-position__heading">
        <p class="psm-position__ordinal">Tuple Position 4</p>
        <h2 id="tuple-position-4-title">A Perspective from Which Relation May Acquire Angle</h2>
      </header>

      <div class="psm-position__field psm-position__field--perspective">
        <aside class="psm-position__grounding" aria-label="Position 4 observatory locality">
          <div
            class="psm-image-placeholder psm-image-placeholder--observatory"
            role="img"
            aria-label="Reserved Position 4 observatory image locality"
          >
            <span>Observatory Image</span>
            <code>observatory_position_4_perspective.webp</code>
          </div>
        </aside>

        <article class="psm-position__center">
          <section class="psm-harboring" aria-labelledby="position-4-harbor-title">
            <p class="psm-section-kicker">Harboring Image</p>
            <h3 id="position-4-harbor-title">THIS RE-STEP WALL</h3>

            <div
              class="psm-image-placeholder psm-image-placeholder--harbor"
              role="img"
              aria-label="Reserved Harboring Image: THIS RE-STEP WALL"
            >
              <span>Harbor Image</span>
              <code>harbor_position_4_re_step_wall.webp</code>
            </div>

            <div class="psm-prose">
              <p>The RE-Step Wall now stands foregrounded.</p>
              <p>The Track Rail Line Rail Track remains standing.</p>
              <p>The Wall remains standing.</p>
              <p>
                The COB may now stand in Relationing to the Wall while traversaling within the YT
                Waters.
              </p>
              <p>The RE-Step Wall does not move.</p>
              <p>The RE-Step Wall does not traverse.</p>
              <p>The RE-Step Wall furnishes perspective.</p>
              <p>Angular displacement from the Wall now becomes distinguishable.</p>
              <p>
                The PUBLIC-SITUATION-MACHINE therefore first becomes capable of Perspective.
              </p>
            </div>
          </section>

          <section class="psm-diagram-section" aria-labelledby="position-4-diagram-title">
            <p class="psm-section-kicker">Instrument Diagram</p>
            <h3 id="position-4-diagram-title">Position 4 Diagram</h3>

            <div
              class="psm-image-placeholder psm-image-placeholder--instrument"
              role="img"
              aria-label="Reserved Position 4 instrument image locality"
            >
              <span>Instrument Image</span>
              <code>instrument_position_4_re_step_wall.webp</code>
            </div>

            <div
              id="position-4-instrument-chamber"
              class={["psm-perspective-stage", @regard == :inward && "psm-perspective-stage--inward"]}
            >
              <%= if @regard == :outward do %>
                <div class="psm-perspective-stage__outward">
                  <div class="psm-re-step-geometry" aria-label="Fixed RE-Step Wall geometry">
                    <div class="psm-re-step-geometry__background" aria-hidden="true">
                      <span class="psm-re-step-geometry__piton"></span>
                      <span class="psm-re-step-geometry__rail"></span>
                      <span class="psm-re-step-geometry__curve psm-re-step-geometry__curve--left"></span>
                      <span class="psm-re-step-geometry__curve psm-re-step-geometry__curve--right"></span>
                    </div>
                    <span class="psm-re-step-geometry__wall" aria-hidden="true"></span>
                    <span class="psm-re-step-geometry__cob" aria-label="Displaced COB locality">COB</span>
                    <span
                      class="psm-re-step-geometry__trace psm-re-step-geometry__trace--one"
                      aria-hidden="true"
                    ></span>
                    <span
                      class="psm-re-step-geometry__trace psm-re-step-geometry__trace--two"
                      aria-hidden="true"
                    ></span>
                    <span
                      class="psm-re-step-geometry__trace psm-re-step-geometry__trace--three"
                      aria-hidden="true"
                    ></span>
                  </div>

                  <button
                    id="position-4-regard-inward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-inward"
                    phx-value-position="4"
                  >Regard Inward</button>
                </div>
              <% else %>
                <article
                  id="position-4-recital"
                  class="psm-recital-chamber"
                  aria-labelledby="position-4-recital-title"
                >
                  <header class="psm-recital-chamber__header">
                    <p class="psm-section-kicker">Inward Regard</p>
                    <h4 id="position-4-recital-title">
                      PSM-COB Orchestrationing Recital of Co-Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position 4 recital">
                    <p>
                      En-Distinguish-Mint-ing-Able-En-Ment-ing-Able-En-Lining-Mint-ing-Ment
                    </p>
                  </div>

                  <button
                    id="position-4-regard-outward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-outward"
                    phx-value-position="4"
                  >Regard Outward</button>
                </article>
              <% end %>
            </div>
          </section>

          <section class="psm-diagram-description" aria-labelledby="position-4-description-title">
            <p class="psm-section-kicker">Diagram Description</p>
            <div id="position-4-description-title" class="psm-prose">
              <p>The Track Rail Line Rail Track remains standing.</p>
              <p>The RE-Step Wall remains standing.</p>
              <p>The COB now occupies localities of Regard relative to the Wall.</p>
              <p>The Wall furnishes Perspective.</p>
              <p>The Waters furnish possible Regards.</p>
              <p>The difference in angle between Wall and Regard locality becomes the source of:</p>
              <p class="psm-diagram-declaration">
                Bearingings,<br /> Drift,<br /> Weathering,<br /> Trajectory,<br /> Excursioning.
              </p>
              <p>Without the Wall there is only:</p>
              <p class="psm-diagram-declaration">here</p>
              <p>The Wall first makes possible:</p>
              <p class="psm-diagram-declaration">there</p>
              <p>and therefore:</p>
              <p class="psm-diagram-declaration">again</p>
            </div>
          </section>
        </article>

        <aside class="psm-position__readiness" aria-labelledby="position-4-readiness">
          <p class="psm-region-label" id="position-4-readiness">Readiness for Position 5</p>
          <p class="psm-readiness-outreading">
            En-Traversal-Mint-ing-Ably-En-Ment-ing-Ably-En-Regard-Mint-ing-En-Ment standinging.
          </p>
        </aside>
      </div>

      <%= unless @position_five_unfolded? do %>
        <footer class="psm-unfolding-control">
          <button
            id="unfold-position-5"
            type="button"
            class="psm-unfold-control"
            phx-click="unfold-position"
            phx-value-position="5"
          >Unfold</button>
        </footer>
      <% end %>
    </section>
    """
  end

  attr :regard, :atom, required: true
  attr :position_six_unfolded?, :boolean, required: true

  defp position_five(assigns) do
    ~H"""
    <section class="psm-oag" aria-labelledby="position-5-oag-title">
      <div class="psm-oag__instrument-plate">
        <p class="psm-oag__eyebrow">OAG Outreadingment</p>
        <h2 id="position-5-oag-title">Regarded in Continuity-ing</h2>
      </div>
    </section>

    <section
      id="tuple-position-5"
      class="psm-position psm-position--perspective psm-position--newly-unfolded"
      aria-labelledby="tuple-position-5-title"
    >
      <header class="psm-position__heading">
        <p class="psm-position__ordinal">Tuple Position 5</p>
        <h2 id="tuple-position-5-title">A Means through Which Continuity May Become Carried</h2>
      </header>

      <div class="psm-position__field psm-position__field--perspective">
        <aside class="psm-position__grounding" aria-label="Position 5 observatory locality">
          <div
            class="psm-image-placeholder psm-image-placeholder--observatory"
            role="img"
            aria-label="Reserved Position 5 observatory image locality"
          >
            <span>Observatory Image</span>
            <code>observatory_position_5_continuity.webp</code>
          </div>
        </aside>

        <article class="psm-position__center">
          <section class="psm-harboring" aria-labelledby="position-5-harbor-title">
            <p class="psm-section-kicker">Harbor Image</p>
            <h3 id="position-5-harbor-title">THIS RE-STEP</h3>
            <div
              class="psm-image-placeholder psm-image-placeholder--harbor"
              role="img"
              aria-label="Reserved Harbor Image: THIS RE-STEP"
            >
              <span>Harbor Image</span>
              <code>harbor_position_5_re_step.webp</code>
            </div>
            <div class="psm-prose">
              <p>The RE-Step now stands foregrounded.</p>
              <p>The RE-Step Wall remains standing.</p>
              <p>The Track Rail Line Rail Track remains standing.</p>
              <p>Continuity may now become carried through Traversaling.</p>
              <p>The PUBLIC-SITUATION-MACHINE first becomes capable of Excursioning.</p>
              <p>
                The COB may now venture from its original locality while preserving Relationing to
                where it has been.
              </p>
              <p>Continuity does not remain behind.</p>
              <p>Continuity travels.</p>
            </div>
          </section>

          <section class="psm-diagram-section" aria-labelledby="position-5-diagram-title">
            <p class="psm-section-kicker">Instrument Diagram</p>
            <h3 id="position-5-diagram-title">Position 5 Diagram</h3>
            <div
              class="psm-image-placeholder psm-image-placeholder--instrument"
              role="img"
              aria-label="Reserved Position 5 instrument image locality"
            >
              <span>Instrument Image</span>
              <code>instrument_position_5_re_step.webp</code>
            </div>

            <div
              id="position-5-instrument-chamber"
              class={["psm-perspective-stage", @regard == :inward && "psm-perspective-stage--inward"]}
            >
              <%= if @regard == :outward do %>
                <div class="psm-perspective-stage__outward">
                  <div class="psm-continuity-geometry" aria-label="RE-Step continuity geometry">
                    <p class="psm-geometry-label psm-geometry-label--top">XT SHORE</p>
                    <span class="psm-continuity-geometry__origin" aria-hidden="true"></span>
                    <span class="psm-continuity-geometry__wall" aria-hidden="true"></span>
                    <p class="psm-continuity-geometry__wall-label">RE-STEP WALL</p>
                    <span class="psm-continuity-geometry__turn" aria-hidden="true"></span>
                    <span class="psm-continuity-geometry__arrival" aria-hidden="true"></span>
                    <p class="psm-geometry-label psm-geometry-label--bottom">YT WATERS</p>
                  </div>
                  <button
                    id="position-5-regard-inward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-inward"
                    phx-value-position="5"
                  >Regard Inward</button>
                </div>
              <% else %>
                <article
                  id="position-5-recital"
                  class="psm-recital-chamber"
                  aria-labelledby="position-5-recital-title"
                >
                  <header class="psm-recital-chamber__header">
                    <p class="psm-section-kicker">Inward Regard</p>
                    <h4 id="position-5-recital-title">
                      PSM-COB Orchestrationing Recital of Co-Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position 5 recital">
                    <p>En-RE-Step-En-Ment-ing-Mint</p>
                    <p>of</p><p>En-Ment-ing</p><p>of</p><p>En-Mint-ing</p><p>of</p>
                    <p>En-Ment-ing</p><p>of</p><p>En-Mint-ing</p>
                  </div>
                  <button
                    id="position-5-regard-outward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-outward"
                    phx-value-position="5"
                  >Regard Outward</button>
                </article>
              <% end %>
            </div>
          </section>

          <section class="psm-diagram-description" aria-labelledby="position-5-description-title">
            <p class="psm-section-kicker">Diagram Description</p>
            <div id="position-5-description-title" class="psm-prose">
              <p>The original locality remains standing.</p>
              <p>The traversingable locality now stands available.</p>
              <p>The relationing stands carried.</p>
              <p>The RE-Step does not sever relation to origin.</p>
              <p>The RE-Step carries the Continuity Line forward through Traversaling.</p>
              <p>Excursioning now stands available to this PUBLIC-SITUATION-MACHINE.</p>
            </div>
          </section>
        </article>

        <aside class="psm-position__readiness" aria-labelledby="position-5-readiness">
          <p class="psm-region-label" id="position-5-readiness">Readiness for Position 6</p>
          <p class="psm-readiness-outreading">
            En-Recursion-Mint-ing-Ably-En-Ment-ing-Ably-En-Return-Mint-ing-En-Ment standinging.
          </p>
        </aside>
      </div>

      <%= unless @position_six_unfolded? do %>
        <footer class="psm-unfolding-control">
          <button
            id="unfold-position-6"
            type="button"
            class="psm-unfold-control"
            phx-click="unfold-position"
            phx-value-position="6"
          >Unfold</button>
        </footer>
      <% end %>
    </section>
    """
  end

  attr :regard, :atom, required: true

  defp position_six(assigns) do
    ~H"""
    <section class="psm-oag" aria-labelledby="position-6-oag-title">
      <div class="psm-oag__instrument-plate">
        <p class="psm-oag__eyebrow">OAG Outreadingment</p>
        <h2 id="position-6-oag-title">Regarded in Returning</h2>
      </div>
    </section>

    <section
      id="tuple-position-6"
      class="psm-position psm-position--perspective psm-position--newly-unfolded"
      aria-labelledby="tuple-position-6-title"
    >
      <header class="psm-position__heading">
        <p class="psm-position__ordinal">Tuple Position 6</p>
        <h2 id="tuple-position-6-title">
          A Means through Which This Thing May Become Like This Thing Again
        </h2>
      </header>

      <div class="psm-position__field psm-position__field--perspective">
        <aside class="psm-position__grounding" aria-label="Position 6 observatory locality">
          <div
            class="psm-image-placeholder psm-image-placeholder--observatory"
            role="img"
            aria-label="Reserved Position 6 observatory image locality"
          >
            <span>Observatory Image</span>
            <code>observatory_position_6_returning.webp</code>
          </div>
        </aside>

        <article class="psm-position__center">
          <section class="psm-harboring" aria-labelledby="position-6-harbor-title">
            <p class="psm-section-kicker">Harboring Image</p>
            <h3 id="position-6-harbor-title">THIS RE-STEP-MENT MOMENT</h3>
            <div
              class="psm-image-placeholder psm-image-placeholder--harbor"
              role="img"
              aria-label="Reserved Harboring Image: THIS RE-STEP-MENT MOMENT"
            >
              <span>Harbor Image</span>
              <code>harbor_position_6_re_step_ment_moment.webp</code>
            </div>
            <div class="psm-prose">
              <p>The RE-Step-Ment Moment now stands foregrounded.</p>
              <p>The RE-Step remains standing.</p>
              <p>The RE-Step Wall remains standing.</p>
              <p>The Track Rail Line Rail Track remains standing.</p>
              <p>The original locality remains standing.</p>
              <p>The traversed locality remains standing.</p>
              <p>The PUBLIC-SITUATION-MACHINE first becomes capable of Returning.</p>
              <p>Returning is not repetition.</p>
              <p>Returning is not restoration.</p>
              <p>Returning is not reversal.</p>
              <p>Returning is the possibility that:</p>
              <p class="psm-diagram-declaration">This Thing</p>
              <p>may become:</p>
              <p class="psm-diagram-declaration">Like This Thing Again</p>
              <p>through Lawful Continuity Carriage over Discrete Turns.</p>
            </div>
          </section>

          <section class="psm-diagram-section" aria-labelledby="position-6-diagram-title">
            <p class="psm-section-kicker">Instrument Diagram</p>
            <h3 id="position-6-diagram-title">Tuple Position 6 Diagram</h3>
            <div
              class="psm-image-placeholder psm-image-placeholder--instrument"
              role="img"
              aria-label="Reserved Position 6 instrument image locality"
            >
              <span>Instrument Image</span>
              <code>instrument_position_6_re_step_ment_moment.webp</code>
            </div>

            <div
              id="position-6-instrument-chamber"
              class={["psm-perspective-stage", @regard == :inward && "psm-perspective-stage--inward"]}
            >
              <%= if @regard == :outward do %>
                <div class="psm-perspective-stage__outward">
                  <div class="psm-return-geometry" aria-label="RE-Step-Ment Moment return geometry">
                    <p>RE-STEP-MENT MOMENT</p>
                    <span class="psm-return-geometry__locality psm-return-geometry__locality--origin"></span>
                    <span class="psm-return-geometry__return" aria-hidden="true">↺</span>
                    <span class="psm-return-geometry__locality psm-return-geometry__locality--arrival"></span>
                    <strong>RE-STEP</strong>
                  </div>
                  <button
                    id="position-6-regard-inward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-inward"
                    phx-value-position="6"
                  >Regard Inward</button>
                </div>
              <% else %>
                <article
                  id="position-6-recital"
                  class="psm-recital-chamber"
                  aria-labelledby="position-6-recital-title"
                >
                  <header class="psm-recital-chamber__header">
                    <p class="psm-section-kicker">Inward Regard</p>
                    <h4 id="position-6-recital-title">
                      PSM-COB Orchestrationing Recital of Co-Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position 6 recital">
                    <p>En-RE-Step-En-Mint-ing-En-Ment</p>
                  </div>
                  <button
                    id="position-6-regard-outward"
                    type="button"
                    class="psm-regard-control"
                    phx-click="regard-outward"
                    phx-value-position="6"
                  >Regard Outward</button>
                </article>
              <% end %>
            </div>
          </section>

          <section class="psm-diagram-description" aria-labelledby="position-6-description-title">
            <p class="psm-section-kicker">Diagram Description</p>
            <div id="position-6-description-title" class="psm-prose">
              <p>The Moment stands simultaneously as:</p>
              <p class="psm-diagram-declaration">
                departure locality,<br /> arrival locality,<br /> and return locality.
              </p>
              <p>
                The Moment therefore stands not as a coordinate but as a Continuity Relation carried
                over Discrete Turns.
              </p>
              <p>The PUBLIC-SITUATION-MACHINE does not preserve sameness.</p>
              <p>It preserves lawful becoming.</p>
            </div>
          </section>
        </article>

        <aside class="psm-position__readiness" aria-labelledby="position-6-readiness">
          <p class="psm-region-label" id="position-6-readiness">Readiness for Tuple Position 0</p>
          <p class="psm-readiness-outreading">
            En-May-Be-Be-Coming-Like-This-Thing-Again-Mint-ing-Ably-En-Ment-ing-Ably-En-Mint-ing-Able-En-Ment-ing-Able-En-Mint-ing-ly-En-Ment-ing-ly-En-Mint-ing-En-Ment-ing
          </p>
        </aside>
      </div>
    </section>
    """
  end
end
