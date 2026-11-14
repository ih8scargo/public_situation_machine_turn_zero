defmodule PublicSituationMachineTurnZero.Workshop.AlongsideStaging do
  @moduledoc """
  Bounded alongside/angular-registration witness; no actual acquisition authority.
  Canon: docs/architecture/geometry/table-crossing-staging.md (R21–R23).
  """
  alias PublicSituationMachineTurnZero.Workshop.MaterialRibbon, as: M
  @version "alongside-angular-registration-v1"
  @angles [0, 30, 60, 90]
  def version, do: @version
  def angles, do: @angles

  def new do
    %{
      regarding: 0,
      target: nil,
      staged: nil,
      furnished: [],
      selected: "alongside:inherited-reference",
      notice: nil,
      appointments: [],
      inherited: sheet("alongside:inherited-reference", 0, :already_standing_reference),
      human_frame_acquired: false,
      landinging_acquired: false,
      from_down_under: false
    }
  end

  def aperture do
    %{
      id: "un-vanishing-aperture",
      center: [3, 3, 0],
      normal: [0, 0, 1],
      radius: 0.4,
      points:
        for(
          i <- 0..32,
          do: [
            3 + 0.4 * :math.cos(i * 2 * :math.pi() / 32),
            3 + 0.4 * :math.sin(i * 2 * :math.pi() / 32),
            0
          ]
        ),
      relation: "REGISTERED OPENING TOWARD REGARDING",
      frame: "exploration-six-v1",
      status: :candidate_physical_registration,
      correspondence:
        "Crossing THREE center reference; distinct from monitor and material aperture",
      physical_passage: :unproved
    }
  end

  def sheet(id, angle, status) do
    a = angle * :math.pi() / 180
    tangent = [:math.cos(a), 0, -:math.sin(a)]
    radial = [:math.sin(a), 0, :math.cos(a)]
    center = M.add(aperture().center, radial)

    corners =
      for {w, h} <- [{-0.12, -0.25}, {0.12, -0.25}, {0.12, 0.25}, {-0.12, 0.25}],
          do: M.add(center, M.add(M.scale(tangent, w), [0, h, 0]))

    vertices =
      Enum.map(corners, &M.add(&1, M.scale(radial, -0.015))) ++
        Enum.map(corners, &M.add(&1, M.scale(radial, 0.015)))

    faces =
      for indices <- [
            [0, 3, 2, 1],
            [4, 5, 6, 7],
            [0, 1, 5, 4],
            [1, 2, 6, 5],
            [2, 3, 7, 6],
            [3, 0, 4, 7]
          ],
          do: Enum.map(indices, &Enum.at(vertices, &1))

    %{
      id: id,
      source: "alongside-planar-janusite-stock-v1",
      status: status,
      angle: angle,
      center: center,
      vertices: vertices,
      faces: faces,
      width: 0.24,
      height: 0.5,
      thickness: 0.03,
      frame: "exploration-six-v1",
      unit: "trial extent",
      office:
        if(status == :already_standing_reference,
          do: "inherited fixture / office not attested",
          else: "FT COB candidate furnishing / TF COB unmounted"
        ),
      acquisition:
        if(status == :already_standing_reference, do: :not_attested, else: :not_acquired),
      from_down_under: false,
      relation: "UP FROM HERE OVER ACROSS",
      source_scope: :staging_geometry_preview,
      ancestry: ["xt-to-xt-from-here", "current-turn:xt-toward-yt-measure", aperture().id]
    }
  end

  def command(s, {:pivot, angle}) when angle in @angles,
    do:
      {:ok,
       %{
         s
         | regarding: angle,
           notice:
             "Regarding pivot only. All material world vertices and acquisition remain unchanged."
       }, :regarding_pivot, :no_material_change}

  def command(s, :appoint_wedging) do
    appointment = %{
      id: "wedging-appointment-#{length(s.appointments) + 1}",
      angle: s.regarding,
      source: :human_appointment,
      office: "FT COB",
      frame: "exploration-six-v1"
    }

    {:ok,
     %{
       s
       | target: appointment,
         appointments: s.appointments ++ [appointment],
         notice:
           "Human appointment retained. Material has not moved; explicitly stage a new specimen."
     }, :human_appointment, appointment}
  end

  def command(%{target: nil} = s, :stage), do: blocked(s, :staging, [:wedging_not_appointed])

  def command(%{staged: staged} = s, :stage) when not is_nil(staged),
    do: blocked(s, :staging, [:existing_staged_material_must_be_retained_first])

  def command(s, :stage) when length(s.furnished) < 6 do
    id = "alongside:material-#{length(s.furnished) + 1}"
    candidate = sheet(id, s.target.angle, :newly_staged)
    collision = Enum.find([s.inherited | s.furnished], &M.collision?(&1, candidate))
    outside = Enum.any?(candidate.vertices, fn p -> Enum.any?(p, &(&1 < 0 or &1 > 6)) end)

    cond do
      outside ->
        blocked(s, :staging, [:occupied_material_outside_registered_frame])

      collision ->
        blocked(s, :staging, [{:occupied_material_interference, collision.id}])

      true ->
        candidate =
          Map.merge(candidate, %{
            appointment: s.target.id,
            alongside: s.inherited.id,
            inherited_furnishing: Enum.map(s.furnished, & &1.id),
            projection: "alongside-shared-projectioning"
          })

        {:ok,
         %{
           s
           | staged: candidate,
             notice:
               "New material staged alongside the inherited reference UP FROM HERE OVER ACROSS, THROUGH-BY the registered opening. No acquisition or FROM DOWN UNDER."
         }, :material_staged, %{material: id, appointment: s.target.id}}
    end
  end

  def command(s, :stage), do: blocked(s, :resource_limit, [:six_specimen_session_bound_not_canon])

  def command(%{staged: nil} = s, :retain_furnishing),
    do: blocked(s, :furnishing, [:no_staged_material])

  def command(s, :retain_furnishing) do
    furnished = %{s.staged | status: :candidate_furnished}

    {:ok,
     %{
       s
       | furnished: s.furnished ++ [furnished],
         staged: nil,
         notice:
           "Candidate furnishing retained under the same material ID. This preview is not lawful Landinging acquisition; FROM DOWN UNDER remains unavailable."
     }, :candidate_material_furnished,
     %{material: furnished.id, acquisition: furnished.acquisition}}
  end

  def command(s, {:inspect, id}) do
    if id in Enum.map(materials(s), & &1.id),
      do:
        {:ok,
         %{
           s
           | selected: id,
             notice:
               "Selected Segmentationing for Human inspection only; COB work is not authorized."
         }, :segmentation_inspection, id},
      else: {:error, :unknown_material}
  end

  def command(s, :acquire_landing),
    do:
      blocked(s, :landinging_acquisition, [
        :human_frame_unacquired,
        :material_joining_unproved,
        :landinging_completion_unwitnessed
      ])

  def command(s, :cob_scan),
    do: blocked(s, :cob_work, [:human_frame_unacquired, :landinging_not_acquired])

  def command(_, _), do: {:error, :unsupported_staging_operation}

  defp blocked(s, operation, reasons),
    do:
      {:ok,
       %{
         s
         | notice:
             "BLOCKED #{operation}: #{inspect(reasons)}. Existing material and constitutional standing retained."
       }, :blocked_staging, %{operation: operation, missing: reasons}}

  def materials(s), do: [s.inherited] ++ s.furnished ++ if(s.staged, do: [s.staged], else: [])

  def model(s) do
    controls = Enum.map([s.inherited | s.furnished], & &1.center)

    turns =
      controls
      |> Enum.chunk_every(3, 1, :discard)
      |> Enum.map(fn [a, b, c] ->
        u = M.unit(M.sub(b, a))
        v = M.unit(M.sub(c, b))
        :math.acos(max(-1, min(1, M.dot(u, v)))) * 180 / :math.pi()
      end)

    %{
      version: @version,
      aperture: aperture(),
      materials: materials(s),
      projection: %{
        id: "alongside-shared-projectioning",
        opening: aperture().id,
        material_ids: Enum.map(materials(s), & &1.id),
        relation: "UP FROM HERE OVER ACROSS",
        framing: "six-frame",
        physical_transfer: :unproved
      },
      axle: %{
        id: "angular-registration-axle-candidate",
        points: controls,
        deflections: turns,
        basis: Enum.map([s.inherited | s.furnished], & &1.id),
        status: :registration_control_only,
        occupied_curvature: :unproved,
        lawful_acquisition: :not_attested
      },
      relationships:
        Enum.flat_map(materials(s), fn material ->
          [
            %{subject: material.id, relation: material.relation, object: "HERE / OVER ACROSS"},
            %{subject: material.id, relation: "THROUGH-BY", object: aperture().id}
          ] ++
            if Map.has_key?(material, :alongside) do
              [
                %{
                  subject: material.id,
                  relation: "FROM OVER ACROSS",
                  object: "Projectioning Crossing"
                },
                %{
                  subject: material.id,
                  relation: "STAGED ALONGSIDE",
                  object: material.alongside,
                  lifecycle:
                    if(material.status == :newly_staged,
                      do: :current_staging,
                      else: :inherited_staging_basis
                    )
                }
              ]
            else
              []
            end
        end),
      future_relation: %{
        relation: "FROM DOWN UNDER",
        status: :not_established,
        requires: [:lawfully_acquired_human_frame, :lawful_landinging_acquisition],
        actual_material_ids: []
      },
      work: %{permitted: false, scope: "same acquired six-frame only", actual_cob: nil},
      note:
        "Inherited standing is a stipulated reference fixture; no physical acquisition is attested by this preview."
    }
  end

  # A camera basis rotation about the aperture center, applied at projection time only.
  def project(points, view, regarding) do
    a = -regarding * :math.pi() / 180

    Enum.map_join(points, " ", fn p ->
      [x, y, z] = M.sub(p, aperture().center)
      rotated = [x * :math.cos(a) + z * :math.sin(a), y, -x * :math.sin(a) + z * :math.cos(a)]
      [rx, ry, rz] = rotated

      {u, v} =
        case view do
          "transverse" -> {rz, ry}
          "plan" -> {rx, rz}
          _ -> {rx, ry}
        end

      "#{160 + u * 95},#{140 - v * 95}"
    end)
  end
end
