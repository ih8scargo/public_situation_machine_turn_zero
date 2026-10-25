defmodule PublicSituationMachineTurnZero.Architecture.Craft do
  @moduledoc """
  Small ZEROETH craft rehearsal. Poses and grasps are ephemeral; explicit Seat and
  Buckle requests alone may furnish existing domain relations. No overlap test
  or cursor coordinate establishes a receiving relation. This is not a magic hand.
  """
  alias PublicSituationMachineTurnZero.Architecture, as: Lab

  defstruct open?: false,
            box?: false,
            pointer?: false,
            offered: "projected-tc",
            held: nil,
            pointed: nil,
            target: nil,
            x: 315.0,
            y: 385.0,
            turn: 0.0,
            aligned?: false,
            wrapped?: false,
            lifted?: false

  def catalog do
    %{
      "co-bobbing" => %{
        "id" => "co-bobbing",
        "name" => "THIS ONE CO-BOBBING THING",
        "job" =>
          "ATTENDING CO-OFFICINGER STANDING ATTENTIONING TOWARD THIS ONE CONSTITUTIONING HUMAN",
        "kind" => "attending apparatus"
      },
      "co-situationing-doll" => %{
        "id" => "co-situationing-doll",
        "name" => "THIS ONE CO-SITUATIONING DOLL",
        "job" => "Differentiated Doll; not Co-Bobbing",
        "kind" => "reserved apparatus identity"
      },
      "square-buckle" => %{
        "id" => "square-buckle",
        "name" => "THIS ONE SQUARE BUCKLE",
        "job" => "Provisional TC/Chair craft rehearsal",
        "kind" => "craft artifact"
      }
    }
  end

  def register_inventory(standing) do
    additions =
      for {id, label, deps} <- [
            {"projected-tc", "THIS ONE TERRESTRIAL COMPUTER / projected furnishing",
             ["pointing-calibrated"]},
            {"square-buckle", "THIS ONE SQUARE BUCKLE", ["tc-positioned"]}
          ],
          into: %{} do
        {id,
         %{
           "id" => id,
           "label" => label,
           "encounter" => "ZEROETH",
           "aim" => "TC / Little Square Chair craft rehearsal",
           "dependencies" => deps,
           "pretendingable" => true,
           "usingable" => true,
           "job" => "Explicit fixture craft; consequences remain guarded by the domain",
           "provenance" => "Toy craft next-pass print",
           "notes" => "Provisional; not universal Zippering law"
         }}
      end

    Map.put(standing, "toys", Map.merge(additions, standing["toys"]))
  end

  def available?(m), do: m.projection? && !m.flat? && !Lab.stepped?(m) && m.craft.open?

  def graspable?(m, id) do
    toy = m.standing["toys"][id]

    available?(m) && m.craft.pointer? && m.craft.box? &&
      id in ["projected-tc", "square-buckle"] && m.craft.offered == id &&
      toy != nil && toy["encounter"] == "ZEROETH" &&
      (toy["pretendingable"] ||
         (toy["usingable"] && Lab.dependencies_hold?(m, toy["dependencies"])))
  end

  def articulation(m) do
    cond do
      m.craft.held && m.craft.target == "little-square-chair" -> "square"
      m.craft.held -> "grasp"
      graspable?(m, m.craft.pointed) -> "offer"
      true -> "rest"
    end
  end

  def operate(m, :open) do
    if m.projection? && !m.flat? && !Lab.stepped?(m),
      do:
        {:ok,
         %{
           m
           | craft: %{m.craft | open?: !m.craft.open?, held: nil, target: nil, aligned?: false},
             approach: nil,
             approach_depth: 0
         }},
      else: {:error, :labor_locality_required}
  end

  def operate(m, op) do
    if available?(m), do: manipulate(m, op), else: {:error, :labor_locality_required}
  end

  defp manipulate(m, :draw_pointer), do: put_craft(m, %{m.craft | pointer?: true})
  defp manipulate(m, :box), do: put_craft(m, %{m.craft | box?: !m.craft.box?})

  defp manipulate(m, :next_piece) do
    if m.craft.held do
      {:error, :release_first}
    else
      put_craft(m, %{
        m.craft
        | offered:
            if(m.craft.offered == "projected-tc", do: "square-buckle", else: "projected-tc"),
          pointed: nil,
          target: nil,
          aligned?: false,
          turn: 0.0
      })
    end
  end

  defp manipulate(m, {:point, id}) do
    allowed =
      ["projected-tc", "square-buckle", "little-square-chair", "calibration-mark"] ++
        Map.keys(m.standing["materials"])

    if m.craft.pointer? && id in allowed,
      do: put_craft(m, %{m.craft | pointed: id}),
      else: {:error, :draw_pointer_first}
  end

  defp manipulate(m, :calibrate) do
    if m.craft.pointer? && m.craft.pointed == "calibration-mark",
      do: Lab.operate(m, :calibrate),
      else: {:error, :point_at_calibration_mark}
  end

  defp manipulate(m, :grasp) do
    if is_nil(m.craft.held) && graspable?(m, m.craft.pointed) do
      put_craft(m, %{
        m.craft
        | held: m.craft.pointed,
          x: 315.0,
          y: 385.0,
          target: nil,
          aligned?: false,
          lifted?: false
      })
    else
      {:error, :not_furnished_for_grasp}
    end
  end

  defp manipulate(m, :release),
    do: put_craft(m, %{m.craft | held: nil, target: nil, aligned?: false, lifted?: false})

  defp manipulate(%{craft: %{held: nil}}, _), do: {:error, :grasp_first}

  defp manipulate(m, :lift),
    do: put_craft(m, %{m.craft | y: max(160.0, m.craft.y - 35), lifted?: true, aligned?: false})

  defp manipulate(m, {:turn, delta}) when is_number(delta) and delta in [-30, 30] do
    put_craft(m, %{m.craft | turn: normalize(m.craft.turn + delta), aligned?: false})
  end

  defp manipulate(m, {:pose, x, y, turn})
       when is_number(x) and is_number(y) and is_number(turn) do
    # Input only moves a projection. Receiver identity must still be explicitly
    # taken TOWARD, aligned and seated; coordinates never decide those operations.
    put_craft(m, %{
      m.craft
      | x: max(100.0, min(900.0, x)),
        y: max(100.0, min(550.0, y)),
        turn: normalize(turn),
        aligned?: false
    })
  end

  defp manipulate(m, :toward) do
    put_craft(m, %{m.craft | target: "little-square-chair", x: 610.0, y: 320.0, aligned?: false})
  end

  defp manipulate(m, :align) do
    if m.craft.target == "little-square-chair",
      do: put_craft(m, %{m.craft | aligned?: true, turn: 0.0}),
      else: {:error, :take_receiver_toward}
  end

  defp manipulate(m, :seat) do
    if m.craft.held == "projected-tc" && m.craft.target == "little-square-chair" &&
         m.craft.aligned? do
      case Lab.operate(m, :position) do
        {:ok, next} ->
          put_craft(next, %{
            m.craft
            | held: nil,
              aligned?: false,
              target: nil,
              offered: "square-buckle",
              pointed: nil
          })

        error ->
          error
      end
    else
      {:error, :select_and_align_receiver}
    end
  end

  defp manipulate(m, :wrap) do
    if m.craft.held == "square-buckle" && Lab.furnished?(m, "tc-positioned") &&
         m.craft.target == "little-square-chair" do
      put_craft(m, %{m.craft | wrapped?: true})
    else
      {:error, :seated_tc_required_for_wrap}
    end
  end

  defp manipulate(m, :buckle) do
    if m.craft.held == "square-buckle" && m.craft.target == "little-square-chair" &&
         m.craft.aligned? && m.craft.wrapped? do
      case Lab.operate(m, :appoint) do
        {:ok, next} ->
          next =
            update_in(
              next.standing["relations"]["tc-appointed"],
              &Map.put(
                &1,
                "provenance",
                "Human explicitly Buckled the provisional wrapping rehearsal FROM ZEROETH; projected TC stands FOR actual TC. Not a universal Zippering law."
              )
            )

          put_craft(next, %{m.craft | held: nil, target: nil, aligned?: false})

        error ->
          error
      end
    else
      {:error, :wrap_and_align_first}
    end
  end

  defp manipulate(_, _), do: {:error, :unavailable_craft_operation}

  def projection(m) do
    c = m.craft

    %{
      open: c.open?,
      box: c.box?,
      pointer: c.pointer?,
      offered: c.offered,
      held: c.held,
      pointed: c.pointed,
      target: c.target,
      x: c.x,
      y: c.y,
      turn: c.turn,
      aligned: c.aligned?,
      wrapped: c.wrapped?,
      articulation: articulation(m),
      seated: Lab.furnished?(m, "tc-positioned"),
      appointed: Lab.furnished?(m, "tc-appointed"),
      calibrated: Lab.furnished?(m, "pointing-calibrated"),
      nav: m.nav,
      tunnel: Lab.stepped?(m)
    }
  end

  defp put_craft(m, craft), do: {:ok, %{m | craft: craft}}
  defp normalize(n), do: n - :math.floor(n / 360) * 360
end
