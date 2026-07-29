defmodule PublicSituationMachineTurnZeroWeb.ApplianceLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "THE APPLIANCE")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <main id="appliance-page" class="site-page site-page--placeholder">
        <header class="site-page__header">
          <p class="site-page__eyebrow">PUBLIC-SITUATION-MACHINE-</p>
          <p class="site-page__subtitle">General Purpose Situationing Appliance</p>
          <h1>THE APPLIANCE</h1>
        </header>
        <p>This Locality now stands in Composementing.</p>
      </main>
    </Layouts.app>
    """
  end
end
