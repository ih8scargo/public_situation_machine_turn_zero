defmodule PublicSituationMachineTurnZero.ParkingingStandRegistryTest do
  use ExUnit.Case, async: false

  alias PublicSituationMachineTurnZero.ParkingingStandRegistry

  test "persists sequential Leashings for lawful return" do
    first_pin = "AAAA BBBB CCCC DDDD"
    second_pin = "EEEE FFFF 0000 1111"
    piece_of_time = DateTime.utc_now() |> DateTime.truncate(:second)

    first = ParkingingStandRegistry.furnish_leashing(first_pin, piece_of_time)
    second = ParkingingStandRegistry.furnish_leashing(second_pin, piece_of_time)

    assert first.parkinging_stand =~ ~r/^\d{12}$/
    assert second.parkinging_stand =~ ~r/^\d{12}$/

    assert String.to_integer(second.parkinging_stand) ==
             String.to_integer(first.parkinging_stand) + 1

    assert {:ok, returned} =
             ParkingingStandRegistry.re_shackle(first.parkinging_stand, first_pin)

    assert returned.ceremony_time == piece_of_time
    assert :error = ParkingingStandRegistry.re_shackle(first.parkinging_stand, second_pin)

    assert {:ok, named} =
             ParkingingStandRegistry.furnish_name(
               first.parkinging_stand,
               first_pin,
               "A Persistent Leashing"
             )

    assert named.name == "A Persistent Leashing"

    assert {:ok, renamed} =
             ParkingingStandRegistry.furnish_pet_name(
               first.parkinging_stand,
               first_pin,
               "A Newer Pet Name",
               piece_of_time
             )

    assert Enum.map(renamed.pet_name_history, & &1.name) == [
             "A Newer Pet Name",
             "A Persistent Leashing"
           ]

    assert {:ok, appointed} =
             ParkingingStandRegistry.furnish_appointmenting(
               first.parkinging_stand,
               first_pin,
               :lanterning,
               piece_of_time
             )

    assert appointed.appointmentings == %{lanterning: piece_of_time}

    assert {:ok, located} =
             ParkingingStandRegistry.furnish_earthly_locality(
               first.parkinging_stand,
               first_pin,
               %{country: "US", region: "CA", city: "Oakland"},
               piece_of_time
             )

    assert located.earthly_locality == %{country: "US", region: "CA", city: "Oakland"}
    assert [%{earthly_locality: %{city: "Oakland"}}] = located.earthly_locality_history

    later_piece_of_time = DateTime.add(piece_of_time, 60, :second)

    assert {:ok, relocated} =
             ParkingingStandRegistry.furnish_earthly_locality(
               first.parkinging_stand,
               first_pin,
               %{country: "US", region: "CA", city: "Berkeley"},
               later_piece_of_time
             )

    assert Enum.map(relocated.earthly_locality_history, fn entry ->
             {entry.earthly_locality.city, entry.furnished_at}
           end) == [{"Berkeley", later_piece_of_time}, {"Oakland", piece_of_time}]

    assert {:ok,
            %{
              name: "A Newer Pet Name",
              earthly_locality: %{country: "US", region: "CA", city: "Berkeley"}
            }} =
             ParkingingStandRegistry.re_shackle(first.parkinging_stand, first_pin)
  end
end
