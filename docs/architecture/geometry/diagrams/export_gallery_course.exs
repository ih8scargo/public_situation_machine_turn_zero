alias PublicSituationMachineTurnZero.Workshop.CoBuilding
alias CoBuilding, as: C

pack = fn mesh ->
  vertices=Enum.uniq(mesh.vertices)
  index=vertices |> Enum.with_index() |> Map.new()
  faces=Enum.map(mesh.faces,fn face -> Enum.map(face,&Map.fetch!(index,&1)) end)
  true=Enum.map(faces,fn ids -> Enum.map(ids,&Enum.at(vertices,&1)) end)==mesh.faces
  cells=for cell <- Map.get(mesh,:cells,[]),do: Enum.map(cell.faces,fn face -> Enum.map(face,&Map.fetch!(index,&1)) end)
  %{vertices: vertices,faces: faces,convex_cells: cells}
end
s=C.new();m=C.model(s)
parts=Enum.map(m.parts,fn p ->
  p |> Map.drop([:geometry,:source_geometry,:vertices,:face_normals,:display_geometry])
  |> Map.put(:source_mesh,pack.(p.source_geometry))
  |> Map.put(:pose_mesh,if(p.geometry==p.source_geometry,do: :same_as_source,else: pack.(p.geometry)))
end)
witnesses=for {pose,angle,view} <- [{"flat",0.0,"flat"},{"flat",22.5,"flat"},{"flat",90.0,"flat"},{"road",22.5,"transverse"}] do
  state=%{s | r_pose: pose,door: angle,view: view}
  model=C.model(state);r=C.selected(model,"cb:R")
  %{pose: pose,door_degrees: angle,view: view,source_id: r.source_letter,source_hash: r.source_hash,world_vertices: r.geometry.vertices,visibility: C.visibility(r,state,model),camera: C.camera(state),acquisition: model.acquisition}
end
view_witnesses=for view <- C.views() do
  state=%{s | view: view}
  %{name: view,camera: C.camera(state),source_hash: C.source_digest(C.model(state)),reference_acquisition_delta: 0}
end
trial=C.model(%{s | wedge: 90.0})
trial_b=C.selected(trial,"cb:wedge-B")
payload=%{wedge_trial: %{degrees: 90, interference: trial.clearance.wedge_trial_interference, actual_fold: false, source_hash: trial_b.source_hash, pose_mesh: pack.(trial_b.geometry)},contract: C.contract(),algorithm: C.version(),scope: :co_building_reference_and_rehearsal,unit: "trial extent; no terrestrial manufacturing calibration",
  gallery_course: m.gallery_course, material_lifecycle: m.material_lifecycle, frame: m.frame,zero: m.zero,one: m.one,three: m.three,inherited: m.inherited,parts: parts,clearance: m.clearance,material_sources: m.material_sources,tools: m.tools,
  r_witnesses: witnesses,view_witnesses: view_witnesses,acquisition: m.acquisition,pending: m.pending,readiness: m.readiness,physical_certification: m.physical_certification,
  source_files: Map.new(~w(co_building co_building_geometry gallery_course geometry_exploration here_wedging material_ribbon),fn name ->
    file="lib/public_situation_machine_turn_zero/workshop/#{name}.ex"
    {file,:crypto.hash(:sha256,File.read!(file)) |> Base.encode16(case: :lower)}
  end)}
true=Enum.all?(witnesses,&(&1.source_hash==hd(witnesses).source_hash))
true=Enum.all?(view_witnesses,&(&1.source_hash==hd(view_witnesses).source_hash))
true=m.clearance.wedge_miter_contact_area>0 and not m.clearance.wedge_miter_interference

File.write!(Path.join(__DIR__,"gallery-course-v8-witness.json"),Jason.encode!(payload,pretty: true))
IO.puts("Exported #{length(parts)} finite/reference listings, one-R pose witnesses and #{length(view_witnesses)} invariant Regardings.")
