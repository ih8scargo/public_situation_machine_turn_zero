defmodule PublicSituationMachineTurnZeroWeb.CommonMaterialPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  attr :model, :map, required: true

  def panel(assigns) do
    ~H"""
    <section id="common-material" class="cm-panel" aria-labelledby="cm-title">
      <p class="text-xs uppercase tracking-widest text-teal-300">Bounded geometric witness</p>
      <h2 id="cm-title" class="text-2xl font-semibold">One ribbon · two Regardings</h2>
      <p class="text-slate-300">
        The diagonal midpoint anchors a proposed transverse extent. Both views project the same world points. Physical correspondence remains a hypothesis.
      </p>
      <div
        id="cm-source"
        data-material={@model.source && @model.source.material["id"]}
        class="cm-source"
      >
        <%= if @model.source do %>
          <span class="text-xs uppercase tracking-widest text-teal-300">Existing staged source</span>
          <p class="whitespace-pre-wrap break-words text-lg">{@model.source.material["text"]}</p>
          <p class="break-all text-xs text-slate-400">
            {@model.source.material["id"]} · {@model.source.turn}
          </p>
        <% else %>
          <p>
            No incoming material registered. Retain Human Quilling and explicitly register it to a furnished turn in the existing workbench above. Drafts and page load supply no String.
          </p>
        <% end %>
      </div>
      <div
        id="cm-renderer"
        phx-hook="CommonMaterial"
        phx-update="ignore"
        data-model={Jason.encode!(@model)}
      >
        <div class="cm-controls" role="group" aria-label="Material Regarding">
          <button id="cm-both" type="button" data-cm-mode="both" aria-pressed="true">Paired</button>
          <button id="cm-tunneling" type="button" data-cm-mode="tunneling" aria-pressed="false">Tunneling Regarding</button>
          <button id="cm-flat" type="button" data-cm-mode="flat" aria-pressed="false">Flat Presentationing</button>
        </div>
        <div class="cm-pair">
          <figure id="cm-tunneling-card">
            <figcaption>
              Tunneling Regarding <span>FROM midpoint TOWARD Human · candidate</span>
            </figcaption>
            <svg
              id="cm-tunneling-scene"
              viewBox="0 0 600 340"
              role="img"
              aria-label="Same source from the seated-eye bearing toward diagonal midpoint"
            />
            <p>
              Eye → M is the sight axis. Incoming M → eye projects to M. XT TO XT lies outside this focused view; inspect it in Flat or the ledger.
            </p>
          </figure>
          <figure id="cm-flat-card">
            <figcaption>
              Flat Presentationing
              <span>YT TOWARD YT relative to inherited XT TO XT · candidate</span>
            </figcaption>
            <svg
              id="cm-flat-scene"
              viewBox="0 0 600 340"
              role="img"
              aria-label="Same source and inherited XT TO XT in the Snail XY projection"
            />
            <p>
              XY projection of the same world points. Amber is the trial YT span. Markers retain source indices; the complete ribbon text stands above.
            </p>
          </figure>
        </div>
        <p id="cm-view-status" role="status" class="text-sm text-teal-200"></p>
        <noscript>Enable JavaScript for paired source projections. The complete registration ledger is available below.</noscript>
      </div>
      <div class="cm-key text-sm">
        <span>◯ Diagonal midpoint</span><span class="text-amber-300">— Proposed YT TOWARD YT</span><span class="text-teal-300">— Inherited XT TO XT</span>
      </div>
      <p class="text-sm text-slate-300">
        {Enum.map_join(@model.sequence, " → ", & &1.name)}. Required order retained; physical transitions UNREGISTERED. Changing Regarding performs none of them.
      </p>
      <details id="cm-ledger" class="cm-ledger">
        <summary>Inspect coordinates, mapping and yellow registrations</summary>
        <p class="py-3 text-amber-200">
          Ground-to-Snail transform, NEXT upper boundary/floor, canonical issuing-post endpoints, physical YT measure and material transformation remain UNREGISTERED. SIX is height UP FROM independent Ground, not horizontal HERE-to-NEXT separation.
        </p>
        <pre class="overflow-auto text-xs">{Jason.encode!(@model, pretty: true)}</pre>
      </details>
      <details id="cm-inheritance" class="cm-ledger">
        <summary>Snail House inheritance · separate unconfirmed hypothesis</summary>
        <p :for={hypothesis <- @model.inheritance_hypothesis} class="py-1 text-sm text-slate-300">
          {hypothesis}
        </p>
      </details>
    </section>
    """
  end
end
