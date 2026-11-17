# Read-only source extraction and small inspection diagnostic; no workshop state is saved.
alias PublicSituationMachineTurnZero.Workshop.{CubicalConstruction, GeometryExploration, HereWedging, JanusiteInheritance, MaterialRibbon, SnailBody, AlongsideStaging, WedgingGeometry}
alias MaterialRibbon, as: M

c = CubicalConstruction.model()
j = JanusiteInheritance.model(JanusiteInheritance.new())
h = HereWedging.model()
native = SnailBody.model(SnailBody.new())
legacy_unit = [[0,0,0],[Enum.max(Enum.map(native.fixed.here,&hd/1))/3,0,0]]
refs = GeometryExploration.references()
get = fn id -> Enum.find(refs, &(&1.id == id)).points end
centroid = fn points -> Enum.reduce(points, [0,0,0], &M.add/2) |> M.scale(1/length(points)) end
inner = Enum.find(native.surfaces, &(&1.id == "inner-aperture"))
pair = CubicalConstruction.material_pair()
origin = h.table
t = M.unit(M.sub(c.fixed_endpoint, [0,0,0]))
b = [0,0,1]
n = M.cross(b,t)
frame = %{origin: origin, along: t, across: b, section_up: n, determinant: M.dot(t,M.cross(b,n)), basis: "derived from fixed global diagonal A; not appointed surface A or Wedge A/B"}
section_min_x = pair |> hd() |> Map.fetch!(:points) |> Enum.map(&hd/1) |> Enum.min()
slice_mid_x = (section_min_x+3)/2
notch = :math.atan2(2.4,slice_mid_x-3)*180/:math.pi()

ray_hit = fn triangle, phi ->
  rad = phi*:math.pi()/180
  dir = [:math.cos(rad),0,:math.sin(rad)]
  [p0,p1,p2] = triangle
  e1 = M.sub(p1,p0); e2 = M.sub(p2,p0)
  q = M.cross(dir,e2); det = M.dot(e1,q)
  if abs(det)<1.0e-10 do
    nil
  else
    v0 = M.sub(origin,p0)
    u = M.dot(v0,q)/det
    cross = M.cross(v0,e1)
    v = M.dot(dir,cross)/det
    distance = M.dot(e2,cross)/det
    if u >= -1.0e-9 and v >= -1.0e-9 and u+v <= 1+1.0e-9 and distance >= 0,
      do: %{point: M.add(origin,M.scale(dir,distance)), distance: distance, barycentric: [1-u-v,u,v]},
      else: nil
  end
end
ray_samples = for phi <- [0.0,90.0,notch,96.0,100.0] do
  %{phi: phi, hits: Enum.flat_map(pair,fn m -> case ray_hit.(m.points,phi) do
    nil -> []
    hit -> [Map.put(hit,:material_id,m.material_id)]
  end end)}
