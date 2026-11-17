defmodule PublicSituationMachineTurnZeroWeb.OneCubicalDoorwayPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  attr :state, :map, required: true
  attr :model, :map, required: true

  def panel(assigns) do
    assigns =
      assign(
        assigns,
        :passage_form,
        to_form(
          %{
            "revision" => assigns.state.revision,
            "doorway_progress" => assigns.state.doorway.progress
          },
          as: :toy
        )
      )

    ~H"""
    <section id="unit-doorway" class="rfh-controls">
      <h2>ONE-CUBICAL COB · one letter through the Door</h2>
      <p>
        Preferred Candidate B: Table-furnished rear surface and upper receiving frame. COB stands exactly ONE × ONE × ONE UP FROM OUT OF its Table surface. The principal Table and THREE retain separate measures.
      </p>
      <div class="rtb-controls">
        <button
          :for={
            {id, label} <- [
              {"candidate", "Inspect constructed Table / paired computers"},
              {"legacy", "Inspect preserved v12 R / U / M sources"}
            ]
          }
          id={"unit-layer-"<>id}
          phx-click="room-toy-action"
          phx-value-action="doorway"
          phx-value-choice={id}
          phx-value-revision={@state.revision}
          aria-pressed={to_string(@state.doorway.layer == id)}
        >{label}</button>
      </div>
      <p id="unit-passage-status">
        Letter {Enum.at(["R", "O1", "O2", "M"], @state.doorway.index) || "succession complete"} · {@state.doorway.phase} · offloaded {inspect(
          @state.doorway.completed
        )}. One letter may occupy the passage. Previous letters are separately offloaded before the next enters.
      </p>
      <div class="rtb-controls">
        <button
          :for={
            {id, label} <- [
              {"trace", "1 · Human traces"},
              {"select", "2 · Select traced source"},
              {"place", "3 · Place unit letter"},
              {"open", "4 · Open Stage Door"},
              {"needle", "5 · Appoint Doll / Needle; prepare offload"}
            ]
          }
          id={"unit-"<>id}
          phx-click="room-toy-action"
          phx-value-action="doorway"
          phx-value-choice={id}
          phx-value-revision={@state.revision}
        >{label}</button>
      </div>
      <.form for={@passage_form} id="unit-passage-settings" phx-change="room-toy-setting">
        <.input field={@passage_form[:revision]} id="unit-revision" type="hidden" />
        <.input
          field={@passage_form[:doorway_progress]}
          id="rtb-doorway_progress"
          type="range"
          min="0"
          max="1"
          step="0.025"
          label="Advance one source letter through the corridor, then along its offload course"
          disabled={@state.doorway.phase not in ["open", "passing", "offloading"]}
        />
      </.form>
      <p class="rtb-yellow">
        Trace, selection, placement and Door opening do not stitch. Doll / Needle appointment and finite material offload are rehearsals; actual Needle purchase, PITTONING, load-bearing acceptance and lawful RE-STEP remain distinct. Unit-letter extent is furnished by a finite ONE-CUBICAL carrier; the inherited R/M inscription is rigidly placed inside it without rescaling.
      </p>
      <details id="unit-material-ledger" class="rtb-details">
        <summary>COB, Table measures, paired computer bodies and doorway material ledger</summary>
        <p>
          Real TC UNDER Table: doorway:real-tc. Pretend TC UNDER Seat: doorway:pretend-tc, with square-axle bore and ZERO-to-ONE leverage slot. Actual monitor cb:monitor remains fixed.
        </p>
        <pre>{inspect(%{table: @model.table,correspondence: @model.correspondence,protected: @model.protected},pretty: true,limit: :infinity)}</pre>
        <article :for={p <- @model.pieces} id={"unit-ledger-"<>String.replace(p.id,":","-")}>
          <h3>{p.name}</h3><pre>{inspect(Map.drop(p,[:geometry,:source_geometry]),pretty: true,limit: :infinity)}</pre>
        </article>
      </details>
      <details id="unit-alternatives" class="rtb-details">
        <summary>Compared alternatives and selected finite arrangement</summary><pre>{inspect(@model.alternatives,pretty: true,limit: :infinity)}</pre>
      </details>
    </section>
    """
  end
end
