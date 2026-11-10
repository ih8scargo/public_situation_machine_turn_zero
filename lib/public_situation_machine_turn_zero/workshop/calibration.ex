defmodule PublicSituationMachineTurnZero.Workshop.Calibration do
  @moduledoc "Versioned, bounded mechanical hypotheses alongside unchanged schema-3 construction."
  @defaults %{
    "quarter_turn" => 0.0,
    "opening" => 45.0,
    "wishbone" => -20.0,
    "coupling" => "independent",
    "axis" => "x",
    "radius" => 1.5,
    "u_width" => 2.4,
    "u_height" => 2.4
  }
  def defaults, do: @defaults

  def parameters,
    do: [
      {"quarter_turn", "Quarter-turn curvature (degrees)", 0, 90},
      {"opening", "Pinned aperture opening (degrees; 45 is separate from 90)", 0, 45},
      {"wishbone", "Independent Regarding wishbone (degrees)", -45, 45},
      {"radius", "SIX excursion radius (provisional extents)", 0.5, 1.8},
      {"u_width", "U opening width (hypothesis)", 1.8, 3},
      {"u_height", "U opening height (hypothesis)", 1.8, 3}
    ]

  def new,
    do: %{"version" => 1, "revision" => 0, "parameters" => @defaults, "history" => [@defaults]}

  def valid_parameters?(p) when is_map(p) do
    Enum.sort(Map.keys(p)) == Enum.sort(Map.keys(@defaults)) and p["axis"] in ~w(x z) and
      p["coupling"] in ~w(independent counter linked) and
      Enum.all?(parameters(), fn {key, _, low, high} ->
        is_number(p[key]) and p[key] >= low and p[key] <= high
      end)
  end

  def valid_parameters?(_), do: false

  def valid?(%{"version" => 1, "revision" => r, "parameters" => p, "history" => h} = s)
      when is_integer(r) and is_list(h) do
    map_size(s) == 4 and r in 0..100 and length(h) == r + 1 and hd(h) == @defaults and
      List.last(h) == p and Enum.all?(h, &valid_parameters?/1)
  end

  def valid?(_), do: false

  def change(s, revision, p, locked?) do
    cond do
      locked? ->
        {:error, :locked}

      revision != s["revision"] ->
        {:error, :stale}

      not valid_parameters?(p) ->
        {:error, :invalid}

      p == s["parameters"] ->
        {:ok, s}

      s["revision"] >= 100 ->
        {:error, :limit}

      true ->
        {:ok,
         %{s | "revision" => revision + 1, "parameters" => p, "history" => s["history"] ++ [p]}}
    end
  end

  def registry(state, model) do
    p = state["parameters"]
    u = [15, 3, 0]
    pivot = [15, 0, 0]
    ground = [15, -6, 0]
    here = [15, 0, -1.5]
    next = [15, 0, 1.5]
    monitor = [15, 3, -2]
    thing_origin = [15, 2.5, -1.5]
    opening_radians = p["opening"] * :math.pi() / 180
    monitor_hit = [15, 2.5 + 0.5 * :math.tan(opening_radians), -2]
    r = p["radius"]
    a = p["quarter_turn"]
    tip = arc(pivot, r, a, p["axis"])
    resolve = [Enum.at(tip, 0), -6, Enum.at(tip, 2)]
    toe_a = [14.8, 0, 0]
    toe_b = [15.2, 0, 0]
    far_a = add(toe_a, rotate([0, 0, 0.8], "x", p["opening"]))
    far_b = add(toe_b, rotate([0, 0, 0.8], "x", p["opening"]))

    regarding_angle =
      case p["coupling"] do
        "linked" -> p["opening"]
        "counter" -> -p["opening"]
        _ -> p["wishbone"]
      end

    first = List.first(model["rehearsal"]["footings"])
    # Cross glyphs have no measured physical bottom; explicitly appoint a provisional baseline.
    zero = if first, do: add(first["source_point"], [0, -0.1, 0]), else: nil
    restep = [15, -6, -1.5]

    subject = %{
      "author" => "Constitutioning Human: workshop calibration scenario",
      "illumination" => "real Terrestrial Computer; not material author",
      "footings" => Enum.map(model["rehearsal"]["footings"], & &1["id"])
    }

    items = [
      item(
        "u-bearing",
        "Locked U reference bearing",
        "line",
        [u, add(u, [0, 0, 2])],
        [0, 0, 1],
        "APPOINTED",
        "U bearing remains transverse; normal +Z, never rotated by curvature",
        "STANDING FOR STAGING",
        "U13",
        "architecture",
        "architecture"
      ),
      item(
        "u-aperture",
        "U aperture · fixed bearing",
        "aperture",
        rect(u, p["u_width"], p["u_height"], "xy"),
        [0, 0, 1],
        "PROVISIONAL",
        "Closed inspection aperture; dimensions hypothetical, not a decorative U glyph",
        "STANDING FOR STAGING",
        "U13",
        "bobbining enclosure",
        "architecture"
      ),
      item(
        "bobbining-enclosure",
        "Bobbining enclosure WITHIN U",
        "surface",
        rect(u, 1.2, 1.2, "xy"),
        [0, 0, 1],
        "PROVISIONAL",
        "Nested flat envelope, not a furnished CAB; four depth edges identify enclosure volume",
        "STANDING FOR STAGING",
        "u-aperture",
        "Human entry",
        "u-aperture"
      ),
      item(
        "enclosure-depth",
        "Enclosure depth witness",
        "line",
        [
          [14.4, 2.4, -0.4],
          [14.4, 2.4, 0.4],
          [15.6, 2.4, 0.4],
          [15.6, 3.6, 0.4],
          [15.6, 3.6, -0.4],
          [14.4, 3.6, -0.4],
          [14.4, 2.4, -0.4]
        ],
        [0, 0, 1],
        "PROVISIONAL",
        "Depth 0.8; envelope bounds within fixed U width/height",
        "STANDING FOR STAGING",
        "u-aperture",
        "Human entry",
        "u-aperture"
      ),
      item(
        "human-entry",
        "Human entry / Regarding THROUGH enclosure",
        "line",
        [[15, 3, -3], u, [15, 3, 2]],
        [0, 0, 1],
        "APPOINTED",
        "WITHIN enclosure WITHIN U; no avatar or habitation operation",
        "STAGING FOR STANDING",
        "HERE",
        "architecture",
        "architecture"
      ),
      item(
        "ground-reference",
        "Ground reference line",
        "line",
        [[12, -6, 0], [18, -6, 0]],
        [1, 0, 0],
        "MEASURED",
        "Existing lower Ground-side plane Y=-6",
        "STANDING FOR STAGING",
        "lower Ground",
        "TC",
        "curvature resolution"
      ),
      item(
        "ground-resolution",
        "Curvature resolution against Ground",
        "line",
        [tip, resolve, ground],
        [0, -1, 0],
        "MEASURED",
        "Drop to Y=-6 then resolve to existing Ground line; geometric projection, not acquired purchase",
        "STAGING FOR STANDING",
        "quarter-turn endpoint",
        "ground-reference",
        "ground-reference"
      ),
      item(
        "quarter-turn",
        "Bounded quarter-turn curvature",
        "line",
        Enum.map(0..30, &arc(pivot, r, a * &1 / 30, p["axis"])),
        [0, 1, 0],
        "PROVISIONAL",
        "0–90 degrees around selected X/Z axis; U frame does not pivot",
        "STAGING FOR STANDING",
        "stage-pivot",
        "SIX-upstage",
        "ground-reference"
      ),
      item(
        "quarter-range",
        "Full quarter-turn range / 90 endpoint",
        "line",
        Enum.map(0..30, &arc(pivot, r, 90 * &1 / 30, p["axis"])),
        [0, 1, 0],
        "MEASURED",
        "Range guide independent of current angle",
        "STANDING FOR STAGING",
        "stage-pivot",
        "SIX-upstage",
        "ground-reference"
      ),
      item(
        "stage-pivot",
        "Hypothesized stage hinge axis",
        "line",
        if(p["axis"] == "x", do: [[14, 0, 0], [16, 0, 0]], else: [[15, 0, -1], [15, 0, 1]]),
        if(p["axis"] == "x", do: [1, 0, 0], else: [0, 0, 1]),
        "PROVISIONAL",
        "Adjustable axis hypothesis; neither is a settled constitutional joint",
        "STANDING FOR STAGING",
        "Crossing",
        "stage",
        "ground-reference"
      ),
      item(
        "SIX-upstage",
        "SIX · upstage ends here in Diorama",
        "line",
        [arc(pivot, r, 90, p["axis"]), add(arc(pivot, r, 90, p["axis"]), [0, 0, 0.6])],
        [0, 0, 1],
        "APPOINTED",
        "SIX labels the upstage end; it is not six acquired Footings",
        "STANDING FOR STAGING",
        "quarter-range",
        "Oblique structural overview",
        "stage"
      ),
      item(
        "stage",
        "Situationing Stage",
        "surface",
        [
          pivot,
          arc(pivot, r, 0, p["axis"]),
          arc(pivot, r, 45, p["axis"]),
          arc(pivot, r, 90, p["axis"])
        ],
        [1, 0, 0],
        "PROVISIONAL",
        "Quarter-sector scene witness shares pivot and SIX endpoint; not final theatre dimensions",
        "STANDING FOR STAGING",
        "Crossing",
        "apron",
        "HERE"
      ),
      item(
        "apron",
        "Apron · forward toward standing",
        "surface",
        rect([15, 0, -0.6], 1.5, 0.6, "xz"),
        [0, 1, 0],
        "PROVISIONAL",
        "Material comes forward TOWARD HERE; not a corridor",
        "STAGING FOR STANDING",
        "stage",
        "HERE",
        "HERE"
      ),
      item(
        "HERE",
        "THIS HERE APPROACHING LANDINGING",
        "surface",
        rect(here, 0.8, 0.8, "xz"),
        [0, 1, 0],
        "APPOINTED",
        "Persistent HERE square; NEXT never becomes HERE",
        "STANDING FOR STAGING",
        "CH WITH TC",
        "architecture",
        "NEXT"
      ),
      item(
        "NEXT",
        "THIS NEXT APPROACHING LANDINGING",
        "surface",
        rect(next, 0.8, 0.8, "xz"),
        [0, 1, 0],
        "APPOINTED",
        "OVER ACROSS; Projectioning TOWARD HERE",
        "STAGING FOR STANDING",
        "OVER ACROSS THERE",
        "HERE",
        "HERE"
      ),
      item(
        "flat-aperture",
        "Doll flat aperture · hinged",
        "surface",
        [toe_a, toe_b, far_b, far_a],
        rotate([0, 1, 0], "x", p["opening"]),
        "PROVISIONAL",
        "0–45 degrees about the toe line; separate from 0–90 stage curvature",
        "STANDING FOR STAGING",
        "HERE",
        "flat-monitor",
        "flat-monitor"
      ),
      item(
        "doll-toes",
        "Doll toes PINNED to aperture",
        "line",
        [toe_a, toe_b],
        [1, 0, 0],
        "APPOINTED",
        "Both hinge-line endpoints invariant for every aperture opening",
        "STANDING FOR STAGING",
        "flat-aperture",
        "flat-monitor",
        "flat-monitor"
      ),
      item(
        "projection-wishbone",
        "Projectioning wishbone",
        "line",
        wishbone(pivot, p["opening"]),
        [0, 0, 1],
        "PROVISIONAL",
        "Opening angle 0–45; attached at toe hinge midpoint",
        "STAGING FOR STANDING",
        "flat-aperture",
        "flat-monitor",
        "flat-monitor"
      ),
      item(
        "regarding-wishbone",
        "Regarding wishbone",
        "line",
        wishbone([15, 0, -0.5], regarding_angle),
        [0, 0, 1],
        "PROVISIONAL",
        "Independent / counter / linked alternatives; no mandatory rigid coupling or 180 flip",
        "STANDING FOR STAGING",
        "HERE",
        "projection-wishbone",
        "architecture"
      ),
      item(
        "XT-YT",
        "XT → YT bounded passage witness",
        "line",
        [[15, 0, -1.5], pivot, tip],
        [0, 0, 1],
        "PROVISIONAL",
        "Only registered control polyline; no operational tunnel Traversaling",
        "STAGING FOR STANDING",
        "XT / HERE",
        "YT / stage endpoint",
        "YT"
      ),
      item(
        "archway",
        "Archway over fishing pole",
        "line",
        [[14.4, 0.5, -0.5], [14.4, 1.3, -0.5], [15.6, 1.3, -0.5], [15.6, 0.5, -0.5]],
        [0, 0, 1],
        "PROVISIONAL",
        "Open frame; appointed UNDER relation measured at pole crossing",
        "STANDING FOR STAGING",
        "HERE",
        "XT-YT",
        "architecture"
      ),
      item(
        "fishing-pole",
        "Fishing pole UNDER archway",
        "line",
        [[15, 0.3, -1.5], [15, 0.3, 0.5]],
        [0, 0, 1],
        "APPOINTED",
        "At archway Z=-0.5, pole Y=0.3 is below frame Y>=0.5",
        "STAGING FOR STANDING",
        "HERE",
        "stage",
        "architecture"
      ),
      item(
        "flat-monitor",
        "Flat monitor · fixed plane",
        "surface",
        rect(monitor, 2.4, 1.8, "xy"),
        [0, 0, 1],
        "PROVISIONAL",
        "Plane Z=-2 stays flat and fixed; central Projectioning ray crosses its center",
        "STANDING FOR STAGING",
        "TC illumination",
        "architecture",
        "Human Regarding"
      ),
      item(
        "projection-thing",
        "Projectioning Thing · separate from TWO",
        "line",
        [
          thing_origin,
          monitor_hit,
          add(monitor_hit, [0, 0.5 * :math.tan(opening_radians), -0.5])
        ],
        [0, 1, 0],
        "APPOINTED",
        "STANDING WITHIN HERE FROM OVER ACROSS THERE; not a camera. Ray pivots with aperture opening; at 45 degrees it passes through flat-monitor center. Other openings show off-center hits; optical coupling is provisional",
        "STAGING FOR STANDING",
        "OVER ACROSS THERE WITHIN HERE",
        "flat-monitor",
        "flat-monitor"
      ),
      item(
        "camera-one",
        "CAMERA ONE · RE-STEP reference line",
        "line",
        [restep, add(restep, [1, 0, 0])],
        [1, 0, 0],
        "APPOINTED",
        "Registers line only; no RE-STEP execution",
        "STANDING FOR STAGING",
        "HERE",
        "monitor resolution field",
        "flat-monitor"
      ),
      item(
        "camera-two",
        "CAMERA TWO · Human aperture-toward",
        "line",
        [here, u],
        [0, 1, 0],
        "APPOINTED",
        "Human Regarding opens TOWARD architecture; retains HERE provenance",
        "STANDING FOR STAGING",
        "HERE",
        "u-aperture",
        "architecture"
      ),
      item(
        "monitor-resolution",
        "ZERO/ONE resolution field",
        "surface",
        [restep, add(restep, [1, 0, 0]), monitor, add(monitor, [1, 0, 0])],
        [0, 0, 1],
        "PROVISIONAL",
        "Reference ruled field: upside-toward and Groundward ACROSS; no operational optics",
        "STAGING FOR STANDING",
        "HERE",
        "flat-monitor",
        "flat-monitor"
      ),
      item(
        "projection-up",
        "PROJECTIONING UP TOWARD",
        "line",
        [[14.5, -3, 0], [14.5, 3, 0]],
        [0, 1, 0],
        "MEASURED",
        "Pure UP component",
        "STAGING FOR STANDING",
        "lower source",
        "Crossing",
        "monitor field"
      ),
      item(
        "projection-over",
        "PROJECTIONING OVER",
        "line",
        [next, here],
        [0, 0, -1],
        "APPOINTED",
        "NEXT to HERE across; does not relabel NEXT",
        "STAGING FOR STANDING",
        "NEXT",
        "HERE",
        "HERE"
      ),
      item(
        "projection-up-over-across",
        "PROJECTIONING UP OVER ACROSS",
        "line",
        [[15, -3, 0], monitor],
        [0, 1, -1],
        "MEASURED",
        "Composed UP and transverse components; monitor-center target",
        "STAGING FOR STANDING",
        "lower source",
        "flat-monitor",
        "flat-monitor"
      ),
      item(
        "lantern-line",
        "Lanterning Bug · reserved illumination line",
        "line",
        [[13, 1, -1], pivot],
        [1, -1, 1],
        "PROVISIONAL",
        "Conceptual illumination appointment only; THREE is not a Footing count",
        "STAGING FOR STANDING",
        "Lanterning Bug",
        "stage",
        "stage"
      ),
      item(
        "tc-return",
        "Ground-side return WITH TC",
        "line",
        [here, ground, [model["positions"]["tc"] + 3, -6, 0]],
        [-1, 0, 0],
        "PROVISIONAL",
        "Reference association to THIS ONE TC; FROM HERE WITH CH, no furnished corridor or teleport",
        "STAGING FOR STANDING",
        "HERE WITH CH",
        "TC",
        "TC"
      )
    ]

    camera_zero =
      if zero do
        [
          item(
            "camera-zero",
            "CAMERA ZERO · first Footing baseline",
            "line",
            [zero, restep],
            [0, -1, 0],
            "PROVISIONAL",
            "Begins at bottom of provisional 0.2-high Footing envelope centered on first source point; source registration unchanged, physical dimensions unappointed",
            "STANDING FOR STAGING",
            "HERE / #{first["id"]}",
            "camera-one",
            "flat-monitor"
          )
        ]
      else
        []
      end

    six_marks =
      for i <- 1..6 do
        q = arc(pivot, r, 15 * i, p["axis"])

        item(
          "six-mark-#{i}",
          "SIX calibration arc mark #{i}/6",
          "line",
          [q, add(q, [0.12, 0, 0.12])],
          [1, 0, 0],
          "PROVISIONAL",
          "Six evenly spaced guide marks over quarter-turn; exact marking spacing is a calibration hypothesis",
          "STANDING FOR STAGING",
          "quarter-range",
          "SIX-upstage",
          "stage"
        )
      end

    excursions =
      for number <- [4, 6, 8] do
        item(
          "excursion-#{number}",
          "#{number} geometric excursion relative to SIX",
          "line",
          Enum.map(0..24, &arc(pivot, r * number / 6, 90 * &1 / 24, p["axis"])),
          [0, 1, 0],
          "PROVISIONAL",
          "Relative radius #{number}/6; label is not Groundward purchase, Footings or turns",
          "STAGING FOR STANDING",
          "stage-pivot",
          "ground-reference",
          "SIX-upstage"
        )
      end

    posts = [
      item(
        "four-posts-three",
        "THREE related to two FOUR posts",
        "line",
        [[14.5, 0, 0], [14.5, 1, 0], [15.5, 1, 0], [15.5, 0, 0]],
        [0, 1, 0],
        "PROVISIONAL",
        "Two posts and transverse THREE relation only; no default three Footings or turns",
        "STANDING FOR STAGING",
        "HERE",
        "SIX distinct pivot",
        "stage"
      )
    ]

    base =
      for entity <- Map.values(model["entities"]), surface <- entity["surfaces"] do
        points = Enum.map(surface["vertices"], &Enum.at(entity["vertices"], &1))

        item(
          surface["id"],
          "#{entity["name"]} / #{surface["role"]}",
          "surface",
          points,
          normal(points),
          "MEASURED",
          "Existing registered cube surface; no architectural preposition inferred from normal",
          "STANDING FOR STAGING",
          entity["id"],
          "inspection",
          "none appointed"
        )
      end

    source = [
      item(
        "a03-source",
        "Assignment 03 lower source",
        "surface",
        model["projection"]["source"]["outline"],
        [0, 1, 0],
        "MEASURED",
        model["projection"]["attachment"],
        "STAGING FOR STANDING",
        "lower",
        "Crossing",
        "Crossing"
      )
    ]

    projected =
      for bearing <- ~w(vertical oblique) do
        points =
          Enum.map(
            model["projection"]["source"]["outline"],
            &add(&1, model["projection"][bearing]["presentation_offset"])
          )

        item(
          "a03-#{bearing}-material",
          "Assignment 03 #{bearing} presentation surface",
          "surface",
          points,
          [0, 1, 0],
          "MEASURED",
          "Same lower authored source transformed through Crossing; illumination does not confer authorship",
          "STAGING FOR STANDING",
          "a03-source",
          "Crossing",
          "Crossing"
        )
      end

    # Explicit source-to-monitor planar projection, independent of acquisition status.
    monitor_material =
      for {id, source, target_y, status} <- [
            {"already-standing", here, 3.45, "STANDING FOR STAGING"},
            {"prospective", next, 2.5, "STAGING FOR STANDING"}
          ] do
        points =
          Enum.map(rect(source, 0.4, 0.3, "xz"), fn [x, _y, z] ->
            [x, target_y + z - Enum.at(source, 2), -2]
          end)

        item(
          "monitor-#{id}",
          "Monitor material · #{status}",
          "surface",
          points,
          [0, 0, 1],
          "PROVISIONAL",
          "Explicit planar map (x,y,z) -> (x,#{target_y}+z-#{Enum.at(source, 2)},-2); scene status is authored, not an acquisition",
          status,
          if(id == "already-standing", do: "HERE", else: "NEXT"),
          "Human flat-monitor Regarding",
          "flat-monitor"
        )
      end

    monitor_reference =
      item(
        "monitor-center-reference",
        "Monitor resolution reference · below-line is not below Ground",
        "line",
        [[13.8, 3, -2], [16.2, 3, -2]],
        [1, 0, 0],
        "MEASURED",
        "Prospective monitor patch has Y=2.35–2.65 below this Y=3 line, above physical Ground Y=-6",
        "STANDING FOR STAGING",
        "flat-monitor center",
        "Human Regarding",
        "none appointed"
      )

    references =
      [
        item(
          "common-rail",
          "Common 18-extent rail",
          "line",
          [model["rail"]["start"], model["rail"]["end"]],
          [1, 0, 0],
          "MEASURED",
          "Existing rail intervals unchanged",
          "STANDING FOR STAGING",
          "existing construction",
          "CH WITH TC",
          "none appointed"
        ),
        item(
          "u13-return",
          "U13 Projectioning return (distinct from N18)",
          "line",
          model["steeling"]["u_return"]["post"]["points"],
          [0, 1, 0],
          "APPOINTED",
          "Original registered U13 post; aperture hypothesis is additional",
          "STANDING FOR STAGING",
          "U13",
          "Crossing",
          "Crossing"
        ),
        item(
          "n18-return",
          "N18 Groundward return",
          "line",
          model["steeling"]["n_return"]["points"],
          [0, -1, 0],
          "APPOINTED",
          "Original return and N-derived MACHINE unchanged",
          "STANDING FOR STAGING",
          "N18",
          "Ground",
          "MACHINE"
        ),
        item(
          "gallery-reference",
          "Original gallery plane hypothesis",
          "surface",
          model["steeling"]["gallery"]["boundary"],
          [0, 0, 1],
          "PROVISIONAL",
          "Existing broad Steeling course is not declared operational Roundabout Gallery",
          "STANDING FOR STAGING",
          "Assignment 02",
          "structural inspection",
          "none appointed"
        ),
        item(
          "cob-course",
          "Independent COB reference Traversaling course",
          "line",
          model["projection"]["course"]["points"],
          [1, 0, 0],
          "MEASURED",
          "t in [0,1]; Y=3, independent of acquisition count",
          "STANDING FOR STAGING",
          "Crossing",
          "course endpoint",
          "none appointed"
        )
      ] ++
        for bearing <- ~w(vertical oblique) do
          item(
            "a03-#{bearing}-bearing",
            "Original #{bearing} bearing",
            "line",
            model["projection"][bearing]["points"],
            model["projection"][bearing]["direction"],
            "MEASURED",
            "Original source, entry and Crossing intersection retained",
            "STAGING FOR STANDING",
            "lower source",
            "Crossing",
            "Crossing"
          )
        end

    footing_envelopes =
      for f <- model["rehearsal"]["footings"] do
        item(
          "footing-bottom-#{f["sequence"]}",
          "Footing #{f["sequence"]} · provisional bottom envelope",
          "surface",
          rect(add(f["source_point"], [0, -0.1, 0]), 0.3, 0.3, "xz"),
          [0, -1, 0],
          "PROVISIONAL",
          "Inspection envelope height 0.2 around original source; physical Footing size unappointed, acquisition unchanged",
          "STANDING FOR STAGING",
          f["id"],
          "camera-one",
          "Crossing"
        )
      end

    %{
      "version" => 1,
      "parameters" => p,
      "u_frame" => %{
        "origin" => u,
        "basis" => [[1, 0, 0], [0, 1, 0], [0, 0, 1]],
        "bearing_locked" => true
      },
      "quarter_endpoint" => tip,
      "projection_thing" => %{
        "origin" => thing_origin,
        "monitor_hit" => monitor_hit,
        "center" => monitor,
        "opening_degrees" => p["opening"],
        "status" => "provisional ray coupling; center calibrated at 45 degrees"
      },
      "ground_resolution" => resolve,
      "toe_points" => [toe_a, toe_b],
      "regarding_angle" => regarding_angle,
      "camera_zero" =>
        if(zero,
          do:
            "first Footing bottom of 0.2-high inspection envelope; physical dimensions provisional",
          else: "UNFURNISHED until first Footing; no fabricated origin"
        ),
      "source_provenance" => subject,
      "roles" => %{
        "furnishing" =>
          "Existing CH-fashioned rehearsal inspected AS Furnishing COB; original records unchanged",
        "traversaling" => "reserved; requires explicit furnished by-way-of witness",
        "fellow" => "reserved; no autonomous COB or second ship"
      },
      "acquisition_context" => %{
        "interpretation" =>
          "Furnishing COB inspection role; no retrospective relabeling of original events",
        "furnishing_references" => Enum.map(model["rehearsal"]["footings"], & &1["id"]),
        "traversaling_acquisitions" => [],
        "furnished_by_way_of" => nil,
        "fellow_tuple_ship" => nil
      },
      "purchase" => %{
        "geometric_excursion" => "FOUR/SIX/EIGHT relative radii only",
        "groundward" => "coordinate relation, not acquisition",
        "actual_acquisitions" => length(model["rehearsal"]["footings"]),
        "authored_contribution" =>
          "half + half can furnish ONE only in an explicitly authored scenario; unappointed here",
        "completed_restep_turns" => 0
      },
      "items" =>
        base ++
          items ++
          camera_zero ++
          six_marks ++
          excursions ++
          posts ++
          source ++
          projected ++ references ++ footing_envelopes ++ monitor_material ++ [monitor_reference]
    }
  end

  defp item(id, label, kind, points, bearing, class, note, status, from, toward, projects) do
    origin = hd(points)

    measured =
      if kind in ~w(surface aperture) do
        normal(points)
      else
        case Enum.find(Enum.drop(points, 1), &(&1 != origin)) do
          nil -> [0, 0, 0]
          target -> unit(Enum.zip_with(target, origin, &(&1 - &2)))
        end
      end

    %{
      "id" => id,
      "label" => label,
      "kind" => kind,
      "points" => points,
      "closed" => kind in ~w(surface aperture),
      "frame" => %{
        "origin" => origin,
        "basis" => [[1, 0, 0], [0, 1, 0], [0, 0, 1]],
        "bearing" => measured
      },
      "appointed_reference_bearing" => bearing,
      "bearing_measurement" =>
        "surface normal or first nonzero segment; does not infer architectural prepositions",
      "outreadings" => [
        %{
          "class" => "MEASURED",
          "placement" => %{"points" => points, "frame_origin" => origin, "bearing" => measured}
        },
        %{"class" => class, "statement" => note}
      ],
      "relations" => %{
        "FROM" => from,
        "WITHIN" =>
          case id do
            id when id in ["bobbining-enclosure", "enclosure-depth"] -> "U aperture"
            "human-entry" -> "bobbining enclosure WITHIN U"
            "projection-thing" -> "HERE (appointed standing; FROM OVER ACROSS THERE)"
            _ -> "registered workshop; no further enclosure appointed"
          end,
        "UPON" =>
          case id do
            "doll-toes" ->
              "flat-aperture hinge"

            id
            when id in [
                   "monitor-already-standing",
                   "monitor-prospective",
                   "monitor-center-reference"
                 ] ->
              "flat-monitor plane Z=-2"

            _ ->
              "explicit points; no additional contact appointed"
          end,
        "OVER ACROSS" => if(id == "NEXT", do: "HERE", else: "only where explicitly appointed"),
        "stands_toward" => toward,
        "regards_toward" => toward,
        "projects_toward" => projects
      },
      "material_status" => status,
      "provenance" => %{
        "author" => "Human calibration scenario / original construction",
        "illumination" => "TC; not authorship",
        "source" => from
      },
      "limits" => %{
        "u_bearing" => "fixed +Z",
        "curvature_degrees" => [0, 90],
        "aperture_degrees" => [0, 45],
        "axis" => "explicit hypothesis, not inferred from normals"
      },
      "camera_invariants" => [
        "world points",
        "material status",
        "source authorship",
        "Footing provenance",
        "U bearing lock",
        "HERE identity"
      ]
    }
  end

  defp rect([x, y, z], w, h, plane) do
    for {a, b} <- [{-1, -1}, {1, -1}, {1, 1}, {-1, 1}],
        do:
          if(plane == "xy",
            do: [x + a * w / 2, y + b * h / 2, z],
            else: [x + a * w / 2, y, z + b * h / 2]
          )
  end

  defp wishbone(origin, angle),
    do: Enum.map([[-0.55, 0, 1], [0, 0, 0], [0.55, 0, 1]], &add(origin, rotate(&1, "x", angle)))

  defp arc(origin, r, angle, axis) do
    t = angle * :math.pi() / 180

    add(
      origin,
      if(axis == "x",
        do: [0, r * :math.sin(t), r * :math.cos(t)],
        else: [r * :math.cos(t), r * :math.sin(t), 0]
      )
    )
  end

  defp rotate([x, y, z], "x", angle) do
    t = angle * :math.pi() / 180
    [x, y * :math.cos(t) + z * :math.sin(t), -y * :math.sin(t) + z * :math.cos(t)]
  end

  defp normal([a, b, c | _]) do
    [x, y, z] = Enum.zip_with(b, a, &(&1 - &2))
    [u, v, w] = Enum.zip_with(c, a, &(&1 - &2))
    n = [y * w - z * v, z * u - x * w, x * v - y * u]
    length = :math.sqrt(Enum.reduce(n, 0, &(&1 * &1 + &2)))
    if length == 0, do: [0, 0, 0], else: Enum.map(n, &(&1 / length))
  end

  defp unit(v) do
    length = :math.sqrt(Enum.reduce(v, 0, &(&1 * &1 + &2)))
    if length == 0, do: [0, 0, 0], else: Enum.map(v, &(&1 / length))
  end

  defp add(a, b), do: Enum.zip_with(a, b, &(&1 + &2))
end
