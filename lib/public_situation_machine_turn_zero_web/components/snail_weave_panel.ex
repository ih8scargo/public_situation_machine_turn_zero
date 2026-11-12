defmodule PublicSituationMachineTurnZeroWeb.SnailWeavePanel do
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Architecture, as: A
  attr :id, :string, required: true
  attr :material, :string, default: nil
  slot :membrane
  slot :xt
  slot :yt

  def gallery_wall(assigns) do
    ~H"""
    <div
      id={@id}
      class={["sw-composition", @membrane != [] && "relative"]}
      data-material={@material}
      aria-label="Longhouse Gallery Wall · flat Looking THROUGHING THROUGHING Glass"
    >
      <div class="sw-composition-from" aria-hidden={if @xt == [], do: "true"}>
        {render_slot(@xt)}
      </div>
      <article class="sw-composition-across">{render_slot(@yt)}</article>
      {render_slot(@membrane)}
    </div>
    """
  end

  attr :state, :map, required: true
  attr :model, :map, required: true
  attr :form, :any, required: true
  attr :emergence_form, :any, required: true
  attr :quill_form, :any, required: true
  attr :take_form, :any, required: true
  attr :restore_form, :any, required: true
  attr :view, :string, required: true
  attr :interface, :string, required: true
  attr :message, :string, default: nil

  def panel(assigns) do
    assigns =
      assign(
        assigns,
        :turn,
        if(assigns.state["active"],
          do: Enum.find(assigns.state["turns"], &(&1["id"] == assigns.state["active"]["turn"])),
          else: List.last(assigns.state["turns"])
        )
      )

    ~H"""
    <section id="snail-weave" class="wgr-workshop sb-panel" data-revision={@state["revision"]}>
      <p class="sb-eyebrow">ONE SNAIL HOUSE · WORK WITH THE FURNISHED TURN</p>
      <h2>Begin furnishing from HERE</h2>
      <p>
        The Human and Terrestrial Computer stand WITH one another upon Ground. Begin with the existing opening and PUFFING; geometry configuration is optional. Nothing is acquired on page load.
      </p>
      <p id="sw-message" role="status">{@message}</p>
      <div class="wgr-views">
        <button
          id="sw-alongside"
          phx-click="weave-interface"
          phx-value-mode="alongside"
          aria-pressed={to_string(@interface == "alongside")}
        >Composementing ALONGSIDE</button><button
          id="sw-across"
          phx-click="weave-interface"
          phx-value-mode="across"
          aria-pressed={to_string(@interface == "across")}
        >Observationing OVER ACROSS</button><button
          :for={
            {v, label} <- [
              {"flat", "Flat monitor · Longhouse Gallery Wall"},
              {"section", "Section"},
              {"plan", "Plan / FRONT run"},
              {"within", "FROM WITHIN · seated Regarding"},
              {"ceiling", "Look UP · Crossing"}
            ]
          }
          id={"sw-view-"<>v}
          phx-click="weave-view"
          phx-value-view={v}
          aria-pressed={to_string(@view == v)}
        >{label}</button>
      </div>
      <div
        id="sw-renderer"
        phx-hook="SnailWeave"
        phx-update="ignore"
        data-model={Jason.encode!(@model)}
        data-view={@view}
      >
        <section class="sw-wheel-panel" aria-labelledby="sw-wheel-title">
          <div
            id="sw-wheel"
            class="sw-wheel"
            role="slider"
            tabindex="0"
            aria-label="Regarding Wheel bearing"
            aria-describedby="sw-wheel-help"
            aria-valuemin="0"
            aria-valuemax="359"
            aria-valuenow="0"
          >
            <svg viewBox="0 0 120 120" aria-hidden="true">
              <circle cx="60" cy="60" r="55" fill="#071728" stroke="#59778b" stroke-width="2" />
              <path d="M60 2v8 M118 60h-8 M60 118v-8 M2 60h8" stroke="#cee8ef" stroke-width="2" />
              <g data-wheel-rotor>
                <circle cx="60" cy="60" r="43" fill="none" stroke="#5eead4" stroke-width="9" />
                <path d="M60 60V19 M60 60l36 21 M60 60L24 81" stroke="#5eead4" stroke-width="7" />
                <circle cx="60" cy="60" r="10" fill="#18374a" stroke="#5eead4" stroke-width="2" />
                <circle cx="60" cy="17" r="6" fill="#fbbf24" />
              </g>
            </svg>
          </div>
          <div>
            <h3 id="sw-wheel-title">Regarding Wheel · AROUND ABOUT</h3>
            <p id="sw-wheel-help">
              Drag the rim with a mouse or finger, or focus it and use the arrow keys.
              Turn the selected view. Choose a stand to inspect a registered relation closer or farther.
            </p>
            <p>
              <strong id="sw-wheel-bearing">0°</strong>
              · <span id="sw-wheel-mode">Ready to turn</span>
            </p>
            <div class="sw-wheel-actions">
              <button type="button" id="sw-wheel-reset">Reset inspection</button>
              <button type="button" id="sw-wheel-return" hidden>Return to selected view</button>
            </div>
            <div class="sw-stand-controls">
              <label for="sw-stand">Inspection stand</label>
              <select id="sw-stand">
                <option value="">Selected view bearing</option>
              </select>
              <div class="sw-wheel-actions">
                <button type="button" id="sw-closer">Closer</button>
                <button type="button" id="sw-farther">Farther</button>
                <button type="button" id="sw-up">UP OVER</button>
                <button type="button" id="sw-down">DOWN UNDER</button>
              </div>
            </div>
          </div>
        </section>
        <p id="sw-bearing" class="sw-bearing" aria-live="polite"></p>
        <div class="sw-regarding-pair">
          <div class="sw-bearing-outreading">
            <.gallery_wall
              id="sw-flat-material"
              material={@model.near_monitor.flat.material && @model.near_monitor.flat.material["id"]}
            >
              <:yt>
                <p data-composition-text></p>
                <details class="sw-material-provenance">
                  <summary>Material registration</summary><small data-composition-source></small>
                </details>
              </:yt>
            </.gallery_wall>
            <svg
              id="sw-scene"
              viewBox="0 0 1000 650"
              role="img"
              aria-label="One continuous Snail House: Zeroeth arches, furnished arc, seated Regarding and directed Projectioning"
            ></svg>
          </div>
          <aside class="sw-locator" aria-labelledby="sw-locator-title">
            <h3 id="sw-locator-title">Diorama locator</h3>
            <svg
              id="sw-locator"
              viewBox="0 0 280 200"
              role="img"
              aria-label="Snail House locator with fixed Seat, inspection stand and camera direction"
            ></svg>
            <p class="sw-locator-key">
              White · HERE <span>Gold · stand</span> <strong>Teal · camera and gaze</strong>
            </p>
            <h4 id="sw-from">Outreading FROM selected bearing</h4>
            <p id="sw-stand-source"></p>
          </aside>
        </div>
        <details class="sw-passaging-notes">
          <summary>Passagingway annotations · In-Stringing-Mentings pending</summary>
          <ul>
            <li>
              Seat toward aperture · 45° registration. Piping and annotation appointment pending.
            </li>
            <li>
              Bearing archways toward the Projectioning Crossing · Zeroeth arch witnesses. String attachments pending.
            </li>
            <li>
              Far mouth toward near mouth · candidate YT→YT probe. Retained triangle clearance and receipt INTO HERE remain open.
            </li>
            <li>
              Near mouth toward PITTONING and radial fold · modeled intersection. COB RE-STANDING would require appointed operational stands and a qualified passage.
            </li>
          </ul>
        </details>
        <nav id="sw-orientation" aria-label="Identify an existing registration">
          <button
            :for={r <- @model.near_monitor.orientation}
            type="button"
            id={"sw-identify-"<>r.id}
            data-orientation={r.id}
            aria-pressed={to_string(r.id == "seat")}
          >{r.name}</button>
        </nav>
        <p id="sw-orientation-reading" aria-live="polite"></p>
        <p id="sw-outreading" data-outreading aria-live="polite">
          Hover or focus a registered relation; click/Enter pins, Escape releases.
        </p>
      </div>
      <details id="sw-cubical-comparison" phx-mounted={JS.ignore_attributes(["open"])}>
        <summary>CUBICAL reconciliation · differentiated source frames</summary>
        <p>
          One given computering Ground. The CH and TC reservations, Craft/Seat and JANUSITE ribbon retain separate identities. The cabinet outline is an external inspection envelope.
        </p>
        <p>
          No common transform from the earlier CH/TC reservations to the Snail Seat is appointed. The native Seat reserve [0,-0.85,0.35] and revised inspection Seat [0,0,0] are in different frames; they have not been silently aligned.
        </p>
        <.link navigate={~p"/experiments/architecture"}>Inspect native CAB / ALONGSIDE appliance</.link>
        <pre>{Jason.encode!(@model.near_monitor.cubical, pretty: true)}</pre>
      </details>
      <section id="sw-emergence" class="sw-emergence">
        <h3>Seat-to-Spiral emergence · one inherited body</h3>
        <p id="sw-emergence-standing">
          {@model.emergence.binding.standing}. The revised Seat, eye and aperture registrations are inspectable; source acquisitions and material identities remain unchanged.
        </p>
        <div class="wgr-views">
          <button
            id="sw-view-contraption"
            aria-pressed={to_string(@view == "contraption")}
            phx-click="weave-view"
            phx-value-view="contraption"
          >Contraption Regarding</button><button
            id="sw-view-volume"
            aria-pressed={to_string(@view == "volume")}
            phx-click="weave-view"
            phx-value-view="volume"
          >Snail House Volume Regarding</button><button
            id="sw-view-groundward"
            aria-pressed={to_string(@view == "groundward")}
            phx-click="weave-view"
            phx-value-view="groundward"
          >Groundward / Unvanishing Line</button>
        </div>
        <details id="sw-groundward-check" phx-mounted={JS.ignore_attributes(["open"])}>
          <summary>Groundward registration · centered UP OVER 45° check</summary>
          <% check = @model.near_monitor.groundward_check %>
          <p>
            From the revised aperture {inspect(check.aperture)}, the rise toward the fixed HERE
            Seat is {Float.round(check.aperture_to_seat_degrees, 1)}°. Toward the seated eye
            it is {Float.round(check.aperture_to_eye_degrees, 1)}°. The opening is centered
            in the Z=0 section and has a lateral X offset of {check.aperture_lateral_offset} relative to the Human.
          </p>
          <p>
            The monitor's geometric center {inspect(
              Enum.map(check.monitor_center, &Float.round(&1, 3))
            )} rises toward HERE
            at {Float.round(check.monitor_to_seat_degrees, 1)}° and toward the eye at {Float.round(
              check.monitor_to_eye_degrees,
              1
            )}°. A 45° line from its extended
            center-line to HERE would start at {inspect(
              Enum.map(check.monitor_centerline_at_45, &Float.round(&1, 3))
            )}, {if check.monitor_45_within_center_line, do: "within", else: "outside"} the modeled panel. Its X offset from the Seat is {Float.round(
              check.monitor_lateral_offset,
              3
            )}.
          </p>
          <p>
            Groundward view aims its camera from the aperture along the aperture-to-HERE axis.
            This centers the aperture in projection. The flat view draws the monitor-local
            center-line. A shared monitor pivot, aperture and seated eye-line still needs a
            physical registration.
          </p>
        </details>
        <.form for={@emergence_form} id="sw-emergence-form" phx-change="weave-emergence">
          <.input
            field={@emergence_form[:quarter_turn]}
            type="range"
            min="0"
            max="90"
            step="1"
            label="Human Regarding quarter-turn · flat-to-tunneling sweep from TWO"
            class="wgr-range"
            phx-debounce="100"
          />
          <details id="sw-fresh-engineering" phx-mounted={JS.ignore_attributes(["open"])}>
            <summary>Engineering: acquired source, fresh zero and later accretion preview</summary>
            <p
              id="sw-fresh-state"
              data-extent={@model.emergence.fresh.inspected_later_extent}
              data-inherited={length(@model.emergence.fresh.inherited_material_ids)}
              data-next={to_string(@model.emergence.fresh.next_frame_available)}
            >
              Fresh local extent: {@model.emergence.fresh.local_fashioning_extent}. Inspecting later fashioning: {@model.emergence.fresh.inspected_later_extent}. Inherited authored items: {length(
                @model.emergence.fresh.inherited_material_ids
              )}. Zero local extent does not erase inherited standing. This is a postcondition inspection, not RE-STEP.
            </p>
            <.input
              field={@emergence_form[:extent]}
              type="number"
              min="0"
              step="any"
              label="Inspect later local fashioning amount · no architectural count limit or automatic accretion"
              class="wgr-input"
              phx-debounce="150"
            />
            <.input
              field={@emergence_form[:candidate]}
              type="select"
              label="Inspect JANUSITE-derived wedging opportunity (selection does not PUFF)"
              options={[
                {"ALONG THROUGH actual wedge", "through"},
                {"Toward arrival aperture · ineligible", "arrival"},
                {"Toward standing HERE / Rooming · ineligible", "standing"}
              ]}
              class="wgr-input"
            />
            <button id="sw-fresh" type="button" phx-click="weave-fresh-inspection">Return engineering preview to fresh local zero</button>
            <p>
              These numbers inspect a conditional post-RE-STEP state. They perform neither RE-STEP nor Footing acquisition.
            </p>
          </details>
        </.form>
        <details id="sw-human-cob-table" phx-mounted={JS.ignore_attributes(["open"])}>
          <summary>TWO–THREE–FOUR · Human, monitor, COB and Table registration</summary>
          <% registration = @model.emergence.registration %>
          <p id="sw-regarding-correspondence" data-angle={@model.emergence.regard.quarter_turn}>
            TWO is the one computing and Traversaling Seat at {inspect(registration.fixed_seat)}.
            THREE is the ordinary monitor pivot reference for the flat-to-tunneling correspondence. The keyboard and quilling-stitching
            working region lies between TWO and THREE in the recovered design.
            FOUR names the proposed UPSTANDING FASHIONING bearing from that same locality. Compare Flat monitor with FROM WITHIN, then use the quarter-turn
            control above to inspect its proposed sweep from the same seated eye {inspect(
              registration.revised_eye
            )}. The Regarding Wheel is a separate full-circle inspection. The Table has its own mechanical registration.
          </p>
          <dl>
            <dt>Monitor · existing world presentation</dt>
            <dd>{inspect(Enum.find(@model.surfaces, &(&1.id == "ordinary-flat-monitor")).points)}</dd>
            <dt>HERE and Crossing · existing reference</dt>
            <dd>
              HERE square centered at {inspect(@model.landinging_registration.common_center)}.
              The Crossing uses this reference. Its six-extent enclosure and THREE-inward monitor
              registration still need a shared metric transform.
            </dd>
            <dt>Pretend TC · DOWN UNDER requirement</dt>
            <dd>
              Six extents directly beneath TWO, with HOME opening inherited from the inaugural
              PITTONING wedge. Existing computer envelope {inspect(@model.fixed.computer)} is a
              reference only. Actual TC standing is tracked separately.
            </dd>
            <dt>RE-SURFACING Table · existing annulus, recovered working dimensions</dt>
            <dd>
              The reference annulus is centered on the spindle at Y = −0.1.
              The recovered three-extent diameter and three-extent rise need registration to the
              contraption floor and independent Ground. The center opening and spindle are
              available for comparison with the required cylinder THROUGH the Table.
              Table rotation and Regarding rotation have separate pivots pending a demonstrated coupling.
            </dd>
            <dt>COB · one Craft, two offices</dt>
            <dd>
              Reference eye {inspect(registration[:COB_eye])}.
              The one-extent COB CUBICAL needs a Ground-registered footing furnished by the Table.
              Derive its working placement from the appointed passage, clearance, horizontal and
              vertical curvature, and Regarding FROM. The reference eye does not appoint that placement.
              First extent is Human reach. Second and third are COB-mediated working requirements.
            </dd>
            <dt>TOWARD SIX · outer wall</dt>
            <dd>
              Outer wall Regarding is available for inspection. Material-associated Noticingmenting placement is open.
            </dd>
          </dl>
        </details>
        <p
          id="sw-wall-test"
          data-material={
            @model.emergence.wall_test.material && @model.emergence.wall_test.material["id"]
          }
        >
          Wall sample “{@model.emergence.wall_test.sample}”: {@model.emergence.wall_test.visible_count} glyph centres clear, {@model.emergence.wall_test.hidden_count} obstructed from the revised seated eye. Actual JANUSITE quads, projection registrations and eye rays are separate. No finished relay is appointed.
        </p>
        <details id="sw-emergence-ledger" phx-mounted={JS.ignore_attributes(["open"])}>
          <summary>
            Inspect revised coordinates, continuity, diagonals, fresh state, wall orientation / occlusion and candidate eligibility
          </summary><pre>{Jason.encode!(Map.drop(@model.emergence,[:presentation]),pretty: true)}</pre>
        </details>
      </section>
      <p id="sw-conflict" role="status">
        Historical proposal finding: the FRONT reference run is outside the swept bound by {Float.round(
          @model.clearances.long_run_sweep_margin,
          3
        )} units. The Loading Deck lead intersects cabinet front Z=1.45. Physical fitting of that lead, the bellows relay and optical exit remains unresolved; cabinet proportions have not changed.
      </p>
      <div class="wgr-views">
        <button
          id="sw-pull"
          phx-click="weave-action"
          phx-value-op="pull"
          disabled={A.opened?(A.restore(@state["opening"]))}
        >Pull the existing opening</button><button
          id="sw-puff"
          phx-click="weave-action"
          phx-value-op="puff"
          disabled={
            !A.opened?(A.restore(@state["opening"])) || A.puffed?(A.restore(@state["opening"]))
          }
        >First PUFFING</button><button
          id="sw-brace"
          phx-click="weave-action"
          phx-value-op="brace"
          disabled={!A.puffed?(A.restore(@state["opening"])) || @state["body"]["needle"] != "inkwell"}
        >Pull UP brace → Quilling Stitching Needle</button><button
          id="sw-seat"
          phx-click="weave-action"
          phx-value-op="seat"
          disabled={!A.puffed?(A.restore(@state["opening"])) || @state["seat"] != nil}
        >Lock Seat into this room</button>
      </div>
      <p id="sw-yt-standing" data-available={to_string(@state["yt"])}>
        YT: {if @state["yt"],
          do: "available through Human word-stringing",
          else: "awaits Human word-stringing; inspection cannot furnish it"}. Brace ancestry: {@state[
          "brace"
        ]}.
      </p>
      <.form for={@quill_form} id="sw-quill-form" phx-submit="weave-quill" phx-change="weave-draft">
        <.input
          field={@quill_form[:text]}
          type="textarea"
          label="String UP your words WITH the held Quilling Stitching Needle"
          class="wgr-input"
          maxlength="2000"
          disabled={@state["body"]["needle"] != "held"}
        /><button id="sw-quill" disabled={@state["body"]["needle"] != "held"}>Retain words and their material identity</button>
      </.form>
      <div class="wgr-views">
        <button
          id="sw-withdraw"
          phx-click="weave-action"
          phx-value-op="withdraw"
          disabled={
            !@state["yt"] || @state["body"]["needle"] != "held" ||
              @state["body"]["outstanding"] >= 6000
          }
        >Withdraw 0.5 YT</button><button
          id="sw-inkwell"
          phx-click="weave-action"
          phx-value-op="inkwell"
          disabled={@state["body"]["needle"] != "held"}
        >Seat needle in Inkwell</button><button
          id="sw-gather"
          phx-click="weave-action"
          phx-value-op="gather"
          disabled={@state["body"]["needle"] != "gathering"}
        >Gather measured remainder</button>
      </div>
      <p
        id="sw-line"
        data-outstanding={@state["body"]["outstanding"]}
        data-ready={to_string(@state["body"]["ready_for_pinning"])}
      >
        YT withdrawn {@state["body"]["withdrawn"] / 1000} = outstanding {@state["body"]["outstanding"] /
          1000} + gathered {@state["body"]["gathered"] / 1000}. Readiness FOR PINNING is distinct from actual PINNING; no PINNING control is furnished.
      </p>
      <div class="wgr-views">
        <button
          :for={
            {o, label} <- [{"xt", "Appoint XT Furnishing COB"}, {"yt", "Appoint YT Traversaling COB"}]
          }
          id={"sw-appoint-"<>o}
          phx-click="weave-appoint"
          phx-value-office={o}
          disabled={!A.puffed?(A.restore(@state["opening"])) || Map.has_key?(@state["offices"], o)}
        >{label}</button>
      </div>
      <p id="sw-offices">
        XT Furnishing: {if Map.has_key?(@state["offices"], "xt"),
          do: "appointed",
          else: "awaits appointment"} · YT Traversaling: {if Map.has_key?(@state["offices"], "yt"),
          do: "appointed",
          else: "awaits appointment"}. Distinct offices WITH the Human; their identities and TOWARD relations remain inspectable in the ledger.
      </p>
      <div class="wgr-views">
        <button
          id="sw-provide"
          phx-click="weave-action"
          phx-value-op="provide"
          disabled={
            !@state["yt"] || @state["seat"] == nil || !Map.has_key?(@state["offices"], "xt") ||
              length(@state["turns"]) >= 2 || (@turn && @turn["status"] not in ~w(resolved rehearsed))
          }
        >Furnishing provides CUBICAL standing</button><button
          id="sw-register"
          phx-click="weave-action"
          phx-value-op="register"
          disabled={is_nil(@turn) || @turn["status"] != "furnishing"}
        >Register the authored item to that standing</button><button
          id="sw-settle"
          phx-click="weave-action"
          phx-value-op="settle"
          disabled={is_nil(@turn) || @turn["status"] != "emplacing"}
        >Confirm em-placementing · provide turn</button>
      </div>
      <p id="sw-current-turn" data-status={if @turn, do: @turn["status"], else: "none"}>
        {if @turn,
          do:
            "#{@turn["id"]} · #{@turn["status"]} · #{@turn["arc"]} · arc addresses #{inspect(@turn["addresses"])}",
          else: "No turn furnished yet. CUBICAL standing precedes material registration."}
      </p>
      <.form for={@take_form} id="sw-take-form" phx-submit="weave-take">
        <.input field={@take_form[:passage]} type="hidden" />
        <.input
          field={@take_form[:turn]}
          type="select"
          label="Inherit a Furnishing-provided turn"
          options={Enum.map(@state["turns"], &{&1["id"], &1["id"]})}
          class="wgr-input"
        /><.input
          field={@take_form[:mode]}
          type="select"
          label="Taking provenance"
          options={[
            {"Rehearsaling · no Footing acquired", "rehearsal"},
            {"Actual appointed completion · own Footing", "actual"}
          ]}
          class="wgr-input"
        /><.input
          field={@take_form[:human]}
          type="text"
          label="Acquiring Constitutioning Human relation (no avatar)"
          maxlength="80"
          class="wgr-input"
        /><button
          id="sw-take"
          disabled={
            @state["active"] != nil || !Map.has_key?(@state["offices"], "yt") || is_nil(@turn)
          }
        >Traversaling inherits and takes</button>
      </.form>
      <div class="wgr-views">
        <button
          id="sw-advance"
          phx-click="weave-action"
          phx-value-op="advance"
          disabled={is_nil(@state["active"]) || @state["active"]["position"] >= 2}
        >Follow next appointed motion</button><button
          id="sw-complete"
          phx-click="weave-action"
          phx-value-op="complete"
          disabled={is_nil(@state["active"]) || @state["active"]["position"] != 2}
        >Appoint completion once</button><button
          id="sw-point"
          phx-click="weave-action"
          phx-value-op="point"
          disabled={@state["seat"] == nil}
        >Point FROM the seated locality</button>
      </div>
      <p
        id="sw-acquisitions"
        data-count={length(@state["footings"])}
        data-completions={length(@state["completions"])}
      >
        Scooping Spooning Footings: {length(@state["footings"])}. Rehearsals and actual completions are separately recorded. Manual scrubbing below cannot complete a turn.
      </p>
      <article :if={List.last(@state["footings"])} id="sw-latest-footing" class="sw-footing">
        <h3>Own Scooping Spooning Footing retained</h3>
        <p>
          {List.last(@state["footings"])["human"]} · arc address {Float.round(
            List.last(@state["footings"])["address"],
            4
          )} · appointed completion, not rehearsal.
        </p>
        <details>
          <summary>Inspect this Footing's source turn, office and material</summary><pre>{Jason.encode!(List.last(@state["footings"]),pretty: true)}</pre>
        </details>
      </article>
      <p id="sw-transverse" data-held={to_string(@model.crossing.second.held_UP)}>
        {if @model.crossing.second.held_UP,
          do: "TC TAKING holds the second archway's transverse Regarding UP",
          else: "Second archway available UP OVER ACROSS; no TC-taking hold is being claimed"}.
      </p>
      <details id="sw-bearing-archway" phx-mounted={JS.ignore_attributes(["open"])}>
        <summary>Bearing archway · proposed YT passage</summary>
        <% registration = @model.crossing.monitor_registration %>
        <% passage = @model.crossing.yt_through %>
        <p>
          {Enum.join(registration.cubical_extents, " × ")} extents · {registration.inward_extents} extents inward from the monitor pivot.
          Human at TWO · monitor pivot at THREE · Table working bearing at FOUR.
        </p>
        <p>{registration.presentation}. Workshop world registration is unconfirmed.</p>
        <p>{passage.relation} · {passage.status}.</p>
        <p>
          Piping {passage.piping} · clearance {passage.clearance} · HERE receipt {passage.here_receipt}. {passage.qualification}
        </p>
        <% probe = passage.probe %>
        <p id="sw-yt-centerline">
          Cyan runs from the existing far tunnel mouth through the near mouth to an inward sample.
          It hits {length(probe.center_wall_hits)} tunnel wall faces.
          The pink off-axis comparison hits {length(probe.control_wall_hits)}.
        </p>
        <p>
          Displayed faces intersecting the cyan course: {case probe.displayed_face_hits do
            [] -> "none"
            hits -> Enum.map_join(hits, ", ", & &1.object)
          end}.
          The far mouth is a candidate bearing. The inward sample still needs registration to HERE.
        </p>
      </details>
      <details id="sw-inspection" phx-mounted={JS.ignore_attributes(["open"])}>
        <summary>Inspect the same apparatus · folds, bearings, provenance and clearances</summary>
        <.form for={@form} id="sw-inspection-form" phx-change="weave-inspect">
          <.input
            field={@form[:pose]}
            type="range"
            label="Inspect radial fold · affected em-placementing is protected"
            min="0"
            max="90"
            step="1"
            class="wgr-range"
            phx-debounce="100"
          /><.input
            field={@form[:quarter]}
            type="select"
            label="One arc, six inspection purchases"
            options={Enum.map(0..5, &{"Purchase #{&1 + 1}", &1})}
            class="wgr-input"
          /><.input
            field={@form[:look]}
            type="range"
            label="Regard AROUND ABOUT from the fixed Seat · no stepping"
            min="-180"
            max="180"
            step="1"
            class="wgr-range"
            phx-debounce="100"
          /><.input
            field={@form[:scrub]}
            type="range"
            label="Inspection scrub only · never appointed completion"
            min="0"
            max="1"
            step="0.01"
            class="wgr-range"
            phx-debounce="100"
          />
        </.form>
        <details id="sw-geometry" phx-mounted={JS.ignore_attributes(["open"])}>
          <summary>
            Arc frames, Seat registration, archways, projection stages and swept bounds
          </summary><pre>{Jason.encode!(Map.drop(@model,[:surfaces,:lines]),pretty: true)}</pre>
        </details>
        <details id="sw-ledger" phx-mounted={JS.ignore_attributes(["open"])}>
          <summary>
            Already standing / Human labor / CUBICAL furnishing / staging / encounter / acquisition / returnability
          </summary><pre>{Jason.encode!(@state,pretty: true)}</pre>
        </details>
      </details>
      <div class="wgr-views">
        <button id="sw-export" phx-click="weave-export">Download integrated witness</button>
      </div><details id="sw-restore" phx-mounted={JS.ignore_attributes(["open"])}>
        <summary>Restore integrated witness</summary><.form
          for={@restore_form}
          id="sw-restore-form"
          phx-submit="weave-import"
        >
          <.input
            field={@restore_form[:json]}
            type="textarea"
            label="Versioned witness JSON"
            class="wgr-input"
          /><button id="sw-import">Replay and validate ancestry</button>
        </.form>
      </details>
      <p class="sb-key">
        POOFING has no recovered operation contract in the inspected opening code; its constitutional effect remains for Engineering Hall review. The existing PULL/PUFF precedent is called directly. No RE-STEP, NAV-STEP, mechanical PINNING or new room is furnished here. Transparent inspection meshes do not establish opaque optical visibility.
      </p>
    </section>
    """
  end
end
