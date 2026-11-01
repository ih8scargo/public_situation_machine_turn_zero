defmodule PublicSituationMachineTurnZero.TraversalCourseTest do
  use ExUnit.Case, async: true
  alias PublicSituationMachineTurnZero.Architecture, as: A
  alias PublicSituationMachineTurnZero.Architecture.TraversalCourse, as: C

  defp appointed(yaw \\ 18, pitch \\ 9) do
    {:ok, m} = A.operate(A.new(), {:opening_pull, %{"dx" => 10, "dy" => 0}})
    {:ok, m} = A.operate(m, :puff)

    {:ok, m} =
      A.operate(
        m,
        {:opening_feed, %{"yaw" => yaw, "pitch" => pitch, "length" => 2.6, "extension" => 1}}
      )

    {:ok, m} = A.operate(m, :opening_appoint)
    m
  end

  defp op(m, action, revision),
    do: A.operate(m, {:traversal_rehearsal, %{"action" => action, "revision" => revision}})

  test "finite descending banked course starts at the retained Flick purchase and reaches its stable future seat" do
    for {yaw, pitch} <- [{0, 0}, {60, 45}, {-60, -45}] do
      m = appointed(yaw, pitch)
      state = C.model(m)
      course = state["course"]
      assert state["appointed"] == false
      assert course["origin"]["point"] == m.standing["opening_geometry"]["stick"]["cob_center"]
      assert hd(course["samples"])["point"] == course["origin"]["point"]
      assert List.last(course["samples"])["point"] == course["destination"]["point"]
      refute course["destination"]["future_seat_with_cob"]
      assert course["length"] > 12

      assert List.last(course["samples"])["point"] |> Enum.at(1) <
               Enum.at(course["origin"]["point"], 1)

      assert Enum.any?(course["samples"], &(abs(&1["bank"]) > 0.7))
      assert Enum.all?(course["samples"], &(Enum.at(&1["point"], 1) > course["floor_y"]))
      assert length(course["signs"]) == 4

      for [a, b] <- Enum.chunk_every(course["samples"], 2, 1, :discard),
          do: assert(b["distance"] > a["distance"])

      for s <- course["samples"] do
        assert_in_delta Enum.zip_with(s["up"], s["tangent"], &(&1 * &2)) |> Enum.sum(), 0, 1.0e-10
      end
    end
  end

  test "issuance requires appointment, preserves the complete prefix and constitutional provenance, and is bounded" do
    m = appointed()
    source = m.standing
    assert {:error, :unavailable} = op(m, "issue", 0)
    {:ok, m} = op(m, "appoint", 0)
    base = C.model(m)["course"]
    assert {:error, :unavailable} = op(m, "issue", 1)

    m =
      Enum.reduce(1..3, m, fn _, current ->
        before = C.model(current)
        {:ok, authorized} = op(current, "appoint-continuation", before["revision"])
        assert {:error, :unavailable} = op(authorized, "issue", before["revision"])
        {:ok, next} = op(authorized, "issue", before["revision"] + 1)
        after_course = C.model(next)["course"]
        old = before["course"]
        assert Enum.take(after_course["samples"], length(old["samples"])) == old["samples"]
        assert after_course["destination"] == base["destination"]
        assert List.last(after_course["samples"])["point"] == base["destination"]["point"]
        assert List.last(after_course["samples"])["tangent"] == [0, 0, 1]
        assert Map.delete(next.standing, "traversal_rehearsal") == source

        assert Jason.decode!(Jason.encode!(next.standing))["traversal_rehearsal"]["course"][
                 "samples"
               ] == after_course["samples"]

        next
      end)

    assert {:error, :unavailable} = op(m, "appoint-continuation", C.model(m)["revision"])
  end

  test "unfinished and legacy material cannot acquire NAV standing" do
    assert C.model(A.new()) == nil
    assert {:error, :unavailable} = op(A.new(), "appoint", 0)
  end

  test "current seat reservation is beneath the aperture while older appointed courses remain unchanged" do
    m = appointed()
    state = C.model(m)

    old_course =
      state["course"]
      |> Map.put("id", "flick-to-seat-v1")
      |> Map.update!("destination", &Map.put(&1, "future_seat_with_cob", true))

    old_state = state |> Map.put("course", old_course) |> Map.put("appointed", true)
    old = %{m | standing: Map.put(m.standing, "traversal_rehearsal", old_state)}
    assert C.model(old) == old_state
    assert A.restore(old.standing).standing == old.standing

    cutaway =
      PublicSituationMachineTurnZero.Architecture.ApplianceCutaway.model(old_course["floor_y"])

    assert cutaway["reserved_seat"]["point"] == [0, old_course["floor_y"] + 0.35, 0.35]
    assert cutaway["reserved_seat"]["facing"] == [0, 0, 1]
    assert cutaway["reserved_seat"]["source"] == "aperture-available"
    assert cutaway["destination_is_seat"] == false
    assert Jason.decode!(Jason.encode!(cutaway)) == cutaway
  end
end
