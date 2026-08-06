defmodule PublicSituationMachineTurnZero.ParkingingStandRegistryTest do
  use ExUnit.Case, async: false

  alias PublicSituationMachineTurnZero.ParkingingStandRegistry

  setup do
    owner =
      Ecto.Adapters.SQL.Sandbox.start_owner!(PublicSituationMachineTurnZero.Repo, shared: true)

    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(owner) end)
  end

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

  @tag :tmp_dir
  test "imports constitutional history from the former DETS registry", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, "parkinging_stands.dets")
    source_table = :parkinging_stand_registry_import_source
    piece_of_time = ~U[2026-08-05 12:00:00Z]
    later_piece_of_time = DateTime.add(piece_of_time, 60, :second)

    {:ok, ^source_table} = :dets.open_file(source_table, file: String.to_charlist(path))

    :ok =
      :dets.insert(source_table, [
        {:last_number, 40},
        {"000000000038",
         %{
           parkinging_stand: "000000000038",
           shackling_pin: "AAAA BBBB CCCC DDDD",
           ceremony_time: piece_of_time,
           name: "The Imported Situationing",
           pet_name_history: [
             %{name: "The Imported Situationing", furnished_at: later_piece_of_time}
           ],
           appointmentings: %{lanterning: later_piece_of_time},
           earthly_locality: %{
             country: "United States",
             region: "California",
             city: "Oakland",
             visionizing_scope: "city"
           },
           earthly_locality_history: [
             %{
               earthly_locality: %{
                 country: "United States",
                 region: "California",
                 city: "Oakland",
                 visionizing_scope: "city"
               },
               furnished_at: later_piece_of_time
             }
           ]
         }}
      ])

    :ok = :dets.close(source_table)

    assert %{imported: 1, last_number: 40} =
             PublicSituationMachineTurnZero.DetsRegistryImporter.import(path)

    assert {:ok, imported} =
             ParkingingStandRegistry.re_shackle(
               "000000000038",
               "AAAA BBBB CCCC DDDD"
             )

    assert imported.name == "The Imported Situationing"
    assert imported.appointmentings == %{lanterning: later_piece_of_time}
    assert imported.earthly_locality.city == "Oakland"

    next = ParkingingStandRegistry.furnish_leashing("EEEE FFFF 0000 1111", piece_of_time)
    assert next.parkinging_stand == "000000000041"
  end
end
