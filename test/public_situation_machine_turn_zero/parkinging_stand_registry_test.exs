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

    assert {:ok, located} =
             ParkingingStandRegistry.furnish_earthly_locality(
               first.parkinging_stand,
               first_pin,
               %{country: "US", region: "CA", city: "Oakland"}
             )

    assert located.earthly_locality == %{country: "US", region: "CA", city: "Oakland"}

    assert {:ok,
            %{
              name: "A Persistent Leashing",
              earthly_locality: %{country: "US", region: "CA", city: "Oakland"}
            }} =
             ParkingingStandRegistry.re_shackle(first.parkinging_stand, first_pin)
  end
end
