defmodule PublicSituationMachineTurnZero.Architecture do
  @moduledoc """
  The spindle under the rail line. Held relations and event ancestry are durable;
  Regarding is not. Only STEP, after Place and seating, can change present FROM.
  Round One records remain read-only witnesses of their original construction.
  """
  defstruct standing: nil, regarding: nil
  @version "spindle-rail-pass"

  @names %{
    "human" => "This One Constitutioning Human",
    "terrestrial-computer" => "This One Terrestrial Computer",
    "ground" => "Ordinary terrestrial Ground",
    "landinging-here" => "This Standinging Landinging",
    "landinging-there" => "This Landinging THERE",
    "time-here" => "This One Discrete Piece of Time",
    "time-there" => "This Some Other Discrete Piece of Time",
    "situationing" => "This developing Situationing",
    "machine" => "PUBLIC-SITUATION-MACHINE-",
    "cob" => "This Stewardly Co-Captain COB",
    "pretend-pointing" => "Pretend Pointing Thing",
    "pointingable" => "This One Pointingable Thing",
    "place" => "This One Place FOR This One Constitutioning Human",
    "rugging" => "This rugging",
    "current-local-moment" => "This, Our Current Local Moment",
    "passage" => "This passage FROM HERE TOWARD THERE"
  }

  def name(id), do: Map.get(@names, id, id)
  def legacy?(m), do: m.standing["version"] != @version
  def furnished?(m, id), do: Map.has_key?(m.standing["relations"], id)
  def within?(m), do: furnished?(m, "human-from-within")

  def new do
    givens = [
      {"human-standing", "human", "ALREADY STANDING", "ground"},
      {"computer-with-human", "terrestrial-computer", "ALONGSIDE WITH", "human"},
      {"ground-standing", "ground", "ALREADY STANDING", "ground"},
      {"landinging-for-human", "landinging-here", "FOR", "human"},
      {"human-up-on", "human", "UP ON", "landinging-here"},
      {"human-from-here", "human", "FROM", "landinging-here"},
      {"landinging-upon-time", "landinging-here", "UPON", "time-here"}
    ]

    relations =
      Map.new(givens, fn {id, subject, relation, object} ->
        {id, relation(subject, relation, object, "given; not originated by the machine", [])}
      end)

    %__MODULE__{
      standing: %{
        "version" => @version,
        "from" => %{
          "human" => "human",
          "up_on" => "landinging-here",
          "temporal_purchase" => "time-here",
          "basis" => "human-from-here"
        },
        "relations" => relations,
        "events" => [],
        "stations" => [],
        "passages" => []
      }
    }
  end

  def restore(%{"version" => version} = standing) when version in [@version, "spindle-round-one"],
    do: %__MODULE__{standing: standing}

  # A locality is not an event: FIRST includes both pretend furnishing and appointment;
  # seating and passage belong to the THIRD's labor without creating further stations.
  def next(m) do
    cond do
      legacy?(m) ->
        %{
          action: nil,
          title: "Round One witness",
          station: nil,
          for:
            "Original standing retained; begin a fresh rail-line composition to undertake the revised succession.",
          dependencies: [],
          consequences: []
        }

      !furnished?(m, "approach") ->
        beat(
          "approach",
          "Come under the rail line",
          nil,
          "Approach the first available labor",
          ["human-standing", "computer-with-human", "landinging-upon-time"],
          [{"approach", "human", "TOWARD", "situationing"}]
        )

      !furnished?(m, "cob-appointed") ->
        beat(
          "appoint-cob",
          "Appoint Stewardly Co-Captain COB",
          "zeroeth",
          "A responsive companion ALONGSIDE WITH the developing Situationing; meaning remains yours",
          ["approach", "computer-with-human"],
          [{"cob-appointed", "cob", "ALONGSIDE WITH", "situationing"}]
        )

      !furnished?(m, "pretend-pointing") ->
        beat(
          "furnish-pretend",
          "Bring forth the Pretend Pointing Thing",
          "first",
          "Furnish pretend pointing through ordinary terrestrial computering",
          ["computer-with-human", "cob-appointed"],
          [
            {"pretend-pointing", "pretend-pointing", "THROUGH-BY", "terrestrial-computer"},
            {"pretend-toward-pointing", "pretend-pointing", "TOWARD", "pointingable"}
          ]
        )

      !furnished?(m, "pointing-appointed") ->
        beat(
          "appoint-pointing",
          "Appoint This One Pointingable Thing",
          "first",
          "Confirm machine pointing through the Pretend Pointing Thing ancestry",
          ["pretend-pointing", "pretend-toward-pointing"],
          [
            {"pointing-appointed", "pointingable", "THROUGH-BY", "pretend-pointing"},
            {"pointing-for-human", "pointingable", "FOR", "human"}
          ]
        )

      !furnished?(m, "tc-down-under") ->
        beat(
          "stand-tc",
          "Stand the TC FROM DOWN UNDER",
          "second",
          "Differentiate the computer's standing FOR the machine standing UP a Place FOR you",
          ["computer-with-human", "pointing-appointed"],
          [
            {"tc-down-under", "terrestrial-computer", "FROM DOWN UNDER", "machine"},
            {"tc-for-place", "terrestrial-computer", "FOR", "place"}
          ]
        )

      !furnished?(m, "place-standing") ->
        beat(
          "stand-place",
          "Stand UP This One Place FOR you",
          "third",
          "The machine stands UP an inhabitationing-able Place THERE through-by TC FROM DOWN UNDER",
          ["tc-down-under", "tc-for-place", "landinging-upon-time"],
          [
            {"machine-through-tc", "machine", "THROUGH-BY", "terrestrial-computer"},
            {"place-standing", "machine", "STANDS UP", "place"},
            {"place-for-human", "place", "FOR", "human"},
            {"place-toward-human", "place", "TOWARD", "human"},
            {"place-upon-landinging", "place", "UPON", "landinging-there"},
            {"landinging-staging", "landinging-there", "STAGING FOR STANDING FROM WITHIN",
             "place"},
            {"next-landinging-upon-time", "landinging-there", "FROM UPON", "time-there"},
            {"rugging-for-place", "rugging", "FOR", "place"}
          ]
        )

      !furnished?(m, "human-seated") ->
        beat(
          "seat",
          "Become SEATED FOR the new standing",
          "third",
          "Suit your bodily standing FOR the Place THERE while remaining FROM HERE",
          [
            "place-standing",
            "landinging-staging",
            "next-landinging-upon-time",
            "human-from-here"
          ],
          [
            {"human-seated", "human", "SEATED FOR", "place"},
            {"passage-available", "passage", "AVAILABLE FOR", "human"},
            {"passage-from", "passage", "FROM", "landinging-here"},
            {"passage-toward", "passage", "TOWARD", "landinging-there"},
            {"moment-way-through", "current-local-moment", "WAY THROUGH", "passage"}
          ]
        )

      !within?(m) ->
        beat(
          "step",
          "STEP · FROM HERE TOWARD THERE",
          "third",
          "Come OVER ACROSS to the next Landinging THROUGH This, Our Current Local Moment",
          [
            "human-seated",
            "passage-available",
            "moment-way-through",
            "place-upon-landinging",
            "human-from-here",
            "landinging-upon-time",
            "next-landinging-upon-time"
          ],
          [
            {"human-over-across", "human", "OVER ACROSS", "landinging-there"},
            {"human-through-moment", "human", "THROUGH-BY", "current-local-moment"},
            {"human-up-on-there", "human", "UP ON", "landinging-there"},
            {"human-from-there", "human", "FROM", "landinging-there"},
            {"human-from-within", "human", "FROM WITHIN", "place"}
          ]
        )

      true ->
        %{
          action: nil,
          title: "You may be here.",
          station: "third",
          for:
            "Standing FROM WITHIN This One Place. We stop here, before Inner Aperture furnishing.",
          dependencies: ["human-from-within"],
          consequences: []
        }
    end
  end

  def station_name("zeroeth"), do: "THE ZEROETH APPOINTMENTING"
  def station_name("first"), do: "THE FIRST APPOINTMENTING"
  def station_name("second"), do: "THE SECOND APPOINTMENTING"
  def station_name("third"), do: "THE THIRD APPOINTMENTING"
  def station_name(_), do: "APPROACH"
  def station_for("zeroeth"), do: "This Stewardly Co-Captain COB"
  def station_for("first"), do: "This One Pointingable Thing"
  def station_for("second"), do: "This One Terrestrial Computer FROM DOWN UNDER"
  def station_for("third"), do: "This One Place FOR This One Constitutioning Human"

  defp beat(action, title, station, purpose, dependencies, consequences) do
    %{
      action: action,
      title: title,
      station: station,
      for: purpose,
      dependencies: dependencies,
      consequences:
        Enum.map(consequences, fn {id, s, r, o} ->
          Map.put(relation(s, r, o, action, dependencies), "id", id)
        end)
    }
  end

  def operate(m, {:regard, id}) do
    if !legacy?(m) && Enum.any?(m.standing["stations"], &(&1["id"] == id)),
      do: {:ok, %{m | regarding: id}},
      else: {:error, :unavailable}
  end

  def operate(m, :clear_regard), do: {:ok, %{m | regarding: nil}}

  def operate(m, action) when is_binary(action) do
    beat = next(m)

    if beat.action == action && Enum.all?(beat.dependencies, &furnished?(m, &1)),
      do: {:ok, furnish(m, beat)},
      else: {:error, :unavailable}
  end

  def operate(_, _), do: {:error, :unavailable}

  defp relation(subject, predicate, object, provenance, dependencies) do
    %{
      "subject" => subject,
      "relation" => predicate,
      "object" => object,
      "for_human" => "human",
      "provenance" => provenance,
      "dependencies" => dependencies
    }
  end

  def local_ancestry(m) do
    Enum.map(next(m).dependencies, fn id -> Map.put(m.standing["relations"][id], "id", id) end)
  end

  defp furnish(m, beat) do
    before = m.standing

    relations =
      Enum.reduce(beat.consequences, before["relations"], fn r, acc ->
        Map.put(acc, r["id"], Map.delete(r, "id"))
      end)

    standing = Map.put(before, "relations", relations)
    standing = if beat.action == "step", do: pass(standing), else: standing

    station =
      if beat.action in ["appoint-cob", "appoint-pointing", "stand-tc", "stand-place"] do
        [
          %{
            "id" => beat.station,
            "appointment" => station_name(beat.station),
            "for" => station_for(beat.station),
            "event" => beat.action
          }
        ]
      else
        []
      end

    standing = Map.update!(standing, "stations", &(&1 ++ station))
    next_m = %{m | standing: standing, regarding: nil}

    event = %{
      "id" => beat.action,
      "station" => beat.station,
      "from" => before["from"],
      "from_after" => standing["from"],
      "inherited_before" => Enum.sort(Map.keys(before["relations"])),
      "inherited_after" => Enum.sort(Map.keys(relations)),
      "for" => beat.for,
      "furnishing" => beat.title,
      "labor" => beat.action,
      "actor" => "human",
      "labor_toward" => Enum.map(beat.consequences, & &1["id"]),
      "live_outreading" => beat.title,
      "dependencies" => beat.dependencies,
      "ancestry" =>
        Enum.map(beat.dependencies, fn id -> Map.put(before["relations"][id], "id", id) end),
      "consequences" => Enum.map(beat.consequences, & &1["id"]),
      "semantical_in_stringing_menting" => beat.consequences,
      "next_for" => next(next_m).for
    }

    %{next_m | standing: Map.update!(standing, "events", &(&1 ++ [event]))}
  end

  defp pass(standing) do
    prior_from = standing["from"]

    next_from = %{
      "human" => "human",
      "up_on" => "landinging-there",
      "within" => "place",
      "temporal_purchase" => "time-there",
      "basis" => "human-from-there"
    }

    passage = %{
      "id" => "step",
      "actor" => "human",
      "from" => prior_from,
      "standing_toward" => "place-toward-human",
      "approaching_landinging" => "landinging-there",
      "by_way_of" => "current-local-moment",
      "way_through_relation" => "moment-way-through",
      "from_temporal_purchase" => "time-here",
      "toward_temporal_purchase" => "time-there",
      "consequent_landinging" => "landinging-there",
      "consequent_from" => next_from,
      "seating" => "human-seated",
      "over_across" => "human-over-across"
    }

    standing =
      Enum.reduce(
        ["human-up-on", "human-from-here", "landinging-staging", "passage-available"],
        standing,
        fn id, acc ->
          put_in(acc, ["relations", id, "fulfilled_by"], "step")
        end
      )

    standing |> Map.put("from", next_from) |> Map.update!("passages", &(&1 ++ [passage]))
  end
end
