defmodule PublicSituationMachineTurnZero.Architecture.Seed do
  @moduledoc "Revisable first-slice material, identities and composing conjectures. No template prose authority."
  @localities ~w(ZEROETH ONE TWO THREE FOUR FIVE SIX)
  @categories [
    "Human-Brought Enablingmentings",
    "Approach Noticingments",
    "Bureaucratic Outreadingmentings",
    "Readyingmenting",
    "Cues for Inhabitationing",
    "Human Labor / Appointmenting / Craft Laboring-ings",
    "Manipulationing Consequence",
    "Toy Box / Pretending Affordmentings",
    "Standing / Projectioning / Regarding / Pretendinging / Usingability",
    "Relationing + Provenance",
    "Landinging Aims + Dependency Conditions",
    "Continuity Checksum"
  ]
  def localities, do: @localities
  def categories, do: @categories
  def bearings, do: ~w(approach wallward toybox groundward)

  def regions,
    do: ~w(locality approach groundward continuing-from continuing-toward toy-box landing-aim)

  def standing do
    notes = [
      "Terrestrial Ground / Pointing-able / TC Appointmenting.",
      "Groundworking / first Bearinging / Human-relative Place relations / Current Local Moment beginnings.",
      "Weddinging Chapelling / differentiated Human-TC furnishing.",
      "Current Local Moment labor / RE-STEPPING AND MAY BE RE-STOMPING; split unresolved.",
      "Current Local Moment labor; relation to THREE unresolved.",
      "Excursioning / OUT AMONG WITH / standing TOWARD consequence.",
      "Return TOWARD HERE / WITHIN HERE; closure unresolved."
    ]

    tunnels =
      Enum.zip(@localities, tl(@localities))
      |> Map.new(fn {a, b} ->
        {"#{a}-#{b}",
         %{"id" => "#{a}-#{b}", "from" => a, "toward" => b, "status" => "composing conjecture"}}
      end)

    %{
      "entities" =>
        Map.new(
          [
            {"human", "already-standing Human", "given"},
            {"actual-tc", "actual terrestrial computer", "given"},
            {"terrestrial-ground", "ordinary terrestrial Ground", "given"},
            {"projected-tc", "projected furnishing FOR actual TC upon Appointmenting",
             "projection furnishing"},
            {"little-square-chair", "grounded/resting projected TC relation", "furnishing"},
            {"human-place-square", "Human-relative Place", "distinct Square job"},
            {"inner-aperture", "local calibrated Regarding Square", "distinct Square job"},
            {"four-pin-square", "four-pin Projectioning relation", "distinct Square job"},
            {"slate-base-square", "Slate Base relation", "distinct Square job"}
          ],
          fn {id, job, kind} -> {id, %{"id" => id, "job" => job, "kind" => kind}} end
        ),
      "version" => 1,
      "from" => "ZEROETH",
      "passages" => [],
      "localities" =>
        Enum.zip(@localities, notes)
        |> Map.new(fn {id, note} ->
          {id, %{"id" => id, "aim" => note, "status" => "provisional"}}
        end),
      "tunnels" => tunnels,
      "relations" => %{
        "human-ground" =>
          relation(
            "human-ground",
            "ZEROETH",
            [],
            "Given: Human already standing UP ON Ground; acknowledged, not manufactured."
          ),
        "tc-ground" =>
          relation(
            "tc-ground",
            "ZEROETH",
            [],
            "Given: actual terrestrial computer already alongside WITH the Human."
          )
      },
      "requirements" => %{
        "pointing-calibrated" => ["human-ground"],
        "tc-positioned" => ["pointing-calibrated", "tc-ground"],
        "tc-appointed" => ["tc-positioned"],
        "quiet-enclosure" => ["tc-appointed"]
      },
      "materials" => materials(),
      "toys" => toys()
    }
  end

  def relation(id, origin, dependencies, note) do
    {subject, predicate, object} =
      case id do
        "human-ground" -> {"human", "already-standing-on", "terrestrial-ground"}
        "tc-ground" -> {"actual-tc", "already-grounded-alongside", "human"}
        "pointing-calibrated" -> {"pointing-able", "calibrated-by", "human"}
        "tc-positioned" -> {"projected-tc", "rests-in", "little-square-chair"}
        "tc-appointed" -> {"projected-tc", "stands-for", "actual-tc"}
        "quiet-enclosure" -> {"ONE", "development-enclosure-fixture", "ONE"}
      end

    %{
      "id" => id,
      "origin" => origin,
      "dependencies" => dependencies,
      "subject" => subject,
      "predicate" => predicate,
      "object" => object,
      "provenance" => note,
      "kind" => "standing relation"
    }
  end

  def material(
        id,
        title,
        text,
        location,
        origin,
        region,
        bearing,
        course,
        categories,
        dependencies \\ []
      ) do
    %{
      "id" => id,
      "title" => title,
      "text" => text,
      "location" => location,
      "origin" => origin,
      "toward" => if(location == "ZEROETH-ONE", do: "ONE", else: location),
      "region" => region,
      "bearing" => bearing,
      "course" => course,
      "categories" => categories,
      "dependencies" => dependencies,
      "revision" => 1,
      "provenance" => [
        %{"origin" => origin, "action" => "provisional implementation print", "revision" => 1}
      ]
    }
  end

  defp materials do
    [
      material(
        "this-place",
        "THIS ONE PLACE",
        "THIS ONE PLACE FOR THIS ONE CONSTITUTIONING HUMAN. The mature WHAT-FOR wording remains under Composementing.",
        "ZEROETH",
        "ZEROETH",
        "approach",
        "approach",
        0,
        ["Approach Noticingments"]
      ),
      material(
        "human-brings",
        "What Human already brings",
        "Your own ways of noticing, pointing things out, distinguishing, operating your computer, and deciding what to bring ALONG THROUGH.",
        "ZEROETH",
        "ZEROETH",
        "locality",
        "wallward",
        0,
        ["Human-Brought Enablingmentings"]
      ),
      material(
        "pretending",
        "PRETENDINGING FOR REAL",
        "What standing around about where I ordinarily operate my computer do I wish to bring ALONG THROUGH?",
        "ZEROETH",
        "ZEROETH",
        "toy-box",
        "toybox",
        0,
        ["Toy Box / Pretending Affordmentings", "Cues for Inhabitationing"]
      ),
      material(
        "ground",
        "Already standing FROM GROUND HERE",
        "The Human arrives already standing UP ON Ground. Actual TC is already alongside WITH the Human. This machine confers neither.",
        "ZEROETH",
        "ZEROETH",
        "groundward",
        "groundward",
        0,
        ["Bureaucratic Outreadingmentings", "Relationing + Provenance"],
        ["human-ground", "tc-ground"]
      ),
      material(
        "appointment-consequence",
        "Appointmenting consequence",
        "Before: projected furnishing unappointed → Human calibrates, places and appoints → projected TC stands FOR actual TC in the Little Square Chair relation. Actual computer does not physically move; no passage has occurred.",
        "ZEROETH",
        "ZEROETH",
        "locality",
        "wallward",
        0,
        ["Manipulationing Consequence", "Human Labor / Appointmenting / Craft Laboring-ings"],
        ["tc-appointed"]
      ),
      material(
        "square-jobs",
        "Squares / differentiated jobs",
        "Human Place-Square · Inner Aperture / Regarding Square · four-pin Projectioning square · Slate Base Square. Common geometry does not establish a common constitutional job.",
        "ZEROETH",
        "ZEROETH",
        "locality",
        "wallward",
        0,
        ["Standing / Projectioning / Regarding / Pretendinging / Usingability"]
      ),
      material(
        "from-zeroeth",
        "CONTINUING FROM ZEROETH",
        "Inherited relations remain individually outread below. They do not collapse into a single completed state.",
        "ZEROETH-ONE",
        "ZEROETH",
        "continuing-from",
        "groundward",
        0,
        ["Continuity Checksum", "Relationing + Provenance"]
      ),
      material(
        "tunnel-notice",
        "ALONG THROUGH",
        "This Tunnel stands on the far side of STEP. NAV-STEP advances Regard through its material; it does not perform consequential labor or complete the receiving locality.",
        "ZEROETH-ONE",
        "ZEROETH",
        "locality",
        "wallward",
        2,
        ["Approach Noticingments", "Cues for Inhabitationing"]
      ),
      material(
        "tunnel-enabling",
        "Your ways of expressioning",
        "The Human already brings their own ways of expressioning. The machine stands in Readyingmenting toward them.",
        "ZEROETH-ONE",
        "ZEROETH",
        "locality",
        "wallward",
        3,
        ["Human-Brought Enablingmentings"]
      ),
      material(
        "toward-one",
        "CONTINUING TOWARD",
        "THIS ONE SOME SUCH QUIET ALCOVE. Prospective Groundworking remains Regardingable. Its fuller enclosingmenting is unresolved; a development fixture may rehearse it without claiming the public labor.",
        "ZEROETH-ONE",
        "ZEROETH",
        "continuing-toward",
        "approach",
        4,
        ["Continuity Checksum", "Landinging Aims + Dependency Conditions", "Readyingmenting"],
        ["tc-appointed", "quiet-enclosure"]
      ),
      material(
        "quiet-aim",
        "THIS ONE SOME SUCH QUIET ALCOVE",
        "Receiving approach toward ONE. Exact Groundworking relations remain under Composementing. A receiving half-circle is not a percentage of completion.",
        "ONE",
        "ONE",
        "approach",
        "approach",
        6,
        ["Landinging Aims + Dependency Conditions"]
      )
    ]
    |> Map.new(&{&1["id"], &1})
  end

  defp toys do
    [
      {"pointing-able", "This One Pointing-able Thing", "ZEROETH", "Pointing-able calibration",
       [], "Prepare the means for TC Appointmenting"},
      {"projectioning-er", "THIS ONE PROJECTIONING-ER THING", "ZEROETH", "Projection diagnostic",
       [], "Cease/rederive Regard; Standing remains"},
      {"slate", "THIS ONE SLATE", "ONE", "Groundworking", ["tc-appointed"], "Unresolved"},
      {"slate-base", "Slate Base Square relation", "ONE", "Differentiated Square relation",
       ["tc-appointed"], "Unresolved"},
      {"bobbin", "THIS ONE NEVER-ENDING BOBBINING STRINGING THING", "TWO",
       "Semantical In-Stringing-Menting", [], "Unresolved"},
      {"needle", "THIS ONE QUILLING STITCHING NEEDLE", "TWO", "Quilling / Stitching", [],
       "Unresolved"},
      {"time-one", "THIS ONE DISCRETE PIECE OF TIME", "THREE", "Current Local Moment", [],
       "Unresolved"},
      {"time-other", "THIS SOME OTHER DISCRETE PIECE OF TIME", "FOUR", "Current Local Moment", [],
       "Unresolved"},
      {"folding-bar", "THIS ONE WHAT-FOR FROM HERE OVER WHAT-FOR FROM HERE FOLDING BAR", "THREE",
       "Working morphology", [], "Unresolved"},
      {"traversaling-seat", "Traversaling Seat", "FIVE", "Excursioning", [], "Unresolved"},
      {"doll-stand", "Doll Upstanding Stand apparatus", "ONE", "Groundworking", [], "Unresolved"},
      {"steering", "Later Steering apparatus", "FIVE", "Excursioning", [], "Unresolved"},
      {"restep-foot", "RE-STEP Foot / four-wheel Roller Skate", "FOUR", "Calibrated tractioning",
       [], "Variable labor does not imply variable consequential extent"},
      {"airplane", "THIS ONE LITTLE RE-ZIPPERING AIRPLANE", "FOUR",
       "Bounded circuit / later tractioning", [],
       "Inspectable machinery; Pretendingable artifact not yet furnished"},
      {"dispensationaling", "THIS ONE NEVER-ENDING DISPENSATIONALING STAND", "ZEROETH", "RUGGING",
       [], "Recurring apparatus; first known furnishing RUGGING"}
    ]
    |> Map.new(fn {id, label, locality, aim, deps, job} ->
      {id,
       %{
         "id" => id,
         "label" => label,
         "encounter" => locality,
         "aim" => aim,
         "dependencies" => deps,
         "pretendingable" => id in ["pointing-able", "projectioning-er"],
         "usingable" => id in ["pointing-able", "projectioning-er"],
         "job" => job,
         "provenance" => "Implementation print / provisional inventory",
         "notes" => "Morphology and later operations remain under Composementing."
       }}
    end)
  end
end
