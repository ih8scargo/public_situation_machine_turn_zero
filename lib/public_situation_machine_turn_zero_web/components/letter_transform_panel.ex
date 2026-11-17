defmodule PublicSituationMachineTurnZeroWeb.LetterTransformPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  attr :state, :map, required: true
  attr :record, :map, required: true

  def panel(assigns) do
    assigns =
      assign(
        assigns,
        :inspection_form,
        to_form(
          %{
            "revision" => assigns.state.revision,
            "letter_bearing" => assigns.state.letter_inspection.bearing,
            "letter_door" => assigns.state.letter_inspection.door,
            "letter_curvature" => assigns.state.letter_inspection.curvature
          },
          as: :toy
        )
      )

    ~H"""
    <section
      id="letter-transform-inspection"
      class="rfh-controls"
      data-contract={@record.contract}
      data-source-id={@record.source_identity}
      data-source-hash={@record.source_hash}
      data-active={to_string(@record.active)}
    >
      <h2>One R · two independently inspectable transformations</h2>
      <p>
        One existing source: {@record.source_identity}. Inscription: {@record.inscription_source}. Allocation remains ONE × ONE × ONE in the letter's own frame. The ROOM remains SIX × SIX × SIX.
      </p>
      <div class="rtb-controls">
        <button
          id="letter-inspect"
          phx-click="room-toy-action"
          phx-value-action="letter_inspection"
          phx-value-choice="activate"
          phx-value-revision={@state.revision}
        >Inspect the same R and leading toe</button>
        <button
          id="letter-inspection-close"
          phx-click="room-toy-action"
          phx-value-action="letter_inspection"
          phx-value-choice="close"
          phx-value-revision={@state.revision}
        >Restore workflow pose / Regarding</button>
      </div>
      <.form for={@inspection_form} id="letter-transform-settings" phx-change="room-toy-setting">
        <.input field={@inspection_form[:revision]} id="letter-transform-revision" type="hidden" />
        <.input
          field={@inspection_form[:letter_door]}
          id="rtb-letter_door"
          type="range"
          min="0"
          max="90"
          step="0.5"
          label="Door opening · finite leaf pose, same R stationary"
        />
        <.input
          field={@inspection_form[:letter_bearing]}
          id="rtb-letter_bearing"
          type="range"
          min="0"
          max="90"
          step="0.5"
          label="T1 · Flat to edge-on Regarding · observer bearing only"
        />
        <.input
          field={@inspection_form[:letter_curvature]}
          id="rtb-letter_curvature"
          type="range"
          min="0"
          max="1"
          step="0.03125"
          label="T2 · Existing U curvature-frame sample · rigid letter pose preview"
        />
      </.form>
      <p id="letter-transform-status">
        {if @record.active,
          do: "INSPECTION POSE ·",
          else: "WORKFLOW RESTORED · retained inspection parameters:"} T1 bearing {@state.letter_inspection.bearing}° · Door {@state.letter_inspection.door}°. T2 source sample {@record.curvature.index} / 32 · material frame {Float.round(
          @record.material_pose.degrees,
          4
        )}°. The source mesh is unchanged. A rotated world bounding box is not an enlarged allocation.
      </p>
      <svg
        id="letter-curvature-source"
        viewBox="0 0 360 180"
        role="img"
        aria-label="Existing U source curve and selected frame; inspection reference, no second letter"
      >
        <polyline points={curve_points(@record.curvature.source_course)} class="rtb-guide" />
        <circle
          cx={cx(@record.curvature.point)}
          cy={cy(@record.curvature.point)}
          r="4"
          fill="#b46b38"
        />
        <line
          x1={cx(@record.curvature.point)}
          y1={cy(@record.curvature.point)}
          x2={cx(@record.curvature.point) + Enum.at(@record.curvature.tangent, 0) * 25}
          y2={cy(@record.curvature.point) - Enum.at(@record.curvature.tangent, 1) * 25}
          stroke="#31594d"
          stroke-width="2"
        />
        <text x="15" y="165">Existing candidate U · source sample · no new material</text>
      </svg>
      <p class="rtb-yellow" id="letter-curvature-gate">
        T2 samples the existing candidate U and co-registers its frame at the same letter origin. It does not bend the glyph or establish a new passage. Actual curvature standing through lawful PUFFING remains unbound; preview overlaps are reported below.
      </p>
      <button
        id="letter-puffing-gate"
        phx-click="room-toy-action"
        phx-value-action="letter_inspection"
        phx-value-choice="puff"
        phx-value-revision={@state.revision}
      >Test lawful PUFFING gate</button>
      <details id="letter-transform-ledger">
        <summary>Before/after source, material pose, curvature, bearing and toe provenance</summary><pre>{inspect(Map.drop(@record,[:posed_geometry,:posed_allocation]),pretty: true,limit: :infinity)}</pre>
      </details>
      <p id="letter-toe-source" data-source-id={@record.toe.id}>
        R leading toe: original final diagonal stroke end-cap · source face {@record.toe.source_face_index}. Its material point and the reference TOWARD back-wall YT follow the same rigid pose. Issuing reference is not accepted PINNING or PITTONING.
      </p>
    </section>
    """
  end

  defp cx([x, _, _]), do: 180 + (x - 5.6) * 100
  defp cy([_, y, _]), do: 130 - (y - 5.02) * 100
  defp curve_points(points), do: Enum.map_join(points, " ", fn p -> "#{cx(p)},#{cy(p)}" end)
end
