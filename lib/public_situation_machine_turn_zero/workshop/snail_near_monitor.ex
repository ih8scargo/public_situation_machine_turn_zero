defmodule PublicSituationMachineTurnZero.Workshop.SnailNearMonitor do
  @moduledoc "Presentation registrations only. Keeps the source standing, material and acquisition ledger unchanged."
  alias PublicSituationMachineTurnZero.Workshop.Geometry
  alias PublicSituationMachineTurnZero.Architecture.{ApplianceCutaway, CrossingRehearsal}

  def model(state, geometry) do
    registration = geometry.emergence.registration
    monitor = Enum.find(geometry.surfaces, &(&1.id == "ordinary-flat-monitor"))
    [a, b, c, d] = monitor.points
    center = Enum.zip_with(a, c, &((&1 + &2) / 2))
    right = [Enum.at(center, 0) + abs(hd(a) - hd(b)) / 4, Enum.at(center, 1), Enum.at(center, 2)]
    turn = List.last(state["turns"])
    native = ApplianceCutaway.model()

    material =
      if turn && turn["registration"] && "monitor" in turn["registration"]["stages"],
        do: Enum.find(state["body"]["material"], &(&1["id"] == turn["material"])),
        else: nil

    %{
      version: "near-monitor-regarding-v1",
      flat: %{
        plane: monitor,
        center_line: [mid(a, b), mid(c, d)],
        screen_right_basis: [1, 0, 0],
        staging_point: right,
        material: material,
        turn: material && turn["id"],
        basis:
          "Existing explicit monitor-stage registration; positive monitor-local X is display right. No new acquisition or physical relay."
      },
      groundward_check: groundward_check(registration, center, [mid(a, b), mid(c, d)]),
      orientation: [
        %{
          id: "here",
          name: "THIS HERE",
          point: registration.fixed_seat,
          relation:
            "Persistent HERE square; ordinary computering Ground is given, not this inspection boundary."
        },
        %{
          id: "craft",
          name: "Traversaling Craft",
          point: registration.fixed_seat,
          relation:
            "Craft/Seat relationship at HERE. Craft envelope remains unmeasured; marker is a relation, not a new chassis."
        },
        %{
          id: "seat",
          name: "Fixed Traversaling Seat",
          point: registration.fixed_seat,
          relation: "Human UPON the Craft Seat; fixed [0,0,0] inspection datum."
        },
        %{
          id: "eye",
          name: "Seated eye-line",
          point: registration.revised_eye,
          relation: "Human FROM [0,0.63,0]; COB FROM OUT OF the same Seat at common eye height."
        },
        %{
          id: "aperture",
          name: "Groundward aperture",
          point: registration.revised_aperture,
          relation:
            "45° aperture-to-HERE relation; native square opening retained by rigid registration."
        },
        %{
          id: "spiral",
          name: "Spiral FROM DOWN UNDER",
          point: [0.85, -0.55, 0],
          relation:
            "Original spiral address zero; joined to the acquired-source inspection prefix."
        },
        %{
          id: "volume",
          name: "Snail House JANUSITE",
          point: [0, -1.3, 0],
          relation: "Continuous ribbon, not the external cabinet box or a CH/TC CUBICAL."
        },
        %{
          id: "tc",
          name: "TC DOWN UNDER reference",
          point: [0, -2.45, 0],
          relation:
            "Existing computer box center. Its relation to the canonical TC CUBICAL is unregistered; no second Ground or floor is inferred."
        }
      ],
      cubical: %{
        status: "Comparison only: no common CH/TC-to-Snail transform is appointed.",
        earlier_regions: Geometry.regions(%{"tc" => 0, "ch" => 6}),
        earlier_source:
          "Existing /workshop reservations; separate from native Architecture appliance and its cabinet.",
        native_operating_reference: CrossingRehearsal.operating_reference(),
        native_seat: %{
          point: native["reserved_seat"]["point"],
          frame: "appliance-cutaway-v1",
          status: "reserved, not seated"
        },
        snail_seat: registration.fixed_seat,
        snail_computer: %{min: [-0.65, -2.65, -0.45], max: [0.65, -2.25, 0.45]},
        external_boundary: %{
          min: [-1.45, -2.8, -1.45],
          max: [1.45, -0.2, 1.45],
          role: "existing cabinet inspection envelope; neither CH nor TC CUBICAL"
        },
        ground:
          "One given ordinary computering Ground. HERE and table surfaces are not substitute terrestrial Grounds.",
        optical_limit:
          "Native near-aperture cameras establish a presentation grammar, not a calibrated shorter physical relay in the Snail frame."
      },
      ledger: %{
        standing: "All source coordinates, acquisitions and material identities retained.",
        affordmenting:
          "Ordinary monitor, seated bearing, contextual orientation and separate external inspection.",
        outreading: "Source frames and provisional cross-frame incompatibilities exposed.",
        human_laboring: "No new authored material or operation supplied by inspection.",
        confirmationing: "No physical seating or optical fit confirmation.",
        returnability:
          "Return to Flat monitor or any appointed Regarding without changing standing."
      }
    }
  end

  defp groundward_check(registration, center, center_line) do
    seat = registration.fixed_seat
    eye = registration.revised_eye
    aperture = registration.revised_aperture
    y45 = Enum.at(seat, 1) - horizontal_run(center, seat)
    [low, high] = center_line |> Enum.map(&Enum.at(&1, 1)) |> Enum.sort()

    %{
      aperture: aperture,
      monitor_center: center,
      aperture_to_seat_degrees: elevation(aperture, seat),
      aperture_to_eye_degrees: elevation(aperture, eye),
      monitor_to_seat_degrees: elevation(center, seat),
      monitor_to_eye_degrees: elevation(center, eye),
      aperture_lateral_offset: hd(aperture) - hd(seat),
      monitor_lateral_offset: hd(center) - hd(seat),
      monitor_centerline_at_45: [hd(center), y45, Enum.at(center, 2)],
      monitor_45_within_center_line: y45 >= low and y45 <= high
    }
  end

  defp elevation(from, to) do
    :math.atan2(Enum.at(to, 1) - Enum.at(from, 1), horizontal_run(from, to)) *
      180 / :math.pi()
  end

  defp horizontal_run([x, _, z], [tx, _, tz]),
    do: :math.sqrt((tx - x) ** 2 + (tz - z) ** 2)

  defp mid(a, b), do: Enum.zip_with(a, b, &((&1 + &2) / 2))
end
