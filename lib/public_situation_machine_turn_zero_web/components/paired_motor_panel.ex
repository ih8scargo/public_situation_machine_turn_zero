defmodule PublicSituationMachineTurnZeroWeb.PairedMotorPanel do
  # Historical/trial presentation: no revised Seat ONE/Table THREE fit or protected acquisition is implied.
  # Reconcile against docs/architecture/geometry/README.md and impact-ledger.md before changing geometry.
  use PublicSituationMachineTurnZeroWeb, :html
  alias PublicSituationMachineTurnZero.Workshop.PairedMotor
  attr :motor, :map, required: true
  attr :bugs, :integer, default: 1
  attr :cargo, :string, default: nil

  def panel(assigns) do
    assigns =
      assign(assigns,
        model: PairedMotor.model(assigns.motor),
        identities: PairedMotor.identities(assigns.cargo || "prospective-cargo")
      )

    ~H"""
    <section
      id="paired-motor"
      class="my-6 rounded-2xl border border-teal-800 bg-slate-950 p-5 text-slate-200"
      data-index={@motor.index}
    >
      <p class="text-xs tracking-widest text-teal-300">PAIRED MOTOR / RECOVERY LAB</p>
      <h2 class="my-2 text-xl font-semibold">The plane remains. The course develops.</h2>
      <p>
        REHEARSAL ONLY · Phase: {@motor.phase} · progression {@motor.q} · actual turn index {@motor.index}
      </p>
      <p class="my-2 text-sm">
        Trial plane X = Z, 45° in plan. HERE and NEXT remain SIX cubes. NEXT placement is a comparison hypothesis, not acquired Standing.
      </p>
      <p id="paired-motor-current-turn-qualification" class="my-2 text-sm">
        Historical diagnostic YT prefix only: this panel does not furnish or acquire a continuation beyond current-turn Diagonal B. See the Geometry RE-surfacing Table's current-turn measure witness.
      </p>
      <div class="my-4 flex flex-wrap gap-2">
        <button
          :for={
            {action, label} <- [
              {"start", "Beginning"},
              {"middle", "Intermediate"},
              {"end", "Quarter-turn completion"},
              {"ground", "Rehearse Ground + immediate zipper"},
              {"pending", "Rehearse PENDING UN-BUTTONING"},
              {"return", "Record return-furnished extent"},
              {"next", "Stage subsequent Footing"},
              {"earlier", "Inspect return to first entrance"}
            ]
          }
          id={"motor-#{action}"}
          phx-click="motor"
          phx-value-action={action}
          phx-value-revision={@motor.revision}
          class="rounded-lg border border-teal-800 px-3 py-2 text-sm transition hover:bg-teal-900 focus-visible:outline-2 focus-visible:outline-teal-300"
        >{label}</button>
      </div>
      <div class="grid gap-4 lg:grid-cols-2">
        <figure :for={
          {view, title} <- [
            {:side, "Side Regarding"},
            {:within, "FROM-WITHIN · fixed perspective eye"}
          ]
        }>
          <figcaption>{title} · same world points</figcaption>
          <svg
            id={"motor-view-#{view}"}
            viewBox="-200 -80 850 500"
            role="img"
            aria-label={title}
            class="w-full rounded-xl bg-slate-900"
          >
            <polyline
              :for={edge <- @model.here}
              points={PairedMotor.project(edge, view)}
              fill="none"
              stroke="#64748b"
              stroke-width="1"
            />
            <polyline
              :for={edge <- @model.next}
              points={PairedMotor.project(edge, view)}
              fill="none"
              stroke="#a78bfa"
              stroke-dasharray="4 3"
            />
            <polyline
              points={
                PairedMotor.project(
                  [[-3, 0, -3], [9, 0, 9], [9, 6, 9], [-3, 6, -3], [-3, 0, -3]],
                  view
                )
              }
              fill="none"
              stroke="#475569"
              stroke-dasharray="2 4"
            />
            <polyline
              :for={{m, i} <- Enum.with_index(@model.members)}
              points={PairedMotor.project(m.points, view)}
              fill="none"
              stroke={Enum.at(["#fff", "#2dd4bf", "#fbbf24", "#fb7185"], i)}
              stroke-width="2"
            >
              <title>{m.name} · shared q={m.q}</title>
            </polyline>
            <polyline
              points={PairedMotor.project(@model.next_outgoing, view)}
              fill="none"
              stroke="#fbbf24"
              stroke-dasharray="5 3"
            />
            <polyline
              points={PairedMotor.project(@motor.return_path, view)}
              fill="none"
              stroke="#38bdf8"
              stroke-width="4"
            />
            <polyline
              points={PairedMotor.project(@model.pinning.line, view)}
              fill="none"
              stroke="#e879f9"
              stroke-dasharray="1 3"
            />
            <polyline
              :for={i <- 1..@bugs}
              points={
                PairedMotor.project(
                  [
                    PairedMotor.point(@motor.q * i / @bugs),
                    PairedMotor.point(@motor.q * i / @bugs + 0.03)
                  ],
                  view
                )
              }
              fill="none"
              stroke="#fef08a"
              stroke-width="7"
            >
              <title>Lanterning presence {i}; no Ground consequence</title>
            </polyline>
          </svg>
        </figure>
      </div>
      <p class="my-3 text-sm">
        White: invariant bar · teal: outgoing triangle · rose: reciprocal trial · gold: YT succession · violet: NEXT · blue: centerline return. Both hinges retain the source diagonal. Face orientation is ordered vertex winding; reciprocal reflection remains unproved.
      </p>
      <div id="motor-footings" class="my-3 text-sm">
        <p :for={f <- @motor.footings} id={f.id}>
          {f.id}: Ground rehearsed; return extent recorded separately in event history. COB/Craft reference {f.cob_ground}; entrance {inspect(
            f.entrance
          )}. No constitutional acquisition.
        </p>
      </div>
      <details class="my-3">
        <summary>Material identities and append-only rehearsal history</summary>
        <p :for={{role, id} <- @identities}>{role}: {id}</p>
        <p>
          PINNING endpoint held by {@model.pinning.holder}: {inspect(@model.pinning.endpoint)}. Bobbining String remains separate.
        </p>
        <p :for={event <- @motor.events}>
          #{event.sequence}: {inspect(event.action)} · Footing {event.footing} · acquired index {event.index}
        </p>
      </details>
      <details id="motor-arc-comparison" class="my-3">
        <summary>Recovered FOUR / SIX / EIGHT diorama · Assignment 04</summary>
        <svg
          viewBox="0 150 500 150"
          class="w-full max-w-lg"
          aria-label="Provisional relative-radius arc comparison"
        >
          <polyline
            :for={arc <- PairedMotor.arcs()}
            points={PairedMotor.project(arc.points, :side)}
            fill="none"
            stroke={if arc.reference == 6, do: "#2dd4bf", else: "#a78bfa"}
          >
            <title>{arc.reference}: radius {arc.radius}</title>
          </polyline>
        </svg>
        <p>
          Separate source-local quarter-sector, not a motor-frame transform. SIX remains canonical; FOUR and EIGHT are prospective comparisons. No ceiling or acquired Ground is derived.
        </p>
      </details>
      <p class="my-2 text-sm">
        Diagnostic course length: {@model.accounting.retained}; shown prefix: {@model.accounting.newly_shown}. {@model.accounting.supply}. Triangle edge lengths remain six; twist and solid passage remain unproved.
      </p>
      <div id="motor-failures" class="rounded-lg border border-amber-800 p-3 text-sm text-amber-200">
        <p :for={failure <- @model.failures}>{failure}</p>
        <p>
          FOUR downshift / SIX reference / EIGHT upshift: Assignment 04 comparison: provisional radii r·4/6, r, r·8/6 (r=1.5). Constitutional arc law and relation to this motor remain unresolved.
        </p>
      </div>
    </section>
    """
  end
end
