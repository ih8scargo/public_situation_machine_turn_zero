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
            PUBLIC-SITUATION-MACHINE- Appliance Tag
          </p>
          <p class="psm-identification__value">PSM: 00000001</p>
        </div>

        <div class="psm-identification__plate">
          <p class="psm-identification__label">
            -COORDINATIONING-OPERATIONING-BOBBINING Appliance Tag
          </p>
          <p class="psm-identification__value">COB: 00428173</p>
        </div>

        <div class="psm-identification__plate psm-identification__plate--relation">
          <p class="psm-identification__label">
            PUBLIC-SITUATION-MACHINE-COORDINATIONING-OPERATIONING-BOBBINING-Relation-Tag
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
                  Occupancy-ing at the center of this Constitutional Locality
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
                        PSM-COB Orchestrationing Recital of Occupancy-ing within
                        This Mounted Statefullment
                      </p>
                    </header>

                    <div class="psm-recital-chamber__recital" aria-label="Position Zero recital">
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
              Position Zero now stands available for inheritance.
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
        <.position_two regard={@position_2_regard} />
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
                    <p>The Position Zero Stitch continues through this Constitutional Locality.</p>
                    <p>This Post remains locally coincident with This Pier.</p>
                    <p>The Position Zero Stitch continues through This Constitutional Locality.</p>
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
                      PSM-COB Orchestrationing Recital of Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position One recital">
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
                      PSM-COB Orchestrationing Recital of Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position Two recital">
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
    </section>
    """
  end
end
