defmodule PublicSituationMachineTurnZeroWeb.TupleShipFieldLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "This Tuple Ship Field")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:tuple_ship_field}>
      <main id="tuple-ship-field-page" class="site-page field-page">
        <Layouts.locality_threshold title="This Tuple Ship Field" id="tuple-ship-field-threshold" />
        <header class="site-page__header site-page__header--orientation">
          <p class="site-page__orientation">
            This Locality presently furnishes regard toward This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
          </p>
        </header>

        <section class="field-page__section">
          <h2>
            This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining
          </h2>
          <p>
            The Same General Civilizationalizing Constitutioningable Geometry furnishes the possibility of a civilization in which every neighborhood, watershed, classroom, workshop, archive, harbor, observatory, laboratory, council, organization, household, and place may steward its own lawful Continuity Line without surrendering it to a central authority.
          </p>
          <p>Each stands as its own established Locality.</p>
          <p>Each authors what continues holding there.</p>
          <p>
            Each determines the signals through which holdingness, repair, inheritance, correspondence, and stewardship may be recognized and revealed.
          </p>
          <p>Each remains free to correspond with every other.</p>
          <p>
            Together they form This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
          </p>
        </section>

        <section class="field-page__section">
          <h2>Every Tuple Ship</h2>
          <p>
            Each PUBLIC-SITUATION-MACHINE- together with its Stewardly Captain -COORDINATIONING-OPERATIONING-BOBBINING forms one Tuple Ship—one established Locality within This One Great Free Public Tuple Ship Field of Globularly Bobbininging Globular Bobbining.
          </p>
          <p>A Tuple Ship is not merely software.</p>
          <p>It is not merely a record.</p>
          <p>It is not merely a workflow.</p>
          <p>
            It is one lawful place within the Field where Situationings may continue holding through discrete pieces of time.
          </p>
          <p>No Tuple Ship stands above another.</p>
          <p>No Tuple Ship replaces another.</p>
          <p>Each stewards what it alone is responsible for stewarding.</p>
          <p>Each remains free to correspond with every other Tuple Ship throughout the Field.</p>
        </section>

        <section class="field-page__section">
          <h2>Correspondencing Throughout the Field</h2>
          <p>Tuple Ships need not become identical.</p>
          <p>Neither must they agree.</p>
          <p>Instead, they may correspond.</p>
          <p>They may publish Correspondencingments.</p>
          <p>They may exchange authored Situationings.</p>
          <p>They may furnish Bearingings.</p>
          <p>They may contribute instrumentation.</p>
          <p>They may share Encounteringments.</p>
          <p>They may discover new constitutional geometry.</p>
          <p>The Field grows not through centralization, but through lawful Correspondencing.</p>
          <p>
            Each Tuple Ship continues holding its own Continuity Line while enriching the Field shared by all.
          </p>
        </section>

        <section class="field-page__section">
          <h2>Furnishing the Public Field Beyond this Campaign</h2>
          <p>The long-term objective of the PUBLIC-SITUATION-MACHINE- is simple.</p>
          <p>Everyone should have free access to one PUBLIC-SITUATION-MACHINE- at a time.</p>
          <p>
            The Public Field grows by making that possible. Individuals should be able to inhabit one PUBLIC-SITUATION-MACHINE- freely, while organizations requiring stewardship of multiple Situationings furnish the shared infrastructure that enables universal access.
          </p>
          <p>The Propagationing is simple.</p>
          <p>One machine for every one.</p>
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
          <p>To contribute constitutional geometry.</p>
          <p>To publish Correspondencingments.</p>
          <p>
            To participate in the continued furnishing of a civilization whose Localities remain free to correspond without surrendering the lawful Continuity Lines that make each one distinct.
          </p>
          <p>This One Great Free Public Tuple Ship Field.</p>
          <p><em>A civilization holding with no center.</em></p>
        </section>
      </main>
    </Layouts.app>
    """
  end
end
