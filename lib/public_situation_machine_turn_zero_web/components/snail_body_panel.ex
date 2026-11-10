defmodule PublicSituationMachineTurnZeroWeb.SnailBodyPanel do
  use PublicSituationMachineTurnZeroWeb, :html

  attr :state, :map, required: true
  attr :model, :map, required: true
  attr :view, :string, required: true
  attr :form, :any, required: true
  attr :quill_form, :any, required: true
  attr :restore_form, :any, required: true
  attr :message, :string, default: nil
  attr :show_instrument, :boolean, required: true

  def panel(assigns) do
    ~H"""
    <section id="snail-body" class="wgr-workshop sb-panel" data-revision={@state["revision"]}>
      <div class="sb-heading">
        <p class="sb-eyebrow">BODY STUDY · QUILLING</p><h2>Corkscrew &amp; stationary standing</h2><p>
          One cabinet, table and Standing Landinging. Work the folds and the held line; keep HERE standing.
        </p>
      </div>
      <p id="sb-message" role="status">{@message}</p>
      <div class="wgr-views" aria-label="Body Regardings">
        <button
          :for={
            {id, label} <- [
              {"external", "Oblique body"},
              {"reverse", "Opposed oblique"},
              {"section", "Section / DOWN UNDER"},
              {"plan", "Plan"},
              {"within", "FROM WITHIN tunneling"}
            ]
          }
          id={"sb-view-"<>id}
          phx-click="body-view"
          phx-value-view={id}
          aria-pressed={to_string(@view == id)}
        >{label}</button>
        <button
          id="sb-instrument-visibility"
          phx-click="body-instrument"
          aria-pressed={to_string(@show_instrument)}
        >Instrumentation: {if @show_instrument, do: "shown", else: "hidden; standing retained"}</button>
      </div>
      <div
        id="sb-renderer"
        phx-hook="SnailBody"
        phx-update="ignore"
        data-model={Jason.encode!(@model)}
        data-view={@view}
        data-instrument={to_string(@show_instrument)}
      >
        <svg
          id="sb-scene"
          viewBox="0 0 1000 650"
          role="img"
          aria-label="Shared Snail House body geometry: fixed HERE, table, descending corkscrew and computer DOWN UNDER"
        ></svg><p id="sb-outreading" data-outreading aria-live="polite">
          Hover or focus geometry to inspect world points. Click or Enter to pin; Escape to release.
        </p>
      </div>
      <p class="sb-key">
        Teal: Standing Landinging / corkscrew · amber: table / YT · violet: intermediate shield / tunneling · pink: PITTONING / side instrumentation · blue: DOWN UNDER computer. Transparent inspection surfaces expose relations; they do not prove optical visibility or load-bearing purchase.
      </p>
      <div class="sb-grid">
        <section>
          <h3>Resolve a wedging</h3>
          <.form for={@form} id="sb-fold-form" phx-change="body-fold">
            <.input
              field={@form[:fold]}
              type="range"
              label="Quarter-turn resolution (0° vertical → 90° downward)"
              min="0"
              max="90"
              step="1"
              class="wgr-range"
              phx-debounce="100"
            />
            <.input
              field={@form[:quarter]}
              type="select"
              label="Inspect emergence along descending corkscrew"
              options={Enum.map(0..5, &{"Quarter locality #{&1 + 1}", &1})}
              class="wgr-input"
            />
          </.form>
          <p
            id="sb-fold-status"
            data-degrees={@model.fold.degrees}
            data-normal={Jason.encode!(@model.fold.normal)}
          >
            {@model.fold.degrees}° · mouth normal {Jason.encode!(
              Enum.map(@model.fold.normal, &Float.round(&1 * 1.0, 3))
            )}. The shared partial-ring plane and PITTONING patch fold together; XT → YT and YT → XT reverse one THROUGH ALONG line.
          </p>
          <p>
            Quarter localities and dimensions are inspection hypotheses. No mechanical RE-STEP Foot or movement of the Human's standing is furnished.
          </p>
        </section>
        <section>
          <h3>Hold this piece of discrete time</h3>
          <p id="sb-needle-status" data-condition={@state["needle"]}>
            Quilling Stitching Needle · {@state["needle"]}
          </p>
          <div class="wgr-views">
            <button id="sb-take" phx-click="body-take" disabled={@state["needle"] != "inkwell"}>Hold Quilling Stitching Needle</button><button
              id="sb-return"
              phx-click="body-return"
              disabled={@state["needle"] != "held"}
            >Return needle to Inkwell</button>
          </div>
          <p>
            No timer advances this held piece. Returning relinquishes the hold and initiates measured gathering; it does not acquire another turn.
          </p>
          <.form
            for={@quill_form}
            id="sb-quill-form"
            phx-submit="body-quill"
            phx-change="body-quill-draft"
          >
            <.input
              field={@quill_form[:text]}
              type="textarea"
              label="Human Quilling within this held piece"
              class="wgr-input"
              maxlength="2000"
              disabled={@state["needle"] != "held"}
            />
            <button id="sb-quill" disabled={@state["needle"] != "held"}>Retain authored material &amp; provenance</button>
          </.form>
        </section>
        <section>
          <h3>Resolve the bobbin's YT line</h3>
          <div class="wgr-views">
            <button
              id="sb-withdraw"
              phx-click="body-withdraw"
              disabled={@state["needle"] != "held" || @state["outstanding"] >= 6000}
            >Withdraw 0.5 unit YT</button><button
              id="sb-gather"
              phx-click="body-gather"
              disabled={@state["needle"] != "gathering"}
            >Gather 0.5 unit toward bobbin</button><button
              id="sb-gather-all"
              phx-click="body-gather-all"
              disabled={@state["needle"] != "gathering"}
            >Resolve all outstanding YT</button>
          </div>
          <p
            id="sb-line-status"
            data-outstanding={@state["outstanding"]}
            data-gathered={@state["gathered"]}
            data-withdrawn={@state["withdrawn"]}
          >
            Withdrawn {@state["withdrawn"] / 1000} = outstanding {@state["outstanding"] / 1000} + gathered {@state[
              "gathered"
            ] / 1000} units. Gathering retains the piece's original routed trace and material.
          </p>
          <p id="sb-ready" data-ready={to_string(@state["ready_for_pinning"])}>
            {if @state["ready_for_pinning"],
              do: "Line at readying position FOR next PINNING. PINNING has not been performed.",
              else: "Next PINNING not yet readied."}
          </p>
        </section>
        <section>
          <h3>Ordinary flat monitor</h3>
          <div id="sb-flat-monitor" aria-label="Ordinary flat monitor; authored material">
            <%= if List.last(@state["material"]) do %>
              <p>{List.last(@state["material"])["text"]}</p><small>Human Quilling · retained Pretending material</small>
            <% else %>
              <p>Ready for the Human's Quilling.</p>
            <% end %>
          </div>
          <p>
            The ordinary monitor, inner aperture and cabinet-side aperture are separate planes. The intermediate shield blocks direct access DOWN through the tabletop opening. Side instrumentation turns at an explicit candidate planar fold; its registration to production Projectioning remains open.
          </p>
        </section>
      </div>
      <details id="sb-geometry-ledger">
        <summary>
          Inspect body geometry, fixed standing, side-plane Projectioning and reciprocal bearings
        </summary><pre>{Jason.encode!(Map.drop(@model,[:surfaces,:lines]),pretty: true)}</pre>
      </details>
      <details id="sb-provenance">
        <summary>Held-piece provenance, material and measured bobbin resolutions</summary><pre>{Jason.encode!(@state,pretty: true)}</pre>
      </details>
      <div class="wgr-views">
        <button id="sb-export" phx-click="body-export">Download body / Quilling witness</button>
      </div>
      <details id="sb-restore">
        <summary>Restore a body / Quilling witness</summary><.form
          for={@restore_form}
          id="sb-restore-form"
          phx-submit="body-import"
        >
          <.input
            field={@restore_form[:json]}
            type="textarea"
            label="Versioned witness JSON"
            class="wgr-input"
          /><button id="sb-import">Validate &amp; restore</button>
        </.form>
      </details>
      <p class="sb-key">
        Experimental furnishing, not operational RE-STEP, PINNING or an ANCHORED TURNING INDEX. No new Ground or independent Human/Computer is created. Prior rounds remain below. Download before reset or reload.
      </p>
    </section>
    """
  end
end
