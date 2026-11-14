defmodule PublicSituationMachineTurnZeroWeb.ComingAboardMachinePanel do
  # Historical/trial presentation: no revised Seat ONE/Table THREE fit or protected acquisition is implied.
  # Reconcile against docs/architecture/geometry/README.md and impact-ledger.md before changing geometry.
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Workshop.ComingAboardMachine

  attr :state, :map, required: true

  def machine(assigns) do
    assigns =
      assign(assigns,
        lines: ComingAboardMachine.scene(assigns.state),
        glyphs: ComingAboardMachine.glyphs(assigns.state),
        registry: ComingAboardMachine.registration(),
        part_form: to_form(%{"id" => assigns.state.inspected_part}, as: :part),
        quill_form: to_form(%{"text" => ""}, as: :quill),
        input_form:
          to_form(%{"device" => assigns.state.input_device, "kind" => assigns.state.input_kind},
            as: :input
          )
      )

    ~H"""
    <section
      id="ca-common-machine"
      class="ca-common-machine"
      data-open={to_string(@state.machine_open?)}
      data-material={@state.inscription}
      data-view={@state.machine_view}
      data-puffed={to_string(@state.puffed?)}
    >
      <div class="ca-section-heading">
        <div>
          <p class="ca-eyebrow">LAWFUL QUADRANGLEMENTING · COMMON EXTENT FRAME</p><h2>
            Standing together FROM HERE
          </h2>
        </div><span class="ca-status">SIX × SIX × SIX extents</span>
      </div>
      <p class="ca-note">
        One seated Human. One fixed monitor. One COB UP FROM OUT OF the Table. The Slate below is a separate furnishing.
      </p>
      <div class="ca-toolbar" aria-label="Common-machine Regarding">
        <button
          :for={
            {view, label} <- [
              {"flat", "Flat · monitor face"},
              {"dollside", "Dollside · XT side"},
              {"tunnel", "Tunneling · THROUGH U"},
              {"top", "Inspect top"},
              {"back", "Inspect far backside"}
            ]
          }
          id={"ca-machine-#{view}"}
          phx-click="appliance:machine-view"
          phx-value-selection={view}
          aria-pressed={to_string(@state.machine_view == view)}
        >{label}</button>
      </div>
      <figure>
        <svg
          id="ca-machine-scene"
          viewBox="0 0 720 480"
          role="img"
          aria-label="Registered Groundward square, Table, central aperture, axle, one COB, distinct Seats, U and stationary monitor"
        >
          <defs>
            <marker
              id="ca-project-arrow"
              markerWidth="7"
              markerHeight="7"
              refX="6"
              refY="3"
              orient="auto"
            >
              <path d="M0 0 L6 3 L0 6" fill="none" stroke="#edbd80" />
            </marker>
          </defs>
          <polyline
            :for={line <- @lines}
            id={"ca-registered-#{line.id}"}
            points={line.projection}
            class={[
              "ca-machine-line ca-machine-#{line.kind}",
              @state.inspected_part == line.id && "ca-machine-inspected"
            ]}
            data-world={Jason.encode!(line.points)}
            data-label={line.label}
            marker-end={if line.kind == "projection", do: "url(#ca-project-arrow)"}
          >
            <title>{line.label}</title>
          </polyline>
          <g
            id="ca-inscription-face"
            data-readable={to_string(@state.machine_view in ~w(flat dollside tunnel))}
            data-stitched={to_string(MapSet.member?(@state.stitched, @state.inscription))}
          >
            <text
              :for={glyph <- @glyphs}
              :if={glyph.visible}
              x={glyph.x}
              y={glyph.y - 10}
              class="ca-machine-glyph"
              data-material={glyph.material}
              data-glyph={glyph.id}
              data-world={Jason.encode!(glyph.point)}
            >
              {glyph.text}
            </text>
          </g>
          <text x="24" y="28" class="ca-machine-label">
            {if @state.machine_view == "flat",
              do: "Projectioning TOWARD the monitor face",
              else: "Same source geometry · #{@state.machine_view} Regarding"}
          </text>
          <text x="24" y="452" class="ca-machine-label">
            Groundward SIX × SIX · XT TO XT ZERO-TO-ONE · Table seated without volume
          </text>
          <text x="24" y="473" class="ca-machine-label">
            Traversaling Seat TWO · Craft Seat height SIX · COB rise ONE
          </text>
        </svg>
        <figcaption id="ca-machine-reading" class="ca-machine-reading">
          <%= cond do %>
            <% @state.machine_view in ~w(top back) -> %>
              Top and far backside do not furnish the readable inscription face.
            <% is_nil(@state.inscription) -> %>
              Human Quilling is available on the Slate after the inaugural pull.
            <% @state.machine_view != "flat" && !MapSet.member?(@state.stitched, @state.inscription) -> %>
              Human markings retained. Doll Stitching has not yet been issued.
            <% true -> %>
              <span
                :for={record <- @state.needle["material"]}
                :if={record["id"] == @state.inscription}
              >{record["text"]}</span>
          <% end %>
        </figcaption>
      </figure>
      <.form for={@part_form} id="ca-inspect-part-form" phx-change="appliance:inspect-part">
        <.input
          field={@part_form[:id]}
          type="select"
          label="Locate a registered part"
          options={Enum.map(@lines, &{&1.label, &1.id})}
        />
      </.form>
      <p
        :for={line <- @lines}
        :if={line.id == @state.inspected_part}
        id="ca-part-reading"
        class="ca-note"
      >
        {line.label} · {bounds(line.points)} extents
      </p>
      <div
        id="ca-fixed-monitor-inscription"
        class="ca-fixed-monitor-inscription"
        data-plane={Jason.encode!(@registry.monitor.points)}
        data-material={@state.inscription}
      >
        <span class="ca-eyebrow">FIXED FLAT MONITOR · HUMAN MARKINGS RETAINED</span>
        <p :for={record <- @state.needle["material"]} :if={record["id"] == @state.inscription}>
          {record["text"]}
        </p>
      </div>
      <div class="ca-toolbar" aria-label="U bearing along existing curvature">
        <button
          :for={
            {t, label} <- [
              {"0", "XT origin"},
              {"0.5", "Along curvature"},
              {"1", "Transverse bearing"}
            ]
          }
          id={"ca-road-#{t}"}
          phx-click="appliance:road-regard"
          phx-value-selection={t}
        >{label}</button>
        <span class="ca-note">U follows the rail tangent through 45°. Inspection preserves Standing.</span>
      </div>
      <div class="ca-machine-workbench">
        <section
          id="ca-slate"
          class="ca-work-surface"
          data-distinct-from="table"
          data-device={@state.input_device}
          data-kind={@state.input_kind}
        >
          <p class="ca-eyebrow">SLATE · HUMAN QUILLING FIRST</p><h3>Quilling Stitching Needle</h3>
          <div class="ca-toolbar">
            <button
              id="ca-needle-take"
              phx-click="appliance:needle-take"
              disabled={!@state.machine_open? || @state.needle["needle"] != "inkwell"}
            >Take Needle FROM Inkwell</button>
            <button
              id="ca-needle-return"
              phx-click="appliance:needle-return"
              disabled={@state.needle["needle"] != "held"}
            >Return Needle INTO Inkwell</button>
          </div>
          <.form for={@quill_form} id="ca-quill-form" phx-submit="appliance:quill">
            <.input
              field={@quill_form[:text]}
              id="ca-quill-text"
              type="textarea"
              label="Human In-Stringing-Mentings"
              maxlength="2000"
              disabled={
                @state.needle["needle"] != "held" || @state.input_device != "keyboard" ||
                  @state.input_kind != "semantical marking"
              }
              placeholder="Quill a marking FROM HERE…"
            />
            <button
              id="ca-quill"
              class="ca-action"
              disabled={
                @state.needle["needle"] != "held" || @state.input_device != "keyboard" ||
                  @state.input_kind != "semantical marking"
              }
            >Quill these markings</button>
          </.form>
          <button
            id="ca-stitch"
            class="ca-action"
            phx-click="appliance:stitch"
            disabled={
              is_nil(@state.inscription) || MapSet.member?(@state.stitched, @state.inscription)
            }
          >Doll Stitches these same markings UP ON THE ROAD</button>
          <p class="ca-note">
            Doll performs the furnished Stitching of Human-authored markings. This does not perform constitutional PINNING or acquire Standing.
          </p>
          <details>
            <summary>Persistent input appointmenting</summary>
            <.form
              for={@input_form}
              id="ca-input-appointment"
              phx-change="appliance:input-appointment"
            >
              <.input
                field={@input_form[:device]}
                type="select"
                label="Input device"
                options={[{"Keyboard", "keyboard"}, {"Pointing-able input", "pointer"}]}
              />
              <.input
                field={@input_form[:kind]}
                type="select"
                label="Kind of input"
                options={["semantical marking", "pointing"]}
              />
            </.form>
          </details>
        </section>
        <section
          id="ca-inkwell"
          class="ca-work-surface"
          data-held={@state.needle["held"]}
          data-needle={@state.needle["needle"]}
        >
          <p class="ca-eyebrow">INKWELL · STRINGING SOURCE LOCALITY</p><h3>Hold and return</h3>
          <p>
            Needle: {@state.needle["needle"]} · outstanding: {@state.needle["outstanding"] / 1000} · gathered: {@state.needle[
              "gathered"
            ] / 1000}
          </p>
          <div class="ca-toolbar">
            <button
              id="ca-needle-withdraw"
              phx-click="appliance:needle-withdraw"
              disabled={@state.needle["needle"] != "held" || @state.needle["outstanding"] >= 6000}
            >Withdraw ½ extent</button><button
              id="ca-needle-gather"
              phx-click="appliance:needle-gather"
              disabled={@state.needle["needle"] != "gathering"}
            >Gather the outstanding Stringing</button>
          </div>
          <p class="ca-note">
            Returning INTO Inkwell relinquishes the hold upon this discrete piece of time. Gathering readies the line; it does not perform PINNING.
          </p>
          <p id="ca-machine-notice" role="status">{@state.machine_notice}</p>
          <details id="ca-quadranglement-source">
            <summary>Inspect inherited registration and offices</summary><p>
              Single canonical source: priv/tuple/canonical_tuple_positions.md. Extents are not inches. Source Snail HERE maps its 1.4 side to SIX; original meshes remain intact.
            </p><p :for={row <- @registry.tuple.rows}>
              {Enum.at(row, 2).text} · {Enum.at(row, 0).text} · {Enum.at(row, 1).text}
            </p>
          </details>
        </section>
      </div>
    </section>
    """
  end

  defp bounds(points) do
    Enum.map_join(Enum.with_index(~w(X Y Z)), " · ", fn {axis, i} ->
      values = Enum.map(points, &Enum.at(&1, i))

      "#{axis} #{Float.round(Enum.min(values) * 1.0, 3)}…#{Float.round(Enum.max(values) * 1.0, 3)}"
    end)
  end
end
