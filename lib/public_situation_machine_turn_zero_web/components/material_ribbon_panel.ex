defmodule PublicSituationMachineTurnZeroWeb.MaterialRibbonPanel do
  # Historical/trial presentation: no revised Seat ONE/Table THREE fit or protected acquisition is implied.
  # Reconcile against docs/architecture/geometry/README.md and impact-ledger.md before changing geometry.
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Workshop.MaterialRibbon, as: M

  attr :bench, :map, required: true
  attr :motor, :map, required: true
  attr :cargo, :any, default: nil

  def panel(assigns) do
    model = M.model(assigns.bench, assigns.motor, assigns.cargo)

    assigns =
      assign(assigns,
        model: model,
        piece: Enum.find(model.pieces, &(&1.id == assigns.bench.selected)),
        form:
          to_form(%{"q" => round(assigns.bench.q * 100), "revision" => assigns.bench.revision},
            as: :material_fold
          ),
        inscription:
          to_form(%{"reference" => "SIX", "text" => "", "revision" => assigns.bench.revision},
            as: :reference
          )
      )

    ~H"""
    <section
      id="material-bench"
      class="mr-bench"
      data-version={@model.version}
      data-revision={@bench.revision}
      data-q={@bench.q}
      data-view={@bench.view}
      data-index="0"
    >
      <header class="mr-header">
        <div>
          <p class="sr-eyebrow">EXPERIMENTAL MATERIAL CRAFTING / 01</p><h2>Work WITH the Ribbon</h2><p>
            One construction · six Regardings · no acquired turns
          </p>
        </div>
        <span class="mr-badge">BODY AHEAD OF THEORY</span>
      </header>
      <nav class="mr-views" aria-label="Material Regarding">
        <button
          :for={view <- M.views()}
          id={"mr-view-#{view}"}
          phx-click="material-command"
          phx-value-kind="view"
          phx-value-choice={view}
          phx-value-revision={@bench.revision}
          aria-pressed={to_string(@bench.view == view)}
        >{view_label(view)}</button>
      </nav>
      <div class="mr-columns">
        <div>
          <div class="mr-canvas-label">
            <strong>Occupied material / {@bench.view}</strong><span>motor-extent-v1 · orthographic</span>
          </div>
          <svg
            id="mr-world"
            viewBox="0 0 500 440"
            role="img"
            aria-label="Same occupied Ribbon surfaces with retained entrances and reference gauges"
          >
            <defs>
              <pattern id="mr-grid" width="24" height="24" patternUnits="userSpaceOnUse">
                <path d="M 24 0 L 0 0 0 24" fill="none" stroke="#dce1d4" stroke-width="0.5" />
              </pattern>
            </defs>
            <rect width="500" height="440" fill="url(#mr-grid)" />
            <polygon
              :for={f <- @model.footings}
              id={"mr-#{f.door_id}"}
              points={M.project(f.points, @bench.view)}
              data-world={Jason.encode!(f.points)}
              fill="none"
              stroke="#8374a4"
              stroke-dasharray="4 4"
            >
              <title>{f.id} · retained entrance · {inspect(f.ground)}</title>
            </polygon>
            <polyline
              id="mr-straight"
              points={M.project(@model.straight_control, @bench.view)}
              stroke="#9ba197"
              stroke-width="2"
              stroke-dasharray="5 5"
              fill="none"
            >
              <title>Straight control: no material surface or N18 incidence</title>
            </polyline>
            <polyline
              :for={g <- @model.gauges}
              :if={@bench.gauges?}
              id={"mr-#{g.id}"}
              points={M.project(g.points, @bench.view)}
              fill="none"
              stroke={if(g.label == 6, do: "#b08b3f", else: "#b8b39d")}
              stroke-dasharray={if(g.axis == "x", do: "", else: "3 3")}
            >
              <title>{g.label} · A04 {g.axis}-axis alternative · reference, not trajectory</title>
            </polyline>
            <g
              :for={p <- @model.pieces}
              id={"mr-piece-#{p.id}"}
              data-world={Jason.encode!(p.vertices)}
              data-material={p.material_id}
              data-source={p.source}
              class={if(@bench.selected == p.id, do: "mr-selected", else: "")}
            >
              <polygon
                :for={{face, i} <- Enum.with_index(p.faces)}
                id={"mr-face-#{p.id}-#{i}"}
                points={M.project(face, @bench.view)}
                fill={color(p.id)}
                fill-opacity={if(i == 0, do: "0.78", else: "0.35")}
                stroke={color(p.id)}
                stroke-width="1.1"
              >
                <title>{p.id} face {i} · {p.thickness} thick · {inspect(p.status)}</title>
              </polygon>
              <polyline
                points={M.project(p.hinge.endpoints, @bench.view)}
                stroke="#1f3938"
                stroke-width="3"
              >
                <title>Ordered inherited hinge A TOWARD B</title>
              </polyline>
            </g>
            <polyline
              id="mr-local-bar"
              points={M.project(@model.bar, @bench.view)}
              stroke="#172d30"
              stroke-width="5"
            >
              <title>Invariant XT TO XT · ZERO TO ONE · length one</title>
            </polyline>
            <polyline
              id="mr-return"
              points={M.project(@model.return.points, @bench.view)}
              data-world={Jason.encode!(@model.return.points)}
              stroke="#ac5864"
              stroke-width="2"
              stroke-dasharray="6 3"
              fill="none"
            >
              <title>
                N18 THROUGH Crossing TOWARD HERE · waypoint trial, occupied clearance unproved
              </title>
            </polyline>
            <polyline
              :for={o <- @model.crossing.objects}
              id={"mr-crossing-#{o.id}"}
              points={
                M.project(
                  o.points ++ if(o.id == "pretend-projector-ray", do: [], else: [hd(o.points)]),
                  @bench.view
                )
              }
              data-world={Jason.encode!(o.points)}
              fill="none"
              stroke="#3f87a1"
              stroke-width="1.2"
            >
              <title>{o.id} · A04 reference</title>
            </polyline>
            <polygon
              id="mr-aperture"
              points={M.project(@model.aperture.points, @bench.view)}
              fill="none"
              stroke="#3f87a1"
              stroke-width="2"
            >
              <title>
                A04 toe-fixed aperture · beta 45°; separate from −45° transverse registration
              </title>
            </polygon>
            <polygon
              :for={{face, i} <- Enum.with_index(@model.obstacle.faces)}
              :if={@bench.obstacle?}
              id={"mr-stop-#{i}"}
              points={M.project(face, @bench.view)}
              fill="#ba4c42"
              fill-opacity="0.5"
              stroke="#a83c35"
            >
              <title>Occupied clearance-stop fixture</title>
            </polygon>
            <text x="18" y="26" fill="#52625c" font-size="11">
              SIX / FOUR / EIGHT are references. The course is fashioned.
            </text>
            <text :if={@bench.inscriptions?} x="18" y="410" fill="#52625c" font-size="11">
              COB orientationing · Rail / Road / String / PINNING remain distinct
            </text>
          </svg>
          <div class="mr-legend">
            <span>● outgoing</span><span>● retained</span><span>● reciprocal trial</span><span>┄ N18 return trial</span>
          </div>
          <p id="mr-fold-notice" class="mr-notice" role="status">
            {@bench.notice ||
              "Select a piece, then propose a hinge position. Every manipulation remains a candidate."}
          </p>
        </div>
        <aside class="mr-controls">
          <h3>Material & hinge</h3>
          <div class="mr-pieces">
            <button
              :for={id <- M.pieces()}
              id={"mr-select-#{id}"}
              phx-click="material-command"
              phx-value-kind="select"
              phx-value-choice={id}
              phx-value-revision={@bench.revision}
              aria-pressed={to_string(@bench.selected == id)}
            >{id}</button>
          </div>
          <.form for={@form} id="mr-fold-form" phx-change="material-fold">
            <.input field={@form[:revision]} type="hidden" />
            <.input
              field={@form[:q]}
              type="range"
              min="0"
              max="100"
              step="1"
              label={"Propose fold · #{round(@bench.q * 90)}° / 90°"}
            />
          </.form>
          <button
            id="mr-fold-end"
            phx-click="material-command"
            phx-value-kind="fold"
            phx-value-choice="100"
            phx-value-revision={@bench.revision}
          >Propose full fold</button>
          <div class="mr-toggles">
            <button
              :for={
                {key, label} <- [
                  {"gauges", "Reference gauges"},
                  {"inscriptions", "Reference inscriptions"},
                  {"obstacle", "Clearance stop"}
                ]
              }
              id={"mr-toggle-#{key}"}
              phx-click="material-command"
              phx-value-kind="toggle"
              phx-value-choice={key}
              phx-value-revision={@bench.revision}
            >{label}</button>
          </div>
          <p>Compare ±180° Rail roll. Handedness remains unappointed.</p>
          <div class="mr-pieces">
            <button
              :for={h <- [-1, 1]}
              id={"mr-hand-#{h}"}
              phx-click="material-command"
              phx-value-kind="hand"
              phx-value-choice={h}
              phx-value-revision={@bench.revision}
            >{h * 180}° trial</button>
          </div>
          <.form for={@inscription} id="mr-inscription-form" phx-submit="material-inscribe">
            <.input field={@inscription[:revision]} type="hidden" />
            <.input
              field={@inscription[:reference]}
              type="select"
              options={M.references()}
              label="Appoint TOWARD a reference"
            />
            <.input
              field={@inscription[:text]}
              type="text"
              maxlength="160"
              label="Your inscription / interpretation"
            />
            <button id="mr-appoint" type="submit">Appoint inscription</button>
          </.form>
          <p id="mr-appointments">{inspect(@bench.appointments)}</p>
          <p class="mr-fine">
            Looking THROUGHING THROUGHING Glass · references optional. Inscription changes neither material identity nor acquired Standing.
          </p>
        </aside>
      </div>
      <div class="mr-columns mr-registers">
        <section>
          <h3>Rail: same source, different Regardings</h3>
          <p>
            3 / 6 / 9 / 7 · correspondence by ordinal, not a physical square-to-curve deformation.
          </p>
          <div class="mr-rail-views">
            <svg
              :for={view <- ["flat", "gallery"]}
              id={"mr-rail-#{view}"}
              viewBox="0 0 260 240"
              role="img"
              aria-label={"Source Rail #{view}"}
            >
              <polygon
                :for={{face, i} <- Enum.with_index(@model.rail.ribbon.faces)}
                id={"mr-rail-#{view}-face-#{i}"}
                points={M.project(face.points, view, 40, [35, 205])}
                data-world={Jason.encode!(face.points)}
                fill="#ba8857"
                fill-opacity="0.75"
                stroke="#75583b"
                stroke-width="0.35"
              />
              <text x="12" y="20" font-size="12">{view} · same material source</text>
            </svg>
          </div>
          <details id="mr-rail-register">
            <summary>Backstage square registrations / all 25 correspondences</summary>
            <table>
              <thead>
                <tr>
                  <th>Identity</th><th>Square source</th><th>Curved source center</th>
                </tr>
              </thead><tbody>
                <tr :for={link <- @model.rail.links} id={"mr-#{link.id}"}>
                  <td>{link.square["index"]} · {link.square["letter"]}</td><td>
                    {inspect(link.square["point"])}
                  </td><td>{inspect(link.curved_midpoint)}</td>
                </tr>
              </tbody>
            </table>
          </details>
        </section>
        <section id="mr-n18">
          <h3>N18 · established return locality</h3>
          <dl>
            <dt>Steeling N18 / incoming chord</dt><dd>
              {inspect(@model.return.n_return["point"])} / {inspect(@model.return.incoming)}
            </dd><dt>Inscription boundary purchase 18</dt><dd>{inspect(@model.rail.n18_boundary)}</dd><dt>
              N18 / M19 centers, purchases 17.5 / 18.5
            </dt><dd>
              {inspect(@model.rail.n18_center.point)} / {inspect(@model.rail.m19_center.point)}
            </dd><dt>Candidate material roll</dt><dd>
              17.5 → 18.5 · {@bench.hand * 180}° · unresolved handedness
            </dd><dt>Return waypoints, source frame</dt><dd>
              {inspect(@model.return.source_points)}
            </dd>
          </dl>
          <p>
            N18 → U13 → Projectioning Thing → A04 HERE. These reference points do not prove passage THROUGH the finite aperture.
          </p>
          <details>
            <summary>Projectioning Crossing / U WITHIN U / exact transform</summary><p>
              Rigid pivot preserves the aperture's straight boundary; it cannot itself create curvature. Square/curved appearances and optical UP ACROSS DOWN transfer remain different correspondences.
            </p><pre>{inspect(@model.registration, pretty: true)}</pre><p>
              A04 fixed U13, nested 1.2 × 1.2 enclosure within 2.4 × 2.4 U, source normal +Z. Physical return incidence and curvature-producing optical law remain unproved.
            </p>
          </details>
        </section>
      </div>
      <details id="mr-material-ledger">
        <summary>
          Selected material · vertices, faces, hinges, provenance and DIRT requirements
        </summary>
        <pre :if={@piece}>{inspect(@piece, pretty: true)}</pre>
        <pre :if={is_nil(@piece)}>{inspect(Map.take(@model.rail.ribbon, [:id, :head, :tail, :source, :provenance, :thickness_candidate, :twist_range]), pretty: true)}</pre>
        <p>
          Model {@model.version}; frame motor-extent-v1; trial extent unit; source identities {inspect(
            @model.identities
          )}.
        </p>
        <p id="mr-event-count">
          {length(@bench.events)} session events · 0 acquired turns · no persistence or CSV round-trip claim.
        </p>
        <pre>{inspect(List.last(@bench.events), pretty: true)}</pre>
      </details>
      <details id="mr-failures">
        <summary>Demonstrated limits / next geometrical proofs</summary><ul>
          <li :for={failure <- @model.failures}>{failure}</li>
        </ul>
      </details>
    </section>
    """
  end

  defp color("outgoing"), do: "#9d783f"
  defp color("retained"), do: "#568a79"
  defp color(_), do: "#8d78a4"
  defp view_label("backstage"), do: "Backstage / square"
  defp view_label("gallery"), do: "Roundabout Gallery"
  defp view_label("through"), do: "THROUGH open end"
  defp view_label("along"), do: "ALONG toward ceiling"
  defp view_label(view), do: String.capitalize(view)
end
