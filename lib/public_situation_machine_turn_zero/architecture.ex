defmodule PublicSituationMachineTurnZero.Architecture do
  @moduledoc "Elementary opening and retained experimental quarry. Standing is durable; Regarding and gesture staging are temporary."
  alias PublicSituationMachineTurnZero.Architecture.{Extent, PullWitness, SemanticalCourse}

  defstruct standing: nil,
            pulling: nil,
            feeding: nil,
            opening_stage: nil,
            regarding: %{
              bearing: "end-on",
              instrumentation: true,
              inspected: nil,
              tool: "stick",
              material: nil
            }

  @version "operable-opening-v2"
  @witnesses [
    "elementary-opening-v1",
    "first-puffing-v1",
    "semantic-fountaining-v1",
    "zeroeth-cubical-v1",
    "spindle-round-one",
    "spindle-rail-pass",
    "toy-box-opening-v1"
  ]
  @limit 6
  @names %{
    "human" => "This One Constitutioning Human",
    "ground" => "Ground",
    "here" => "HERE",
    "page" => "this page / PUBLIC-SITUATION-MACHINE-",
    "fountaining" => "This One In-Stringing-Menting Fountaining",
    "janusite" => "100% JANUSITE ribbonating substrationing infrastructioning",
    "track" => "underlying Track Rail Line Rail Track",
    "crossing" => "Human-relative constitutional crossing",
    "xt-opening" => "opening FROM HERE",
    "xt" => "XT",
    "landinging" => "This CUBICAL Standinging Landinging",
    "center-square" => "the already-standing center square",
    "stick" => "THIS ONE PRETENDINGING STICK FOR POINTING THINGS OUT",
    "regarding-square" => "THIS ONE SQUARE FOR REGARDING",
    "doll" => "THIS ONE CO-SITUATIONING DOLL FOR PRETENDINGING",
    "needle" => "THIS ONE QUILLING STITCHING NEEDLE",
    "cob" => "THIS STEWARDLY CO-CAPTAIN COB",
    "toy-box" => "Toy Box",
    "cob-square" => "the small square furnishing",
    "puffing-tunneling-thing" => "THIS ONE TRULY BORINGINGING PUFFINGINGING TUNNELING THING",
    "extent-for-possibility" => "this furnished extent FOR possibility",
    "standinging-landinging-0" => "This One Standinging Landinging · 0",
    "place-for-human" => "This One Place for This One Constitutioning Human",
    "projectioning-er" => "Projectioning-er",
    "road-unscrolling-re-rolling-thing" =>
      "THIS ONE NEVER ENDING ROAD UNSCROLLING, ROAD RE-ROLLING THING",
    "spindle" => "Spindle",
    "pointingable" => "THIS ONE POINTING-ABLE THING",
    "current-local-moment" => "this our current local moment",
    "big-bellowing-thing" => "THIS ONE BIG BELLOWING THING"
  }
  def version, do: @version
  def versions, do: [@version | @witnesses]
  def label, do: "PULL."
  def name(id), do: Map.get(@names, id, id)
  def legacy?(m), do: m.standing["version"] != @version
  def furnished?(m, id), do: Map.has_key?(m.standing["relations"], id)
  def opened?(m), do: furnished?(m, "opening-accomplished")
  def spindle_extent(m), do: Map.get(m.standing, "spindle_extent", 0)
  def spindle_limit, do: @limit
  def complete?(m), do: furnished?(m, "pointingable-standing")

  # Historical rehearsal remains executable quarry; it is never the new opening.
  def new, do: PublicSituationMachineTurnZero.Architecture.Opening.new()

  def puffing_witness do
    givens = [
      {"human-standing", "human", "ALREADY STANDING FROM", "here"},
      {"ground-standing", "ground", "ALREADY STANDING", "here"},
      {"computer-with-human", "ordinary terrestrial computering", "ALONGSIDE WITH", "human"}
    ]

    relations =
      Map.new(givens, fn {id, s, r, o} ->
        {id, rel(s, r, o, "given; not originated by the machine", [])}
      end)

    %__MODULE__{
      standing: %{
        "version" => @version,
        "from" => %{
          "human" => "human",
          "here" => "here",
          "basis" => "human-standing",
          "landinging" => "standinging-landinging-0"
        },
        "relations" => relations,
        "events" => [],
        "zipperings" => %{},
        "localities" => %{},
        "stations" => [],
        "spindle_extent" => 0,
        "landings" => %{
          "standinging-landinging-0" => %{
            "number" => 0,
            "kind" => "present standing",
            "relation" => "human-upon-landinging"
          }
        }
      }
    }
    |> furnish(
      "reserve-toy-box",
      "public construction",
      "reserve existing furnishings",
      "An available operation WITH the Human",
      ["human-standing", "ground-standing"],
      "toy-box-course",
      [
        node(
          "landinging-standing",
          "standinging-landinging-0",
          "STANDING UPON",
          "ground",
          "ground-standing",
          "substratum"
        ),
        node(
          "human-upon-landinging",
          "human",
          "UP ON",
          "standinging-landinging-0",
          "landinging-standing",
          "standing"
        ),
        node(
          "place-standing",
          "place-for-human",
          "FROM HERE UPON",
          "standinging-landinging-0",
          "human-upon-landinging",
          "place"
        ),
        node(
          "toy-box-standing",
          "toy-box",
          "AVAILABLE UPON",
          "ground",
          "place-standing",
          "projection-head"
        ),
        node(
          "cob-square-standing",
          "cob-square",
          "RESERVED WITHIN",
          "toy-box",
          "toy-box-standing",
          "furnishing"
        ),
        node(
          "puffer-available",
          "puffing-tunneling-thing",
          "FOR FURNISHING EXTENT TOWARD",
          "toy-box",
          "cob-square-standing",
          "operation"
        ),
        node(
          "stick-available",
          "stick",
          "AVAILABLE WITH",
          "human",
          "toy-box-standing",
          "pretending"
        ),
        node(
          "regarding-square-available",
          "regarding-square",
          "AVAILABLE WITH",
          "human",
          "toy-box-standing",
          "pretending"
        ),
        node(
          "monitor-square-standing",
          "monitor-plane-square",
          "UPON",
          "ordinary terrestrial computering",
          "computer-with-human",
          "square"
        ),
        node(
          "projection-square-correspondence",
          "regarding-square",
          "CORRESPONDING WITH",
          "monitor-plane-square",
          "monitor-square-standing",
          "correspondence"
        ),
        node(
          "projectioning-er-standing",
          "projectioning-er",
          "THROUGH REGARDING BY WAY OF",
          "regarding-square",
          "projection-square-correspondence",
          "apparatus"
        ),
        node(
          "seat-reserved",
          "traversaling-seat",
          "RESERVED UPON",
          "ground",
          "ground-standing",
          "reserved identity"
        ),
        node(
          "axle-reserved",
          "xt-yt-axle",
          "RESERVED FOR",
          "XT→YT",
          "seat-reserved",
          "reserved identity"
        ),
        node(
          "road-reserved",
          "road-unscrolling-re-rolling-thing",
          "DISTINCT APPARATUS FOR",
          "reliable material course surface",
          "axle-reserved",
          "reserved identity"
        ),
        node(
          "road-supply-behind-seat",
          "road-supply-roll",
          "RESERVED BEHIND",
          "traversaling-seat",
          "road-reserved",
          "spatial relation"
        ),
        node(
          "road-end-through-axle",
          "road-other-end",
          "RESERVED UP THROUGH",
          "xt-yt-axle",
          "road-supply-behind-seat",
          "outreading-tail"
        )
      ]
    )
  end

  def puffed?(m), do: furnished?(m, "first-puffing-accomplished")

  def rehearsal do
    givens = [
      {"human-standing", "human", "ALREADY STANDING FROM", "here"},
      {"ground-standing", "ground", "ALREADY STANDING", "here"},
      {"computer-with-human", "ordinary terrestrial computering", "ALONGSIDE WITH", "human"},
      {"human-suitingable", "human", "ALREADY SUITINGABLE AND ENABLINGMENTING FROM", "here"}
    ]

    relations =
      Map.new(givens, fn {id, s, r, o} ->
        {id, rel(s, r, o, "given; not originated by the machine", [])}
      end)

    m = %__MODULE__{
      standing: %{
        "version" => @version,
        "from" => %{"human" => "human", "here" => "here", "basis" => "human-standing"},
        "relations" => relations,
        "events" => [],
        "zipperings" => %{},
        "localities" => %{},
        "stations" => [],
        "geometry" => Extent.geometry(),
        "material" => Extent.material(),
        "spindle_extent" => 0
      }
    }

    m =
      furnish(
        m,
        "fashion-substratum",
        "public construction",
        "fashion underlying course",
        "Traceable constitutional extent READYINGMENTING TOWARD EN-FURNISHINGMENTING",
        ["ground-standing"],
        "infrastructioning",
        [
          node("page-by-way-of", "page", "BY-WAY-OF", "ground", "ground-standing", "substratum"),
          node(
            "fountaining-standing",
            "fountaining",
            "FROM OUT OF",
            "page",
            "page-by-way-of",
            "source"
          ),
          node(
            "janusite-standing",
            "janusite",
            "FROM",
            "fountaining",
            "fountaining-standing",
            "ribbon"
          ),
          node(
            "track-standing",
            "track",
            "THROUGH-BY",
            "janusite",
            "janusite-standing",
            "infrastructure"
          ),
          node(
            "landinging-standing",
            "landinging",
            "CUBICAL THROUGH-BY",
            "page",
            "track-standing",
            "extent"
          ),
          node(
            "extent-readying",
            "landinging",
            "READYINGMENTING TOWARD",
            "EN-FURNISHINGMENTING",
            "landinging-standing",
            "readiness"
          ),
          node(
            "center-square-standing",
            "center-square",
            "WITHIN",
            "landinging",
            "extent-readying",
            "square"
          ),
          node(
            "crossing-standing",
            "crossing",
            "THROUGH",
            "landinging",
            "center-square-standing",
            "crossing"
          ),
          node(
            "xt-opening-standing",
            "Human-relative Rail Line",
            "AT THE OPENING",
            "xt-opening",
            "crossing-standing",
            "bend"
          ),
          node(
            "xt-out-toward",
            "xt-opening",
            "OUT TOWARD",
            "xt",
            "xt-opening-standing",
            "opening"
          ),
          node(
            "xt-from-here",
            "Human-relative Rail Line",
            "FROM HERE",
            "human",
            "xt-out-toward",
            "source"
          ),
          node("xt-standing", "Human-relative Rail Line", "ON", "xt", "xt-from-here", "rail"),
          node(
            "xt-toward-xt",
            "Human-relative Rail Line",
            "TOWARD",
            "xt",
            "xt-standing",
            "toward"
          ),
          node(
            "xt-upon-track",
            "Human-relative Rail Line",
            "UPON",
            "track",
            "xt-toward-xt",
            "purchase"
          ),
          node(
            "xt-station-ready",
            "XT opening locality",
            "READYINGMENTING TOWARD",
            "EN-FURNISHINGMENTING",
            "xt-upon-track",
            "locality"
          ),
          node(
            "material-standing",
            "In-Stringing-Menting characters",
            "ALONG THROUGH",
            "xt",
            "xt-station-ready",
            "material"
          )
        ]
      )

    opening_locality = %{
      "id" => Ecto.UUID.generate(),
      "event" => "fashion-substratum",
      "relative_to" => "landinging",
      "relation" => "xt-station-ready",
      "bearing" => "AT THE OPENING / OUT TOWARD",
      "readiness" => "READYINGMENTING TOWARD EN-FURNISHINGMENTING"
    }

    m = %{
      m
      | standing:
          m.standing
          |> put_in(["localities", "xt-opening"], opening_locality)
          |> Map.update!("events", fn events ->
            Enum.map(events, fn event ->
              if event["id"] == "fashion-substratum",
                do: Map.put(event, "locality_consequences", [opening_locality["id"]]),
                else: event
            end)
          end)
    }

    m =
      furnish(
        m,
        "assemble-toys",
        "public construction",
        "assemble early available affordmentings",
        "Pretendinging without ceremonial or calibration gating",
        ["xt-standing"],
        "toy-affordmentings",
        [
          node(
            "toy-box-standing",
            "Toy Box",
            "AVAILABLE THROUGH",
            "landinging",
            "material-standing",
            "projection-head"
          ),
          node("doll-available", "doll", "FOR", "Pretendinging", "toy-box-standing", "tool"),
          node(
            "stick-available",
            "stick",
            "FOR",
            "pointing things out",
            "toy-box-standing",
            "tool"
          ),
          node(
            "regarding-square-available",
            "regarding-square",
            "FOR",
            "Human Regarding",
            "toy-box-standing",
            "tool"
          ),
          node(
            "needle-available",
            "needle",
            "FROM / ALONG THROUGH",
            "xt",
            "material-standing",
            "tool"
          ),
          node(
            "pull-available",
            "ring / string / square pull tab",
            "FOR",
            "resolving the Regarding of this extent",
            "toy-box-standing",
            "labor"
          )
        ]
      )

    furnish(
      m,
      "cob-already-standing",
      "public construction",
      "COB stands before Spindle labor",
      "Restrained responsive co-labor; no substitution for Human labor",
      ["xt-standing"],
      "cob-course",
      [
        node("cob-ground", "COB chain", "FROM OUT OF", "ground", "xt-upon-track", "ground"),
        node(
          "cob-chain-standing",
          "COB chain",
          "ALONG THROUGH",
          "landinging",
          "cob-ground",
          "zippering"
        ),
        node("cob-standing", "cob", "UP FOR", "human", "cob-chain-standing", "projection-head"),
        node("cob-for", "cob", "ALONGSIDE WITH", "human", "cob-standing", "outreading-tail")
      ]
    )
    |> stand_semantic_course()
  end

  defp stand_semantic_course(m) do
    {nodes, _} =
      Enum.map_reduce(SemanticalCourse.specs(), "fountaining-standing", fn {id, kind, predicate,
                                                                            object},
                                                                           previous ->
        {node(id, "ordinary In-Stringing-Menting material", predicate, object, previous, kind),
         id}
      end)

    nodes =
      nodes ++
        [
          node(
            "ordinary-material-standing",
            "Stringing",
            "THROUGH-BY",
            SemanticalCourse.id(),
            "sc-toward",
            "material"
          )
        ]

    m =
      furnish(
        m,
        "stand-semantic-course",
        "already-ready public construction",
        "stand the local semantic course",
        "Ordinary material changes bearing through locally stood transitions",
        ["fountaining-standing", "track-standing"],
        SemanticalCourse.id(),
        nodes
      )

    localities =
      Map.new(SemanticalCourse.specs(), fn {id, _, _, _} ->
        {id,
         %{
           "id" => "locality-#{id}",
           "relation" => id,
           "event" => "stand-semantic-course",
           "relative_to" => SemanticalCourse.id()
         }}
      end)

    %{
      m
      | standing:
          m.standing
          |> Map.put("semantical_course", SemanticalCourse.held_course())
          |> Map.put("rehearsal_material", SemanticalCourse.material())
          |> Map.update!("localities", &Map.merge(&1, localities))
    }
  end

  def semantic_projection(m), do: SemanticalCourse.compile(m.standing)

  def restore(%{"version" => v} = s) when v in [@version | @witnesses] do
    m = %__MODULE__{standing: s}

    if v == @version && !Map.has_key?(s, "opening_geometry") && opened?(m),
      do: %{m | regarding: %{m.regarding | bearing: "situated"}},
      else: m
  end

  def next(m) do
    cond do
      legacy?(m) ->
        %{action: nil, for: "Retained witness"}

      Map.has_key?(m.standing, "opening_geometry") ->
        %{
          action: nil,
          for:
            "PULL, first PUFFING THROUGH, appointment, second PUFFING AROUND ABOUT; compose drawer purchases."
        }

      furnished?(m, "puffer-available") ->
        %{action: if(puffed?(m), do: nil, else: "puff"), for: "Furnish an extent FOR possibility"}

      Map.has_key?(m.standing, "semantical_course") ->
        %{action: nil, for: "One source, one short semantical course. Stop here."}

      !opened?(m) ->
        %{action: "pull", for: "PULL."}

      !complete?(m) ->
        %{
          action: "feed-spindle",
          for:
            "Pretend the Stick UP THROUGH your Square FOR Regarding, then UP THROUGH the same center square"
        }

      true ->
        %{action: nil, for: "Pointingable relation stands. Stop before Calibrationing."}
    end
  end

  def operate(%{standing: %{"opening_geometry" => _}} = m, {:traversal_rehearsal, params}),
    do: PublicSituationMachineTurnZero.Architecture.TraversalCourse.operate(m, params)

  def operate(m, {:crossing_rehearsal, params}),
    do: PublicSituationMachineTurnZero.Architecture.CrossingRehearsal.operate(m, params)

  def operate(m, {:inaugural, params}),
    do: PublicSituationMachineTurnZero.Architecture.Inaugural.operate(m, params)

  def operate(%{standing: %{"opening_geometry" => _}} = m, :second_puff),
    do: PublicSituationMachineTurnZero.Architecture.Diorama.second_puff(m)

  def operate(%{standing: %{"opening_geometry" => _}} = m, {:diorama_operation, params}),
    do: PublicSituationMachineTurnZero.Architecture.Diorama.operate(m, params)

  def operate(%{standing: %{"opening_geometry" => _}} = m, op)
      when op in [:opening_pull, :puff, :opening_appoint, :appoint_pointingable] or
             (is_tuple(op) and elem(op, 0) in [:opening_lock, :opening_pull, :opening_feed]) do
    PublicSituationMachineTurnZero.Architecture.Opening.operate(m, op)
  end

  def operate(m, :puff) do
    deps = ["human-standing", "toy-box-standing", "cob-square-standing", "puffer-available"]

    if !legacy?(m) && !puffed?(m) && Enum.all?(deps, &furnished?(m, &1)) do
      {:ok,
       furnish(
         m,
         "first-puffing",
         "human",
         "compression of puffing apparatus TOWARD Toy Box",
         "FROM possibility OF extent, furnish extent FOR possibility",
         deps,
         "first-puffing-course",
         [
           node(
             "first-puffing-accomplished",
             "human",
             "PUFFING TOWARD",
             "toy-box",
             "puffer-available",
             "labor"
           ),
           node(
             "possibility-extent-standing",
             "extent-for-possibility",
             "FURNISHED WITHIN",
             "toy-box",
             "first-puffing-accomplished",
             "extent"
           ),
           node(
             "extent-over-across",
             "extent-for-possibility",
             "OVER ACROSS",
             "toy-box-top",
             "possibility-extent-standing",
             "projection-head"
           ),
           node(
             "cob-standing",
             "cob",
             "EMBODIED BOBBINING FROM WITHIN",
             "toy-box",
             "possibility-extent-standing",
             "standing"
           ),
           node(
             "cob-from-square",
             "cob",
             "PUFFED UP FROM",
             "cob-square",
             "cob-standing",
             "material continuity"
           ),
           node("cob-for", "cob", "ALONGSIDE WITH", "human", "cob-from-square", "outreading-tail")
         ]
       )}
    else
      {:error, :unavailable}
    end
  end

  def operate(m, :appoint_pointingable) do
    deps = ["cob-for", "stick-available", "human-standing"]

    if !legacy?(m) && puffed?(m) && !complete?(m) && Enum.all?(deps, &furnished?(m, &1)) do
      {:ok,
       furnish(
         m,
         "appoint-pointingable",
         "human WITH cob",
         "take the Pretending Stick FOR pointing things out",
         "Pointingable standing WITH the Human",
         deps,
         "first-pointing-course",
         [
           node(
             "pointingable-co-labor",
             "pointingable",
             "ALONGSIDE WITH",
             "cob",
             "cob-for",
             "co-labor"
           ),
           node(
             "pointingable-standing",
             "pointingable",
             "APPOINTED FOR",
             "pointing things out",
             "pointingable-co-labor",
             "outreading-tail"
           )
         ]
       )}
    else
      {:error, :unavailable}
    end
  end

  def operate(m, :take_purchase) do
    if !legacy?(m) && !opened?(m) && is_nil(m.pulling),
      do: {:ok, %{m | pulling: %{token: Ecto.UUID.generate(), moved?: false}}},
      else: {:error, :unavailable}
  end

  def operate(%{pulling: %{token: t}} = m, {:pull, t}),
    do: {:ok, %{m | pulling: %{token: t, moved?: true}}}

  def operate(%{pulling: %{token: t}} = m, {:cancel_pull, t}), do: {:ok, %{m | pulling: nil}}
  def operate(m, :abandon_purchase), do: {:ok, %{m | pulling: nil, feeding: nil}}

  def operate(%{pulling: %{token: t, moved?: true}} = m, {:release, t, measurements}) do
    if !legacy?(m) && !opened?(m) do
      m =
        furnish(
          m,
          "resolve-opening",
          "human",
          "take purchase → pull → release",
          "Discover the already-fashioned CUBICAL extent",
          ["pull-available"],
          "opening-course",
          [
            node(
              "pull-performed",
              "human",
              "PULLS AND RELINQUISHES",
              "square pull tab",
              "pull-available",
              "labor"
            ),
            node(
              "opening-accomplished",
              "human",
              "REGARDING PURCHASE UPON",
              "landinging",
              "pull-performed",
              "accomplishment"
            ),
            node(
              "pull-instrumentation",
              "pull witness",
              "ALONGSIDE / RELATIVE TO",
              "landinging",
              "opening-accomplished",
              "instrumentation"
            )
          ]
        )

      witness = PullWitness.build(measurements)

      locality = %{
        "id" => Ecto.UUID.generate(),
        "event" => "resolve-opening",
        "relative_to" => "landinging",
        "bearing" => "ALONGSIDE",
        "relation" => "pull-instrumentation",
        "witness" => witness
      }

      standing = put_in(m.standing, ["localities", "pull-instrumentation"], locality)

      standing =
        Map.update!(standing, "events", fn events ->
          Enum.map(events, fn e ->
            if e["id"] == "resolve-opening",
              do:
                Map.merge(e, %{
                  "performed_labor" => %{
                    "purchase" => true,
                    "nonzero_pull" => true,
                    "release" => true
                  },
                  "instrumentation_locality" => locality["id"]
                }),
              else: e
          end)
        end)

      {:ok,
       %{
         m
         | standing: standing,
           pulling: nil,
           regarding: %{m.regarding | bearing: "situated", instrumentation: true}
       }}
    else
      {:error, :unavailable}
    end
  end

  def operate(m, {:bearing, b}) when b in ["end-on", "situated"] do
    if !legacy?(m),
      do: {:ok, %{m | regarding: %{m.regarding | bearing: b}}},
      else: {:error, :unavailable}
  end

  def operate(m, {:instrumentation, visible}) when is_boolean(visible) do
    if opened?(m) && !legacy?(m),
      do: {:ok, %{m | regarding: %{m.regarding | instrumentation: visible}}},
      else: {:error, :unavailable}
  end

  def operate(m, {:tool, tool}) when tool in ["stick", "doll", "needle", "regarding-square"],
    do: regard(m, :tool, tool)

  def operate(m, {:material, "flow"}), do: regard(m, :material, nil)

  def operate(m, {:material, id}) when is_binary(id) do
    if !legacy?(m) &&
         Enum.any?(
           m.standing["material"] ++ Map.get(m.standing, "rehearsal_material", []),
           &(&1["id"] == id)
         ),
       do: regard(m, :material, id),
       else: {:error, :unavailable}
  end

  def operate(m, {:inspect, id}) when is_binary(id) do
    if !legacy?(m) && furnished?(m, id),
      do: regard(m, :inspected, id),
      else: {:error, :unavailable}
  end

  def operate(m, :start_feed) do
    if !legacy?(m) && opened?(m) && !complete?(m) && m.regarding.tool == "stick" &&
         is_nil(m.feeding),
       do: {:ok, %{m | feeding: %{token: Ecto.UUID.generate(), through: :neither}}},
       else: {:error, :unavailable}
  end

  def operate(
        %{feeding: %{token: t, through: :neither}} = m,
        {:feed_through, t, "regarding-square"}
      ),
      do: {:ok, %{m | feeding: %{token: t, through: :regarding_square}}}

  def operate(
        %{feeding: %{token: t, through: :regarding_square}} = m,
        {:feed_through, t, "center-square"}
      ),
      do: {:ok, %{m | feeding: %{token: t, through: :both}}}

  def operate(%{feeding: %{token: t}} = m, {:cancel_feed, t}), do: {:ok, %{m | feeding: nil}}

  def operate(%{feeding: %{token: t, through: :both}} = m, {:feed, t, extent})
      when is_integer(extent) and extent > 0 and extent <= @limit do
    if extent == spindle_extent(m) + 1 && !complete?(m) do
      previous = if extent == 1, do: "center-square-standing", else: "spindle-#{extent - 1}"

      performed =
        if extent == 1,
          do: [
            node(
              "feed-stick-through-regarding",
              "stick",
              "UP THROUGH",
              "regarding-square",
              "stick-available",
              "labor"
            ),
            node(
              "feed-stick-through-center",
              "stick",
              "UP THROUGH",
              "center-square",
              "feed-stick-through-regarding",
              "labor"
            )
          ],
          else: []

      m =
        furnish(
          m,
          "feed-spindle-#{extent}",
          "human ALONGSIDE WITH COB",
          "Stick UP THROUGH Regarding square then existing center square",
          "Finite Spindle extent through the same square",
          [
            previous,
            "cob-standing",
            "xt-standing",
            "stick-available",
            "regarding-square-available"
          ],
          "spindle-course-#{extent}",
          performed ++
            [
              node(
                "spindle-#{extent}",
                "spindle",
                "UP THROUGH",
                "center-square",
                previous,
                "extent"
              ),
              node(
                "cob-lift-#{extent}",
                "same COB chain",
                "ANOTHER ASPECT THROUGH",
                "spindle",
                "spindle-#{extent}",
                "embedding"
              )
            ]
        )

      m = %{
        m
        | standing:
            m.standing
            |> Map.put("spindle_extent", extent)
            |> put_in(["geometry", "spindle"], Extent.spindle(extent))
      }

      m =
        if extent == @limit do
          furnish(
            m,
            "pointingable-accomplished",
            "human ALONGSIDE WITH COB",
            "accomplish the finite Spindle co-labor",
            "Pointing acquires constitutional consequence through actual ancestry",
            ["spindle-6", "cob-standing", "stick-available"],
            "pointingable-course",
            [
              node(
                "stick-through-spindle",
                "stick",
                "THROUGH-BY",
                "spindle",
                "spindle-6",
                "ancestry"
              ),
              node(
                "pointingable-co-labor",
                "pointingable",
                "ALONGSIDE WITH",
                "cob",
                "stick-through-spindle",
                "co-labor"
              ),
              node(
                "pointingable-standing",
                "pointingable",
                "FROM / THROUGH-BY",
                "stick",
                "pointingable-co-labor",
                "consequence"
              )
            ]
          )
        else
          m
        end

      {:ok, m}
    else
      {:error, :unavailable}
    end
  end

  def operate(_, _), do: {:error, :unavailable}

  defp regard(m, key, value) do
    if !legacy?(m),
      do: {:ok, %{m | regarding: Map.put(m.regarding, key, value)}},
      else: {:error, :unavailable}
  end

  def projection(m), do: Extent.projection(m)

  defp rel(s, r, o, event, deps) do
    %{
      "subject" => s,
      "relation" => r,
      "object" => o,
      "provenance" => event,
      "dependencies" => deps,
      "for_human" => "human"
    }
  end

  defp node(id, s, r, o, through, role),
    do: %{id: id, subject: s, predicate: r, object: o, through: through, role: role}

  # Local predecessor links are consequential relations, not inferred adjacency.
  # Each new node carries only its immediate predecessor, which remains traversable.
  @doc false
  def furnish(m, id, actor, labor, purpose, deps, course_id, nodes) do
    before = m.standing

    {relations, steps, links} =
      Enum.reduce(nodes, {before["relations"], [], []}, fn n, {relations, steps, links} ->
        r =
          rel(n.subject, n.predicate, n.object, id, [n.through])
          |> Map.put("through_by_way_of", n.through)
          |> Map.put("course", course_id)

        r =
          if n.id == "spindle-1",
            do:
              Map.merge(r, %{
                "alongside_with" => "cob-standing",
                "from_along_through" => "xt-standing",
                "through_labor" => "feed-stick-through-center"
              }),
            else: r

        r =
          if n.id == "pointingable-standing",
            do: Map.put(r, "pretending_ancestry", "stick-available"),
            else: r

        r =
          if n.id == "sc-source", do: Map.put(r, "from_along_through", "track-standing"), else: r

        link_id = n.id <> "-through"
        link = rel(n.id, "THROUGH-BY-WAY-OF", n.through, id, [n.through])
        link = link |> Map.put("course", course_id) |> Map.put("through_by_way_of", n.through)

        step = %{
          "id" => n.id,
          "relation" => n.id,
          "role" => n.role,
          "through" => n.through,
          "link" => link_id
        }

        {relations |> Map.put(n.id, r) |> Map.put(link_id, link), steps ++ [step],
         links ++ [link_id]}
      end)

    course = %{
      "id" => course_id,
      "for" => purpose,
      "inherited_through" => hd(nodes).through,
      "steps" => steps,
      "links" => links,
      "head" => find_role(steps, "projection-head"),
      "tail" => find_role(steps, "outreading-tail"),
      "return" => List.last(steps)["id"]
    }

    standing =
      before |> Map.put("relations", relations) |> put_in(["zipperings", course_id], course)

    event = %{
      "id" => id,
      "station" => nil,
      "actor" => actor,
      "labor" => labor,
      "for" => purpose,
      "from" => before["from"],
      "from_after" => standing["from"],
      "furnishing" => course_id,
      "labor_toward" => Enum.map(steps, & &1["id"]),
      "inherited_before" => Enum.sort(Map.keys(before["relations"])),
      "inherited_after" => Enum.sort(Map.keys(relations)),
      "dependencies" => deps,
      "ancestry" => Enum.map(deps, &Map.put(before["relations"][&1], "id", &1)),
      "consequences" => Enum.map(steps, & &1["id"]) ++ links,
      "semantical_in_stringing_menting" => course,
      "live_outreading" => Enum.map(steps, & &1["id"]),
      "next_for" => "Wind only the next available relation"
    }

    event =
      case PublicSituationMachineTurnZero.Architecture.Inscriptioning.locality(id) do
        nil -> event
        locality -> Map.put(event, "inscription_locality", locality)
      end

    %{m | standing: Map.update!(standing, "events", &(&1 ++ [event]))}
  end

  defp find_role(steps, role),
    do: Enum.find_value(steps, fn s -> if s["role"] == role, do: s["id"] end)

  @doc "Follow the actual local predecessor course, ending at given standing."
  def ancestry(m, id), do: follow(m.standing["relations"], id, MapSet.new())

  defp follow(relations, id, seen) do
    case {Map.get(relations, id), MapSet.member?(seen, id)} do
      {nil, _} ->
        []

      {_, true} ->
        []

      {r, false} ->
        next_seen = MapSet.put(seen, id)

        branches =
          [
            r["through_by_way_of"],
            r["alongside_with"],
            r["from_along_through"],
            r["pretending_ancestry"],
            r["reference_geometry"],
            r["through_labor"]
          ]
          |> Enum.reject(&is_nil/1)

        ([Map.put(r, "id", id)] ++ Enum.flat_map(branches, &follow(relations, &1, next_seen)))
        |> Enum.uniq_by(& &1["id"])
    end
  end

  def outreading(m, id) do
    case m.standing["relations"][id] do
      nil -> nil
      r -> "#{name(r["subject"])} #{r["relation"]} #{name(r["object"])}"
    end
  end
end
