defmodule PublicSituationMachineTurnZeroWeb.BearingRegistrationPanel do
  use PublicSituationMachineTurnZeroWeb, :html

  alias PublicSituationMachineTurnZero.Workshop.{BearingRegistrationStudy, SharedFaceStudy}

  def study(assigns) do
    assigns = assign(assigns, :model, BearingRegistrationStudy.model())

    ~H"""
    <section
      id="ge-bearing-study"
      class="ge-measure-witness my-4 space-y-4 p-4"
      data-face-match={to_string(@model.face_match)}
    >
      <header>
        <h3>45° XT TOWARD YT · local registration</h3>
        <p>
          X right, Y up from Ground, Z into the drawing. Blue origin [0, 0, 0], yellow origin
          [0, 0, 3], parallel axes. The whole Z=3 face registers over X,Y ∈ [0, 3], area {@model.area}.
        </p>
        <p>
          Green is the local bearing. Magenta holds the drawing’s return fixed
          [3, 3, 3] → [0, 0, 6] (3√3, −35.264° elevation, 135° azimuth).
          The dashed segment marks a position gap. Global Diagonal A/B and XT TO XT retain their own registrations.
        </p>
      </header>
      <div class="grid gap-4 lg:grid-cols-3">
        <article
          :for={trial <- @model.trials}
          id={"ge-bearing-#{trial.id}"}
          class="min-w-0 rounded-lg border border-slate-400/40 p-3"
          data-point-match={to_string(trial.point_match)}
          data-overlap={to_string(trial.overlap)}
        >
          <h4 class="font-semibold">{trial.label}</h4>
          <.diagram trial={trial} model={@model} view="Oblique" />
          <p>[0, 0, 0] → {trial.exact_endpoint} · {trial.exact_length}</p>
          <p>
            Rise 3 · run {number(trial.run)} · elevation {number(trial.elevation)}° · azimuth {number(
              trial.azimuth
            )}°
          </p>
          <p>
            Shared-plane ray {point(trial.plane_hit)} · segment on shared face {point(trial.face_hit)} ·
            gap to magenta {number(trial.gap)}.
          </p>
          <div class="my-2 grid grid-cols-2 gap-2">
            <.diagram
              :for={view <- ["Flat", "Side", "Top", "Tunnel"]}
              trial={trial}
              model={@model}
              view={view}
            />
          </div>
          <p>
            Directed turn {number(trial.turn)}° · tangent dot {number(trial.tangent_dot)} · material normal dot {number(
              trial.normal_dot
            )}.
          </p>
          <p>
            Oriented end sections match {yes(trial.end_match)} · finite bars overlap {yes(
              trial.overlap
            )}.
          </p>
          <p>
            Local stock fit blue/yellow {yes(trial.blue_fits)}/{yes(trial.yellow_fits)} ·
            SIX stock fit {Enum.map_join(trial.footprints, "/", &yes/1)}.
          </p>
          <details class="mt-2">
            <summary>Finite JANUSITE and hinge samples</summary>
            <p>Stock section 0.16 × 0.04 · two-piece volume {number(trial.stock_volume)}.</p>
            <p>
              UN-VANISHING section (green) {status(trial.workshop_aperture)}.
              Trial seam disk at [3, 3, 3], normal +Z, radius 0.4.
              Blue/yellow {Enum.map_join(trial.trial_aperture, " / ", &status/1)} ·
              joined passage {yes(trial.trial_combined_aperture)}.
            </p>
            <p>
              Drawn-position occupied floors Y {Enum.map_join(trial.floors, " / ", &number/1)} · newest strictly lower {yes(
                trial.newest_nearest
              )}.
            </p>
            <p>
              Magenta rotates about its start toward green’s tangent in eight equal steps.
              Rigid stock is conserved. Max sampled length error {trial.hinge
              |> Enum.map(& &1.length_error)
              |> Enum.max()
              |> scientific()}.
              Pin, seam construction and clearance between samples remain open.
            </p>
            <p class="text-xs">
              Lower compares occupied stock floors. Both in SIX includes Ground clearance.
            </p>
            <table class="my-2 w-full border-collapse text-xs [&_td]:px-1 [&_th]:px-1 [&_th]:pb-1">
              <caption class="sr-only">Bounded hinge sweep</caption>
              <thead>
                <tr>
                  <th>Angle</th><th>Overlap</th><th>Both in SIX</th><th>Disk</th><th>Lower</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={sample <- trial.hinge}>
                  <td>{number(sample.angle)}°</td><td>{yes(sample.overlap)}</td><td>
                    {yes(sample.both_fit_six)}
                  </td>
                  <td>{status(sample.seam_aperture)}</td><td>{yes(sample.newest_nearest)}</td>
                </tr>
              </tbody>
            </table>
          </details>
        </article>
      </div>
      <p>
        From the blue origin, a rise-3 line at 45° reaches Z=3 only at [0, 3, 3]. Any X travel uses some of the horizontal run.
      </p>
      <p>
        Flat looks along +Z, Side uses Z/Y, Top uses X/Z, and Tunnel is a depth-scaled view along +Z.
        The drawing’s brown rims still need physical planes and radii.
      </p>
      <p>
        Two local framings fit in SIX. Physical two-Footing capacity remains open.
        The prospective third reference begins at Z=6 and extends to Z=9.
        This inspection leaves the acquisition index at ZERO.
      </p>
    </section>
    """
  end

  attr :trial, :map, required: true
  attr :model, :map, required: true
  attr :view, :string, required: true

  defp diagram(assigns) do
    assigns = assign(assigns, :project, &BearingRegistrationStudy.project(&1, assigns.view))

    ~H"""
    <figure class="min-w-0">
      <figcaption class="text-xs">{@view}</figcaption>
      <svg
        viewBox="0 5 172 165"
        class="w-full rounded"
        style="background: #101827"
        role="img"
        aria-label={"#{@trial.label} · #{@view}"}
      >
        <polygon points={@project.(@model.face)} fill="#facc15" fill-opacity="0.14" />
        <g
          :for={{box, color} <- [{@model.blue, "#65aaff"}, {@model.yellow, "#facc15"}]}
          stroke={color}
          opacity="0.65"
        >
          <polyline :for={edge <- SharedFaceStudy.edges(box)} points={@project.(edge)} fill="none" />
        </g>
        <g
          :for={{faces, color} <- Enum.zip(@trial.stock_edges, ["#86efac", "#f472e8"])}
          fill={color}
          fill-opacity="0.3"
          stroke={color}
          stroke-width="0.35"
        >
          <polygon :for={face <- faces} points={@project.(face)} />
        </g>
        <polyline
          :if={!@trial.point_match}
          points={@project.([List.last(@trial.bearing), hd(@trial.return)])}
          stroke="#f8fafc"
          stroke-dasharray="2 3"
          fill="none"
        />
        <g
          :for={{bearing, color} <- [{@trial.bearing, "#86efac"}, {@trial.return, "#f472e8"}]}
          stroke={color}
        >
          <polyline points={@project.(bearing)} stroke-width="1.6" fill="none" />
          <% {x, y} = BearingRegistrationStudy.position(List.last(bearing), @view) %>
          <circle cx={x} cy={y} r="2" fill={color} />
        </g>
      </svg>
    </figure>
    """
  end

  defp yes(true), do: "yes"
  defp yes(false), do: "no"
  defp status(value), do: value |> Atom.to_string() |> String.replace("_", " ")
  defp number(n), do: :erlang.float_to_binary(n * 1.0, decimals: 4)
  defp scientific(n), do: :erlang.float_to_binary(n, scientific: 1)
  defp point(nil), do: "none"
  defp point(values), do: "[" <> Enum.map_join(values, ", ", &number/1) <> "]"
end
