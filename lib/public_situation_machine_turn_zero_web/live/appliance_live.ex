defmodule PublicSituationMachineTurnZeroWeb.ApplianceLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "THE APPLIANCE")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:appliance}>
      <main id="appliance-page" class="site-page appliance-surfaces">
        <Layouts.locality_threshold title="THE APPLIANCE" id="appliance-threshold" />

        <article class="appliance-surfaces__journey">
          <header class="appliance-surfaces__introduction">
            <p>What follows are several of the appliance's most developed operational surfaces.</p>
            <p>
              Many remain engineering and constitutional workspaces rather than finished public interfaces.
            </p>
            <p>
              They show the architecture exactly where it stands today—and the work this Kickstarter will help us continue.
            </p>
          </header>

          <section class="appliance-surfaces__chapter" aria-labelledby="staginging-complex-title">
            <h2 id="staginging-complex-title">THE SITUATIONAL STAGINGING COMPLEX</h2>
            <p>
              The Situational Staginging Complex provides operational surfaces through which This Stewardly Captain COB may Traversal a Situationing and stand in Regard toward its Traversalings from a Navigationing perspective.
            </p>

            <.surface_image
              filename="situationing-stage.svg"
              alt="Placeholder for the Situationing Stage Navigationing view"
              caption="Situationing Stage. A Navigationing view onto This COB’s Traversalings along its Continuity Line Over Discrete Turns."
            />

            <p>
              At its center, the Situationing Stage makes This COB’s developing Traversalings inspectioningable along its Continuity Line over Discrete Turns.
            </p>
            <p>
              Beginning at the base of the Stage, we can briefly work our way upward through some of what is already operationing.
            </p>
          </section>

          <.surface_section
            id="dirt-tracks"
            title="Decision Integrity Recordinging Tractioning Tracks"
            filename="dirt-tracks.svg"
            alt="Placeholder for the Decision Integrity Recordinging Tractioning Tracks"
          >
            The DIRT Tracks preserve visible traces of repeated Traversalings. Their dot patterns record developing Pull Values, allowing excursioning toward YT and returning toward XT to remain inspectioningable across Discrete Turns.
          </.surface_section>

          <.surface_section
            id="re-step"
            title="RE-Step"
            filename="re-step.svg"
            alt="Placeholder for the RE-STEP operational controls"
          >
            RE-STEP advances This Continuity Line by One Discrete Turn. The controls surrounding it also expose Stewardly Instrumentationing Affordmentings used when furnishing relations through which future Traversaling may occur.
          </.surface_section>

          <.surface_section
            id="appliance-readout-lane"
            title="Appliance Readout Lane"
            filename="appliance-readout-lane.svg"
            alt="Placeholder for the Appliance Readout Lane"
          >
            Operational Outreadingments make visible some of the bureaucratic work occurring throughout the PUBLIC-SITUATION-MACHINE- as its offices maintain the conditions through which Traversaling and Lawful Successioning remain available.
          </.surface_section>

          <.surface_section
            id="situationing-stage-turn-zero"
            title="Situationing Stage Turn Zero"
            filename="situationing-stage-turn-zero.svg"
            alt="Placeholder for the Situationing Stage Turn Zero surface"
          >
            <p>
              Every Locality within the PUBLIC-SITUATION-MACHINE- has a Turn Zero surface for Staging-in-Place operations.
            </p>
            <p>
              Turn Zero does not mean the beginning of the Situationing. Each new Locality brings another Turn Zero—another One Some Place brought Here as This Stewardly Captain COB continues its Traversaling Over Discrete Turns.
            </p>
          </.surface_section>

          <.surface_section
            id="needle-region-weather-service"
            title="Needle Region + Weather Service"
            filename="needle-region-weather-service.svg"
            alt="Placeholder for the Needle Region and Situationing Weathering Service"
          >
            <p>
              The appliance's Directorate of Needle Mechanics provides operational readings of XT—What Continues to Hold—and YT—What is Becoming. These are not scores. They make the developing Pull through This COB’s Traversalings inspectioningable over Discrete Turns.
            </p>
            <p>
              Above the Needle Region, the Situationing Weathering Service provides higher-level readings against Weather furnished particularly for the Situationing at hand.
            </p>
            <p>
              The PUBLIC-SITUATION-MACHINE- does not predict what happens next. Its instrumentationing helps make differences in Traversaling available for Stewardly Regard.
            </p>
          </.surface_section>

          <section
            class="appliance-surfaces__chapter"
            aria-labelledby="observationmintingmenting-title"
          >
            <h2 id="observationmintingmenting-title">OBSERVATIONMINTINGMENTING</h2>
            <p>
              Traversaling is one of Three Canonical Postures available to This Stewardly Captain COB. This COB may also enter Observationmintingmenting Posture, where preserved Traversalings can be inspectioned without altering what was Encounteringmented through them.
            </p>
            <p>
              The Observationmintingmenting Annex is a substantial working region of the appliance devoted to these Stewardly Laborings.
            </p>
          </section>

          <.surface_section
            id="navigationing-gallery"
            title="Tuple Ship Navigationing Gallery + Observationing Harbor Rail"
            filename="tuple-ship-navigationing-gallery.svg"
            alt="Placeholder for the Tuple Ship Navigationing Gallery and Observationing Harbor Rail"
          >
            <p>
              The Navigationing Gallery provides a working surface through which This Stewardly Captain COB may bring its Observationing Harbors and preserved Traversalings into Stewardly Regard.
            </p>
            <p>
              One Traversaling does not tell the whole story of a Situationing. Here, repeated Traversalings may be revisited and regarded together without changing what was Encounteringmented through them.
            </p>
            <p>
              The Observationing Harbor Rail provides Navigationing affordmentings for working with those Regards. Observationing Harbors may be placed, focused, and orientationed so that This Stewardly Captain COB may inspect the Relations becoming Distinguishingmentingable among its Traversalings Over Discrete Turns.
            </p>
            <p>The Annex does not determine what those Traversalings mean.</p>
            <p>
              It furnishes This Stewardly Captain COB with ways of moving its Regard around what has been preserved.
            </p>
          </.surface_section>

          <.surface_section
            id="watchstead"
            title="The Watchstead"
            filename="watchstead.svg"
            alt="Placeholder for The Watchstead"
          >
            <p>The Watchstead is the Continuity Ward of the Observationmintingmenting Annex.</p>
            <p>
              Here, This Stewardly Captain COB may steward what may become newly Encounteringmentingable without treating every possible new Relation as though it were already standing available.
            </p>
            <p>
              The Watchstead helps preserve Continuity as the field of Observationing changes—providing operational machinery through which new Encounteringments may be inspectioned and qualificationed before the field is allowed to widen.
            </p>
          </.surface_section>

          <.surface_section
            id="cabinet-cellar-rooms"
            title="The Cabinet Room and The Cellar Room"
            filename="cabinet-cellar-rooms.svg"
            alt="Placeholder for The Cabinet Room and The Cellar Room"
          >
            <p>
              The Cabinet Room and Cellar Room provide chambers aboard The Tuple Ship for the Stewardly Laborings of Retentioning and Cellaring.
            </p>
            <p>
              Not everything made available through Traversaling and Observationmintingmenting needs to remain in active Regard forever. Some material may need to remain actively retained. Other material may be ready for Cellaring—preserved without remaining actively present within This COB’s ongoing Observationmintingmenting.
            </p>
            <p>
              This allows the PUBLIC-SITUATION-MACHINE- to preserve Continuity without confusing Continuity with the permanent accumulation of Every Thing. What continues to hold may remain available in different ways, under different forms of Stewardly Custody, as the Situationing continues Over Discrete Turns.
            </p>
          </.surface_section>
        </article>
      </main>
    </Layouts.app>
    """
  end

  attr :filename, :string, required: true
  attr :alt, :string, required: true
  attr :caption, :string, default: nil

  defp surface_image(assigns) do
    ~H"""
    <figure class="appliance-surface-image">
      <img src={~p"/images/appliance/#{@filename}"} alt={@alt} />
      <figcaption :if={@caption}>{@caption}</figcaption>
    </figure>
    """
  end

  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :filename, :string, required: true
  attr :alt, :string, required: true
  slot :inner_block, required: true

  defp surface_section(assigns) do
    ~H"""
    <section id={@id} class="appliance-surfaces__surface">
      <h3>{@title}</h3>
      <.surface_image filename={@filename} alt={@alt} />
      <div class="appliance-surfaces__prose">{render_slot(@inner_block)}</div>
    </section>
    """
  end
end
