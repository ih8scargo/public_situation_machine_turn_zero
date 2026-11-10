defmodule PublicSituationMachineTurnZeroWeb.SnailGalleryPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  attr :model, :map, required: true
  attr :form, :any, required: true
  attr :error, :string, default: nil

  def panel(assigns) do
    ~H"""
    <details
      id="gallery-registration"
      class="wgr-workshop sgr-panel"
      phx-mounted={JS.ignore_attributes(["open"])}
    >
      <summary>CUBICAL · AROUND ABOUT Gallery · RE-SURFACING registration rehearsal</summary>
      <p class="sgr-intro">Move an inspection ghost, retain the furnished standing.</p>
      <p>
        The six-reference-unit HERE extent stays fixed. Orbit moves the ghost center about the axle; spin turns it about its own center. These controls neither furnish a new CUBICAL nor perform NAV-STEP or RE-STEP.
      </p>
      <p id="sgr-registration-status">
        PROVISIONAL overlay: the earlier eight-sided Gallery and Snail body have no adopted common transform. UN-FOLDING-derived vertical registration and physical Craft/cylinder dimensions remain unresolved.
      </p>
      <p :if={@error} id="sgr-error" role="alert">{@error}</p>
      <section id="sgr-recovered-constraints">
        <h3>Recovered furnishing constraints · no solids moved</h3>
        <p id="sgr-ground-relation">
          Ground is independent. Table working surface is coincident with Ground G; Human stands AT the Table at H BELOW G. The COB's Table-level contact is at G. No numeric world elevation is selected here.
        </p>
        <p id="sgr-unfolding">
          The SIX-unit vertical CUBICAL is furnished through wedge UN-FOLDING when HERE is established. The contraption height is SIX extents. Its six-unit UP OVER and six-unit DOWN UNDER relations from Ground are distinct; they do not furnish a single twelve-unit object. The old visually scaled box is not this furnishing and is no longer drawn as its volume.
        </p>
        <p id="sgr-centered-stand">
          The COB stand is centered WITH the Table/axle and rises ONE extent UP FROM Ground. The COB's local 1 × 1 × 1 CUBICAL corresponds WITH the surrounding six-unit geometry. Stand height, local CUBICAL and eye height remain distinct; no stacked two-unit body is assumed.
        </p>
        <p id="sgr-cylinder-conflict">
          CLEARANCE UNRESOLVED: the current central spindle is a zero-width line, not a dimensioned cylinder. A centered solid stand and solid cylinder occupying the same axial interval would overlap. No radius, bore, mount, profile or offset is invented to clear them.
        </p>
        <p id="sgr-footing-constraints">
          In the two-footing RE-STEPPING Room, each Little ROUNDING Footing stands TOWARD half the extent TOWARD the original NEXT. Each has ONE Lanterning Bug by default, reconfigurable to TWO or THREE. Footing geometry, Bug appointmenting and SIX-unit extent are separate. Subsequent Footings accrete FROM WITHIN folding geometry in the 0-to-1 region HERE; two initial Footings are not an accretion cap.
        </p>
        <p>
          These are recorded requirements, not a new Room, Footing acquisition or Bug assignment. The existing local Scooping Footing records are not reinterpreted as the recovered Room.
        </p>
        <ul id="sgr-constraint-conflicts">
          <li :for={c <- @model.furnishing_constraints.conflicts} id={"sgr-conflict-"<>c.id}>
            <strong>{c.status}:</strong> {c.finding}
          </li>
        </ul>
        <p>
          The recovered relationships are retained; physical registration stops here pending wedge, Ground and centered-interface measurements.
        </p>
      </section>
      <.form for={@form} id="sgr-form" phx-change="gallery-registration-inspect">
        <.input
          field={@form[:radius]}
          type="number"
          min="0"
          max="3"
          step="0.05"
          label="Ghost radial offset · 0–3 comparison model units"
          class="wgr-input"
          phx-debounce="200"
        />
        <.input
          field={@form[:orbit]}
          type="range"
          min="0"
          max="360"
          step="1"
          label="AROUND ABOUT axle · orbit degrees"
          class="wgr-range"
          phx-debounce="150"
        />
        <.input
          field={@form[:spin]}
          type="range"
          min="-180"
          max="180"
          step="1"
          label="Local spin about ghost center · degrees"
          class="wgr-range"
          phx-debounce="150"
        />
        <.input
          field={@form[:coupling]}
          type="select"
          label="Candidate coupling · inspection only"
          options={[
            {"Independent local bearing", "independent"},
            {"Co-rotate: spin + orbit", "co"},
            {"Counter-rotate: spin − orbit", "counter"}
          ]}
          class="wgr-input"
        />
      </.form>
      <button id="sgr-reset" type="button" phx-click="gallery-registration-reset">Return ghost to HERE · inspection only</button>
      <div class="sgr-results" aria-live="polite">
        <p
          id="sgr-pose"
          data-orbit={@model.provisional.ghost.orbit_degrees}
          data-yaw={@model.provisional.ghost.world_yaw}
        >
          Orbit {@model.provisional.ghost.orbit_degrees}° · local spin {@model.provisional.ghost.local_spin_degrees}° · resulting bearing {@model.provisional.ghost.world_yaw}°.
        </p>
        <p id="sgr-margin" data-admissible={to_string(@model.computed.selected.admissible)}>
          Plan boundary margin: {Float.round(@model.computed.selected.boundary_margin, 4)}. Negative means outside the actual eight-sided boundary.
        </p>
        <p id="sgr-clearance">
          Historical scaled-box/JANUSITE contacts (not recovered UN-FOLDING clearance): {length(
            @model.computed.selected.wall_contacts
          )}. Conservative wall-distance lower bound: {Float.round(
            @model.computed.selected.wall_distance_lower_bound,
            4
          )}. Prior annulus overlap in plan: {to_string(@model.computed.selected.table_plan_overlap)}; prior-annulus vertical surface gap {Float.round(
            @model.computed.selected.table_vertical_gap,
            3
          )}. Thickness and working/body clearance are unmeasured.
        </p>
        <p id="sgr-next">
          Fixed HERE TOWARD original NEXT: {inspect(@model.observed.next.center)}. This direction is not reassigned toward the Table.
        </p>
      </div>
      <div
        id="sgr-renderer"
        phx-hook="GalleryRegistration"
        phx-update="ignore"
        data-model={Jason.encode!(@model)}
      >
        <div class="sgr-paired">
          <figure>
            <figcaption>PLAN · X/Z · shared axle and source mesh</figcaption><svg
              id="sgr-plan"
              viewBox="0 0 600 600"
              role="img"
              aria-label="Gallery comparison plan with fixed HERE, NEXT, round Table and movement ghost"
            ></svg>
          </figure>
          <figure>
            <figcaption>VERTICAL · Z/Y · Groundward / UP OVER relations</figcaption><svg
              id="sgr-section"
              viewBox="0 0 600 600"
              role="img"
              aria-label="Vertical outreading of the same JANUSITE faces and CUBICAL ghost"
            ></svg>
          </figure>
        </div>
        <p class="sgr-key">
          White: fixed HERE · mint: circular STANDINGING LANDINGING / existing JANUSITE model faces · gold: proposed THREE-extent plan rim · muted: prior annulus · violet: plan-motion ghost only, not a furnished vertical volume · pink: original NEXT. Transparent diagnostic projections retain every source wall; they are not optical visibility proofs.
        </p>
        <p id="sgr-outreading" data-outreading aria-live="polite">
          Hover or focus a source; click/Enter pins, Escape releases. Registered observations highlight in both Regards. Keyboard focus distinguishes plan-coincident observations at different heights.
        </p>
      </div>
      <section
        id="sgr-proposed-table"
        data-diameter={@model.provisional.table.nominal_diameter_extents}
      >
        <h3>Proposed RE-SURFACING Table · THREE extents diameter</h3>
        <p>
          Centered on the Snail axle. HERE remains SIX extents per side. The proposed Table is neither a CUBICAL nor a Landinging. Nominal Table radius 1.5 extents = {Float.round(
            @model.provisional.table.comparison_radius,
            4
          )} comparison model units.
        </p>
        <p>
          Height, thickness and inner profile remain unresolved. The centered 1.5-extent rim-to-square-side difference is not a traversaling pathway.
        </p>
        <p id="sgr-proposed-table-fit">
          Gallery plan margin {Float.round(@model.provisional.table.gallery_plan_margin, 4)}; selected ghost rim-containment margin {Float.round(
            @model.provisional.table.ghost_rim_containment_margin,
            4
          )}. These are planar comparisons, not Craft or navigation clearance.
        </p>
        <p>
          COB-to-rim horizontal distances: {Float.round(
            @model.provisional.table.cob_nearest_plan_rim_distance,
            4
          )}–{Float.round(@model.provisional.table.cob_farthest_plan_rim_distance, 4)} model units. The Seat and COB stand project inside the proposed rim; their physical separation is unregistered. Volumetric reach is unknown without height and a physical stand/Craft envelope.
        </p>
      </section>
      <h3>Candidate courses · 0°–90° about the axle</h3>
      <div class="sgr-table-wrap">
        <table id="sgr-candidates">
          <thead>
            <tr>
              <th>Coupling</th><th>Sample margin</th><th>Continuous boundary lower bound</th><th>
                Boundary certified?
              </th><th>Max NEXT heading error</th><th>Prior annulus work distance</th><th>
                Proposed 3-extent Table min rim margin
              </th><th>
                Historical box-contact poses
              </th>
            </tr>
          </thead>
          <tbody>
            <tr :for={c <- @model.computed.courses} id={"sgr-course-"<>c.mode}>
              <td>{c.mode}</td><td>{Float.round(c.minimum_sample_margin, 4)}</td><td>
                {Float.round(c.continuous_boundary_lower_bound, 4)}
              </td><td>{to_string(c.continuous_boundary_certified)}</td><td>
                {Float.round(c.maximum_next_heading_error, 2)}°
              </td><td>{Float.round(c.maximum_table_distance_from_ghost, 4)}</td><td>
                {Float.round(c.proposed_table_minimum_rim_containment_margin, 4)}
              </td><td>
                {length(c.sampled_wall_contact_poses)} / {c.wall_sample_count}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p>
        No course is certified for continuous physical clearance or operational Traversaling. A positive static margin is not that authority.
      </p>
      <section id="sgr-craft">
        <h3>Craft relation · derive the bearing from registration</h3>
        <p>
          The existing Seat reference is retained. A fixed 45° orbital or Craft heading is superseded; 45° is only a hypothesis to derive from actual registered relationships. No prescribed ray, physical Craft move or mechanical LOCK is furnished.
        </p>
        <p id="sgr-cob">
          Historical COB eye reference {inspect(@model.provisional.cob.eye)} · Human eye {inspect(
            @model.provisional.cob.human_eye
          )} · height difference {@model.provisional.cob.eye_delta_y}. These old eye/ray measurements do not locate the recovered centered stand or calibrate its eye. Reach is not capped by the Human square. Target distances and obstructions are inspectable; physical reach remains unknown. COB lies {Float.round(
            @model.provisional.cob.angle_from_current_human_regard,
            2
          )}° from the current quarter-turn camera bearing. Equal eye level alone does not prove visibility.
        </p>
      </section>
      <section id="sgr-material-work">
        <h3>Retained annulus and material provenance · historical comparison</h3>
        <p>
          The earlier annulus is retained as source geometry, not the proposed three-extent working Table. Its height, opening and work face are not inherited by the new proposal. The Table remains ROUND when presented on the Longhouse Gallery Wall.
        </p>
        <%= if @model.provisional.material_work.material do %>
          <p id="sgr-material" data-material={@model.provisional.material_work.material["id"]}>
            {@model.provisional.material_work.material["text"]}
          </p>
          <p>
            FROM existing registered turns and Footings; historical work preview on prior annulus face {@model.provisional.material_work.proposed_host} at {inspect(
              @model.provisional.material_work.proposed_destination
            )}. The open axle center is not treated as a support surface. Original standing remains in place. This historical face is not a destination on the proposed three-extent Table; that destination remains unregistered. No staging resolution or re-placement occurs here. The Furnishing COB resolves active staging; Traversaling can inherit only actually furnished standing/pathway. These are capacities of the same COB.
          </p>
          <details id="sgr-material-provenance">
            <summary>Material FROM, established standing and proposed work</summary><pre>{Jason.encode!(@model.provisional.material_work,pretty: true)}</pre>
          </details>
        <% else %>
          <p id="sgr-material-empty">
            No registered material. This inspection supplies no authored item.
          </p>
        <% end %>
      </section>
      <section id="sgr-walls">
        <h3>JANUSITE wall observations</h3>
        <p>
          {length(@model.computed.curvature.observations)} successive registered observations; analytic curvature {Float.round(
            @model.computed.curvature.analytic_curvature,
            5
          )}. Horizontal and vertical readings use identical world points and addresses.
        </p>
        <p>
          UNRESOLVED: authored words do not currently deform the source mesh. No Caterpillar displacement law, new wall or traversaling pathway has been invented. Existing wall-registration and eye-ray findings remain intact.
        </p>
      </section>
      <details id="sgr-ledger" phx-mounted={JS.ignore_attributes(["open"])}>
        <summary>Observed / computed / provisional / constitutionally confirmed ledger</summary>
        <pre>{Jason.encode!(Map.drop(@model,[:observed]) |> Map.put(:observed,Map.drop(@model.observed,[:walls]) |> Map.update!(:table,&Map.drop(&1,[:mesh]))),pretty: true)}</pre>
      </details>
    </details>
    """
  end
end