end
letters = Enum.map(j.letters, fn l ->
  f = l.carriage
  %{id: l.id, letter: l.letter, address: l.address, frame: f,
    source_basis_determinant: M.dot(f.tangent,M.cross(f.across,f.normal)),
    wedge: l.wedge, toes: l.toes, loop: l.loop,
    longitudinal: %{leading: hd(l.toes).address, carriage: l.address, trailing: List.last(l.toes).address},
    transverse_road: for({w,d} <- [{-0.5,-0.01},{0.5,-0.01},{0.5,0.01},{-0.5,0.01}], do: M.add(f.point,M.add(M.scale(f.across,w),M.scale(f.normal,d))))}
end)
metrics = %{
  table_normal: [0,1,0], central_aperture_normal: [0,0,1], normals_angle_degrees: 90,
  table_aperture_intersection: [[2.6,3,0],[3.4,3,0]],
  half_table_span: 1.5, central_aperture_radius: 0.4, coplanar_trial_margin: 1.1,
  unit_endpoint_to_three: M.distance(List.last(h.unit.points),origin),
  room_y_range: j.source_line.points |> Enum.map(&Enum.at(&1,1)) |> Enum.min_max() |> Tuple.to_list(),
  whole_legacy_snail_y_range: h.snail.height_range,
  native_inner_center: centroid.(inner.points), native_inner_y_range: Enum.min_max(Enum.map(inner.points,&Enum.at(&1,1))) |> Tuple.to_list(),
  native_annulus_y: -0.1, native_annulus_inner_radius: 0.24, native_annulus_outer_radius: 1.4,
  unit_length: h.unit.length, whole_A_length: M.distance([0,0,0],c.fixed_endpoint),
  legacy_unit_length: M.distance(hd(legacy_unit),List.last(legacy_unit)),
  legacy_unit_common_scale_length: M.distance(hd(legacy_unit),List.last(legacy_unit))*6/1.4,
  legacy_unit_dot_ground_normal: M.dot(M.unit(M.sub(List.last(legacy_unit),hd(legacy_unit))),[0,1,0]),
  current_unit_dot_ground_normal: M.dot(M.unit(M.sub(List.last(h.unit.points),hd(h.unit.points))),[0,1,0]),
  source_notch_phi: notch,
  midsurface_hit_intervals: Enum.map(pair, fn m ->
    z = hd(m.points) |> Enum.at(2)
    %{material_id: m.material_id, interval: [90.0,:math.atan2(z,section_min_x-3)*180/:math.pi()], source_plane: "Y=3; existing triangle midsurface; not occupied/optical clearance"}
  end),
  ray_samples: ray_samples,
  unknowns: %{wedge_A: nil,wedge_B: nil,surface_A: nil,EIGHT_to_outer_panel: nil, eye_TWO_in_v6: nil, reciprocal_FIVE_curve: nil, source_to_three: nil, interpolation_law: nil}
}
world = %{
  frame: %{id: "six-frame", vertices: c.vertices, edges: CubicalConstruction.box_lines(c.vertices)},
  global_A: %{id: "transverse-A", points: [[0,0,0],c.fixed_endpoint]},
  table: %{id: "inherited-table", points: get.("table"), normal: [0,1,0]},
  central_aperture: AlongsideStaging.aperture(),
  horizontal_aperture_reference: %{id: "GeometryExploration:inner-aperture", points: get.("inner-aperture"), normal: [0,1,0]},
  here: %{id: "HERE", points: get.("HERE")}, monitor: %{id: "monitor",points: get.("monitor")},
  seat: %{id: "seated-xt",point: h.seat_point}, unit: h.unit,
  native_unit: %{id: "XT-TO-XT-zero-to-one",points: legacy_unit,source: "SnailEmergence.model/5: half_square/3; native HERE half-square from SnailBody.fixed.here"},
  pair: pair, registry_frame: frame,
  source_curve: %{id: j.source_line.id, material_id: j.id, points: j.source_line.points, cells: j.road.cells, letters: letters, width: j.road.top_to_bottom, thickness: j.road.thickness},
  native_inner: inner, native_table: Enum.filter(native.surfaces,&(&1.kind=="table")),
  outer_outline: %{id: "WedgingGeometry:outline", frame: "unitless-gallery-v1", points: Enum.map(WedgingGeometry.outline(),fn {x,z} -> [x,0,z] end), identity_to_surface_A: nil},
  native_reference_gauge: CubicalConstruction.gauge("SIX"),
  standing: %{actual_footings: c.actual_footings,index: c.acquired_index,next_cursor: c.circuit.next_cursor, craft_receipt: nil},
  offices: %{ft: %{name: "Furnishing Traversaling COB",reference: j.source_line.id,reference_status: "authored candidate source, not occupied COB locality"}, tf: %{name: "Traversaling Furnishing COB", reference: j.source_line.id,actual_locality: nil,receipt: nil}},
  unknown_frames: %{from_here_plane_identity: nil, candidate_monitor_plane: "monitor Z=-1; not identified as Human FROM HERE plane", source_to_current_cubical: nil}
}
sha = fn value -> :crypto.hash(:sha256,value) |> Base.encode16(case: :lower) end
payload = %{scope: "non-operative inspection diagnostic",source_contract: CubicalConstruction.version(),world: world, world_hash: sha.(Jason.encode!(world)),metrics: metrics,
  view_family: "theta=0..45 degrees; U=(cos(theta),sin(theta),0); V=cos(beta)*(-sin(theta),cos(theta),0)+sin(beta)*(0,0,1); beta=25*theta/45 degrees. Orthographic inspection charts, not calibrated seated optics.",
  invariants: %{material_mutation: false,craft_movement: false,new_turns: 0,selection_appointment: false},
  source_hashes: Map.new(~w(cubical_construction geometry_exploration here_wedging janusite_inheritance material_ribbon snail_body snail_gallery_registration snail_emergence snail_near_monitor alongside_staging wedging_geometry),fn name ->
    file = "lib/public_situation_machine_turn_zero/workshop/#{name}.ex"
    {file,sha.(File.read!(file))}
  end)}
# Assertions exercise this diagnostic's geometric basis, not a production mechanism.
true = c.frame.maximum == [6,6,6] and c.acquired_index == 0 and c.circuit.next_cursor == nil
true = abs(M.dot(t,b))<1.0e-12 and abs(M.dot(t,n))<1.0e-12
true = Enum.all?(letters,&(abs(&1.source_basis_determinant+1)<1.0e-10))
true = Enum.count(Enum.at(ray_samples,2).hits)==2 and Enum.count(Enum.at(ray_samples,3).hits)==1
true = hd(metrics.whole_legacy_snail_y_range)>3
json = Jason.encode!(payload,pretty: true)
File.write!(Path.join(__DIR__,"segmentation-inspection.json"),json)
html = File.read!(Path.join(__DIR__,"segmentation-inspection-template.html")) |> String.replace("__SOURCE_PAYLOAD__",Jason.encode!(payload))
File.write!(Path.join(__DIR__,"segmentation-inspection.html"),html)
IO.puts("Exported unchanged source geometry, #{length(letters)} curved letter frames and non-operative selection-ray samples.")
