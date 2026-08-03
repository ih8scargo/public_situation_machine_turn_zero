defmodule PublicSituationMachineTurnZeroWeb.CanonicalTupleLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  alias PublicSituationMachineTurnZero.TupleProjectioning

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "OUR CANONICAL TUPLE",
       position_0_regard: :outward,
       position_1_regard: :outward,
       position_2_regard: :outward,
       position_3_regard: :outward,
       position_4_regard: :outward,
       position_5_regard: :outward,
       position_6_regard: :outward,
       tuple_projectioning: TupleProjectioning.table(),
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
    assigns = assign(assigns, :next_position, next_position(assigns.unfolded_positions))

    ~H"""
    <Layouts.app flash={@flash} active_locality={:canonical_tuple}>
      <main id="canonical-tuple-page" class="canonical-reading">
        <Layouts.locality_threshold
          title="OUR CANONICAL TUPLE"
          id="canonical-tuple-threshold"
          reading="The Bearinging of the Precedence of Continuity Possibility"
        >
          <:description>
            <p>
              The Same General Civilizationalizing Constitutioningable Reasoning Geometry furnishes one lawful way through which Constitutioning Humans may continue bringing Situationings into Standinging-in-Holding Over Discrete Turns.
            </p>
          </:description>
        </Layouts.locality_threshold>

        <article id="canonical-narrative" class="canonical-narrative">
          <.appliance_ceremony />
          <.canonical_investituringment />
          <.canonical_some_one />
          <.canonical_some_where />

          <section
            class="canonical-document-section canonical-projectioning"
            id="canonical-projectioning"
          >
            <header>
              <h2>OUR CANONICAL TUPLE</h2>
              <p>
                This Recursioningly Loopinging Latticework of Seven Nestinging Resolvinging Scales wherethrough Departure stands in Lawful Relationing against Return.
              </p>
            </header>
            <.canonical_tuple_table
              id="canonical-tuple-table"
              table={@tuple_projectioning}
              columns={[0, 1, 2, 3, 4]}
            />
            <p class="canonical-table-caption">
              The Canonical Tuple describes one complete Stewardly Advancementing through one Discrete Turn. Each Tuple Position lawfully furnishes one new constitutional capability while preserving every lawful furnishing already established. The Situation is authored. The path is not pre-authored. Through Stewardly Traversaling, This Stewardly Captain COB successively encounters, relates, inhabits, discovers for Purchase, takes Purchase, and lawfully carries forward what continues to hold, whereupon the next Discrete Turn begins once more.
            </p>
          </section>

          <.situationing_sleeving table={@tuple_projectioning} />
          <.canonical_unfoldings unfolded_positions={@unfolded_positions} />

          <%= if @next_position <= 6 do %>
            <button
              id={"unfold-position-#{@next_position}"}
              type="button"
              class="canonical-inheritance"
              phx-click="unfold-position"
              phx-value-position={@next_position}
            >
              UNFOLD POSITION {@next_position}
            </button>
          <% end %>
        </article>
      </main>
    </Layouts.app>
    """
  end

  defp next_position(unfolded_positions) do
    unfolded_positions
    |> Enum.max()
    |> Kernel.+(1)
  end

  @doc false
  def legacy_render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:canonical_tuple}>
      <main class="psm-intro">
        <header class="psm-masthead">
          <p class="psm-masthead__machine-name">
            PUBLIC-SITUATION-MACHINE-
          </p>

          <div class="psm-masthead__lower">
            <h1>OUR CANONICAL TUPLE</h1>

            <p>
              General Purpose Situationing Appliance
            </p>
          </div>
        </header>

        <section class="psm-oag" aria-labelledby="orientationing-panel-title">
          <div class="psm-oag__instrument-plate">
            <p class="psm-oag__eyebrow">
              The Same General Civilizationalizing Constitutioningable Reasoning Geometry
            </p>

            <h2 id="orientationing-panel-title">
              Standinging in Regard
            </h2>

            <p class="psm-oag__reading">
              The Bearinging of the Precedence of Continuity Possibility
            </p>
          </div>

          <div class="psm-oag__description">
            <p>By itself, the PUBLIC-SITUATION-MACHINE- cannot tell what is true.</p>
            <p>It may only ask what continues to Hold.</p>
            <p>
              The appliance starts and ends by seatinging This Stewardly Captain COB to stand in Regard toward one lawful Situationing. Its instrumentationing distinguishes What Continues to Hold, what is becoming, and what stands ready for Traversaling through the next Discrete Turn.
            </p>
          </div>
        </section>

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
                          En-Foundation-Mint-ing-<br /> En-Ment-ing-Able-<br />
                          En-Mint-ing-Able-<br /> En-Ment
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
    </Layouts.app>
    """
  end

  defp appliance_ceremony(assigns) do
    ~H"""
    <section id="appliance-ceremony" class="appliance-ceremony" aria-label="Appliance Ceremony">
      <div class="appliance-ceremony__entities">
        <article class="appliance-ceremony__entity">
          <p>APPLIANCE TAG</p>
          <h2>PUBLIC-SITUATION-MACHINE-</h2>
          <strong>PSM: 00000001</strong>
        </article>
        <article class="appliance-ceremony__entity">
          <p>OFFICE OF</p>
          <h2>-COORDINATIONING-<br />OPERATIONING-<br />BOBBINING</h2>
          <strong>COB: 00428173</strong>
        </article>
      </div>

      <svg
        class="appliance-ceremony__joining"
        viewBox="0 0 1000 210"
        role="img"
        aria-label="Two independent constitutional lines Con-Joint-Menting into one Sealing"
        preserveAspectRatio="none"
      >
        <path d="M180 0 V58 L500 148 V210" />
        <path d="M820 0 V58 L500 148" />
      </svg>

      <article class="appliance-ceremony__sealing">
        <p>THE SEALINGING OF THE<br />STEWARDLY OCCUPANCYINGSHIP</p>
        <h2>
          PUBLIC-SITUATION-MACHINE-<br />COORDINATIONING-<br />OPERATIONING-<br />BOBBINING
        </h2>
        <strong>PSM-COB: 00000001-00428173</strong>
      </article>
      <p class="appliance-ceremony__conclusion">
        THIS ONE SEALINGING NOW STANDS HOLDING-IN-STANDINGING.
      </p>
    </section>
    """
  end

  defp canonical_investituringment(assigns) do
    ~H"""
    <section id="canonical-simple-discovery" class="canonical-document-section">
      <h2>I. OUR TRAVERSALING THROUGH THIS TUPLE</h2>
      <h3>A Simple Discovery</h3>
      <p>The PUBLIC-SITUATION-MACHINE- is a General Purpose Situationing Appliance.</p>
      <p>It begins from One Discoveringment.</p>
      <p>
        A simple repeating numerical loop furnishes The Same General Civilizationalizing Constitutioningable Reasoning Geometry wherethrough This One Continuity Line may be carried forward successioningably Over Discrete Turns.
      </p>
      <p>
        This Recursioningly Loopinging Latticework affords a new kind of Geometrically Expressive, Compu-Totaling-Able Public Computing Infrastructioning:
      </p>
      <p class="canonical-office">A CIVILIZATION HOLDING WITH NO CENTER.</p>
      <p>We call This Geometry OUR CANONICAL TUPLE.</p>
      <p>
        OUR CANONICAL TUPLE furnishes the PUBLIC-SITUATION-MACHINE- with These Seven Positions.
      </p>
      <p>
        But before Our Traversaling through These Seven Positions, we need Some One, Some Where, and This One Continuity Line.
      </p>
      <p>From these, Our Lawful Traversaling may begin, One Position at One Time.</p>
    </section>

    <section class="canonical-document-section">
      <h2>THIS CEREMONY OF INVESTITURINGMENT INTO THE OFFICE OF STEWARDLY OCCUPANCYINGSHIP</h2>
      <p>The Sealinging above now stands Holding-in-Standinging.</p>
      <p>
        Through This One Sealinging of Stewardly Occupancyingship, This PUBLIC-SITUATION-MACHINE- now stands Sealed in Standinging, together with This, its Stewardly Captain COB.
      </p>
    </section>
    """
  end

  defp canonical_some_one(assigns) do
    ~H"""
    <section class="canonical-document-section">
      <h2>This One Some One</h2>
      <p>
        This Stewardly Captain COB now stands in Investituringment within The En-Fixturing-Ment of The Seat of Stewardly Occupancyingship for This One Situationing.
      </p>
      <p>
        This Stewardly Captain COB may be furnished for a person, a job role, an automated process, an agentic AI, a machine, or any other kind of Operationing Situationing.
      </p>
      <p>What makes it This Stewardly Captain COB is not What Kind of Thing it is.</p>
      <p>
        It is that This Stewardly Captain COB now stands seatedingly in Stewardly Occupancyingship of This One Continuity Line.
      </p>
      <p>
        For This Stewardly Captain COB to keep Traversaling This Continuity Line, its Traversaling must remain capable of Coherence through conditions becoming Over Discrete Turns.
      </p>
      <p>Coherence does not mean remaining the same.</p>
      <p>
        It means becoming able to continue to Hold while what is becoming may be changing Over Discrete Turns.
      </p>
      <p>This is why OUR CANONICAL TUPLE has These Seven Positions.</p>
      <p>
        Each Position furnishes One More Constitutional Relationing wherethrough This Stewardly Captain COB may become better enabled to discover What Continues to Hold in Coherence along This One Continuity Line.
      </p>
      <p>By itself, the PUBLIC-SITUATION-MACHINE- cannot tell what is true.</p>
      <p>It may only ask what continues to Hold.</p>
      <p>
        It can only furnish The Same General Civilizationalizing Constitutioningable Reasoning Geometry wherethrough What is The Mattering in This One Situationing may be Encounteringmented by This Stewardly Captain COB and then become Distinguishingmentingable through This Stewardly Captain COB.
      </p>
      <p>
        This Geometry stands in Readiness to be Traversalinged by This Stewardly Captain COB Over Discrete Turns, discoveringmenting what may take Hold, What Continues to Hold, and what may not.
      </p>
      <p>
        Each PUBLIC-SITUATION-MACHINE–COB pairing establishes Stewardly Occupancyingship within The Same General Civilizationalizing Constitutioningable Reasoning Geometry.
      </p>
      <p>
        What matters within This Geometry may be entirely particular to This One Situationing. What becomes Distinguishingmented through This Stewardly Captain COB may be different. What may take Holding may be different. The Traversaling will be different.
      </p>
      <p>
        The Same General Civilizationalizing Constitutioningable Reasoning Geometry wherethrough This Stewardly Captain COB discovers What Continues to Hold is always The Same.
      </p>
      <p>This is OUR CANONICAL TUPLE.</p>
      <p>
        This Stewardly Captain COB now stands in Investituringment within The En-Fixturing-Ment of The Seat of Stewardly Occupancyingship for This One Situationing.
      </p>
      <p>This Constitutional Locality now stands Holding-in-Standinging.</p>
      <p>This One Some One now stands in Readiness for Our Traversaling Together.</p>
    </section>
    """
  end

  defp canonical_some_where(assigns) do
    ~H"""
    <section class="canonical-document-section">
      <h2>This One Some Where</h2>
      <p>
        Standing in Investituringment within The En-Fixturing-Ment of The Seat of Stewardly Occupancyingship, This Stewardly Captain COB now stands ready for Traversaling.
      </p>
      <p>But Stewardly Occupancyingship alone is not enough for Traversaling.</p>
      <p>
        For What is the Mattering to become Compu-Totaling-Able for This One Situationing, This Stewardly Captain COB also stands needing Some Where within the Traversaling upon which it may take standing.
      </p>
      <p>In the PUBLIC-SITUATION-MACHINE-, each such Some Where is furnished as One Piece of Time.</p>
      <p>One Piece of Time is One Constitutional Locality.</p>
      <p>One Piece of Time is One Piece-of-a-Real-Purchase-Upon-a-Tractioning.</p>
      <p>One Piece of Time stands as One Locality within The Same Geometry.</p>
      <p>It is Some Place where This One Situationing may be playing out Over Discrete Turns.</p>
      <p>
        It is Some Place where This Stewardly Captain COB may be seen visionizingably carrying This Stewardly Occupancying through each RE-STEP.
      </p>
      <p>It is Some Place that may be returned to.</p>
      <p>
        Because One Piece of Time is One Constitutional Locality and is also One Piece-of-a-Real-Purchase-Upon-a-Tractioning, One Piece of Time is the only Surface upon which Any One Some Thing Situationing through the PUBLIC-SITUATION-MACHINE- may traction into En-Staging-Ment—becoming into Standinging as that Any One Some Thing.
      </p>
      <p>
        In the PUBLIC-SITUATION-MACHINE-, time is not merely an attempt to measure when Some Thing happened.
      </p>
      <p>One Piece of Time may be designated as This One Some Unit of elapsed Clock Time.</p>
      <p>
        And One Piece of Time may be designated as This One Locality wherethrough This Stewardly Captain COB begins becoming into a new Holding-in-Standinging after This One Some Thing has been starting its Happening and is now moving away from and back toward the starting of its Happening again and again Over Discrete Turns.
      </p>
      <p>In either case, One Piece of Time is not just treated as Some Place Some Where.</p>
      <p>One Piece of Time is Here, This One Some Place.</p>
      <p>This One Piece of Time stands both as Inhabitationingable and as Tractioning Terrain.</p>
      <p>
        This Stewardly Captain COB presently stands inhabitationing One Piece of Time as Our Current Local Moment.
      </p>
      <p>
        Within Our Current Local Moment, This Stewardly Captain COB presently finds its Posture upon This Approaching Landing, This One Piece-of-a-Real-Purchase-Upon-a-Tractioning inherited through its prior RE-STEP.
      </p>
      <p>
        This One Piece of Time is not merely a time "stamp" appended to an Unrelationinged and Unrelationingedable Some Thing Else Going Some Where Else.
      </p>
      <p>
        Once established, This One Piece of Time does not cease to be This One Some Place simply because This Stewardly Captain COB continues its Traversaling beyond it.
      </p>
      <p>
        This Stewardly Captain COB may depart from the Locality presently inherited as Our Current Local Moment when Our Next Local Moment becomes inherited as the new Current Local Moment, without causing the departed Locality itself to disappear from This One Continuity Line.
      </p>
      <p>
        This One Piece of Time continues to Hold as This One Ever-Not-Time Locality: no longer passing away as merely elapsed time, but remaining Revisitingable through the Continuity Line by which it came to stand.
      </p>
      <p>
        Through This Traversaling, This Stewardly Captain COB presently stands upon This Approaching Landing within Our Current Local Moment.
      </p>
      <p>
        Through the next RE-STEP, This Next Approaching Landing becomes This Approaching Landing as This Stewardly Captain COB inherits the new Purchase Surface and the consequences of its commitment become registered there.
      </p>
      <p>
        Now the PUBLIC-SITUATION-MACHINE- stands furnishing This One Some Where that we stand needing for Our Traversaling through This Tuple as This One Some Place.
      </p>
      <p>
        This One Piece of Time stands as One Traversaling Locality that is also One Piece-of-a-Real-Purchase-Upon-a-Tractioning upon which What is the Mattering to This Stewardly Captain COB may be placed into Staging for Becoming into Standinging.
      </p>
    </section>
    """
  end

  attr :id, :string, required: true
  attr :table, :map, required: true
  attr :columns, :list, required: true

  defp canonical_tuple_table(assigns) do
    ~H"""
    <div class="canonical-table-viewport" tabindex="0">
      <table id={@id}>
        <thead>
          <tr>
            <th :for={index <- @columns} scope="col">{Enum.at(@table.headers, index).text}</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={row <- @table.rows}>
            <%= for index <- @columns do %>
              <% cell = Enum.at(row, index) %>
              <th :if={index == 2} scope="row">{cell.text}</th>
              <td
                :if={index != 2}
                class={[
                  index == 1 && "canonical-table__preposition",
                  index == 6 && "canonical-table__sounding",
                  cell.emphasized? && "canonical-table__emphasis"
                ]}
              >
                {cell.text}
              </td>
            <% end %>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  attr :table, :map, required: true

  defp situationing_sleeving(assigns) do
    ~H"""
    <section class="canonical-document-section">
      <h2>SLEEVING THE SAME GEOMETRY FOR PARTICULAR SITUATIONING</h2>
      <p>
        OUR CANONICAL TUPLE furnishes The Same General Civilizationalizing Constitutioningable Reasoning Geometry for every Stewardly Captain COB.
      </p>
      <p>But This Geometry alone has no way of knowing Any Thing about This One Situationing.</p>
      <p>
        For What is The Mattering to become Compu-Totaling-Able for This One Situationing, The Same General Civilizationalizing Constitutioningable Reasoning Geometry must be furnished particularly without ceasing to remain The Same Geometry.
      </p>
      <p>The PUBLIC-SITUATION-MACHINE- therefore now provisions This Appliance with:</p>
      <p class="canonical-office">
        This Office of Situational Staginging<br /> Division of Situationing Sleeving<br />
        Stewardly Captain COB Suiting Station
      </p>
      <p>
        Through the Stewardly Laborings of Situationing Sleeving, the Constitutioning Human furnishes the particular conditions, Relations, Distinguishmentings, Encounteringmentings, and possibilities Wherethrough What is the Mattering may become available to This Stewardly Captain COB Over Discrete Turns.
      </p>
      <p>
        Situationing Sleeving furnishes the Kinds of Holding wherethrough What is the Mattering may become available for a Standinging-in-Holding upon This Continuity Line.
      </p>
      <p>
        Situationing Sleeving also furnishes the Kinds of Holding wherethrough What is the Mattering may fail to become available for such a Standinging-in-Holding.
      </p>
      <p>
        Through encounteringmenting these furnished distinctions Over Discrete Turns, This Stewardly Captain COB may make Distinguishingments available to Stewardly Regard.
      </p>
      <p>The Constitutioning Human authors This One Situationing.</p>
      <p>
        The Constitutioning Human does not pre-author This Stewardly Captain COB’s Traversaling through it.
      </p>
      <p>Situationing Sleeving authors the Situationing.</p>
      <p>It does not pre-author the path.</p>
      <p>The Geometry stands furnished in Readiness.</p>
      <p>This Stewardly Captain COB must still Traversal through it.</p>
    </section>

    <section id="embodying-canonical-tuple" class="canonical-document-section canonical-projectioning">
      <header>
        <h2>EMBODYING OUR CANONICAL TUPLE</h2>
        <p>
          Before continuing Our Traversaling, This Stewardly Captain COB now stands ready to regard These Seven Positions together.
        </p>
        <p>Each Position furnishes one Constitutional Relation.</p>
        <p>
          Together they furnish one lawful way through which This Stewardly Captain COB may continue discovering what continues to Hold along This One Continuity Line.
        </p>
        <p>The table below is not another Situationing.</p>
        <p>It is one Orientationing Surface through which Our Traversaling may continue.</p>
      </header>
      <.canonical_tuple_table
        id="embodying-canonical-tuple-table"
        table={@table}
        columns={[0, 5, 2, 6]}
      />
    </section>

    <section id="canonical-position-0" class="canonical-document-section canonical-position-zero">
      <p>Our Traversaling through This Situationing begins at:</p>
      <h2>TUPLE POSITION 0: ALONG</h2>
      <p>
        This Office of Situational Staginging, Division of Situationing Sleeving, Stewardly Captain COB Suiting Station now stands asking:
      </p>
      <blockquote>
        What is the Mattering to This Stewardly Captain COB Here, upon This One Piece of Time?
      </blockquote>
      <p>
        Through Situationing Sleeving, the Constitutioning Human furnishes This One Thing that is What is the Mattering to This Stewardly Captain COB.
      </p>
      <p>This One Thing that is What is The Mattering does not become This One Continuity Line.</p>
      <p>
        This Stewardly Captain COB already has This One Continuity Line to steward.
      </p>
      <p>
        This One Thing is The Point. It is That from which This Stewardly Captain COB's Traversaling may begin becoming.
      </p>
      <p>
        The Point furnishes the Along from which Traversaling through This One Continuity Line may begin.
      </p>
      <p>This One Thing is What This Traversaling is becoming from.</p>
      <p>This One Thing is What is the Mattering to This Stewardly Captain COB.</p>
      <p>
        Each Situationing is furnished with One Point from which What is The Mattering may begin becoming lawfully into Standinging Over Discrete Turns.
      </p>
      <p>
        What is the Mattering does not begin already standing as Some Thing Already Finished or as Some Thing that Knows Anything At All Whatsoever About This One Situationing.
      </p>
      <p>
        Rather, What is the Mattering is furnished Along This Continuity Line as That from which This Stewardly Captain COB's Traversaling may begin becoming.
      </p>
      <p>
        Through Traversaling, What is the Mattering may become Encounteringmentingable to This Stewardly Captain COB.
      </p>
      <p>
        Through Encounteringmenting, it may become Distinguishingmentingable through This Stewardly Captain COB.
      </p>
      <p>
        Through those Distinguishingments, What is the Mattering may become available for a Standinging-in-Holding.
      </p>
      <p>
        And through that Standinging-in-Holding, This Stewardly Captain COB may become Holding-in-Standinging with What continues to hold along This Continuity Line.
      </p>
      <p>At TUPLE POSITION 0, no path through This One Situationing has yet been pre-authored.</p>
      <p>No You Are This Type of Thing or Not That Type of Thing stands pre-installed.</p>
      <p>
        No Some Future Landing has already been chosen for This Stewardly Captain COB.
      </p>
      <p>
        There is only This Stewardly Captain COB, This Continuity Line, This One Piece of Time, and This One Thing that is What is the Mattering Here.
      </p>
      <p>This is the Along from which Our Traversaling through This Tuple begins.</p>
    </section>
    """
  end

  attr :unfolded_positions, :any, required: true

  defp canonical_unfoldings(assigns) do
    ~H"""
    <div id="canonical-unfoldings" class="canonical-unfoldings">
      <.canonical_position_one :if={MapSet.member?(@unfolded_positions, 1)} />
      <.canonical_position_two :if={MapSet.member?(@unfolded_positions, 2)} />
      <.canonical_position_three :if={MapSet.member?(@unfolded_positions, 3)} />
      <.canonical_position_four :if={MapSet.member?(@unfolded_positions, 4)} />
      <.canonical_position_five :if={MapSet.member?(@unfolded_positions, 5)} />
      <.canonical_position_six :if={MapSet.member?(@unfolded_positions, 6)} />
    </div>
    """
  end

  defp canonical_position_one(assigns) do
    ~H"""
    <section id="canonical-position-1" class="canonical-document-section canonical-inherited-position">
      <h2>TUPLE POSITION 1: THROUGH</h2>
      <p>
        At TUPLE POSITION 0, This Stewardly Captain COB stands Together with This Continuity Line, This One Piece of Time, and This One Thing that is What is the Mattering Here.
      </p>
      <p>
        But for This Stewardly Captain COB to become Encounteringmenting with What is the Mattering, This Continuity Line must first find Opening.
      </p>
      <p>At TUPLE POSITION 1, This Continuity Line is finding Opening.</p>
      <p>This Opening furnishes This One LINE of Sight.</p>
      <p>
        Through This One LINE of Sight, What is the Mattering may begin becoming Encounteringmentingable to This Stewardly Captain COB.
      </p>
      <p>This One LINE of Sight does not determine What is the Mattering.</p>
      <p>
        Rather, it furnishes One Some Place upon This Continuity Line upon which What is the Mattering may begin becoming available for Standinging.
      </p>
      <p>
        From Out of This Opening, This Kind of What is the Mattering may now be finding This One Some Place for Standinging for Staging.
      </p>
      <p>
        Here, This Kind of What is the Mattering may now stand Staging as a Standinging-in-Holding through which This Stewardly Captain COB may become Holding-in-Standinging at One Discrete Turn.
      </p>
      <p>
        Through This Opening, What is the Mattering may now begin becoming Encounteringmentingable from Out of This One Some Place.
      </p>
      <p>
        This is the Through from Out of which What is the Mattering first becomes available for Encounteringmenting.
      </p>
    </section>
    """
  end

  defp canonical_position_two(assigns) do
    ~H"""
    <section id="canonical-position-2" class="canonical-document-section canonical-inherited-position">
      <h2>TUPLE POSITION 2: ACROSS</h2>
      <p>At TUPLE POSITION 1, This Continuity Line has found Opening.</p>
      <p>
        Through This One LINE of Sight, This Kind of What is the Mattering has now found This One Some Place for Standinging for Staging.
      </p>
      <p>But by itself Standinging is not enough for Distinguishingment.</p>
      <p>
        For This Kind of What is the Mattering to become Standinging for Staging Compu-Totaling-Ably, another Standinging must become available in Relation.
      </p>
      <p class="canonical-relation-recital">
        There may now be:<br /> That Kind of This Thing<br /> across<br /> This Kind of This Thing.
      </p>
      <p>
        What began as the possibility of a Continuity Line, and is now an Opening, may now be Standinging Curvingmenting from This Kind of This Thing toward That Kind of This Thing, and from That Kind of This Thing toward This Kind of This Thing upon This RAIL LINE.
      </p>
      <p>
        Across these Standings-in-Holding upon This RAIL LINE, there may now be Driftinglyinglyness.
      </p>
      <p>
        Through This Driftinglyinglyness, What is the Mattering may become Encounteringmentingably Enumerationinged for This Stewardly Captain COB Over Discrete Turns.
      </p>
      <p>
        Across these Discrete Turns, This Stewardly Captain COB may now begin Encounteringmenting Distinguishingments through Distinguishingmenting Encounteringmenting.
      </p>
      <p>This is the Across whereby Standings first become available in Relation.</p>
    </section>
    """
  end

  defp canonical_position_three(assigns) do
    ~H"""
    <section id="canonical-position-3" class="canonical-document-section canonical-inherited-position">
      <h2>TUPLE POSITION 3: PROJECTIONING CROSSING</h2>
      <h3>EN-VOLUMING</h3>
      <p>At TUPLE POSITION 2:</p>
      <p>Across these Standings-in-Holding, there may now be Driftinglyinglyness.</p>
      <p>
        An Enclosuringmenting TRACK RAIL LINE RAIL TRACK is now set upon This Curvingablemintingmenting Crooked RAIL LINE.
      </p>
      <p>
        Through The Lawful Quadranglementing that is OUR CANONICAL TUPLE, this Driftinglyinglyness is now gaining This RE-STEPPING ROOM, within which Already Standinging Relations between This Kind of this Kind of this Thing and That Kind of this Kind of this Thing may now be standing Situationingedly together in This One Some Place wherethrough they may become Traversalingable Over Discrete Turns.
      </p>
      <p>
        Within This RE-STEPPING ROOM, This RE-STEP Contraption is producing This One Non-Collapsingable Unfoldingedable Accordionationingedable Caterpillar Tunnel, having Six Evenly Divided Globular Abodes of Segmentationing, with an Enclosuringmenting Globularly Globular Abode as the Curvingablemintingmenting Crooked RAIL LINE Seam at its Seventh Segmentationing.
      </p>

      <h3 id="canonical-caterpillar-title" class="canonical-caterpillar-title">
        Regarding THE RE-STEPPING ROOM from the Threshold of the Seam at the Seventh Segmentationing
      </h3>
      <.canonical_caterpillar_tunnel />

      <p>
        Through this Caterpillar Tunnel, This RE-STEPPING ROOM is becoming Roomingingly furnished.
      </p>
      <p>
        Within this Caterpillar Tunnel, Tuple Position Three is furnishing This Approaching Landing.
      </p>
      <p>
        Within Our Current Local Moment, This Stewardly Captain COB is already standing upon This Approaching Landing in Lawful Occupancying.
      </p>
      <p>This Approaching Landing bears the consequences inherited through prior RE-STEPPING.</p>
      <p>
        Upon This Approaching Landing, this COB's inherited One Purchase-Upon-a-Real-Tractioning may now be standing available for Stewardly Encounteringmenting before the next RE-STEP establishes Our Next Local Moment.
      </p>
      <p>
        This Approaching Landing is This One Some Place upon which This Stewardly Captain COB stands in Lawful Occupancying through all its Traversaling over Discrete Turns.
      </p>
      <p>
        Situationing Sleeving is furnishing Localities within this RE-STEPPING ROOM for staging new Standings-in-Holding upon This Approaching Landing.
      </p>
      <p>
        Among the new Relations brought Here thereby, This Stewardly Captain COB may now be Traversaling.
      </p>
      <p>
        This Stewardly Captain COB's One Foot is standing fitted within One Medium-Fitting Traversaling Shoe, One Slightly-Snug Traversaling Shoe, and One Slightly-Loose Traversaling Shoe.
      </p>
      <p>
        This Stewardly Captain COB is standing placed with its One Foot fitted within its Three Traversaling Shoes upon this Single Pedal of this Spooling Unicycle with a Line-Gathering Spinningaker Revolvinging around its Central Axis.
      </p>
      <p>
        This is the Projectioning Crossing whereby This Stewardly Captain COB continually stands within Our Current Local Moment while inheriting the consequences of prior RE-STEPPING.
      </p>
    </section>
    """
  end

  defp canonical_position_four(assigns) do
    ~H"""
    <section id="canonical-position-4" class="canonical-document-section canonical-inherited-position">
      <h2>TUPLE POSITION 4: LEAN</h2>
      <h3>PURCHASE VECTOR</h3>
      <p>At TUPLE POSITION 3:</p>
      <p>This Approaching Landing bears the consequences of prior RE-STEPPING.</p>
      <p>
        Here, This One Purchase-Upon-a-Real-Tractioning thereby inherited now stands available for Stewardly Encounteringmenting before This Stewardly Captain COB's next RE-STEP.
      </p>
      <p>The Seam at the Seventh Segmentationing is furnishing Passageway.</p>
      <p>This RE-STEPPING ROOM stands crossing Tuple Position Three and Tuple Position Four.</p>
      <p>
        Instrumentationing is furnishing this RE-STEPPING ROOM for Stewardly Encounteringmenting, thereby bringing the Relations of this Situationing standing across this Passageway into Lawful Inhabitationingment.
      </p>
      <p>
        This Stewardly Captain COB, standing placed with its One Foot fitted within its Three Traversaling Shoes upon this Single Pedal of this Spooling Unicycle with a Line-Gathering Spinningaker Revolvinging around its Central Axis, together with this Assemblementing, is now standing borne within This Rocking Horse standing upon Two Curvementing Rocking Horse Rails seateding transverse to This LINE of Sight.
      </p>
      <p>
        Within this RE-STEPPING ROOM, This Stewardly Captain COB may now be visionizingably standing Laboringing over its Purchase-Upon-a-Real-Tractioning inheritedingly standing available through This Approaching Landing.
      </p>
      <p>
        Through its Gimbalizing PITON, This Stewardly Captain COB may now be Distinguishingmenting Encounteringmenting.
      </p>
      <p>
        This Stewardly Captain COB may be recursively refittinging differinging Angles of Purchase from This Approaching Landing to The Next This Approaching Landing through the Encounteringmenting Distinguishingments standing placed within this RE-STEPPING ROOM.
      </p>
      <p>
        Over recursive Laboringing within this RE-STEPPING ROOM, This Stewardly Captain COB may now be distinguishingmenting the Wobble-Wobblings among the Relations brought Here thereby.
      </p>
      <p>
        Through this Distinguishingmenting of the Wobble-Wobblings, This Stewardly Captain COB may now be making its Distinguishingmentinged Relations among these Encounteringmentinged Relations visionizingable to Stewardly Regard.
      </p>
      <p>
        Through the recursive Laboringing within this RE-STEPPING ROOM, This Stewardly Captain COB may be becoming more Feelinging within its Footholdinging.
      </p>
      <p>
        Through this becoming Feelinging of its Footholdinging, This Stewardly Captain COB may now be becoming Discoveringmenting for its Posture for its Purchase through the next RE-Step.
      </p>
      <p>
        This is the Lean through which This Stewardly Captain COB may now be holding This One Purchase-Upon-a-Real-Tractioning in Stewardly Regard toward This Next Approaching Landing.
      </p>
    </section>
    """
  end

  defp canonical_position_five(assigns) do
    ~H"""
    <section id="canonical-position-5" class="canonical-document-section canonical-inherited-position">
      <h2>TUPLE POSITION 5: THIS MOMENT OF PURCHASE</h2>
      <p>At TUPLE POSITION 4:</p>
      <p>
        Through this becoming Feelinging of its Footholdinging, This Stewardly Captain COB may now be becoming Discoveringmenting for its Posture for its Purchase through the next RE-STEP.
      </p>
      <p>
        This is the Lean through which This Stewardly Captain COB may now be holding This One Purchase-Upon-a-Real-Tractioning in Stewardly Regard toward This Next Approaching Landing.
      </p>
      <p>
        At the RE-STEP Wall at the Seam between Tuple Position Four and Tuple Position Five, This Rocking Horse is being placed back in line with This LINE of Sight.
      </p>
      <p>
        This RE-STEP Wall has been standing furnishing a Relationingable Referencing against which This Stewardly Captain COB has been standing calibrating its Posture for Excursioning.
      </p>
      <p>
        Through its Gimbalizing PITON, This Stewardly Captain COB may now be coming into standing taking Purchase from its Posture at This RE-STEP Wall.
      </p>
      <p>
        By pulling upon this Continuity Line, This Stewardly Captain COB may be pushing off from This RE-STEP Wall.
      </p>
      <p>
        This Stewardly Captain COB, standing placed with its One Foot fitted within its Three Traversaling Shoes upon the Single Pedal of This Spooling Unicycle with a Line-Gathering Spinningaker Revolvinging around its Central Axis, may now be coming directly into contacting with This Purchase Surface upon This One Piece of Time.
      </p>
      <p>
        Through this Excursioning across This Approaching Landing, This Stewardly Captain COB may now be standingingly taking Purchase upon This One Purchase-Upon-a-Real-Tractioning.
      </p>
      <p>
        This is This Moment of Purchase through which This Stewardly Captain COB comes into Stewardly Taking-Purchase upon This One Piece of Time.
      </p>
    </section>
    """
  end

  defp canonical_position_six(assigns) do
    ~H"""
    <section id="canonical-position-6" class="canonical-document-section canonical-inherited-position">
      <h2>TUPLE POSITION 6: GETTING STITCHED</h2>
      <p>At TUPLE POSITION 5:</p>
      <p>
        Through this Excursioning across This Approaching Landing, This Stewardly Captain COB has now been standingingly taking Purchase upon This One Purchase-Upon-a-Real-Tractioning.
      </p>
      <p>
        Through Stewardly Regard toward the Distinguishingments This Stewardly Captain COB has made available through its Traversaling, what has now been standing taken into Purchase may be standing available for new Placement-in-Relation among already standing Placements-in-Relation.
      </p>
      <p>
        When, through this Traversaling, This Stewardly Captain COB has been standing taking Purchase upon That Kind of This Kind of a Thing, this new Standinging-in-Holding may now become This COB's Holding-in-Standinging upon this Continuity Line as This Kind of This Kind of This Thing.
      </p>
      <p>
        When, through this Traversaling, This Stewardly Captain COB has not been standing taking Purchase upon That Kind of This Kind of a Thing, this new Standinging-in-Holding may now continue becoming into this Continuity Line as This Kind of This Kind of This Thing.
      </p>
      <p>
        In either case, what has now become Standinging-in-Holding may be standing available for future Placement-in-Relation through subsequent Traversaling.
      </p>
      <p>
        In either case, an Embroidery Stitching is being produced and is being placed upon This Stewardly Captain COB's Traversaling Jacket.
      </p>
      <p>
        This Stitching joins the Traversaling through Tuple Positions Three, Four, Five, and Six at the Seam between Tuple Position Two and Tuple Position Three into the next authored Approaching Landing, whereupon This Stewardly Captain COB is standing placed with its One Foot fitted within its Three Traversaling Shoes upon the Single Pedal of This Spooling Unicycle with a Line-Gathering Spinningaker Revolvinging around its Central Axis there upon its Approaching Landing, thereby standing Laboringing, becoming Discoveringmenting within its Posture for its Purchase once more at the lawful beginning of this next Discrete Turn.
      </p>
      <p>
        This is the Getting Stitched whereby what has been taken into Purchase becomes lawfully available for the Continuity Line to carry forward through subsequent Traversaling.
      </p>
    </section>
    """
  end

  defp canonical_caterpillar_tunnel(assigns) do
    ~H"""
    <figure id="canonical-caterpillar-tunnel" class="canonical-caterpillar-figure">
      <img
        src={~p"/images/tuple/Regarding_THE_RE-STEPPING-ROOM.png"}
        alt="Regarding THE RE-STEPPING ROOM from the Threshold of the Seam at the Seventh Segmentationing"
      />
      <figcaption>
        Every fold represents one complete Stewardly Advancementing. Within each fold, The Same Constitutional Geometry is furnished anew and inhabited by This Stewardly Captain COB as it continues Traversaling through successive Discrete Turns.
      </figcaption>
    </figure>
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
                The RAIL LINE therefore furnishes the first Regard from which Situationing Weather may become visible.
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
              <p>The RAIL LINE stands as the first lawful infrastructure of Weathering.</p>
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

              <p>The RAIL LINE acquires reciprocal orientation.</p>

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
                      PSM-COB Orchestrationing Recital of Occupancy-ing within
                      This Mounted Statefullment
                    </h4>
                  </header>

                  <div class="psm-recital-chamber__recital" aria-label="Position Three recital">
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
                The TRACK RAIL LINE RAIL TRACK stands as the first
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
            Position Three now stands available for inheritance.
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
              <p>The TRACK RAIL LINE RAIL TRACK remains standing.</p>
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
                      PSM-COB Orchestrationing Recital of Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position Four recital">
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
              <p>The TRACK RAIL LINE RAIL TRACK remains standing.</p>
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
              <p>The TRACK RAIL LINE RAIL TRACK remains standing.</p>
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
                      PSM-COB Orchestrationing Recital of Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position Five recital">
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
              <p>The TRACK RAIL LINE RAIL TRACK remains standing.</p>
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
                      PSM-COB Orchestrationing Recital of Occupancy-ing within This Mounted Statefullment
                    </h4>
                  </header>
                  <div class="psm-recital-chamber__recital" aria-label="Position Six recital">
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
