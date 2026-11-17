alias PublicSituationMachineTurnZero.Workshop.{RoomToyBox,CoBuilding,CoBuildingGeometry,MaterialRibbon}
alias RoomToyBox, as: T
alias CoBuilding, as: C
alias CoBuildingGeometry, as: G
alias MaterialRibbon, as: M
pack = fn mesh ->
  vs=Enum.uniq(mesh.vertices); index=vs |> Enum.with_index() |> Map.new()
  faces=Enum.map(mesh.faces,fn face -> Enum.map(face,&Map.fetch!(index,&1)) end)
  cells=Enum.map(Map.get(mesh,:cells,[]),fn cell -> Enum.map(cell.faces,fn face -> Enum.map(face,&Map.fetch!(index,&1)) end) end)
  %{vertices: vs,faces: faces,convex_cells: cells}
end
s=T.new();m=T.model(s)
source_digest=fn model -> C.digest(Enum.map(model.pieces,&[&1.id,&1.content_hash])) end
pieces=Enum.map(m.pieces,fn p->p |> Map.drop([:geometry,:source_geometry,:display_geometry]) |> Map.put(:source_mesh,pack.(p.source_geometry)) |> Map.put(:pose_mesh,if(p.geometry==p.source_geometry,do: :same_as_source,else: pack.(p.geometry))) end)
views=for view<-T.views() do
 n=T.model(%{s | view: view}); %{view: view,camera: T.camera(%{s | view: view},n),source_digest: source_digest.(n),body_endpoints: n.body_bearing.endpoints,axle: n.zero_one,acquisition: n.acquisition}
end
poses=for travel<-[0.0,0.25,0.5,0.75,1.0], projection<-[false,true] do
 n=T.model(%{s | travel: travel,projection?: projection}); p=Enum.find(n.pieces,&(&1.id=="room:M"))
 %{travel: travel,projection_only: projection,source_identity: p.source_identity,source_hash: p.content_hash,material_mesh: pack.(p.geometry),display_mesh: pack.(p.display_geometry),basis: p.evidence.projection_basis,acquisition: n.acquisition}
end
{_,pinning_succession}=Enum.reduce(1..3,{s,[]},fn n,{state,rows}->
 {:ok,next}=T.change(state,state.revision,{:pin,n}); model=T.model(next)
 r=Enum.find(model.pieces,&(&1.id=="room:R")); tail=Enum.find(model.pieces,&(&1.id=="room:M"))
 row=%{expected_revision: state.revision,command: ["pin",n],event: List.last(next.events),pins: next.pins,
  source_digest: source_digest.(model),R_source: r.source_identity,R_source_hash: r.content_hash,R_pose: pack.(r.geometry),
  M_source: tail.source_identity,M_source_hash: tail.content_hash,M_pose: pack.(tail.geometry),acquisition: model.acquisition}
 {next,rows++[row]}
end)
rejected=for z<-[-4.5,-5.0] do
 lo=[1.5,0,z];hi=[7.5,6,z+6];b=hd(G.sweep([lo,hi],0.08,0.04).cells)
 b=Enum.reduce(0..2,b,fn i,mesh->axis=for j<-0..2,do: if(i==j,do: 1,else: 0);mesh |> G.clip(axis,Enum.at(lo,i)) |> G.clip(M.scale(axis,-1),-Enum.at(hi,i)) end)
 hits=for p<-m.pieces,p.id in ~w(cb:seat cb:seat-back cb:table),G.collision?(b,p.source_geometry),do: p.id
 %{frame: [lo,hi],solid_bearing: pack.(b),interference: hits,accepted: false,acquired_delta: 0}
end
payload=%{contract: T.contract(),digest_profile: C.digest_profile(),unit: "trial extent; degrees",scope: :prospective_material_rehearsal,
 frame: m.frame,zero_one: m.zero_one,foundation: m.foundation,source_registry: m.source_registry,pieces: pieces,controls: T.controls(),stands: m.stands,pins: m.pins,
 containment: m.containment,body_bearing: m.body_bearing,bearing_clearance: m.bearing_clearance,clearance: m.clearance,joining_diagnostics: m.joining_diagnostics,passage_incidence: m.passage_incidence,port_registration: m.port_registration,
 ribbon: Map.drop(m.ribbon,[:geometry]),under_post_vertical_margin_bound: m.under_post_vertical_margin_bound,views: views,M_poses: poses,pinning_succession: pinning_succession,rejected_frame_trials: rejected,
 acquisition: m.acquisition,movements: m.movements,stopped_portions: m.stopped_portions,source_digest: source_digest.(m),
 source_files: Map.new(~w(room_toy_box room_ribbon co_building co_building_geometry material_ribbon),fn name->f="lib/public_situation_machine_turn_zero/workshop/#{name}.ex";{f,:crypto.hash(:sha256,File.read!(f)) |> Base.encode16(case: :lower)} end)}
true=Enum.all?(views,&(&1.source_digest==source_digest.(m)))
true=Enum.all?(m.clearance,fn {_,hit}->not hit end)
true=Enum.all?(m.bearing_clearance,fn {_,hit}->not hit end)
File.write!(Path.join(__DIR__,"room-toy-box-v11-witness.json"),Jason.encode!(payload,pretty: true))
for stage<-m.movements do
 checkpoint=%{main_witness: "room-toy-box-v11-witness.json",main_sha256: :crypto.hash(:sha256,File.read!(Path.join(__DIR__,"room-toy-box-v11-witness.json"))) |> Base.encode16(case: :lower),contract: T.contract(),movement: stage,evidence: Map.take(payload,case stage.id do 1->[:frame,:zero_one,:containment,:body_bearing,:bearing_clearance];2->[:joining_diagnostics,:stopped_portions];3->[:clearance,:ribbon,:under_post_vertical_margin_bound,:port_registration,:pinning_succession,:passage_incidence];4->[:stands,:views,:controls] end),acquisition: m.acquisition}
 File.write!(Path.join(__DIR__,"toybox-movement-#{stage.id}.json"),Jason.encode!(checkpoint,pretty: true))
end
IO.puts("Exported #{length(m.pieces)} material offices, #{length(views)} Regardings, #{length(poses)} same-M poses, and four bounded movement checkpoints.")
