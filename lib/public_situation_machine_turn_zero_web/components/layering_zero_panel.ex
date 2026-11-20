defmodule PublicSituationMachineTurnZeroWeb.LayeringZeroPanel do
  use PublicSituationMachineTurnZeroWeb, :html

  attr :model, :string, required: true
  attr :standing_digest, :string, required: true

  def panel(assigns) do
    ~H"""
    <section
      id="layering-zero"
      class="lzero"
      phx-hook="LayeringZero"
      phx-update="ignore"
      data-model={@model}
      data-standing-digest={@standing_digest}
    >
      <header class="lzero-header">
        <span>Gallery Door ZERO · Inspection</span>
        <h1>The Standing Appliance</h1>
        <p>Hamster Wheel ↔ ROUNDABOUT Gallery</p>
      </header>
      <div class="lzero-grid">
        <div>
          <nav class="lzero-views" aria-label="Regarding">
            <button id="lzero-flat" type="button" data-view="flat">Flat</button>
            <button id="lzero-bulb" type="button" data-view="bulb">Bulb</button>
            <button id="lzero-coil" type="button" data-view="coil">Coil</button>
            <button id="lzero-diorama" type="button" data-view="diorama">Diorama</button>
          </nav>
          <svg
            id="lzero-scene"
            viewBox="0 0 640 640"
            role="img"
            aria-label="Source-registered standing appliance"
          ></svg>
          <svg
            id="lzero-wayfinding"
            viewBox="0 0 640 132"
            role="img"
            aria-label="Persistent coil wayfinding from below"
          ></svg>
        </div>
        <aside class="lzero-instruments" aria-label="Layering ZERO instruments">
          <h2>Source inspection</h2>
          <label for="lzero-source">Material address</label>
          <select id="lzero-source"></select>
          <output id="lzero-reading" aria-live="polite"></output>
          <label for="lzero-slice">Opening slice</label>
          <select id="lzero-slice">
            <option value="source">Principal · straight source</option>
            <option value="positive">Transverse · positive trial</option>
            <option value="negative">Transverse · negative trial</option>
            <option value="compare">Together · both trials</option>
          </select>
          <label for="lzero-office">COB ribbon witness</label>
          <select id="lzero-office">
            <option value="course">Ceiling-first course</option>
            <option value="ft">Furnishing Traversaling · hold and offer</option>
            <option value="tf">Traversaling Furnishing · return alignment</option>
          </select>
          <label for="lzero-orbit">Around About</label>
          <input id="lzero-orbit" type="range" min="-180" max="180" value="32" />
          <label for="lzero-elevation">Elevation</label>
          <input id="lzero-elevation" type="range" min="-89" max="89" value="24" />
          <label for="lzero-zoom">Close Regarding</label>
          <input id="lzero-zoom" type="range" min="0.7" max="3.5" step="0.05" value="1" />
          <label for="lzero-anchor">Reference lock</label>
          <select id="lzero-anchor">
            <option value="seat">Traversaling Seat</option>
            <option value="table">RE-Surfacing Table</option>
            <option value="material">Selected material</option>
          </select>
          <label for="lzero-pose">Coil and shell pose rehearsal</label>
          <select id="lzero-pose">
            <option value="gallery">ROUNDABOUT Gallery</option>
            <option value="wheel">Upright Hamster Wheel</option>
          </select>
          <label for="lzero-specimen">Footing specimen</label>
          <select id="lzero-specimen">
            <option value="none">Unfurnished frame</option>
            <option value="first">First Footing · wider section</option>
            <option value="blocked">Obstructed control</option>
            <option value="alongside">First + alongside</option>
            <option value="stacked">First + stacked</option>
          </select>
          <div class="lzero-checks">
            <label><input id="lzero-wall" type="checkbox" checked /> Monitor plane</label>
            <label><input id="lzero-upper" type="checkbox" checked /> Upper shell</label>
            <label><input id="lzero-lower" type="checkbox" checked /> Lower shell</label>
            <label><input id="lzero-control" type="checkbox" /> Historic monitor and strip control</label>
            <label><input id="lzero-projection" type="checkbox" /> Source and flat traces</label>
          </div>
          <p>Unacquired specimens · fixed FROM HERE</p>
        </aside>
      </div>
    </section>
    """
  end
end
