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
        <Layouts.locality_threshold
          title="THE APPLIANCE"
          id="appliance-threshold"
          reading="The Bearinging of Enriching Inheritancing"
        >
          <:description>
            <p>
              The PUBLIC-SITUATION-MACHINE- furnishes the Stewardly Instrumentationing through which The Same General Civilizationalizing Constitutioningable Reasoning Geometry may continue enriching inheritance Over Discrete Turns.
            </p>
            <p>Its Offices do not determine what a Situationing means.</p>
            <p>
              They furnish the Constitutional Machinery through which Constitutioning Humans may discover what continues to Hold, what is Becoming, and what may come to stand through Traversaling.
            </p>
          </:description>
        </Layouts.locality_threshold>

        <article class="appliance-surfaces__journey">
          <header class="appliance-surfaces__introduction">
            <h2 id="aboard-working-appliance-title">ABOARD THE WORKING APPLIANCE</h2>
            <p>The PUBLIC-SITUATION-MACHINE- already exists as a working appliance.</p>
            <p>
              Before continuing into the appliance surfaces, you may wish to watch this
              short guided Traversaling of the PUBLIC-SITUATION-MACHINE-. It follows This
              Stewardly Captain COB through one furnished Situationing while introducing
              the geometry, RE-STEP, and the constitutional ideas developed in this
              walkthrough.
            </p><br />

            <div class="video-embed">
              <iframe
                width="100%"
                height="480"
                src="https://www.youtube.com/embed/VKw0nNfBlXs"
                title="Guided Traversaling Demonstration"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowfullscreen
              ></iframe>
            </div><br />
            <p>What follows are several of the appliance's most developed operational surfaces.</p>
            <p>
              Many remain engineering and constitutional workspaces rather than finished public interfaces.
            </p>
            <p>
              They show the architecture exactly where it stands today—and the work This Kickstarter En-Campaign-Menting will help us continue in Regard to This One Great Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
            </p>
          </header>

          <section class="appliance-surfaces__chapter" aria-labelledby="staginging-complex-title">
            <h2 id="staginging-complex-title">THE SITUATIONAL STAGINGING COMPLEX</h2>
            <p>
              The Situational Staginging Complex provides operationingable surfaces through which This Stewardly Captain COB may Traversal This One Situationing and also stand in Regard toward its Traversalings from a Navigationing perspective.
            </p>
            <.surface_image
              filename="situationing-stage.png"
              alt="Situationing Stage showing a Navigationing view of This COB’s Traversalings"
              caption="Situationing Stage. A Navigationing view onto This COB’s Traversalings along its Continuity Line Over Discrete Turns."
            />
            <p>
              At its center, the Situationing Stage makes This Stewardly Captain COB’s developing Traversalings inspectioningable along This One Continuity Line Over Discrete Turns.
            </p>
            <p>
              Beginning at the base of the Stage, we can briefly work our way upward through some of what is already operationing.
            </p>
          </section>

          <.surface_section
            id="dirt-tracks"
            title="Decision Integrity Recordinging Tractioning Tracks"
            filename="dirt-tracks.png"
            alt="Decision Integrity Recordinging Tractioning Tracks"
          >
            The DIRT Tracks preserve visible traces of repeated Traversalings. These dot patterns record developing Pull Values, allowing Departing toward YT and Returning toward XT to remain inspectioningable across Discrete Turns.
          </.surface_section>

          <.surface_section id="re-step" title="RE-Step" filename="re-step.png" alt="RE-STEP controls">
            RE-STEP ends This One Discrete Turn and begins This One Continuity Line's inheritance of its next Discrete Turn. The controls surrounding RE-STEP expose Stewardly Instrumentationing Affordmentings through which the Constitutioning Human may furnish the XT-YT Relationings within which This Stewardly Captain COB's Traversaling may occur.
          </.surface_section>

          <.surface_section
            id="appliance-readout-lane"
            title="Appliance Readout Lane"
            filename="appliance-readout-lane.png"
            alt="Appliance Readout Lane"
          >
            Operational Outreadingments make visible some of the Stewardly Laboringings of the Constitutional Bureaucracy that stands Constitutioning the PUBLIC-SITUATION-MACHINE-. Stewarding Offices of the Appliance—including This Clerk & Recordinginger of Continuity Standards and Practicing and This Office of Topological Traversaling Services—maintain the conditions through which Traversaling and Lawful Successioning stand available for the Stewardly Regard of Constitutioning Humans.
          </.surface_section>

          <.surface_section
            id="situationing-stage-turn-zero"
            title="Situationing Stage Turn Zero Surface"
            filename="situationing_stage_turn_zero.png"
            alt="Situationing Stage Turn Zero Surface"
          >
            <p>
              Every Constitutional Locality within the PUBLIC-SITUATION-MACHINE- furnishes a Turn Zero Surface for Staginging-Em-Place-Menting operations.
            </p>
            <p>
              Turn Zero does not mean the beginning of This One Situationing. Each new Locality affords another Turn Zero—another This One Some Place brought Here as This Stewardly Captain COB continues its Traversaling Over Discrete Turns.
            </p>
            <p>Every Turn Zero is Here.</p>
            <p>
              Every Turn Zero stands as This One Place from which This Stewardly Captain COB may begin bringing The Thing That is What is The Mattering into Standinging-in-Holding.
            </p>
          </.surface_section>

          <.surface_section
            id="needle-region-weather-service"
            title="The Needle Region + Situationing Weathering Service"
            filename="needle-region-weather-service.png"
            alt="The Needle Region and Situationing Weathering Service"
          >
            <p>
              The appliance's Directorate of Needle Mechanics provides operational Outreadingments of XT—What Continues to Hold—and YT—What is Becoming.
            </p>
            <p>
              These are not scores. They are Stewardly Outreadingments. They make the developing Pull through This COB’s Traversalings inspectioningable Over Discrete Turns.
            </p>
            <p>
              Above The Needle Region, the Situationing Weathering Service provides higher-level readings of Weather furnished particularly for This One Situationing through its XT-YT Relationings.
            </p>
            <p>
              The PUBLIC-SITUATION-MACHINE- does not predict what happens next. Through Stewardly Instrumentationing, the Constitutioning Human may make Distinguishingments available for Stewardly Regard.
            </p>
          </.surface_section>

          <section
            class="appliance-surfaces__chapter"
            aria-labelledby="observationmintingmenting-title"
          >
            <h2 id="observationmintingmenting-title">THE OBSERVATIONMINTINGMENTING ANNEX</h2>
            <p>
              Traversaling is the first of Three Canonical Postures available to This Stewardly Captain COB. This COB may also enter Observationmintingmenting Posture, where Embroidery-Stitched Traversalings may be inspectioned without altering what came to stand through them.
            </p>
            <p>
              The Observationmintingmenting Annex is a substantial working region of the PUBLIC-SITUATION-MACHINE- through which these Stewardly Laboringings are carried out.
            </p>
          </section>

          <.surface_section
            id="navigationing-gallery"
            title="Tuple Ship Navigationing Gallery + Observationing Harbor Rail"
            filename="tuple-ship-navigationing-gallery.png"
            alt="Tuple Ship Navigationing Gallery"
          >
            <:additional_images>
              <.surface_image
                filename="tuple-ship-navigation-harbor-rail.png"
                alt="Observationing Harbor Rail"
              />
            </:additional_images>
            <p>
              The Appliance's Tuple Ship Navigationing Gallery furnishes instrumentationing through which This Stewardly Captain COB may bring its Observationing Harbors and preserved Traversalings together into Stewardly Regard.
            </p>
            <p>No One Traversaling tells the whole story of This One Situationing.</p>
            <p>
              Here, the Constitutioning Human may revisit and Re-Regard any number of This Stewardly Captain COB's Traversalings, all standing together in This One Place, without changing what was Encounteringmented through them.
            </p>
            <p>
              The Observationing Harbor Rail provides Navigationing Affordmentings through which Observationing Harbors may be placed, focused, orientationed, and compared so that the Constitutioning Human may inspect the XT-YT Relationing becoming Distinguishingmentingable among These Traversalings Over Discrete Turns.
            </p>
            <p>
              The Observationmintingmenting Annex does not determine what those Traversalings mean. Rather, it furnishes This Stewardly Captain COB with Stewardly Affordmentings through which Regard itself may continue Traversaling.
            </p>
          </.surface_section>

          <.surface_section
            id="watchstead"
            title="The Watchstead"
            filename="watchstead-continuity-ward.png"
            alt="The Watchstead Continuity Ward"
          >
            <p>The Watchstead is the Continuity Ward of the Observationmintingmenting Annex.</p>
            <p>
              Here, This Stewardly Captain COB may steward what is becoming newly Encounteringmentingable without treating every possible new Relationing as though it were already Holding-in-Standinging.
            </p>
            <p>
              The Watchstead helps preserve Continuity as the field of Observationing changes—providing operational machinery through which new Encounteringments may be inspectioned and qualificationed before those Encounteringments become available for the widening of the Continuity Field.
            </p>
          </.surface_section>

          <.surface_section
            id="cabinet-cellar-rooms"
            title="The Cabinet Room and The Cellar Room"
            filename="the_cabinet_room.png"
            alt="The Cabinet Room"
          >
            <:additional_images>
              <.surface_image filename="the_cellar_room.png" alt="The Cellar Room" />
            </:additional_images>
            <p>
              The Cabinet Room and Cellar Room furnish chambers aboard The Tuple Ship for the Stewardly Laboringings of Retentioning and Cellaring.
            </p>
            <p>
              Not everything made available through Traversaling and Observationmintingmenting needs to remain in active Stewardly Regard forever. Some material may need to remain actively retained. Other material may be ready for Cellaring—preserved without remaining actively present within This Stewardly Captain COB’s ongoing Observationmintingmenting.
            </p>
            <p>
              This allows the PUBLIC-SITUATION-MACHINE- to preserve Continuity without confusing Continuity with the permanent accumulation of Every Thing. What continues to hold may remain available under different forms of Stewardly Custody as This One Situationing continues unfolding Over Discrete Turns.
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
  slot :additional_images
  slot :inner_block, required: true

  defp surface_section(assigns) do
    ~H"""
    <section id={@id} class="appliance-surfaces__surface">
      <h3>{@title}</h3>
      <div class="appliance-surfaces__images">
        <.surface_image filename={@filename} alt={@alt} />
        {render_slot(@additional_images)}
      </div>
      <div class="appliance-surfaces__prose">{render_slot(@inner_block)}</div>
    </section>
    """
  end
end
