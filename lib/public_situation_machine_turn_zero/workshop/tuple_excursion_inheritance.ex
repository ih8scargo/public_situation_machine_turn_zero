defmodule PublicSituationMachineTurnZero.Workshop.TupleExcursionInheritance do
  @moduledoc """
  Source-addressed Tuple offices alongside the Toy Box's candidate geometry.

  This registry records material requirements and correspondence obligations.
  It supplies no material mounting, simulated push-off or constitutional operation.
  """
  @source "lib/public_situation_machine_turn_zero_web/live/canonical_tuple_live.ex"
  @authority "docs/architecture/geometry/re-step-wall-canonical-inheritance-2026-11-16.txt"

  def model(toy) do
    stand = fn id -> Enum.find(toy.stands, &(&1.id == id)) end

    %{
      contract: "toybox-tuple-inheritance-2026-11-16.v1",
      geometry_contract: toy.contract,
      entries: [
        entry(
          "tuple:re-step-wall",
          "RE-STEP Wall",
          "FOUR–FIVE Tuple seam",
          "Material purchase and calibration reference for COB Excursioning",
          "canonical_position_five/1",
          %{
            historical_candidate: "RailRecovery.apparatus/0 / RE-STEP-Wall-FOUR",
            historical_frame: "independent recovery frame; mounting unappointed",
            distinct_from: ["room:r-wall", "room:within-u", "regarding plane"]
          }
        ),
        entry(
          "tuple:gimbalizing-piton",
          "Gimbalizing PITON",
          "COB purchase at RE-STEP Wall",
          "Stewardly Captain COB takes purchase THROUGH this PITON FROM the Wall",
          "canonical_position_four/1; canonical_position_five/1",
          %{
            attachment: "COB / RE-STEP Wall purchase interface",
            finite_profile: nil,
            distinct_from: ["three PINNING appointments", "a completed PITTONING purchase"]
          }
        ),
        entry(
          "tuple:purchase-surface-five",
          "Purchase Surface at FIVE",
          "Tuple FIVE",
          "Material receiving purchase TOWARD which COB pushes off FROM the RE-STEP Wall",
          "canonical_position_five/1",
          %{
            material_transform: nil,
            distinct_from: ["toybox:regarding-five", "FIVE camera eye"]
          }
        ),
        entry(
          "toybox:regarding-five",
          "FIVE reciprocal Regarding Stand",
          "Toy Box FIVE",
          "Reciprocal Regarding THROUGH FOUR TOWARD THREE; correspondence with Tuple FIVE",
          "canonical_position_five/1",
          %{
            toybox_source: "RoomToyBox.model/1 / stands FIVE",
            registered_stand: stand.("FIVE"),
            material_equivalence_to_purchase_surface: :unproved,
            distinct_from: ["tuple:purchase-surface-five"]
          }
        ),
        entry(
          "tuple:six-return-reference",
          "SIX return and inherited calibrated reference",
          "Tuple SIX",
          "Retain return, departure/arrival ancestry and inherited calibrated-reference offices",
          "canonical_position_six/1; position-6-description-title",
          %{
            registered_stand: stand.("SIX"),
            reference_arc: "room:six-arc",
            physical_return_join: nil,
            calibrated_transfer_to_toybox: :unproved,
            distinct_from: ["merely projected circle", "newly acquired return"]
          }
        )
      ],
      correspondences: [
        correspondence(
          stand.("FOUR"),
          "tuple:re-step-wall",
          "FOUR Standing Stand corresponds with the FOUR–FIVE material departure seam"
        ),
        correspondence(
          stand.("FIVE"),
          "tuple:purchase-surface-five",
          "FIVE Regarding Stand corresponds with FIVE; it is not the material Purchase Surface"
        ),
        correspondence(
          stand.("SIX"),
          "tuple:six-return-reference",
          "SIX reference-arc Standing Stand retains correspondence with return and calibration"
        )
      ],
      relations: [
        %{
          subject: "Stewardly Captain COB",
          ordered_prepositioning: ["THROUGH", "FROM"],
          instruments: ["tuple:gimbalizing-piton"],
          object: "tuple:re-step-wall",
          office: :taking_purchase,
          status: :canonical_requirement_not_performed
        },
        %{
          subject: "Stewardly Captain COB",
          ordered_prepositioning: ["FROM", "TOWARD"],
          origin: "tuple:re-step-wall",
          object: "tuple:purchase-surface-five",
          office: :push_off_excursioning,
          status: :canonical_requirement_not_performed
        }
      ],
      operation: %{
        push_off: :not_performed,
        re_step: :distinct_protected_operation,
        push_off_alone_permits_re_step: false,
        acquired_delta: 0
      }
    }
  end

  defp entry(id, name, locality, office, source_locality, evidence) do
    %{
      id: id,
      name: name,
      source_identity: id,
      material_office: office,
      standing_locality: %{office: locality, toybox_material_transform: nil},
      bearing: :material_registration_unproved,
      attachment: :material_interface_unproved,
      inheritance: %{
        authority: @authority,
        repository_source: @source,
        source_locality: source_locality
      },
      affordment: :inspection_only,
      regarding: :does_not_replace_material_purchase,
      status: :canonical_office_registered_material_correspondence_yellow,
      geometry: nil,
      evidence: evidence
    }
  end

  defp correspondence(stand, tuple_office, office) do
    %{
      stand: stand,
      tuple_office: tuple_office,
      office: office,
      status: :required_correspondence,
      material_transform: nil,
      physical_equivalence: :unproved
    }
  end
end
