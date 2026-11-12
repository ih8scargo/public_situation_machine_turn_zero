defmodule PublicSituationMachineTurnZeroWeb.EngineeringQuarryLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:wedging_geometry} show_navigation={false}>
      <main class="mx-auto max-w-3xl space-y-6 px-5 py-12">
        <.link navigate={~p"/workshop/coming-aboard"} class="underline">Coming Aboard</.link>
        <h1 class="text-3xl font-semibold">Engineering Quarry</h1>
        <ul class="space-y-4 underline">
          <li>
            <.link navigate={~p"/workshop/engineering-quarry/coming-aboard-rehearsal"}>Coming-Aboard Geometry Rehearsal</.link>
          </li>
          <li>
            <.link navigate={~p"/workshop/wedging-geometry"}>Wedging, common material, Snail Weave and Roundabout Gallery</.link>
          </li>
          <li>
            <.link navigate={~p"/workshop/rail-recovery"}>Rail Recovery and half-twist trial</.link>
          </li>
          <li>
            <.link navigate={~p"/experiments/architecture"}>Toy Box, PUFFING, paired apertures and Pointing-able Thing</.link>
          </li>
          <li>
            <.link navigate={~p"/experiments/refolding"}>Disassembly and refolding witness</.link>
          </li>
        </ul>
        <section class="space-y-3">
          <h2 class="text-xl font-semibold">Bearing archway inscriptions</h2>
          <figure :for={
            {file, label} <- [
              {"archway.png", "Annotated triangle, square and inward flap"},
              {"crossing.png", "Crossing and original bearings"},
              {"length-key.png", "Bearing archway inscription"}
            ]
          }>
            <a href={~p"/images/coming-aboard/#{file}"}><img
              src={~p"/images/coming-aboard/#{file}"}
              alt={label}
              loading="lazy"
            /></a>
            <figcaption>{label}</figcaption>
          </figure>
        </section>
      </main>
    </Layouts.app>
    """
  end
end
