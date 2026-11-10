defmodule PublicSituationMachineTurnZero.Workshop.Surfacing do
  @moduledoc "Relational Surfacing/Consoling appointments and Human-authored routing witnesses. No operational correspondence."
  def new, do: initial(Ecto.UUID.generate())

  defp initial(id),
    do: %{
      "version" => 1,
      "id" => id,
      "revision" => 0,
      "draft" => "",
      "revising" => nil,
      "records" => [],
      "events" => []
    }

  def registrations do
    %{
      "surfacing" => %{
        "id" => "this-one-surfacing-stand",
        "name" =>
          "THIS ONE SURFACING STAND STANDING TOWARD STAGING WITHIN THIS ONE SITUATIONING FROM HERE",
        "class" => "APPOINTED relational locality",
        "WITHIN" => "THIS ONE STANDINGING LANDINGING",
        "stands_TOWARD" => "THIS ONE CONSTITUTIONING HUMAN FROM HERE",
        "office" => "Human Quilling / Semantical In-Stringing-Mentings",
        "placement" => %{
          "status" => "UNAPPOINTED; requires measured architectural registration",
          "coordinates" => nil
        },
        "presentation" => "ordinary flat UI; distinct from diagnostic projector relay"
      },
      "consoling" => %{
        "id" => "this-one-cob-consoling-stand",
        "name" =>
          "THIS ONE COB'S CONSOLING STAND STANDING FROM WITHIN THIS ONE SURFACING STAND STANDING HERE FROM UPON THIS ONE STANDINGING LANDINGING",
        "class" => "APPOINTED relational locality",
        "FROM_WITHIN" => "this-one-surfacing-stand",
        "FROM_OUT_OF" => "THIS HERE APPROACHING LANDINGING",
        "UPON" => "THIS ONE STANDINGING LANDINGING",
        "stands_TOWARD" => "THIS ONE CONSTITUTIONING HUMAN FROM HERE",
        "BY_WAY_OF" => "this-one-stewardly-co-captain-co-bobbining-thing",
        "office" => "IN-QUESTIONINGMENTING; appointed condition only",
        "purpose" =>
          "THIS ONE CONSOLING STAND STANDS FROM HERE FOR STANDING UP IN-QUESTIONINGMENTING TOWARD THIS ONE CONSTITUTIONING HUMAN FROM HERE BY-WAY-OF THIS ONE STEWARDLY CO-CAPTAIN CO-BOBBINING THING CONSOLING WITHIN HERE FROM HERE THROUGHBY THIS ONE CONSOLING STAND STANDING FROM OUT OF THIS HERE APPROACHING LANDINGING.",
        "placement" => %{
          "status" => "UNAPPOINTED; no separate world coordinates invented",
          "coordinates" => nil
        },
        "agency" => "relational COB office, not an independent agent or another Human"
      },
      "here" => %{
        "id" => "THIS HERE APPROACHING LANDINGING",
        "persistent_provenance" => true,
        "source_registration_id" => "HERE",
        "source_registry" =>
          "existing Calibration HERE appointment; this does not appoint the new stands physical placement",
        "NEXT" => "distinct; never substituted for HERE",
        "relation" =>
          "Consoling stands FROM OUT OF HERE; exact attachment to Standinging Landinging remains unmeasured"
      },
      "by_way_of" => %{
        "id" => "this-one-stewardly-co-captain-co-bobbining-thing",
        "name" => "THIS ONE STEWARDLY CO-CAPTAIN CO-BOBBINING THING",
        "relation" =>
          "Human Inquiringingmenting THROUGHBY TOWARD COB's IN-QUESTIONINGMENTING office",
        "status" =>
          "APPOINTED routing relationship; operation and external computation contract unfurnished"
      },
      "staging_route" => %{
        "id" => "staging",
        "material_status" => "STAGING FOR STANDING",
        "destination" =>
          "staging TOWARD Stitching markings UPON the Road WITH the Co-Situationing Doll",
        "operation" => "UNFURNISHED; displayed/routed material is not Stitched UPON the Road",
        "author" => "Constitutioning Human",
        "co_labouring" => "Co-Situationing Doll; not an independent agent"
      },
      "inquiry_route" => %{
        "id" => "inquiry",
        "material_status" => "STAGING FOR STANDING",
        "destination" => "this-one-cob-consoling-stand / IN-QUESTIONINGMENTING office",
        "BY_WAY_OF" => "this-one-stewardly-co-captain-co-bobbining-thing",
        "FROM_OUT_OF" => "THIS HERE APPROACHING LANDINGING",
        "condition" =>
          "IN-QUESTIONINGMENTING appointed following the Human's inquiry; not operational reasoning or an answer"
      }
    }
  end

  def operate(s, revision, command) do
    cond do
      revision != s["revision"] -> {:error, :stale}
      s["revision"] >= 300 -> {:error, :limit}
      true -> apply_command(s, command)
    end
  end

  defp apply_command(s, {:quill, text}) when is_binary(text) and byte_size(text) <= 12_000 do
    if text == s["draft"],
      do: {:ok, s},
      else: {:ok, advance(s, %{"action" => "quill", "text" => text})}
  end

  defp apply_command(s, {:revise, id}) when is_binary(id) do
    if Enum.any?(s["records"], &(&1["id"] == id)),
      do: {:ok, advance(s, %{"action" => "revise", "id" => id})},
      else: {:error, :record}
  end

  defp apply_command(s, :new_draft), do: {:ok, advance(s, %{"action" => "new-draft"})}

  defp apply_command(s, {:route, route}) when route in ~w(staging inquiry) do
    if String.trim(s["draft"]) == "",
      do: {:error, :empty},
      else: {:ok, advance(s, %{"action" => "route", "route" => route})}
  end

  defp apply_command(_, _), do: {:error, :invalid}

  defp advance(s, event) do
    revision = s["revision"] + 1

    s =
      case event do
        %{"action" => "quill", "text" => text} ->
          %{s | "draft" => text}

        %{"action" => "new-draft"} ->
          %{s | "draft" => "", "revising" => nil}

        %{"action" => "revise", "id" => id} ->
          record = Enum.find(s["records"], &(&1["id"] == id))
          %{s | "draft" => record["text"], "revising" => id}

        %{"action" => "route", "route" => route} ->
          record = %{
            "id" => "#{s["id"]}-material-#{length(s["records"]) + 1}",
            "sequence" => length(s["records"]) + 1,
            "revision" => revision,
            "route" => route,
            "text" => s["draft"],
            "supersedes" => s["revising"],
            "author" => "Constitutioning Human",
            "illumination" => "Terrestrial Computer; not material authorship",
            "FROM" => "this-one-surfacing-stand",
            "HERE_provenance" => "THIS HERE APPROACHING LANDINGING",
            "destination" =>
              registrations()[if(route == "staging", do: "staging_route", else: "inquiry_route")],
            "material_status" => "STAGING FOR STANDING",
            "operation_performed" => false
          }

          %{s | "records" => s["records"] ++ [record], "revising" => nil}
      end

    %{s | "revision" => revision, "events" => s["events"] ++ [event]}
  end

  def valid?(%{"version" => 1, "id" => id, "events" => events} = s) when is_list(events) do
    with {:ok, _} <- Ecto.UUID.cast(id), true <- length(events) <= 300 do
      result =
        Enum.reduce_while(events, {:ok, initial(id)}, fn event, {:ok, current} ->
          command =
            case event do
              %{"action" => "quill", "text" => text} when map_size(event) == 2 ->
                {:quill, text}

              %{"action" => "revise", "id" => id} when map_size(event) == 2 ->
                {:revise, id}

              %{"action" => "route", "route" => route} when map_size(event) == 2 ->
                {:route, route}

              %{"action" => "new-draft"} when map_size(event) == 1 ->
                :new_draft

              _ ->
                nil
            end

          case operate(current, current["revision"], command) do
            {:ok, next} when next != current -> {:cont, {:ok, next}}
            _ -> {:halt, :invalid}
          end
        end)

      case result do
        {:ok, expected} -> expected === s
        _ -> false
      end
    else
      _ -> false
    end
  end

  def valid?(_), do: false
end
