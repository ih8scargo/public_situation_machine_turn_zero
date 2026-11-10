defmodule PublicSituationMachineTurnZero.Workshop.SnailFurnishingConstraints do
  @moduledoc "Recovered architectural requirements, not generated solids or new constitutional standing."

  def model(state, geometry) do
    %{
      version: "snail-furnishing-constraints-v1",
      status: "Recovered requirements recorded for review; metric furnishing remains pending.",
      ground: %{
        authority: "Independent architectural Ground; not defined by the Table.",
        world_plane: nil,
        human_standing: "H < G: Human AT the Table at a lower standing level.",
        table_working_surface: "coincident with independently registered Ground G",
        cob_table_contact: "G",
        levels_collapsed: false
      },
      cubical: %{
        side_extents: 6,
        vertical_furnishing:
          "Through wedge UN-FOLDING when the Human comes to stand and HERE is established.",
        visually_scaled_normal_authorized: false,
        unfolding_transform: nil,
        world_vertical_metric: nil,
        here_and_next: geometry.landinging_registration
      },
      contraption: %{
        height_extents: 6,
        unfolded_relations: [
          %{direction: "UP OVER", from: "independent Ground G", extent: 6},
          %{direction: "DOWN UNDER", from: "independent Ground G", extent: 6}
        ],
        combined_object_height: nil,
        note: "Two differentiated six-unit relationships, not a furnished twelve-unit object."
      },
      table: %{
        proposed_diameter_extents: 3,
        plan_center: [0, 0],
        axis_reference: [0, 0, 0],
        working_level: "G",
        world_height: nil,
        thickness: nil,
        cylinder_relation: "central cylinder passes THROUGH",
        inner_profile: nil,
        landinging: false
      },
      cob: %{
        stand_plan_center: [0, 0],
        stand_base: "G",
        stand_top: "G + ONE extent",
        stand_height_extents: 1,
        local_cubical_extents: [1, 1, 1],
        surrounding_cubical_extents: [6, 6, 6],
        local_to_surrounding_frame: nil,
        eye_registration: nil,
        support_profile: nil,
        note:
          "Stand height, local CUBICAL and eye height are distinct. Do not stack two one-unit dimensions into an assumed two-unit body."
      },
      cylinder_interface: %{
        shared_central_axis: true,
        observed_axial_reference: %{
          kind: "zero-width spindle line",
          points: [[0, 0.4, 0], [0, -2.12, 0]]
        },
        cylinder_outer_radius: nil,
        cylinder_inner_profile: nil,
        cylinder_vertical_span: nil,
        stand_solid_profile: nil,
        clearance: nil,
        conditional_conflict:
          "If solid centered components occupy a common axial interval with positive radii, they overlap. A bore, shared support or other interface must be furnished, not presumed.",
        action:
          "STOP before introducing or repositioning solids; missing interface dimensions prevent a physical fit conclusion."
      },
      two_footing_room: %{
        footing_count: 2,
        toward: geometry.landinging_registration.next,
        each_toward_fraction: %{numerator: 1, denominator: 2},
        metric_footing_geometry: nil,
        room_course_registration: nil,
        bugs_per_footing: %{default: 1, reconfigurable: [2, 3], actual_assignments: nil},
        growth_region: %{
          from: 0,
          to: 1,
          locality: "HERE",
          basis: "geometry emerging through folding extents"
        },
        subsequent_accretion_cap: nil,
        note:
          "Footing geometry, Lanterning Bug appointmenting and six-unit extent remain separate. Half TOWARD is not an invented straight three-unit segment.",
        source_records:
          Enum.map(state["footings"], &Map.take(&1, ~w(id turn kind arc address point))),
        source_record_limit:
          "Existing local Scooping Footings are not promoted to a new RE-STEPPING Room or assigned Bugs by this record."
      },
      superseded_previews: [
        "Prescribed 45-degree Craft/orbital relation: angle must now be derived from actual registration.",
        "Normal axis obtained by isotropically scaling the planar HERE square.",
        "COB stand base at Human HERE level and offset from the Table center.",
        "Shared eye height used as evidence of shared standing or new COB eye calibration."
      ],
      conflicts: [
        %{
          id: "unfolding",
          status: "unregistered",
          finding:
            "Current rigid radial fold and planar HERE matrix do not furnish the recovered six-unit normal-axis UN-FOLDING."
        },
        %{
          id: "ground",
          status: "unregistered",
          finding:
            "No Table-coincident independent Ground plane is metrically registered in the Snail frame. The prior annulus at Y=-0.1 cannot be adopted above the current Human reference Y=0 without changing that registration."
        },
        %{
          id: "centered-stand",
          status: "superseded preview",
          finding:
            "Earlier stand base [0.2,0,0] is offset and coplanar with HERE; it is not the recovered centered stand rising one extent FROM Ground."
        },
        %{
          id: "cylinder",
          status: "clearance unresolved",
          finding:
            "A rendered spindle line has no radius or volume. The old annulus opening is not a verified cylinder bore or COB mounting interface."
        },
        %{
          id: "footings",
          status: "correspondence unresolved",
          finding:
            "Existing Footings record completed local turn endpoints, not two registered half-extent furnishings within a recovered RE-STEPPING Room."
        }
      ],
      confirmation:
        "No meshes, registered coordinates, material, Footing records or constitutional operations are changed by this requirements record."
    }
  end
end
