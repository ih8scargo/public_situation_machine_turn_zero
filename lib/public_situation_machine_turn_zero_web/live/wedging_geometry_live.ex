defmodule PublicSituationMachineTurnZeroWeb.WedgingGeometryLive do
  use PublicSituationMachineTurnZeroWeb, :live_view

  alias PublicSituationMachineTurnZero.Workshop.WedgingGeometry, as: Geometry
  alias PublicSituationMachineTurnZero.Workshop.SnailBody, as: Body

  alias PublicSituationMachineTurnZero.Workshop.{
    SnailWeave,
    SnailWeaveGeometry,
    SnailEmergence,
    SnailNearMonitor,
    SnailGalleryRegistration
  }

  alias PublicSituationMachineTurnZero.Workshop.WedgingRehearsal, as: Rehearsal

  def mount(_, _, socket) do
    {:ok, reset(socket)}
  end

  def handle_event("weave-action", %{"op" => op}, socket) do
    state = socket.assigns.weave_state

    command =
      case op do
        "pull" ->
          {:pull, 0, 1}

        "puff" ->
          :puff

        "brace" ->
          :pull_brace

        "seat" ->
          :seat

        "provide" ->
          :provide

        "register" ->
          case List.last(state["body"]["material"]) do
            nil -> nil
            m -> {:register, m["id"]}
          end

        "settle" ->
          :settle

        "advance" ->
          :advance

        "complete" ->
          :complete

        "point" ->
          :point

        "inkwell" ->
          {:body, :return}

        "withdraw" ->
          {:body, {:withdraw, min(500, 6000 - state["body"]["outstanding"])}}

        "gather" ->
          {:body, {:gather, state["body"]["outstanding"]}}

        _ ->
          nil
      end

    weave_operate(socket, command)
  end

  def handle_event("weave-appoint", %{"office" => o}, socket),
    do: weave_operate(socket, {:appoint, o})

  def handle_event("weave-quill", %{"weave_quill" => %{"text" => text}}, socket),
    do: weave_operate(socket, {:quill, text})

  def handle_event("weave-draft", %{"weave_quill" => %{"text" => text} = p}, socket)
      when byte_size(text) <= 2000,
      do: {:noreply, assign(socket, weave_quill_form: to_form(p, as: :weave_quill))}

  def handle_event("weave-take", %{"weave_take" => p}, socket),
    do:
      weave_operate(
        socket,
        {:take, p["turn"], p["passage"] || "continuous-spooning-scooping", p["mode"], p["human"]}
      )

  def handle_event("gallery-registration-inspect", %{"registration" => params}, socket) do
    case SnailGalleryRegistration.parse(params) do
      {:ok, values} ->
        {:noreply,
         socket |> assign(gallery_parameters: values, gallery_error: nil) |> refresh_weave()}

      {:error, _} ->
        {:noreply,
         assign(socket,
           gallery_error: "Invalid inspection values; original standing is unchanged."
         )}
    end
  end

  def handle_event("gallery-registration-reset", _, socket) do
    {:noreply,
     socket
     |> assign(gallery_parameters: SnailGalleryRegistration.defaults(), gallery_error: nil)
     |> refresh_weave()}
  end

  def handle_event("weave-emergence", %{"emergence" => p}, socket) do
    with {extent, ""} <- Float.parse(p["extent"] || ""),
         {angle, ""} <- Integer.parse(p["quarter_turn"] || ""),
         true <- extent >= 0 && angle in 0..90 && p["candidate"] in ~w(through arrival standing) do
      {:noreply,
       socket
       |> assign(
         emergence_extent: extent,
         emergence_angle: angle,
         emergence_candidate: p["candidate"]
       )
       |> refresh_weave()}
    else
      _ ->
        {:noreply,
         assign(socket, weave_message: "Invalid inspection values; acquired ledger retained.")}
    end
  end

  def handle_event("weave-fresh-inspection", _, socket),
    do:
      {:noreply,
       socket
       |> assign(
         emergence_extent: 0.0,
         weave_message:
           "Fresh-turn postcondition inspected; no RE-STEP performed, inherited material retained."
       )
       |> refresh_weave()}

  def handle_event("weave-view", %{"view" => v}, socket)
      when v in ~w(flat external section plan within ceiling contraption volume groundward),
      do: {:noreply, assign(socket, weave_view: v)}

  def handle_event("weave-interface", %{"mode" => m}, socket) when m in ~w(alongside across) do
    if Enum.any?(socket.assigns.weave_state["turns"], &(&1["status"] == "emplacing")) do
      {:noreply,
       assign(socket,
         weave_message:
           "Affected interface fold held during active em-placementing. Regarding and unrelated local folds remain available."
       )}
    else
      {:noreply,
       socket
       |> assign(
         weave_interface: m,
         weave_view:
           if(socket.assigns.weave_view in ~w(contraption volume groundward),
             do: socket.assigns.weave_view,
             else: "external"
           )
       )
       |> refresh_weave()}
    end
  end

  def handle_event("weave-inspect", %{"weave_inspect" => p}, socket) do
    with {pose, ""} <- Integer.parse(p["pose"] || ""),
         {q, ""} <- Integer.parse(p["quarter"] || ""),
         {look, ""} <- Integer.parse(p["look"] || ""),
         {scrub, ""} <- Float.parse(p["scrub"] || ""),
         true <- pose in 0..90 && q in 0..5 && look in -180..180 && scrub >= 0 && scrub <= 1 do
      allowed = SnailWeave.fold_allowed?(socket.assigns.weave_state, q, pose)
      # A blocked local fold never prevents independent eye movement/scrubbing.
      socket = assign(socket, weave_look: look, weave_scrub: scrub)

      socket =
        if allowed,
          do: assign(socket, weave_pose: pose, weave_quarter: q),
          else:
            assign(socket,
              weave_message:
                "Only the actively emplacing registration is held; eye movement remains independent."
            )

      {:noreply, refresh_weave(socket)}
    else
      _ ->
        {:noreply, assign(socket, weave_message: "Invalid inspection values; standing retained.")}
    end
  end

  def handle_event("weave-export", _, socket),
    do:
      {:noreply,
       push_event(socket, "snail-weave-export", %{
         json: SnailWeave.export(socket.assigns.weave_state)
       })}

  def handle_event("weave-import", %{"weave_witness" => %{"json" => json}}, socket) do
    case SnailWeave.import(json) do
      {:ok, state} ->
        {:noreply,
         socket
         |> assign(
           weave_state: state,
           weave_pose: 90,
           weave_quarter: 0,
           weave_interface: "alongside",
           weave_look: 0,
           weave_scrub: 0.0,
           weave_message: "Integrated ancestry replayed and verified."
         )
         |> refresh_weave()}

      _ ->
        {:noreply,
         assign(socket, weave_message: "Invalid integrated witness; acquired standing retained.")}
    end
  end

  def handle_event("body-view", %{"view" => view}, socket)
      when view in ~w(external reverse section plan within),
      do: {:noreply, assign(socket, body_view: view)}

  def handle_event("body-instrument", _, socket),
    do: {:noreply, assign(socket, body_instrument: !socket.assigns.body_instrument)}

  def handle_event("body-fold", %{"body" => p}, socket) do
    with {fold, ""} <- Integer.parse(p["fold"] || ""),
         {quarter, ""} <- Integer.parse(p["quarter"] || ""),
         true <- fold in 0..90 and quarter in 0..5 do
      {:noreply, socket |> assign(body_fold: fold, body_quarter: quarter) |> refresh_body()}
    else
      _ -> {:noreply, assign(socket, body_message: "Fold rejected; existing standing retained.")}
    end
  end

  def handle_event("body-take", _, socket), do: body_operate(socket, :take)
  def handle_event("body-return", _, socket), do: body_operate(socket, :return)

  def handle_event("body-withdraw", _, socket),
    do:
      body_operate(socket, {:withdraw, min(500, 6000 - socket.assigns.body_state["outstanding"])})

  def handle_event("body-gather", _, socket),
    do: body_operate(socket, {:gather, min(500, socket.assigns.body_state["outstanding"])})

  def handle_event("body-gather-all", _, socket),
    do: body_operate(socket, {:gather, socket.assigns.body_state["outstanding"]})

  def handle_event("body-quill-draft", %{"quill" => params}, socket),
    do: {:noreply, assign(socket, body_quill_form: to_form(params, as: :quill))}

  def handle_event("body-quill", %{"quill" => %{"text" => text}}, socket),
    do: body_operate(socket, {:quill, text})

  def handle_event("body-export", _, socket),
    do:
      {:noreply,
       push_event(socket, "snail-body-export", %{json: Body.export(socket.assigns.body_state)})}

  def handle_event("body-import", %{"body_witness" => %{"json" => json}}, socket) do
    case Body.import(json) do
      {:ok, state} ->
        {:noreply,
         socket
         |> assign(
           body_state: state,
           body_message: "Restored measured line and piece provenance; earlier rounds retained."
         )
         |> refresh_body()}

      _ ->
        {:noreply,
         assign(socket, body_message: "Invalid body witness; existing standing retained.")}
    end
  end

  def handle_event("room-view", %{"view" => mode}, socket)
      when mode in ~w(within plan section external),
      do: {:noreply, assign(socket, view_mode: mode)}

  def handle_event("room-camera", %{"camera" => params}, socket) do
    with {look, ""} <- Float.parse(params["look"] || ""),
         {elevation, ""} <- Float.parse(params["elevation"] || ""),
         {orbit, ""} <- Float.parse(params["orbit"] || ""),
         {zoom, ""} <- Float.parse(params["zoom"] || ""),
         true <-
           abs(look) <= if(socket.assigns.locality == :mouth, do: 22.5, else: 45) &&
             elevation >= 0 && elevation <= 65 && abs(orbit) <= 180 && zoom >= 0.6 && zoom <= 2.4 do
      {:noreply,
       socket
       |> assign(look: look, elevation: elevation, camera_yaw: orbit, camera_zoom: zoom)
       |> refresh()}
    else
      _ ->
        {:noreply,
         assign(socket,
           message: "Camera range rejected; geometry and experimental standing retained."
         )}
    end
  end

  def handle_event("appoint-office", %{"office" => office}, socket)
      when office in ~w(furnishing traversaling),
      do: rehearse(socket, {:appoint, office})

  def handle_event("proposal", %{"candidate" => params} = request, socket) do
    with selected when not is_nil(selected) <- socket.assigns.selected,
         {radius, ""} <- Float.parse(params["radius"] || ""),
         {lift, ""} <- Float.parse(params["lift"] || "") do
      p = %{
        "bay" => selected.id,
        "layout" => params["layout"],
        "radius" => radius,
        "lift" => lift,
        "ordinary_height" => 0.22
      }

      command =
        if request["intent"] == "revise",
          do: {:revise, p, params["purpose"] || ""},
          else:
            {:propose, p, socket.assigns.turn, Atom.to_string(socket.assigns.locality),
             params["purpose"] || ""}

      rehearse(socket, command)
    else
      _ ->
        {:noreply,
         assign(socket,
           message: "Select an available bay and enter bounded candidate dimensions."
         )}
    end
  end

  def handle_event("confirm-pair", _, socket), do: rehearse(socket, :confirm)
  def handle_event("discard-pair", _, socket), do: rehearse(socket, :discard)

  def handle_event("enter-course", %{"pair" => id, "course" => course}, socket),
    do: rehearse(socket, {:enter, id, course})

  def handle_event("travel", %{"travel" => %{"progress" => raw}}, socket) do
    case Float.parse(raw) do
      {t, ""} -> rehearse(socket, {:progress, t})
      _ -> {:noreply, socket}
    end
  end

  def handle_event("travel-step", _, socket) do
    active = socket.assigns.experiment["active"]

    if active,
      do: rehearse(socket, {:progress, min(1, active["progress"] + 0.25)}),
      else: {:noreply, socket}
  end

  def handle_event("show-founding", _, socket),
    do: {:noreply, socket |> assign(view_mode: "plan", camera_zoom: 1.7) |> refresh()}

  def handle_event("export-room", _, socket),
    do:
      {:noreply,
       push_event(socket, "wedging-export", %{json: Rehearsal.export(socket.assigns.experiment)})}

  def handle_event("import-room", %{"witness" => %{"json" => json}}, socket) do
    case Rehearsal.import(json) do
      {:ok, state} ->
        {:noreply,
         socket
         |> assign(
           experiment: state,
           message:
             "Experimental appointments, PITTONING and traversal witnesses restored; production geometry untouched."
         )
         |> refresh()}

      _ ->
        {:noreply,
         assign(socket, message: "Invalid Round Two witness; current experiment retained.")}
    end
  end

  def handle_event("reset", _, socket), do: {:noreply, reset(socket)}

  def handle_event("pivot", %{"step" => step}, socket) when step in ["-1", "1"] do
    turn = Integer.mod(socket.assigns.turn + String.to_integer(step), 4)
    {:noreply, socket |> assign(turn: turn, look: 0) |> refresh()}
  end

  def handle_event("locality", %{"mode" => mode}, socket) when mode in ["mouth", "forward"] do
    locality = if mode == "mouth", do: :mouth, else: :forward
    {:noreply, socket |> assign(locality: locality, look: 0) |> refresh()}
  end

  def handle_event("depth", %{"level" => level}, socket) when level in ~w(0 1 2 3) do
    {:noreply, socket |> assign(depth: String.to_integer(level)) |> refresh()}
  end

  def handle_event("select", %{"bay" => id}, socket) do
    case Enum.find(socket.assigns.bays, &(&1.local and to_string(&1.id) == id)) do
      nil ->
        {:noreply, socket}

      bay ->
        {x, z} = Enum.at(Geometry.outline(), bay.id)
        {u, v} = Enum.at(Geometry.outline(), rem(bay.id + 1, 8))

        angle =
          :math.atan2((x + u) / 2, -(z + v) / 2) * 180 / :math.pi() - socket.assigns.turn * 90

        angle = angle - 360 * :math.floor((angle + 180) / 360)
        {:noreply, socket |> assign(selected: bay, look: max(-45, min(45, angle))) |> refresh()}
    end
  end

  def handle_event("restand", _, socket) do
    {:noreply, assign(socket, standing: socket.assigns.selected || socket.assigns.standing)}
  end

  def handle_event("inspect", _, socket) do
    {:noreply,
     socket
     |> update(:yaw, &Integer.mod(&1 + 45, 360))
     |> update(:camera_yaw, fn v -> if v + 45 > 180, do: v - 315, else: v + 45 end)
     |> refresh()}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  defp weave_operate(socket, c) do
    state = socket.assigns.weave_state

    case SnailWeave.operate(state, state["revision"], c) do
      {:ok, n} ->
        {:noreply,
         socket
         |> assign(
           weave_state: n,
           weave_message: "Witness held with ancestry. Regarding does not acquire standing."
         )
         |> refresh_weave()}

      {:error, why} ->
        {:noreply,
         assign(socket,
           weave_message: "Unavailable: #{why}. Existing standing and material ancestry retained."
         )}
    end
  end

  defp refresh_weave(socket) do
    a = socket.assigns
    s = a.weave_state
    t = List.last(s["turns"])

    base =
      SnailWeaveGeometry.model(
        s,
        a.weave_pose,
        a.weave_quarter,
        a.weave_look,
        a.weave_interface,
        a.weave_scrub
      )

    geometry =
      Map.put(
        base,
        :emergence,
        SnailEmergence.model(
          s,
          base,
          a.emergence_extent,
          a.emergence_angle,
          a.emergence_candidate
        )
      )

    geometry = Map.put(geometry, :near_monitor, SnailNearMonitor.model(s, geometry))

    assign(socket,
      common_material_model:
        PublicSituationMachineTurnZero.Workshop.CommonMaterialRegistration.model(s, geometry),
      weave_model: geometry,
      gallery_model: SnailGalleryRegistration.model(s, geometry, a.gallery_parameters),
      gallery_form: to_form(a.gallery_parameters, as: :registration),
      emergence_form:
        to_form(
          %{
            "extent" => a.emergence_extent,
            "quarter_turn" => a.emergence_angle,
            "candidate" => a.emergence_candidate
          },
          as: :emergence
        ),
      weave_form:
        to_form(
          %{
            "pose" => a.weave_pose,
            "quarter" => a.weave_quarter,
            "look" => a.weave_look,
            "scrub" => a.weave_scrub
          },
          as: :weave_inspect
        ),
      weave_quill_form: Map.get(a, :weave_quill_form, to_form(%{"text" => ""}, as: :weave_quill)),
      weave_take_form:
        to_form(
          %{
            "turn" => t && t["id"],
            "mode" => "rehearsal",
            "human" => "This One Constitutioning Human",
            "passage" => "continuous-spooning-scooping"
          },
          as: :weave_take
        ),
      weave_restore_form: to_form(%{"json" => ""}, as: :weave_witness)
    )
  end

  defp body_operate(socket, command) do
    case Body.operate(socket.assigns.body_state, command) do
      {:ok, state} ->
        {:noreply,
         socket
         |> assign(
           body_state: state,
           body_message: "Pretending witness retained; fixed standing unchanged."
         )
         |> refresh_body()}

      {:error, reason} ->
        {:noreply,
         assign(socket, body_message: "Unavailable: #{reason}. Existing standing retained.")}
    end
  end

  defp refresh_body(socket) do
    assign(socket,
      body_model:
        Body.model(
          socket.assigns.body_state,
          socket.assigns.body_fold,
          socket.assigns.body_quarter
        ),
      body_form:
        to_form(%{"fold" => socket.assigns.body_fold, "quarter" => socket.assigns.body_quarter},
          as: :body
        ),
      body_quill_form:
        to_form(Map.get(socket.assigns, :body_quill_form, %{params: %{"text" => ""}}).params,
          as: :quill
        ),
      body_restore_form: to_form(%{"json" => ""}, as: :body_witness)
    )
  end

  defp rehearse(socket, command) do
    case Rehearsal.operate(
           socket.assigns.experiment,
           socket.assigns.experiment["revision"],
           command
         ) do
      {:ok, state} ->
        {:noreply,
         socket
         |> assign(
           experiment: state,
           message:
             "Experimental witness updated; no protected constitutional operation performed."
         )
         |> refresh()}

      {:error, reason} ->
        {:noreply,
         assign(socket,
           message:
             "Unavailable: #{reason}. Check appointments, local mouths, candidate clearance and the first two returns. Existing standing retained."
         )}
    end
  end

  defp reset(socket) do
    socket
    |> assign(
      turn: 0,
      locality: :forward,
      depth: 2,
      selected: nil,
      standing: nil,
      yaw: 0,
      experiment: Rehearsal.new(),
      weave_state: SnailWeave.new(),
      gallery_parameters: SnailGalleryRegistration.defaults(),
      gallery_error: nil,
      weave_pose: 90,
      weave_quarter: 0,
      weave_look: 0,
      weave_scrub: 0.0,
      weave_view: "flat",
      emergence_extent: 0.0,
      emergence_angle: 90,
      emergence_candidate: "through",
      weave_interface: "alongside",
      weave_message: nil,
      body_state: Body.new(),
      body_view: "external",
      body_fold: 90,
      body_quarter: 0,
      body_instrument: true,
      body_message: nil,
      view_mode: "external",
      look: 0,
      elevation: 18,
      camera_yaw: 35,
      camera_zoom: 1.0,
      message: nil
    )
    |> refresh()
    |> refresh_body()
    |> refresh_weave()
  end

  defp refresh(socket) do
    %{turn: turn, locality: locality, depth: depth, selected: selected} = socket.assigns
    bays = Geometry.bays(turn, locality, depth)
    selected = selected && Enum.find(bays, &(&1.local and &1.id == selected.id))
    state = socket.assigns.experiment

    room =
      Geometry.room(state)
      |> Map.update!(:panels, fn panels ->
        Enum.map(panels, fn p ->
          Map.put(p, :available, Enum.any?(bays, &(&1.id == p.bay && &1.local)))
        end)
      end)

    params =
      if state["proposal"],
        do: state["proposal"]["parameters"],
        else: Geometry.pair_defaults(if(selected, do: selected.id, else: 2 * turn))

    assign(socket,
      bays: bays,
      selected: selected,
      bearing: Geometry.bearing(turn),
      room: room,
      camera_form:
        to_form(
          %{
            "look" => socket.assigns.look,
            "elevation" => socket.assigns.elevation,
            "orbit" => socket.assigns.camera_yaw,
            "zoom" => socket.assigns.camera_zoom
          },
          as: :camera
        ),
      proposal_form:
        to_form(
          Map.put(
            params,
            "purpose",
            if(state["proposal"], do: state["proposal"]["purpose"], else: "")
          ),
          as: :candidate
        ),
      travel_form:
        to_form(%{"progress" => if(state["active"], do: state["active"]["progress"], else: 0)},
          as: :travel
        ),
      import_form: to_form(%{"json" => ""}, as: :witness)
    )
  end

  defp points(vertices), do: Enum.map_join(vertices, " ", fn {x, y} -> "#{x},#{y}" end)

  attr :rest, :global, include: ~w(disabled)
  slot :inner_block, required: true

  defp experiment_button(assigns) do
    ~H"""
    <button
      type="button"
      class={[
        "rounded border border-slate-600 px-3 py-2 text-sm transition hover:border-teal-300 disabled:opacity-40",
        @rest[:"aria-pressed"] == "true" && "bg-teal-900 text-teal-100"
      ]}
      {@rest}
    >{render_slot(@inner_block)}</button>
    """
  end

  defp geometry_ledger(room) do
    Enum.map(room.pairs ++ if(room.proposal, do: [room.proposal], else: []), fn g ->
      courses =
        Map.new(~w(up_over ordinary), fn name ->
          c = g[name]

          {name,
           %{
             length: c.length,
             entrance: c.entrance,
             mouth: c.mouth,
             return: c.return,
             centerline: c.centerline,
             surface: %{
               rings: length(c.rings),
               faces: length(c.faces),
               cross_section_samples: Enum.map([0, 32, 48, 64, 96], &Enum.at(c.rings, &1))
             }
           }}
        end)

      %{
        id: g["id"],
        status: g["status"],
        parameters: g["parameters"],
        clearance: g["clearance"],
        within_reserved: g["within_reserved"],
        courses: courses,
        planes: g["planes"],
        contacts: g["contact_distance"],
        curvature: g["curvature_measurements"],
        inheritance: g["inheritance"]
      }
    end)
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:wedging_geometry} show_navigation={false}>
      <main id="wedging-workshop" class="min-h-screen bg-slate-950 px-5 py-8 text-slate-100">
        <div class="mx-auto max-w-6xl space-y-6">
          <header class="space-y-2">
            <.link navigate={~p"/workshop"} class="text-sm text-teal-300 underline">Existing Workshop</.link>
            <p class="text-xs tracking-widest text-teal-300">
              PUBLIC-SITUATION-MACHINE- · SNAIL HOUSE
            </p>
            <h1 class="text-3xl font-semibold">Wedging Geometry Workshop</h1>
            <.link navigate={~p"/workshop/coming-aboard"} class="text-sm text-teal-300 underline">
              Coming Aboard
            </.link>
            <p class="text-slate-300">
              Zeroeth Bearinging · one continuous Snail House, Human Quilling and Furnishing / Traversaling turn-weaving.
            </p>
          </header>

          <PublicSituationMachineTurnZeroWeb.SnailWeavePanel.panel
            state={@weave_state}
            model={@weave_model}
            form={@weave_form}
            quill_form={@weave_quill_form}
            take_form={@weave_take_form}
            restore_form={@weave_restore_form}
            emergence_form={@emergence_form}
            view={@weave_view}
            interface={@weave_interface}
            message={@weave_message}
          />
          <PublicSituationMachineTurnZeroWeb.CommonMaterialPanel.panel model={@common_material_model} />
          <PublicSituationMachineTurnZeroWeb.SnailGalleryPanel.panel
            model={@gallery_model}
            form={@gallery_form}
            error={@gallery_error}
          />
          <details id="sw-ancestry" phx-mounted={JS.ignore_attributes(["open"])}>
            <summary>
              Retained prior-round witnesses · separate historical ledgers, not current turn acquisition
            </summary>
            <PublicSituationMachineTurnZeroWeb.SnailBodyPanel.panel
              state={@body_state}
              model={@body_model}
              view={@body_view}
              form={@body_form}
              quill_form={@body_quill_form}
              restore_form={@body_restore_form}
              message={@body_message}
              show_instrument={@body_instrument}
            />

            <section id="wgr-workshop" class="wgr-workshop" data-revision={@experiment["revision"]}>
              <p id="wgr-message" role="status">{@message}</p>
              <div class="wgr-views" aria-label="Inspect one shared Snail House geometry">
                <.experiment_button
                  :for={
                    {mode, label} <- [
                      {"within", "FROM WITHIN Gallery"},
                      {"external", "External 3D"},
                      {"plan", "Overhead"},
                      {"section", "Section"}
                    ]
                  }
                  id={"wgr-view-#{mode}"}
                  phx-click="room-view"
                  phx-value-view={mode}
                  aria-pressed={to_string(@view_mode == mode)}
                >{label}</.experiment_button>
              </div>
              <div
                id="wgr-renderer"
                phx-hook="WedgingRoom"
                phx-update="ignore"
                data-room={Jason.encode!(@room)}
                data-view={
                  Jason.encode!(%{
                    mode: @view_mode,
                    turn: @turn,
                    look: @look,
                    elevation: @elevation,
                    orbit: @camera_yaw,
                    zoom: @camera_zoom,
                    selected: @selected && @selected.id
                  })
                }
              >
                <svg
                  id="wgr-scene"
                  viewBox="0 0 1000 650"
                  role="img"
                  aria-label="Shared 3D octagonal framework and paired curved courses"
                ></svg>
              </div>
              <p>
                Gold framework · PSM-supplied candidate surfaces; teal available panels; gold selected panel; violet panels with confirmed experimental relationships. Cyan UP-OVER and amber ordinary course derive from one founding relation. Pink planes / violet support web show geometric tangencies, not verified structural purchase. The tiny octagonal COB/cap marker is an outreading glyph, not a bodily-fit claim.
              </p>
              <.form for={@camera_form} id="wgr-camera-form" phx-change="room-camera">
                <.input
                  field={@camera_form[:look]}
                  type="range"
                  label="Local transverse look (inspection hypothesis; degrees)"
                  min={if @locality == :mouth, do: -22.5, else: -45}
                  max={if @locality == :mouth, do: 22.5, else: 45}
                  step="0.5"
                  class="wgr-range"
                  phx-debounce="150"
                />
                <.input
                  field={@camera_form[:elevation]}
                  type="range"
                  label="Regard outward and UP (degrees)"
                  min="0"
                  max="65"
                  step="1"
                  class="wgr-range"
                  phx-debounce="150"
                />
                <.input
                  field={@camera_form[:orbit]}
                  type="range"
                  label="External camera rotation only (degrees)"
                  min="-180"
                  max="180"
                  step="1"
                  class="wgr-range"
                  phx-debounce="150"
                />
                <.input
                  field={@camera_form[:zoom]}
                  type="range"
                  label="Inspection magnification"
                  min="0.6"
                  max="2.4"
                  step="0.1"
                  class="wgr-range"
                  phx-debounce="150"
                />
              </.form>
              <p>
                Eye [0,0.65,0] and room height 3 are unitless hypotheses anchored to the existing HERE/plan. Local swivel is limited to ±45° (±22.5° for a single mouth). Quarter-turn choices below are candidate resolutions, not proof of unrestricted operational movement.
              </p>
              <div class="wgr-offices">
                <section id="wgr-furnishing-office">
                  <h2>Appoint Furnishing COB</h2><h3>This One Authoring Constitutioning Human</h3><p>
                    UP FROM HERE FOR SITUATIONING, WITH the real Terrestrial Computer.
                  </p><.experiment_button
                    id="wgr-appoint-furnishing"
                    phx-click="appoint-office"
                    phx-value-office="furnishing"
                  >Appoint Stewardly Furnishing Co-Captain COB</.experiment_button><p id="wgr-furnishing-status">
                    {if @experiment["furnishing"],
                      do:
                        "APPOINTED toward Authoring Human; work reaches OVER ACROSS from alongside HERE",
                      else: "Not appointed"}
                  </p>
                </section>
                <section id="wgr-traversaling-office">
                  <h2>Appoint Traversaling COB</h2><h3>
                    This One Pretendinging Constitutioning Human
                  </h3><p>
                    FROM THIS ONE STANDINGING LANDINGING toward furnished Situationing BY WAY OF Traversaling alongside WITH COB.
                  </p><.experiment_button
                    id="wgr-appoint-traversaling"
                    phx-click="appoint-office"
                    phx-value-office="traversaling"
                    disabled={@experiment["confirmed"] == []}
                  >Appoint Stewardly Co-Captain Co-Bobbinning Traversaling Thing</.experiment_button><p id="wgr-traversaling-status">
                    {if @experiment["traversaling"],
                      do: "APPOINTED toward Pretendinging Human",
                      else: "Not appointed; confirmed by-way-of required"}
                  </p>
                </section>
              </div>
              <p>
                Two architectural roles and two offices, not new autonomous Human/COB entities. Eventual shared embodiment remains open. Co-relationing, co-ordinationing, co-operationing and co-officing-er remain differentiated by the appointment ledger.
              </p>
              <section id="wgr-furnishing">
                <h2>Furnish Paired Macaroni · select a local bay below</h2><p id="wgr-selected">
                  Selected: {if @selected, do: "Bay #{@selected.id + 1}", else: "none"}. Available mouths and candidate planes follow the Round One bearing/locality rules.
                </p>
                <div class="wgr-views">
                  <.experiment_button id="wgr-bearing-prev" phx-click="pivot" phx-value-step="-1">Candidate bearing −90°</.experiment_button><.experiment_button
                    id="wgr-bearing-next"
                    phx-click="pivot"
                    phx-value-step="1"
                  >Candidate bearing +90°</.experiment_button><.experiment_button
                    id="wgr-local-mouth"
                    phx-click="locality"
                    phx-value-mode="mouth"
                  >Single facing mouth</.experiment_button><.experiment_button
                    id="wgr-local-forward"
                    phx-click="locality"
                    phx-value-mode="forward"
                  >Forward neighboring mouths</.experiment_button>
                </div>
                <p id="wgr-bearing-context">
                  Candidate bearing context {@turn * 90}°; these are experimental resolution choices, not operational PIVOTING.
                </p>
                <div class="wgr-views" id="wgr-bays">
                  <.experiment_button
                    :for={bay <- @bays}
                    id={"wgr-bay-#{bay.id}"}
                    phx-click="select"
                    phx-value-bay={bay.id}
                    disabled={!bay.local}
                    aria-pressed={to_string((@selected && @selected.id == bay.id) || false)}
                  >Bay {bay.id + 1}{if !bay.local, do: " · unavailable"}</.experiment_button>
                </div>
                <.form for={@proposal_form} id="wgr-proposal-form" phx-submit="proposal">
                  <.input
                    field={@proposal_form[:layout]}
                    type="select"
                    label="Unresolved mouth relationship: compare alternatives explicitly"
                    options={[
                      {"Same panel, vertically differentiated mouths", "same"},
                      {"Neighboring panel clockwise", "next"},
                      {"Neighboring panel counterclockwise", "previous"}
                    ]}
                    class="wgr-input"
                  />
                  <.input
                    field={@proposal_form[:radius]}
                    type="number"
                    label="Tube radius hypothesis (0.025–0.09)"
                    min="0.025"
                    max="0.09"
                    step="0.005"
                    class="wgr-input"
                  />
                  <.input
                    field={@proposal_form[:lift]}
                    type="number"
                    label="UP-OVER height profile (0.7–1.2)"
                    min="0.7"
                    max="1.2"
                    step="0.05"
                    class="wgr-input"
                  />
                  <.input
                    field={@proposal_form[:purpose]}
                    type="textarea"
                    label="Human-authored candidate purpose / held material"
                    maxlength="2000"
                    class="wgr-input"
                  />
                  <div class="wgr-views">
                    <button
                      id="wgr-propose"
                      name="intent"
                      value="propose"
                      disabled={!@experiment["furnishing"] || !@selected || !!@experiment["proposal"]}
                    >Propose paired furnishing</button><button
                      id="wgr-revise"
                      name="intent"
                      value="revise"
                      disabled={!@experiment["proposal"] || !@selected}
                    >Revise selected candidate</button>
                  </div>
                </.form>
                <div :if={@room.proposal} id="wgr-candidate-review">
                  <p>
                    Candidate {@room.proposal["id"]} · surface-clearance lower bound outside shared HERE junction: {Float.round(
                      @room.proposal["clearance"],
                      4
                    )}. Within reserved room/wedge: {to_string(@room.proposal["within_reserved"])}.
                  </p><.experiment_button id="wgr-confirm" phx-click="confirm-pair">Confirm experimental furnishing · enforce clearance</.experiment_button><.experiment_button
                    id="wgr-discard"
                    phx-click="discard-pair"
                  >Remove candidate only</.experiment_button><details open>
                    <summary>Centerline / surface / bearing inheritance, planes and contacts</summary><pre>{Jason.encode!(Map.take(@room.proposal,~w(parameters upper_bay clearance within_reserved inheritance contact_distance curvature_measurements planes)),pretty: true)}</pre>
                  </details>
                </div>
              </section>
              <section id="wgr-traversalings">
                <h2>Inspect Traversalings and Footings</h2><div
                  :for={record <- @experiment["confirmed"]}
                  id={"wgr-confirmed-"<>record["id"]}
                >
                  <strong>{record["id"]} · {record["status"]} · inherits {record["pittoning"]}</strong><div class="wgr-views">
                    <.experiment_button
                      :for={
                        {course, label} <- [
                          {"up_over", "Enter UP-OVER"},
                          {"ordinary", "Enter ordinary elbow"}
                        ]
                      }
                      id={"wgr-enter-#{record["id"]}-#{course}"}
                      phx-click="enter-course"
                      phx-value-pair={record["id"]}
                      phx-value-course={course}
                      disabled={!@experiment["traversaling"]}
                    >{label}</.experiment_button>
                  </div>
                </div>
                <div :if={@experiment["active"]}>
                  <p id="wgr-active">
                    Course {@experiment["active"]["course"]} · progress {@experiment["active"][
                      "progress"
                    ]} · actual point {Jason.encode!(@room.active.point)}. Both return HERE, center height equals tube radius above the existing Ground.
                  </p><.form for={@travel_form} id="wgr-travel-form" phx-change="travel">
                    <.input
                      field={@travel_form[:progress]}
                      type="range"
                      label="Manual distance fraction of actual course length"
                      min="0"
                      max="1"
                      step="0.01"
                      class="wgr-range"
                      phx-debounce="150"
                    />
                  </.form><.experiment_button id="wgr-travel-step" phx-click="travel-step">Move through next quarter of course length</.experiment_button>
                </div>
                <div id="wgr-footings">
                  <article :for={f <- @experiment["footings"]} id={"wgr-footing-#{f["sequence"]}"}>
                    <strong>Little ROUNDING Footing {f["sequence"]} · {f["course"]}</strong><p>
                      {if f["holds_inaugural_office"],
                        do: "FIRST: inherits inaugural PITTONING office",
                        else: "inherits existing founding relation; no new inaugural PITTONING"}
                    </p><details>
                      <summary>Return, office and acquisition witness</summary><pre>{Jason.encode!(f,pretty: true)}</pre>
                    </details>
                  </article>
                </div>
                <p id="wgr-minimum">
                  {if length(@experiment["footings"]) >= 2,
                    do:
                      "Two experimental Footings witnessed. THREE-extent candidate relation is inspectable; RE-STEP remains unperformed.",
                    else:
                      "Complete both inaugural courses to witness the minimum two-Footing / THREE relation."} FOUR is the existing room span; THREE is the pillar-extrema span. No physical Footing spacing or universal contribution law is inferred.
                </p>
              </section>
              <section id="wgr-inheritance">
                <h2>Accrete additional tunnels FROM WITHIN the room</h2><p>
                  After both inaugural returns, return to the Furnishing office, select another available bay and propose. At most four pairs; occupied geometry blocks conflicting candidates. Removing a candidate never removes founding/confirmed standing. No new inaugural PITTONING.
                </p><.experiment_button id="wgr-show-founding" phx-click="show-founding">Recover founding HERE / PITTONING witness</.experiment_button><details
                  id="wgr-founding-ledger"
                  open
                >
                  <summary>One inaugural PITTONING · FROM HERE ALONG THROUGH HERE</summary><pre>{Jason.encode!(@experiment["founding"],pretty: true)}</pre>
                </details>
              </section>
              <details id="wgr-geometry-ledger">
                <summary>
                  Inspect actual centerlines, surface sections, mouth/return elevations and clearance
                </summary><pre>{Jason.encode!(geometry_ledger(@room),pretty: true)}</pre>
              </details>
              <details id="wgr-ledger">
                <summary>
                  Geometry/provenance ledger · inspection camera is not operational state
                </summary><p>
                  Already-standing: original octagon/HERE references. Candidate affordmentings: selected planes and proposal. Appointed: two office bindings. Confirmed: experimental furnishings. Traversaling: actual sampled course/Footing records. Inherited: one founding PITTONING. Hypothetical future: RE-STEP, physical load, final optical/purchase laws.
                </p><pre>{Jason.encode!(@experiment,pretty: true)}</pre>
              </details>
              <div class="wgr-views">
                <.experiment_button id="wgr-export" phx-click="export-room">Download Round Two witness</.experiment_button>
              </div><details>
                <summary>Restore a Round Two witness (camera excluded)</summary><.form
                  for={@import_form}
                  id="wgr-import-form"
                  phx-submit="import-room"
                >
                  <.input
                    field={@import_form[:json]}
                    type="textarea"
                    label="Versioned experimental witness JSON"
                    class="wgr-input"
                  /><button id="wgr-import">Validate and restore experiment</button>
                </.form>
              </details>
            </section>

            <h2 class="text-xl font-semibold">
              Round One · retained plan, local growth and display-only RE-STANDING
            </h2>
            <div class="grid gap-6 lg:grid-cols-[3fr_2fr]">
              <section
                class="rounded-xl border border-slate-700 bg-slate-900 p-4"
                aria-label="Geometry plan"
              >
                <svg
                  id="wg-plan"
                  viewBox="-4.35 -4.35 8.7 8.7"
                  class="mx-auto w-full max-w-[36rem]"
                  role="img"
                  aria-labelledby="wg-plan-title"
                >
                  <title id="wg-plan-title">
                    Snail House plan with octagonal footing course and local wedge growth
                  </title>
                  <g id="wg-inspection" transform={"rotate(#{@yaw})"}>
                    <g
                      :for={bay <- @bays}
                      id={"wg-geometry-#{bay.id}"}
                      data-local={to_string(bay.local)}
                    >
                      <polygon
                        :for={cell <- bay.growth}
                        :if={bay.local}
                        points={points(cell)}
                        fill={if @selected && @selected.id == bay.id, do: "#0f766e", else: "#164e63"}
                        stroke="#67e8f9"
                        stroke-width=".025"
                      />
                      <circle
                        cx={elem(bay.footing, 0)}
                        cy={elem(bay.footing, 1)}
                        r=".075"
                        fill="#fcd34d"
                      />
                    </g>
                    <polygon
                      points={points(Geometry.outline())}
                      fill="none"
                      stroke="#fcd34d"
                      stroke-width=".045"
                    />
                    <path
                      d="M -.65 3.65 L -.45 2 M .65 3.65 L .45 2"
                      fill="none"
                      stroke="#cbd5e1"
                      stroke-width=".035"
                    />
                    <rect
                      x="-.7"
                      y="-.7"
                      width="1.4"
                      height="1.4"
                      fill="none"
                      stroke="#cbd5e1"
                      stroke-width=".03"
                    />
                    <circle r=".48" fill="none" stroke="#5eead4" stroke-width=".035" />
                    <circle
                      r=".2"
                      fill="none"
                      stroke="#cbd5e1"
                      stroke-dasharray=".05 .04"
                      stroke-width=".025"
                    />
                    <circle :for={{x, y} <- Geometry.pillars()} cx={x} cy={y} r=".06" fill="#c4b5fd" />
                    <line
                      x1={-1.5 * elem(@bearing, 1)}
                      y1={1.5 * elem(@bearing, 0)}
                      x2={1.5 * elem(@bearing, 1)}
                      y2={-1.5 * elem(@bearing, 0)}
                      stroke="#f472b6"
                      stroke-width=".028"
                    />
                    <line
                      x1="0"
                      y1="0"
                      x2={2.25 * elem(@bearing, 0)}
                      y2={2.25 * elem(@bearing, 1)}
                      stroke="#f472b6"
                      stroke-dasharray=".11 .06"
                      stroke-width=".045"
                    />
                    <circle
                      :if={@selected}
                      cx={elem(@selected.footing, 0)}
                      cy={elem(@selected.footing, 1)}
                      r=".14"
                      fill="none"
                      stroke="#5eead4"
                      stroke-width=".035"
                    />
                    <g :if={@selected && @depth > 0} id="wg-transfer-witness">
                      <polyline
                        points={
                          points([
                            (@standing && @standing.footing) || {0, 0},
                            @selected.receiving_edge
                          ])
                        }
                        fill="none"
                        stroke="#e9d5ff"
                        stroke-width=".025"
                        stroke-dasharray=".06 .09"
                      />
                      <circle
                        cx={elem(@selected.receiving_edge, 0)}
                        cy={elem(@selected.receiving_edge, 1)}
                        r=".09"
                        fill="none"
                        stroke="#e9d5ff"
                        stroke-width=".03"
                      />
                    </g>
                    <circle
                      :if={@standing}
                      id="wg-standing-marker"
                      cx={elem(@standing.footing, 0)}
                      cy={elem(@standing.footing, 1)}
                      r=".09"
                      fill="#fb7185"
                    />
                  </g>
                </svg>
                <p class="text-sm text-slate-300">
                  Gold · A Little ROUNDING Footings course. Cyan · B accretioning reserves.
                  White square · HERE. Teal circle · THIS ONE STANDINGING LANDINGING.
                  Dashed center · overhead aperture. White lane · approach in plan, with height shown in section. Pink · transverse bearing and forward Regarding ray.
                </p>
              </section>

              <section
                class="space-y-5 rounded-xl border border-slate-700 bg-slate-900 p-5"
                aria-label="Experiment controls"
              >
                <div class="space-y-2">
                  <h2 class="font-semibold">OVER ACROSS Regarding</h2>
                  <p id="wg-bearing" class="text-sm text-slate-300" aria-live="polite">
                    Candidate resolution {@turn + 1} of 4 · {@turn * 90}°
                  </p>
                  <div class="flex flex-wrap gap-2">
                    <.experiment_button id="wg-prev" phx-click="pivot" phx-value-step="-1">Pivot −¼</.experiment_button>
                    <.experiment_button id="wg-next" phx-click="pivot" phx-value-step="1">Pivot +¼</.experiment_button>
                  </div>
                  <div class="flex flex-wrap gap-2">
                    <.experiment_button
                      :for={{mode, label} <- [mouth: "Facing mouth", forward: "Forward side"]}
                      id={"wg-#{mode}"}
                      phx-click="locality"
                      phx-value-mode={mode}
                      aria-pressed={to_string(@locality == mode)}
                    >{label}</.experiment_button>
                  </div>
                  <p class="text-sm text-slate-300">
                    Compare the directly facing bay with every bay whose mouth midpoint lies ahead of the transverse line.
                  </p>
                </div>

                <div class="space-y-2">
                  <h2 class="font-semibold">Accretion generations</h2>
                  <div class="flex gap-2">
                    <.experiment_button
                      :for={level <- 0..3}
                      id={"wg-depth-#{level}"}
                      phx-click="depth"
                      phx-value-level={level}
                      aria-label={"Generation depth #{level}"}
                      aria-pressed={to_string(@depth == level)}
                    >{level}</.experiment_button>
                  </div>
                  <p class="text-sm text-slate-300">
                    Each child pair shares a parent edge, divides it in two, and extends it outward. The gold footing course stays continuous.
                  </p>
                </div>

                <div class="space-y-2">
                  <h2 class="font-semibold">Local selectioning</h2>
                  <div id="wg-local-bays" class="flex flex-wrap gap-2">
                    <.experiment_button
                      :for={bay <- @bays}
                      :if={bay.local}
                      id={"wg-bay-#{bay.id}"}
                      phx-click="select"
                      phx-value-bay={bay.id}
                      aria-pressed={to_string(@selected != nil and @selected.id == bay.id)}
                    >Bay {bay.id + 1}</.experiment_button>
                  </div>
                  <.experiment_button id="wg-restand" phx-click="restand" disabled={is_nil(@selected)}>RE-STAND at selected footing</.experiment_button>
                  <p id="wg-standing" class="text-sm text-slate-300" aria-live="polite">
                    Standing witness · {if @standing, do: "Bay #{@standing.id + 1}", else: "HERE"}
                  </p>
                  <p id="wg-step-comparison" class="text-sm text-slate-300">
                    Hypothetical RE-STEP · select a bay with growth to show the dotted span from the current standing to the first wedge’s outer edge. The span compares endpoints. RE-STANDING places the witness at the inner footing. A future transfer would require a path, clearance, and a receiving support.
                  </p>
                </div>

                <div class="flex flex-wrap gap-2">
                  <.experiment_button id="wg-inspect" phx-click="inspect">Rotate inspection view · {@yaw}°</.experiment_button>
                  <.experiment_button id="wg-reset" phx-click="reset">Reset experiment</.experiment_button>
                </div>
              </section>
            </div>

            <div class="grid gap-4 md:grid-cols-3">
              <section
                :for={{axis, label} <- [y: "Along X", x: "Along Y"]}
                class="rounded-xl border border-slate-700 bg-slate-900 p-4"
              >
                <h2 class="font-semibold">
                  {label} · {length(Geometry.pillar_projection(axis))} apparent pillars
                </h2>
                <svg
                  id={"wg-pillars-#{axis}"}
                  viewBox="-2.1 0 4.2 1.3"
                  class="mt-2 w-full"
                  role="img"
                  aria-label={"Pillar projection #{label}"}
                >
                  <path
                    d="M -2 .18 Q 0 -.05 2 .18 M -2 1.12 H 2"
                    fill="none"
                    stroke="#94a3b8"
                    stroke-width=".025"
                  />
                  <line
                    :for={{offset, count} <- Geometry.pillar_projection(axis)}
                    data-overlap={count}
                    x1={offset}
                    x2={offset}
                    y1=".23"
                    y2="1.12"
                    stroke="#c4b5fd"
                    stroke-width=".09"
                  >
                    <title>{count} physical supports on this sightline</title>
                  </line>
                </svg>
                <p class="text-sm text-slate-300">
                  Fixed orthographic witness through the same four supports.
                </p>
              </section>
              <section class="rounded-xl border border-slate-700 bg-slate-900 p-4">
                <h2 class="font-semibold">Approach to aperture · section</h2>
                <svg
                  id="wg-section"
                  viewBox="0 0 140 62"
                  class="mt-2 w-full"
                  role="img"
                  aria-label="Approach rising to the landing beneath an open roof aperture"
                >
                  <path
                    d="M 4 52 H 21 L 50 39 H 124 M 26 39 Q 40 9 61 9 M 79 9 Q 100 9 116 39"
                    fill="none"
                    stroke="#cbd5e1"
                    stroke-width="2"
                  />
                  <path d="M 61 6 V 14 M 79 6 V 14 M 58 39 H 82" stroke="#5eead4" stroke-width="2" />
                </svg>
                <p class="text-sm text-slate-300">
                  Provisional vertical relationship between approach, landing, and roof opening.
                </p>
              </section>
            </div>

            <p id="wg-pillar-caption">
              This is what happens when you butter both sides with 100% JANUSITE RIBBONATING SUBSTRATIONING INFRASTRUCTIONING.
            </p>
            <aside class="space-y-2 border-t border-slate-700 pt-4 text-sm text-slate-300">
              <p>
                <strong>Demonstrated.</strong>
                Local selection follows the bearing rule. RE-STANDING moves only the standing witness. Inspection rotation moves only the drawing.
              </p>
              <p>
                <strong>Provisional.</strong>
                Quarter-turn stops, local bay rules, and wedge dimensions are candidates. Round One reserves PITTONING and PINNING separately. Round Two furnishes an experimental founding PITTONING witness; physical purchase remains unverified. The quarter-turn selector changes a candidate inspection/bearing hypothesis; it is not operational PIVOTING. Physical travel limits and the eye-to-aperture relation remain open.
              </p>
            </aside>
          </details>
        </div>
      </main>
    </Layouts.app>
    """
  end
end
