defmodule PublicSituationMachineTurnZeroWeb.ArrivalExtent do
  use PublicSituationMachineTurnZeroWeb, :html

  def arrival_extent(assigns) do
    ~H"""
    <section id="arrival-extent" class="arrival-extent" aria-labelledby="arrival-extent-title">
      <header class="arrival-extent__heading">
        <p class="arrival-extent__wayfinding">Approach · TOWARD the Parking Lot</p>
        <h2 id="arrival-extent-title">Come THROUGH, WITH your Terrestrial Computer.</h2>
        <p>You arrive carrying your TC. Ahead, one straight Rail Line extends away from you.</p>
      </header>

      <figure class="arrival-extent__scene">
        <svg
          id="arrival-aperture"
          viewBox="0 0 800 650"
          role="img"
          aria-labelledby="arrival-scene-title arrival-scene-description"
        >
          <title id="arrival-scene-title">Emerging through the circular tunnel aperture</title>
          <desc id="arrival-scene-description">
            A Constitutioning Human carries their Terrestrial Computer through a circular
            aperture. The inscription runs around its inner face. Its center marks a point
            in the Ground. One straight Rail bearing continues away into the machine;
            the computer remains with the Human.
          </desc>
          <defs>
            <radialGradient id="arrival-tunnel-shade">
              <stop offset="0%" stop-color="#252c2d" />
              <stop offset="100%" stop-color="#11191b" />
            </radialGradient>
            <path
              id="arrival-inscription-circle"
              d="M400 202 a158 158 0 1 1 0 316 a158 158 0 1 1 0 -316"
            />
          </defs>

          <text x="400" y="30" class="arrival-extent__svg-label" text-anchor="middle">
            ONE STRAIGHT BEARING · AWAY FROM YOU
          </text>
          <path class="arrival-extent__rail-bed" d="M400 55 V360" />
          <path class="arrival-extent__rail" d="M390 55 V360 M410 55 V360" />

          <circle cx="400" cy="360" r="190" class="arrival-extent__outer-rim" />
          <circle cx="400" cy="360" r="172" fill="url(#arrival-tunnel-shade)" />
          <circle cx="400" cy="360" r="140" class="arrival-extent__inner-rim" />
          <text class="arrival-extent__inscription" textLength="990" lengthAdjust="spacing">
            <textPath href="#arrival-inscription-circle">
              THIS ONE FOR HERE FROM OUT OF THE GROUND POINT
            </textPath>
          </text>

          <path class="arrival-extent__rail" d="M390 55 V360 M410 55 V360" />
          <circle id="arrival-ground-point" cx="400" cy="360" r="4" fill="#f4d394" />
          <path class="arrival-extent__point-leader" d="M410 360 H615" />
          <text x="625" y="356" class="arrival-extent__svg-label">GROUND</text>
          <text x="625" y="376" class="arrival-extent__svg-label">POINT / ORIGIN</text>

          <g id="arrival-human-with-tc" aria-label="Constitutioning Human carrying TC">
            <circle cx="390" cy="420" r="18" class="arrival-extent__human" />
            <path
              d="M390 443 V488 M390 454 L360 477 M390 454 L427 461 M390 488 L368 523 M390 488 L413 523"
              class="arrival-extent__human-limbs"
            />
            <g class="arrival-extent__computer" transform="rotate(9 446 457)">
              <rect x="423" y="437" width="48" height="33" rx="3" />
              <path d="M419 475 H476" />
            </g>
          </g>
          <text x="400" y="585" class="arrival-extent__svg-label" text-anchor="middle">
            CH EMERGING WITH TC
          </text>
          <text x="400" y="614" class="arrival-extent__svg-label" text-anchor="middle">
            THROUGH THE CIRCULAR APERTURE
          </text>
        </svg>
        <figcaption>
          At the threshold of emerging, the inner face notices:
          <strong>THIS ONE FOR HERE FROM OUT OF THE GROUND POINT</strong>
        </figcaption>
      </figure>

      <div id="arrival-distance-prospect" class="arrival-extent__prospect">
        <p class="arrival-extent__wayfinding">TOWARD your first furnishing</p>
        <p class="arrival-extent__question">
          If you could push your Terrestrial Computer down this straight Rail Line away from you,
          how far away would you place it?
        </p>
        <p>Your TC is still WITH you. The distance remains yours to furnish.</p>
      </div>

      <footer class="arrival-extent__continuation">
        <a id="arrival-continue-to-existing-entrance" href="#station-tz-region">
          Continue toward the existing Rail Line entrance
          <.icon name="hero-arrow-down" class="size-4" />
        </a>
      </footer>
    </section>
    """
  end
end
