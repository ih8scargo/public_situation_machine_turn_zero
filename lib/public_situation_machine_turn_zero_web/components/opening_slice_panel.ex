defmodule PublicSituationMachineTurnZeroWeb.OpeningSlicePanel do
  use PublicSituationMachineTurnZeroWeb, :html
  attr :state, :map, required: true
  attr :model, :map, required: true

  def panel(assigns) do
    assigns =
      assign(
        assigns,
        :slice_form,
        to_form(
          %{
            "revision" => assigns.state.revision,
            "slice_progress" => assigns.state.opening_projection.progress
          },
          as: :toy
        )
      )

    ~H"""
    <section id="opening-slice-projection" class="rfh-controls" data-contract={@model.contract}>
      <h2>The opening reserves · Projectioning resolves</h2>
      <p>
        Preferred compact candidate: one source-addressed wedge passes straight through a .18 × .14 opening. It reserves the same letter's ONE-CUBICAL allocation; it contains no miniature letter. The curved representation is resolved afterward from the bound source law.
      </p>
      <div class="rtb-controls">
        <button
          :for={
            {key, label} <- [
              {"compact", "Inspect compact reservation candidate"},
              {"ports", "Inspect preserved resolved-unit / port candidate"}
            ]
          }
          id={"slice-"<>key}
          phx-click="room-toy-action"
          phx-value-action="slice_projection"
          phx-value-choice={key}
          phx-value-revision={@state.revision}
        >{label}</button>
      </div>
      <p id="slice-status">
        {if @state.opening_projection.active,
          do: "COMPACT CANDIDATE",
          else: "PRESERVED WORKSHOP / PORT VIEW"} · {@state.opening_projection.phase} · next letter {Enum.at(
          ["R", "O1", "O2", "M"],
          @state.opening_projection.index
        ) || "complete"} · resolved {length(@state.opening_projection.resolved)}. Acquired turns ZERO.
      </p>
      <div class="rtb-controls">
        <button
          :for={
            {key, label} <- [
              {"appoint", "1 · Appoint one wedge"},
              {"open", "2 · Open for the compact slice"},
              {"resolve", "3 · Inspect Projectioning resolution"},
              {"next", "4 · Finish review; next appointment"}
            ]
          }
          id={"slice-"<>key}
          phx-click="room-toy-action"
          phx-value-action="slice_projection"
          phx-value-choice={key}
          phx-value-revision={@state.revision}
        >{label}</button>
      </div>
      <.form for={@slice_form} id="slice-settings" phx-change="room-toy-setting">
        <.input field={@slice_form[:revision]} id="slice-revision" type="hidden" />
        <.input
          field={@slice_form[:slice_progress]}
          id="rtb-slice_progress"
          type="range"
          min="0"
          max="1"
          step="0.025"
          label="Issue the appointed wedge straight through the compact opening"
          disabled={@state.opening_projection.phase not in ["open", "issuing"]}
        />
      </.form>
      <p id="slice-law">
        Every appointment binds the same ROOM and {Map.fetch!(@model.law, :id)} source law. One unit of source arclength per letter, with unit transverse/radial domains. A changed inherited binding rejects resolution.
      </p>
      <p class="rtb-yellow">
        The former lateral-exit failure remains a resolved-body transport result. It is not a precondition on this unprojected opening. Projectioning is an explicit coordinate resolution, not physical squeezing or a camera trick. Purchase, material realization and constitutional PUFFING / RE-STEP acceptance remain distinct.
      </p>
      <p class="rtb-yellow">
        The bound Snail radial arc is a retained source-backed trial profile. Its explicit ROOM embedding is inspectable; its correspondence with the revised canonical coiling law remains YELLOW. All four appointments inherit this identical profile without a radius or ROOM adjustment.
      </p>
      <details id="slice-ledger">
        <summary>Reservation → Projectioning → resolved material: source and mapping ledger</summary><pre>{inspect(Map.drop(@model,[:extras]),pretty: true,limit: :infinity)}</pre>
      </details>
    </section>
    """
  end
end
