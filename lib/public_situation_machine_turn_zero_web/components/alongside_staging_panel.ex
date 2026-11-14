defmodule PublicSituationMachineTurnZeroWeb.AlongsideStagingPanel do
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Workshop.AlongsideStaging, as: A
  attr :state, :map, required: true
  attr :revision, :integer, required: true

  def panel(assigns) do
    assigns =
      assign(assigns,
        model: A.model(assigns.state),
        selected: Enum.find(A.materials(assigns.state), &(&1.id == assigns.state.selected))
      )

    ~H"""
    <section
      id="alongside-staging"
      class="as-bench"
      data-regarding={@state.regarding}
      data-furnished={length(@state.furnished)}
      data-staged={@state.staged && @state.staged.id}
      data-frame-acquired="false"
      data-from-down-under="false"
    >
      <header>
        <p class="sr-eyebrow">ALONGSIDE STANDING / UN-VANISHING / ANGULAR REGISTRATION</p><h3>
          Stage alongside. Keep the ancestry.
        </h3><p>
          Already-standing reference fixture and new material may share a Projectioning relationship without sharing acquisition status.
        </p>
      </header>
      <p class="as-qualification">
        {@model.note} Actual Human frame and Landinging acquisition remain unproved; no working COB is mounted.
      </p>
      <div class="as-controls">
        <span>Pivot Regarding:</span><button
          :for={angle <- A.angles()}
          id={"as-pivot-#{angle}"}
          phx-click="explore-staging"
          phx-value-action="pivot"
          phx-value-angle={angle}
          phx-value-revision={@revision}
          aria-pressed={to_string(@state.regarding == angle)}
        >{angle}°</button>
        <button
          :for={
            {action, label} <- [
              {"appoint", "Appoint this wedging"},
              {"stage", "Stage alongside"},
              {"retain", "Retain candidate furnishing"},
              {"acquire", "Inspect Landinging gate"},
              {"scan", "Attempt COB scan"}
            ]
          }
          id={"as-#{action}"}
          phx-click="explore-staging"
          phx-value-action={action}
          phx-value-revision={@revision}
        >{label}</button>
      </div>
      <p id="as-appointment">
        Regarding {@state.regarding}° · appointed wedging {if(@state.target,
          do: "#{@state.target.angle}° / #{@state.target.id}",
          else: "none"
        )}. Pivoting does not appoint or move material.
      </p>
      <div class="as-views">
        <figure :for={
          {view, title} <- [
            {"flat", "Flat presentation"},
            {"transverse", "Transverse Gallery profile"},
            {"plan", "Shared registration plan"}
          ]
        }>
          <figcaption>{title} · same material IDs</figcaption>
          <svg id={"as-view-#{view}"} viewBox="0 0 340 250" role="img" aria-label={title}>
            <polyline
              id={"as-aperture-#{view}"}
              points={A.project(@model.aperture.points, view, @state.regarding)}
              data-world={Jason.encode!(@model.aperture.points)}
              fill="none"
              stroke="#36899a"
              stroke-width="2"
            >
              <title>
                UN-VANISHING registered opening TOWARD Regarding; physical transfer unproved
              </title>
            </polyline>
            <polyline
              :for={material <- @model.materials}
              points={A.project([@model.aperture.center, material.center], view, @state.regarding)}
              fill="none"
              stroke="#a8b8ae"
              stroke-dasharray="3 3"
            >
              <title>Shared Projectioning reference; not a material pipe or acquired passage</title>
            </polyline>
            <g
              :for={material <- @model.materials}
              id={"as-#{view}-#{material.id}"}
              data-material={material.id}
              data-world={Jason.encode!(material.vertices)}
              data-status={material.status}
              data-relation={material.relation}
              data-acquisition={material.acquisition}
              data-from-down-under="false"
            >
              <polygon
                :for={face <- material.faces}
                points={A.project(face, view, @state.regarding)}
                fill={color(material.status)}
                fill-opacity="0.48"
                stroke={color(material.status)}
                stroke-width="0.7"
              >
                <title>{material.id} · {material.status} · {material.relation}</title>
              </polygon>
            </g>
            <polyline
              id={"as-axle-#{view}"}
              points={A.project(@model.axle.points, view, @state.regarding)}
              data-world={Jason.encode!(@model.axle.points)}
              data-status="candidate-registration-control"
              fill="none"
              stroke="#9a6999"
              stroke-width="2"
              stroke-dasharray="4 3"
            >
              <title>
                Derived angular-registration control; occupied axle curvature and lawful acquisition unproved
              </title>
            </polyline>
            <text x="12" y="225" font-size="10" fill="#536b5b">
              UP FROM HERE OVER ACROSS · no automatic acquisition
            </text>
          </svg>
        </figure>
      </div>
      <p id="as-notice" class="mr-notice" role="status">
        {@state.notice ||
          "Pivot Regarding → appoint a different wedging → stage material → retain a candidate furnishing. No next YT TOWARD YT is automatically appended."}
      </p>
      <div class="as-ledgers">
        <section>
          <h4>Material and shared opening</h4>
          <div
            :for={material <- @model.materials}
            id={"as-ledger-#{material.id}"}
            class="as-material-record"
          >
            <strong>{material.id}</strong><p>
              {material.status} · {material.angle}° · acquisition {material.acquisition}
            </p>
            <p>{material.relation} · THROUGH-BY {@model.aperture.id}</p>
            <button
              id={"as-inspect-#{material.id}"}
              phx-click="explore-staging"
              phx-value-action="inspect"
              phx-value-material={material.id}
              phx-value-revision={@revision}
            >Inspect this Segmentationing</button>
          </div>
          <p id="as-selection">
            Human inspection selection: {@state.selected}. This is not COB re-standing or working.
          </p>
        </section>
        <section id="as-conditional-standing">
          <h4>Later acquired relationship</h4>
          <dl>
            <dt>Current relationship</dt><dd>
              UP FROM HERE OVER ACROSS. Staging alongside is not acquisition.
            </dd><dt>Required before the later relation</dt><dd>
              Lawfully acquired Human working extent, furnished material, lawful COB Landinging acquisition and its material witnesses.
            </dd><dt>Later consequence, not established here</dt><dd>
              FROM DOWN UNDER in that acquired relationship. No material is relabeled by changing Regarding.
            </dd><dt>Permitted subsequent COB working</dt><dd>
              Only FROM WITHIN the same lawfully acquired SIX frame. Local acquisition or scanning is not another protected RE-STEP.
            </dd>
          </dl>
          <p id="as-deflection">
            Candidate control deflections: {inspect(
              Enum.map(@model.axle.deflections, &Float.round(&1, 3))
            )}°. These measure successive registered centers; they do not prove bent JANUSITE or a finished Gallery axle.
          </p>
        </section>
      </div>
      <details id="as-provenance">
        <summary>Opening, relations, source geometry and angular provenance</summary>
        <p>
          Mechanism {@model.version}; frame exploration-six-v1; trial extents; inherited reference is stipulated, actual acquisition not attested.
        </p>
        <pre>{inspect(@selected,pretty: true)}</pre><pre>{inspect(@model.aperture,pretty: true)}</pre><pre>{inspect(@model.relationships,pretty: true)}</pre><pre>{inspect(@model.axle,pretty: true)}</pre>
        <p>
          Material passage through the opening, joined occupied axle, supply/return mechanics and actual acquired FROM DOWN UNDER remain unproved. Diagonal B retains its current-turn measure; no continuation is furnished by this witness.
        </p>
      </details>
    </section>
    """
  end

  defp color(:already_standing_reference), do: "#658888"
  defp color(:newly_staged), do: "#c39348"
  defp color(_), do: "#688c59"
end
