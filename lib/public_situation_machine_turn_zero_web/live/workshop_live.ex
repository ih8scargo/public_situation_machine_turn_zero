defmodule PublicSituationMachineTurnZeroWeb.WorkshopLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.Architecture.ApplianceCutaway
  alias PublicSituationMachineTurnZero.Workshop

  alias Workshop.{
    Geometry,
    Steeling,
    Projection,
    Rehearsal,
    Calibration,
    Inspection,
    Surfacing,
    DrawOut,
    Groundside
  }

  @structural_regards [
    {"front", "TC toward CH"},
    {"reverse", "CH toward TC"},
    {"plan", "Structural plan"},
    {"transverse", "Transverse gallery"},
    {"lower", "Lower region"},
    {"departure", "Along vertical departure"},
    {"reciprocal", "Oblique reciprocal view"},
    {"tunneling", "Tunneling Regarding"},
    {"diorama", "Oblique structural overview"}
  ]

  def mount(_, _, socket) do
    model = Workshop.new()

    {:ok,
     socket
     |> assign(
       model: model,
       structural_regards: @structural_regards,
       surfacing: nil,
       surfacing_baseline: nil,
       pending_surfacing: nil,
       surfacing_selection: "surfacing",
       inspection: nil,
       inspection_baseline: nil,
       pending_inspection: nil,
       calibration: nil,
       calibration_baseline: nil,
       pending_calibration: nil,
       planar_selection: "u-aperture",
       selected: "ch",
       regard: "front",
       draw_out: "original",
       yaw: 0,
       letter_index: 13,
       bearing: "both",
       footing_sequence: 1,
       baseline: nil,
       loaded: "New construction",
       pending_export: nil,
       message: nil,
       upload_form: to_form(%{}, as: :upload),
       import_form: to_form(%{"json" => ""}, as: :witness)
     )
     |> allow_upload(:witness,
       accept: ~w(.json),
       max_entries: 1,
       max_file_size: Workshop.import_limit()
     )
     |> stream_configure(:stations, dom_id: fn station -> "gw-station-#{station["index"]}" end)
     |> stream_configure(:footings, dom_id: fn f -> "gw-footing-#{f["sequence"]}" end)
     |> stream_configure(:surface_material, dom_id: fn r -> "sf-material-#{r["sequence"]}" end)
     |> stream_configure(:console_material, dom_id: fn r -> "sf-inquiry-#{r["sequence"]}" end)
     |> refresh()}
  end

  def handle_event("sf-open", _, socket) do
    if Workshop.legacy?(socket.assigns.model),
      do: {:noreply, socket},
      else:
        {:noreply,
         socket |> assign(surfacing: socket.assigns.surfacing || Surfacing.new()) |> refresh()}
  end

  def handle_event("sf-inspect", %{"key" => key}, socket) do
    if Map.has_key?(Surfacing.registrations(), key),
      do: {:noreply, assign(socket, surfacing_selection: key)},
      else: {:noreply, socket}
  end

  def handle_event("sf-submit", %{"quill" => params} = request, socket) do
    with state when is_map(state) <- socket.assigns.surfacing,
         {revision, ""} <- Integer.parse(params["revision"] || ""),
         {:ok, next} <- Surfacing.operate(state, revision, {:quill, params["text"]}) do
      result =
        case request["intent"] do
          route when route in ~w(staging inquiry) ->
            Surfacing.operate(next, next["revision"], {:route, route})

          "draft" ->
            {:ok, next}

          _ ->
            {:error, :intent}
        end

      surfacing_change(socket, result)
    else
      _ -> surfacing_change(socket, {:error, :invalid})
    end
  end

  def handle_event("sf-revise", %{"id" => id}, socket) do
    if socket.assigns.surfacing,
      do:
        surfacing_change(
          socket,
          Surfacing.operate(
            socket.assigns.surfacing,
            socket.assigns.surfacing["revision"],
            {:revise, id}
          )
        ),
      else: {:noreply, socket}
  end

  def handle_event("sf-new", _, socket) do
    if socket.assigns.surfacing,
      do:
        surfacing_change(
          socket,
          Surfacing.operate(
            socket.assigns.surfacing,
            socket.assigns.surfacing["revision"],
            :new_draft
          )
        ),
      else: {:noreply, socket}
  end

  def handle_event("inspection-stand", %{"index" => raw}, socket) do
    with {index, ""} <- Integer.parse(raw),
         true <- index in Inspection.stands(),
         false <- Workshop.legacy?(socket.assigns.model) do
      state =
        socket.assigns.inspection ||
          Map.put(Inspection.new(socket.assigns.model, index), "overview", %{
            "regarding" => socket.assigns.regard,
            "yaw" => socket.assigns.yaw
          })

      case Inspection.appoint(state, socket.assigns.model, index) do
        {:ok, state} -> {:noreply, socket |> assign(inspection: state) |> refresh()}
        _ -> {:noreply, socket}
      end
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event(
        "inspection-focus",
        _,
        %{assigns: %{model: %{"schema_version" => version}}} = socket
      )
      when version in [1, 2],
      do: {:noreply, socket}

  def handle_event("inspection-focus", %{"locality" => %{"target" => target}}, socket),
    do: handle_event("inspection-focus", %{"target" => target}, socket)

  def handle_event("inspection-focus", %{"target" => target}, socket) do
    state =
      socket.assigns.inspection ||
        Map.put(Inspection.new(socket.assigns.model), "overview", %{
          "regarding" => socket.assigns.regard,
          "yaw" => socket.assigns.yaw
        })

    registry =
      Calibration.registry(socket.assigns.calibration || Calibration.new(), socket.assigns.model)

    case Inspection.focus(state, socket.assigns.model, registry, target) do
      {:ok, state} ->
        {:noreply,
         socket
         |> assign(
           inspection: state,
           planar_selection: String.replace_prefix(target, "plane:", "")
         )
         |> refresh()}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("inspection-controls", %{"regarding" => params}, socket) do
    state = socket.assigns.inspection

    parsed =
      Enum.map(~w(distance orbit elevation turn monitor_offset), fn key ->
        {key, Float.parse(params[key] || "")}
      end)

    with true <- is_map(state),
         {revision, ""} <- Integer.parse(params["revision"] || ""),
         true <- Enum.all?(parsed, fn {_, v} -> match?({_, ""}, v) end) do
      values = Map.new(parsed, fn {k, {v, ""}} -> {k, v} end)
      through = params["through"] == "true"

      values =
        values
        |> Map.put("through", through)
        |> Map.put("treatment", params["treatment"])
        |> Map.update!("monitor_offset", fn v -> if through, do: v, else: max(0.08, v) end)

      inspection_change(
        socket,
        Inspection.change(state, revision, Map.merge(state["parameters"], values))
      )
    else
      _ ->
        {:noreply,
         assign(socket, message: "Inspection control rejected; current standing retained.")}
    end
  end

  def handle_event("inspection-command", %{"command" => command}, socket) do
    state = socket.assigns.inspection

    if state do
      p = state["parameters"]

      result =
        case command do
          "monitor" ->
            Inspection.monitor(state, socket.assigns.model, socket.assigns.inspection_registry)

          "surface_toward" ->
            Inspection.focus(
              state,
              socket.assigns.model,
              socket.assigns.inspection_registry,
              p["target"]
            )

          "surface_along" ->
            Inspection.change(
              state,
              state["revision"],
              Map.merge(p, %{"mode" => "surface_along", "turn" => 0.0})
            )

          "through_aperture" ->
            if get_in(socket.assigns.inspection_instrument, ["target", "source", "kind"]) ==
                 "aperture",
               do:
                 Inspection.change(
                   state,
                   state["revision"],
                   Map.merge(p, %{"mode" => "orbit", "through" => true})
                 ),
               else: {:error, :aperture}

          direction when direction in ~w(previous_letter next_letter) ->
            index =
              case String.split(p["target"], ":") do
                ["letter", raw] -> String.to_integer(raw)
                _ -> p["stand"]
              end

            target = min(25, max(1, index + if(direction == "next_letter", do: 1, else: -1)))

            Inspection.focus(
              state,
              socket.assigns.model,
              socket.assigns.inspection_registry,
              "letter:#{target}"
            )

          "from" ->
            Inspection.change(
              state,
              state["revision"],
              Map.merge(p, %{
                "target" => "letter:#{p["stand"]}",
                "mode" => "along_forward",
                "distance" => 3.0,
                "turn" => 0.0,
                "through" => false,
                "monitor_offset" => max(0.08, p["monitor_offset"])
              })
            )

          mode when mode in ~w(overview along_forward along_backward orbit) ->
            Inspection.change(
              state,
              state["revision"],
              Map.merge(p, %{"mode" => mode, "turn" => 0.0})
              |> then(fn values ->
                if mode in ~w(along_forward along_backward),
                  do: Map.put(values, "target", "letter:#{p["stand"]}"),
                  else: values
              end)
            )

          action when action in ~w(approach withdraw) ->
            key = if p["mode"] == "monitor", do: "monitor_offset", else: "distance"
            low = if p["through"] && key == "monitor_offset", do: -20, else: 0.08
            high = if key == "monitor_offset", do: 120, else: 80

            next =
              if action == "approach",
                do: p[key] - max(0.15, abs(p[key]) * 0.25),
                else: p[key] + max(0.15, abs(p[key]) * 0.25)

            Inspection.change(
              state,
              state["revision"],
              Map.put(p, key, min(high, max(low, next)))
            )

          _ ->
            {:error, :command}
        end

      socket =
        if command == "overview",
          do:
            assign(socket, regard: state["overview"]["regarding"], yaw: state["overview"]["yaw"]),
          else: socket

      inspection_change(socket, result)
    else
      {:noreply, socket}
    end
  end

  def handle_event("furnish-calibration", _, socket) do
    if Workshop.legacy?(socket.assigns.model) || socket.assigns.model["lock"],
      do: {:noreply, socket},
      else: {:noreply, socket |> assign(calibration: Calibration.new()) |> refresh()}
  end

  def handle_event("select-plane", %{"id" => id}, socket),
    do: {:noreply, socket |> assign(planar_selection: id) |> refresh()}

  def handle_event("calibrate", %{"calibration" => params}, socket) do
    parsed =
      Enum.map(Calibration.parameters(), fn {id, _, _, _} ->
        {id, Float.parse(params[id] || "")}
      end)

    with state when is_map(state) <- socket.assigns.calibration,
         {revision, ""} <- Integer.parse(params["revision"] || ""),
         true <- Enum.all?(parsed, fn {_, value} -> match?({_, ""}, value) end),
         values <-
           Map.new(parsed, fn {id, {number, ""}} -> {id, number} end)
           |> Map.merge(Map.take(params, ["axis", "coupling"])),
         {:ok, next} <-
           Calibration.change(state, revision, values, !is_nil(socket.assigns.model["lock"])) do
      {:noreply, socket |> assign(calibration: next, message: nil) |> refresh()}
    else
      _ ->
        {:noreply,
         assign(socket,
           message:
             "Calibration rejected: stale revision, geometric LOCK, limit or parameters outside displayed bounds. Existing witness retained."
         )}
    end
  end

  def handle_event("select", %{"id" => id}, socket) when id in ~w(ch tc central lower),
    do: {:noreply, socket |> assign(selected: id) |> refresh()}

  def handle_event("draw-out", %{"view" => view}, socket)
      when view in ~w(original side tunnel groundside groundside-tunnel groundside-diorama) do
    {:noreply, assign(socket, :draw_out, view)}
  end

  def handle_event("regard", %{"view" => view}, socket)
      when view in ~w(front reverse plan lower transverse departure reciprocal tunneling diorama),
      do:
        {:noreply,
         if(
           (Workshop.legacy?(socket.assigns.model) && view in ~w(tunneling diorama)) ||
             (socket.assigns.model["schema_version"] == 1 &&
                view in ~w(transverse departure reciprocal)) ||
             (socket.assigns.model["schema_version"] == 2 && view in ~w(departure reciprocal)),
           do: socket,
           else: assign(socket, :regard, view)
         )}

  def handle_event("pick-letter", %{"pick" => %{"index" => index}}, socket),
    do: handle_event("select-letter", %{"index" => index}, socket)

  def handle_event("select-letter", %{"index" => index}, socket) do
    case Integer.parse(to_string(index)) do
      {number, ""} when number in 1..25 ->
        {:noreply, socket |> assign(letter_index: number) |> refresh()}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("pivot", %{"inspection" => %{"yaw" => raw}}, socket) do
    case Float.parse(raw) do
      {yaw, ""} when yaw >= -180 and yaw <= 180 ->
        {:noreply, socket |> assign(yaw: yaw) |> refresh()}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("bearing", %{"mode" => mode}, socket) when mode in ~w(vertical oblique both),
    do: {:noreply, assign(socket, :bearing, mode)}

  def handle_event("select-footing", %{"sequence" => sequence}, socket) do
    case Integer.parse(to_string(sequence)) do
      {n, ""} when n in 1..5 -> {:noreply, socket |> assign(footing_sequence: n) |> refresh()}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("rehearse", %{"action" => action, "revision" => raw}, socket) do
    with {revision, ""} <- Integer.parse(raw),
         command when not is_nil(command) <-
           rehearsal_command(action, socket.assigns.letter_index) do
      rehearse(socket, revision, command)
    else
      _ -> {:noreply, assign(socket, :message, "Unavailable rehearsal command.")}
    end
  end

  def handle_event("progress", %{"traversal" => params}, socket) do
    with {revision, ""} <- Integer.parse(params["revision"] || ""),
         {progress, ""} <- Float.parse(params["progress"] || "") do
      rehearse(socket, revision, {:progress, progress})
    else
      _ -> {:noreply, assign(socket, :message, "Enter reference-course progress from 0 to 1.")}
    end
  end

  def handle_event("projection", %{"projection" => params}, socket) do
    with {revision, ""} <- Integer.parse(params["revision"] || ""),
         {x, ""} <- Float.parse(params["oblique_x"] || ""),
         {z, ""} <- Float.parse(params["oblique_z"] || "") do
      operate(socket, revision, {:projection, %{"oblique_x" => x, "oblique_z" => z}})
    else
      _ ->
        {:noreply, assign(socket, :message, "Enter oblique offsets within the displayed bounds.")}
    end
  end

  def handle_event("steeling", %{"steeling" => params}, socket) do
    with {revision, ""} <- Integer.parse(params["revision"] || ""),
         parsed <-
           Enum.map(Steeling.parameters(), fn {id, _, _, _, _} ->
             {id, Float.parse(params[id] || "")}
           end),
         true <- Enum.all?(parsed, fn {_, result} -> match?({_, ""}, result) end) do
      parameters = Map.new(parsed, fn {id, {number, ""}} -> {id, number} end)
      operate(socket, revision, {:steeling, parameters})
    else
      _ ->
        {:noreply,
         assign(
           socket,
           :message,
           "Enter the three structural parameters within the displayed bounds."
         )}
    end
  end

  def handle_event("migrate-legacy", _, socket) do
    case Workshop.migrate_legacy(socket.assigns.model, socket.assigns.regard, socket.assigns.yaw) do
      {:ok, model} ->
        {:noreply,
         socket
         |> assign(
           model: model,
           baseline: nil,
           loaded: "New Assignment 03 construction from legacy source",
           message:
             "Explicit migration: fresh Assignment 03 construction and rehearsal with corrected reservations. Original witness and LOCK are retained verbatim as legacy_source."
         )
         |> refresh()}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("move", %{"carriage" => params}, socket) do
    with {position, ""} <- Float.parse(params["position"] || ""),
         {revision, ""} <- Integer.parse(params["revision"] || ""),
         id when id in ~w(ch tc) <- params["id"] do
      operate(socket, revision, {:move, id, position})
    else
      _ -> {:noreply, assign(socket, :message, "Enter a position from 0 to 12.")}
    end
  end

  def handle_event("construct", %{"action" => action, "revision" => raw}, socket) do
    commands = %{
      "reset" => :reset,
      "lock" => :lock,
      "release" => :release,
      "reset-steeling" => :reset_steeling
    }

    with {revision, ""} <- Integer.parse(raw),
         command when not is_nil(command) <- commands[action],
         do: operate(socket, revision, command),
         else: (_ -> {:noreply, assign(socket, :message, "Unavailable construction command.")})
  end

  def handle_event("export", _, socket) do
    json =
      Workshop.export(
        socket.assigns.model,
        socket.assigns.regard,
        socket.assigns.yaw,
        socket.assigns.bearing,
        socket.assigns.calibration,
        socket.assigns.inspection,
        socket.assigns.surfacing
      )

    filename =
      "workshop-#{socket.assigns.model["construction_id"]}-r#{socket.assigns.model["revision"]}.json"

    {:noreply,
     socket
     |> assign(
       pending_export: socket.assigns.model,
       pending_calibration: socket.assigns.calibration,
       pending_inspection: socket.assigns.inspection,
       pending_surfacing: socket.assigns.surfacing
     )
     |> push_event("workshop-export", %{
       json: json,
       filename: filename,
       revision: socket.assigns.model["revision"]
     })}
  end

  def handle_event("export-complete", %{"revision" => r}, socket) do
    pending = socket.assigns.pending_export

    if pending && pending["revision"] == r do
      {:noreply,
       assign(socket,
         baseline: pending,
         calibration_baseline: socket.assigns.pending_calibration,
         inspection_baseline: socket.assigns.pending_inspection,
         surfacing_baseline: socket.assigns.pending_surfacing,
         pending_export: nil,
         loaded: "Exported #{pending["construction_id"]} / revision #{r}",
         message:
           "JSON download prepared. Keep the downloaded file to preserve this construction."
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("export-failed", _, socket),
    do:
      {:noreply,
       assign(socket, pending_export: nil, message: "Download unavailable. Try exporting again.")}

  def handle_event("import-json", %{"witness" => %{"json" => json}}, socket),
    do: load_witness(socket, json)

  def handle_event("upload-change", _, socket), do: {:noreply, socket}

  def handle_event("import-file", _, socket) do
    results =
      consume_uploaded_entries(socket, :witness, fn %{path: path}, _entry ->
        {:ok, File.read!(path)}
      end)

    case results do
      [json] -> load_witness(socket, json)
      _ -> {:noreply, assign(socket, :message, "Choose a JSON witness file first.")}
    end
  end

  defp surfacing_change(socket, {:ok, state}),
    do:
      {:noreply,
       socket
       |> assign(
         surfacing: state,
         message:
           "Authored witness retained. No Road Stitching, operational questioning or acquisition performed."
       )
       |> refresh()}

  defp surfacing_change(socket, _),
    do:
      {:noreply,
       assign(socket,
         message:
           "Material witness rejected: save within 12,000 UTF-8 bytes, use a nonempty routing text and current revision (300 changes per stand). Existing witnesses retained."
       )}

  defp inspection_change(socket, {:ok, state}),
    do: {:noreply, socket |> assign(inspection: state, message: nil) |> refresh()}

  defp inspection_change(socket, _),
    do:
      {:noreply,
       assign(socket,
         message:
           "Inspection rejected: stale revision, limit or invalid bounds. Architecture unchanged."
       )}

  defp load_witness(socket, json) do
    case Workshop.import(json) do
      {:ok, model, view} ->
        {:noreply,
         socket
         |> assign(
           model: model,
           surfacing: view["surfacing_v1"],
           surfacing_baseline: view["surfacing_v1"],
           inspection: view["inspection_v1"],
           inspection_baseline: view["inspection_v1"],
           calibration: view["calibration_v1"],
           calibration_baseline: view["calibration_v1"],
           regard: view["regarding"],
           yaw: view["yaw"],
           bearing: view["bearing"] || "both",
           baseline: model,
           loaded: "Loaded #{model["construction_id"]} / revision #{model["revision"]}",
           pending_export: nil,
           message: "Witness loaded. Registered geometry and provenance retained.",
           upload_form: to_form(%{}, as: :upload),
           import_form: to_form(%{"json" => ""}, as: :witness)
         )
         |> refresh()}

      _ ->
        {:noreply,
         assign(
           socket,
           :message,
           "Invalid witness. Expected schema 1–3 construction, schema 4 calibration or schema 5 inspection or schema 6 surfacing envelope with intact geometry, provenance and LOCK records (up to 16 MB). Current construction retained."
         )}
    end
  end

  defp operate(socket, revision, command) do
    case Workshop.operate(socket.assigns.model, revision, command) do
      {:ok, model} ->
        {:noreply, socket |> assign(model: model, message: nil) |> refresh()}

      {:error, :stale_revision} ->
        {:noreply,
         assign(
           socket,
           :message,
           "Stale construction revision. Inspect the current arrangement and try again."
         )}

      {:error, :legacy_read_only} ->
        {:noreply,
         assign(
           socket,
           :message,
           "Earlier witness is preserved read-only. Create an Assignment 03 construction explicitly to revise it."
         )}

      {:error, :revision_limit} ->
        {:noreply,
         assign(
           socket,
           :message,
           "This bounded witness has reached its revision limit. Export it before beginning another construction."
         )}

      _ ->
        {:noreply,
         assign(
           socket,
           :message,
           "Arrangement is locked or command unavailable. Release LOCK before revising."
         )}
    end
  end

  defp rehearsal_command("collect", index), do: {:collect, index}
  defp rehearsal_command("reset", _), do: :reset
  defp rehearsal_command(_, _), do: nil

  defp rehearse(socket, revision, command) do
    case Workshop.rehearse(socket.assigns.model, revision, command) do
      {:ok, model} ->
        {:noreply, socket |> assign(model: model, message: nil) |> refresh()}

      {:error, :stale_rehearsal} ->
        {:noreply,
         assign(
           socket,
           :message,
           "Stale rehearsal revision. Inspect the current ledger and try again."
         )}

      {:error, :five_acquired} ->
        {:noreply,
         assign(
           socket,
           :message,
           "Five distinct stations already acquired. Readiness is a rehearsal condition; no RE-STEP was performed."
         )}

      _ ->
        {:noreply,
         assign(
           socket,
           :message,
           "Rehearsal command unavailable. Earlier witnesses are read-only; each run is bounded to 100 changes and 20 archived resets."
         )}
    end
  end

  defp refresh(socket) do
    id = socket.assigns.selected

    registry =
      if socket.assigns.calibration && !Workshop.legacy?(socket.assigns.model),
        do: Calibration.registry(socket.assigns.calibration, socket.assigns.model)

    inspection_registry =
      if !Workshop.legacy?(socket.assigns.model),
        do: registry || Calibration.registry(Calibration.new(), socket.assigns.model)

    instrument =
      if socket.assigns.inspection,
        do:
          Inspection.instrument(
            socket.assigns.inspection,
            socket.assigns.model,
            inspection_registry
          )

    inspection_values =
      if socket.assigns.inspection,
        do:
          Map.put(
            socket.assigns.inspection["parameters"],
            "revision",
            socket.assigns.inspection["revision"]
          ),
        else: %{}

    socket
    |> assign(
      quill_form:
        to_form(
          %{
            "text" =>
              if(socket.assigns.surfacing, do: socket.assigns.surfacing["draft"], else: ""),
            "revision" =>
              if(socket.assigns.surfacing, do: socket.assigns.surfacing["revision"], else: 0)
          },
          as: :quill
        ),
      inquiry_count:
        if(socket.assigns.surfacing,
          do: Enum.count(socket.assigns.surfacing["records"], &(&1["route"] == "inquiry")),
          else: 0
        ),
      inspection_registry: inspection_registry,
      inspection_instrument: instrument,
      regarding_form: to_form(inspection_values, as: :regarding),
      locality_form:
        to_form(
          %{
            "target" =>
              if(socket.assigns.inspection,
                do: socket.assigns.inspection["parameters"]["target"],
                else: "letter:13"
              )
          },
          as: :locality
        ),
      calibration_registry: registry,
      planar_detail:
        if(registry,
          do: Enum.find(registry["items"], &(&1["id"] == socket.assigns.planar_selection))
        ),
      calibration_form:
        to_form(
          if(socket.assigns.calibration,
            do:
              Map.put(
                socket.assigns.calibration["parameters"],
                "revision",
                socket.assigns.calibration["revision"]
              ),
            else: %{}
          ),
          as: :calibration
        ),
      pick_form: to_form(%{"index" => socket.assigns.letter_index}, as: :pick),
      progress_form:
        to_form(
          %{
            "revision" => get_in(socket.assigns.model, ["rehearsal", "revision"]) || 0,
            "progress" => get_in(socket.assigns.model, ["rehearsal", "progress"]) || 0
          },
          as: :traversal
        ),
      projection_form:
        to_form(
          Map.put(
            get_in(socket.assigns.model, ["projection", "parameters"]) || Projection.defaults(),
            "revision",
            socket.assigns.model["revision"]
          ),
          as: :projection
        ),
      selected_footing:
        Enum.find(
          get_in(socket.assigns.model, ["rehearsal", "footings"]) || [],
          &(&1["sequence"] == socket.assigns.footing_sequence)
        ),
      read_only: Workshop.legacy?(socket.assigns.model),
      selected_station:
        Enum.find(
          get_in(socket.assigns.model, ["steeling", "stations"]) || [],
          &(&1["index"] == socket.assigns.letter_index)
        ),
      pivot_form: to_form(%{"yaw" => socket.assigns.yaw}, as: :inspection),
      steeling_form:
        to_form(
          Map.put(
            get_in(socket.assigns.model, ["steeling", "parameters"]) || Steeling.defaults(),
            "revision",
            socket.assigns.model["revision"]
          ),
          as: :steeling
        ),
      move_form:
        to_form(
          %{
            "id" => id,
            "position" => socket.assigns.model["positions"][id] || 0,
            "revision" => socket.assigns.model["revision"]
          },
          as: :carriage
        )
    )
    |> stream(
      :surface_material,
      if(socket.assigns.surfacing, do: socket.assigns.surfacing["records"], else: []),
      reset: true
    )
    |> stream(
      :console_material,
      if(socket.assigns.surfacing,
        do: Enum.filter(socket.assigns.surfacing["records"], &(&1["route"] == "inquiry")),
        else: []
      ),
      reset: true
    )
    |> stream(:stations, get_in(socket.assigns.model, ["steeling", "stations"]) || [],
      reset: true
    )
    |> stream(:footings, get_in(socket.assigns.model, ["rehearsal", "footings"]) || [],
      reset: true
    )
  end

  attr :text, :string, required: true

  defp semantic_text(assigns) do
    ~H"""
    <p class="sf-text">{@text}</p>
    """
  end

  defp draw_out_panel(assigns) do
    assigns =
      assign(
        assigns,
        :witness,
        if(assigns.mode in ~w(side tunnel),
          do: DrawOut.witness(assigns.model, assigns.registry, assigns.mode)
        )
      )

    ~H"""
    <section id="gw-draw-out" class="gw-draw-out" aria-labelledby="gw-draw-out-title">
      <h2 id="gw-draw-out-title">
        Reversible Projectioning comparisons · Crossing remains 6 × 6 × 6
      </h2>
      <div class="gw-selection" role="group" aria-label="Compare Projectioning presentations">
        <button
          :for={
            {mode, label} <- [
              {"original", "Original · six extents"},
              {"groundside-diorama", "Full diorama · LOWER GROUNDSIDE"},
              {"side", "First experiment · draw-out side"},
              {"tunnel", "First experiment · draw-out Tunneling"},
              {"groundside", "Revised · LOWER GROUNDSIDE side"},
              {"groundside-tunnel", "Revised · U-normal Tunneling probe"}
            ]
          }
          id={"gw-draw-out-#{mode}"}
          type="button"
          phx-click="draw-out"
          phx-value-view={mode}
          aria-pressed={to_string(@mode == mode)}
        >{label}</button>
      </div>
      <p :if={@mode == "groundside-diorama"} id="gw-groundside-diorama-reading">
        In the square Regarding below, the dashed wireframe marks a provisional Projectioning
        allowance continuing six extents outward along +X from LOWER. The amber strip is the
        twelve-extent source-field display. The green dotted rectangle is the registered source.
        Existing Craft and acquired marks keep their places. The +X continuation runs parallel
        to the provisional monitor and U aperture planes. Their physical passage and the
        transform from the native Seat frame remain unresolved.
      </p>
      <%= if @mode in ~w(groundside groundside-tunnel) do %>
        <.groundside_panel
          model={@model}
          registry={@registry}
          mode={@mode}
          surfacing={@surfacing}
          seat={@seat}
        />
      <% end %>
      <%= if @witness do %>
        <p>
          Provisional presentation · {@witness.width} registered extents through the Crossing,
          followed by {@witness.width} display extents along the Craft’s +X rehearsal bearing.
          The Snail House Regarding remains available below.
        </p>
        <svg
          id="gw-draw-out-scene"
          viewBox="0 0 640 304"
          role="img"
          aria-label="Registered Crossing and Craft with prospective staging UP OVER"
          data-mode={@mode}
          data-craft={Jason.encode!(@witness.craft_world)}
          data-prospective={Jason.encode!(@witness.prospective_world)}
        >
          <defs>
            <marker
              id="gw-draw-out-arrow"
              markerWidth="7"
              markerHeight="7"
              refX="6"
              refY="3.5"
              orient="auto"
            >
              <path d="M 0,0 L 7,3.5 L 0,7 Z" fill="#825016" />
            </marker>
          </defs>
          <polygon :for={outline <- @witness.outlines} points={outline} class="gw-draw-crossing" />
          <polygon points={@witness.here} class="gw-draw-here">
            <title>HERE · {@witness.here_provenance} · authored standing reference</title>
          </polygon>
          <polygon points={@witness.prospective} class="gw-draw-next">
            <title>NEXT · {@witness.next_provenance} · provisional draw-out</title>
          </polygon>
          <polyline
            points={@witness.up_over}
            class="gw-draw-ray"
            marker-end="url(#gw-draw-out-arrow)"
          />
          <polyline :if={@witness.datum} points={@witness.datum} class="gw-draw-sight" />
          <polyline points={@witness.return} class="gw-draw-ray" marker-end="url(#gw-draw-out-arrow)" />
          <g :for={mark <- @witness.standing} class="gw-draw-standing">
            <title>{mark.id} · {mark.letter} · acquisition {mark.sequence}</title>
            <circle cx={elem(mark.point, 0)} cy={elem(mark.point, 1)} r="5" />
          </g>
          <circle
            cx={elem(@witness.craft, 0)}
            cy={elem(@witness.craft, 1)}
            r="8"
            class="gw-draw-craft"
          />
          <text
            x={elem(@witness.craft, 0) + 11}
            y={elem(@witness.craft, 1) + if(@mode == "tunnel", do: 26, else: -9)}
          >
            Craft / COB
          </text>
          <circle cx={elem(@witness.head, 0)} cy={elem(@witness.head, 1)} r="5" class="gw-draw-head" />
          <text x={elem(@witness.head, 0) - 8} y={elem(@witness.head, 1) - 11} text-anchor="end">
            NEXT head · last
          </text>
          <g :if={@witness.sight}>
            <circle
              cx={elem(@witness.sight, 0)}
              cy={elem(@witness.sight, 1)}
              r="3"
              class="gw-draw-head"
            />
            <text x={elem(@witness.sight, 0) + 11} y={elem(@witness.sight, 1) - 12}>
              Optical vanishing point
            </text>
          </g>
          <text
            :for={{x, {px, py}} <- if(@mode == "side", do: @witness.ticks, else: [])}
            x={px}
            y={py + 24}
            text-anchor="middle"
          >
            X {x}
          </text>
        </svg>
        <ul class="gw-draw-legend">
          <li class="gw-draw-legend-crossing">Blue outline · registered Crossing</li>
          <li class="gw-draw-legend-standing">
            Green · authored HERE reference. Acquired rehearsal marks · {length(@witness.standing)}.
            HERE provenance · {@witness.here_provenance}.
          </li>
          <li class="gw-draw-legend-next">
            Amber · NEXT staging UP OVER. Provenance · {@witness.next_provenance}.
            The sight guide runs from the optical vanishing point through the last head toward the Crossing.
          </li>
        </ul>
        <p>
          The sight guide illustrates last-in, last-unvanishing. The material’s source and acquisition order are retained.
        </p>
      <% else %>
        <p :if={@mode == "original"}>
          Original six-extent presentation. The Flat Page also retains its six-extent presentation.
        </p>
      <% end %>
    </section>
    """
  end

  defp groundside_panel(assigns) do
    assigns =
      assign(
        assigns,
        :g,
        Groundside.witness(
          assigns.model,
          assigns.registry,
          assigns.mode,
          assigns.surfacing,
          assigns.seat
        )
      )

    ~H"""
    <section id="gw-groundside" aria-label="Revised lower Groundside presentation">
      <h3>LOWER STAGING GROUNDSIDE · TWO × SIX presentation only</h3>
      <p id="gw-groundside-scope">
        Crossing X=12–18 remains 6 × 6 × 6. Only the lower source-field copy reaches X=12–24 at Y=-3; Ground remains Y=-6. No Craft or Seat movement.
      </p>
      <p id="gw-groundside-provisional">
        PROVISIONAL optical relay / U-normal probe. The +X Craft course and +Z U aperture are distinct. The source Y=-3 / Ground Y=-6 Resolutioning relation, native Seat transform, seating eye/pivot and source-window pinning remain unappointed. This is not an established seated view.
      </p>
      <svg
        id="gw-groundside-scene"
        viewBox="0 0 800 480"
        role="img"
        aria-label="Lower-source twelve-extent presentation with a distinct U aperture and candidate window"
        data-mode={@mode}
        data-source={Jason.encode!(@g.source_world)}
        data-strip={Jason.encode!(@g.strip_world)}
        data-window={Jason.encode!(@g.window_world)}
        data-rail-cage={Jason.encode!(@g.rail_cage_world)}
        data-aperture={Jason.encode!(@g.aperture_world)}
        data-craft={Jason.encode!(@g.craft_world)}
        data-eye={Jason.encode!(@g.probe_eye)}
      >
        <defs>
          <marker
            id="gs-static-arrow"
            markerWidth="6"
            markerHeight="6"
            refX="5"
            refY="3"
            orient="auto"
          >
            <path d="M0,0 L6,3 L0,6 Z" fill="#a06a1b" />
          </marker>
        </defs>
        <polygon :for={points <- @g.crossing} points={points} class="gs-crossing" />
        <polygon :for={points <- @g.lower} points={points} class="gs-lower" />
        <polyline points={@g.ground} class="gs-ground" />
        <polygon points={@g.strip_screen} class="gs-strip" />
        <polygon points={@g.source_screen} class="gs-source" />
        <polygon points={@g.window_screen} class="gs-window" />
        <polygon points={@g.far_screen} class="gs-window" />
        <polyline :for={points <- @g.rays} points={points} class="gs-rays" />
        <polyline points={@g.source_to_window} class="gs-source-map" />
        <polyline :for={points <- @g.rail_cage_screen} points={points} class="gs-rail-cage">
          <title>
            Existing one-extent U13 rail cage; not assumed identical to calibration aperture
          </title>
        </polyline>
        <polygon points={@g.aperture_screen} class="gs-aperture">
          <title>
            Existing provisional CALIBRATION U aperture; candidate window follows this frame only
          </title>
        </polygon>
        <polyline points={@g.up_over} class="gs-up-over" />
        <g :for={f <- @g.standing} class="gs-standing">
          <title>{f.id} · acquisition {f.sequence}</title><circle
            cx={elem(f.screen, 0)}
            cy={elem(f.screen, 1)}
            r="4"
          /><text x={elem(f.screen, 0) + 6} y={elem(f.screen, 1) + 17}>{f.letter}{f.sequence}</text>
        </g>
        <g
          :for={t <- @g.tokens}
          class="gs-token"
          data-index={t.index}
          data-material={t.material_id}
          data-world={Jason.encode!(t.world)}
        >
          <title>
            Human-authored {t.material_id} · original index {t.index} · static unvanishing rank {t.unvanishing_rank}
          </title><text x={elem(t.screen, 0)} y={elem(t.screen, 1)}>
            {if String.trim(t.text) == "", do: "·", else: t.text}
          </text>
        </g>
        <polyline
          :if={@g.vanishing_guide}
          points={@g.vanishing_guide}
          class="gs-unvanishing"
          marker-end="url(#gs-static-arrow)"
        >
          <title>Static head direction FROM optical vanishing; no emergence event performed</title>
        </polyline>
        <g class="gs-craft">
          <circle cx={elem(@g.craft_screen, 0)} cy={elem(@g.craft_screen, 1)} r="7" /><text
            x={if @mode == "groundside-tunnel", do: 25, else: elem(@g.craft_screen, 0) + 10}
            y={if @mode == "groundside-tunnel", do: 452, else: elem(@g.craft_screen, 1) - 8}
          >
            Craft/COB · unchanged reference
          </text>
        </g>
        <g :if={@g.vanishing_point}>
          <circle cx="400" cy="215" r="3" class="gs-vanish" /><text x="25" y="426">
            Optical vanishing direction · no new zero
          </text>
        </g>
        <text
          :for={{x, {px, py}} <- if(@mode == "groundside", do: @g.ticks, else: [])}
          x={px}
          y={py + 23}
        >
          X {x}
        </text>
        <text :if={@mode == "groundside"} x="25" y="32">
          SIDE · lower source and two-SIX field, not a stretched Crossing
        </text>
        <text :if={@mode == "groundside-tunnel"} x="25" y="32">
          TUNNELING · U-derived probe, not the unregistered Seat transform
        </text>
      </svg>
      <p>
        U aperture plane Z=0; candidate window plane Z=6. The probe's matching angular borders do not make them one physical plane. The rail cage is not asserted to be the calibration aperture; the inner U opening remains unresolved. This relay is a hypothesis, not an established Seat/window pin.
      </p>
      <ul class="gs-legend">
        <li>
          Blue: unchanged registered Crossing. Green: actual lower source / acquired Footing references.
        </li><li>
          Amber: lower-field twelve-extent display copy and prospective Human material. Purple: provisional calibration U aperture. Thin purple: existing one-extent U13 rail cage. Dashed violet: separate candidate window behind the calibration aperture.
        </li><li>
          Prospective glyphs stand UP OVER the acquired vertical witnesses; the lower source itself stays at Y=-3. The first experiment’s upper NEXT copy remains in its separate comparison.
        </li>
      </ul>
      <p :if={!@g.record} id="gw-groundside-empty">
        No routed Human staging material is furnished. Save a STAGING FOR STANDING witness at the Surfacing Stand to inspect its original sequence here. Outlines are field guides, not invented authored content.
      </p>
      <div :if={@g.record} id="gw-groundside-material">
        <strong>Human staging witness · {@g.record["id"]}</strong><p class="gs-authored">
          {@g.record["text"]}
        </p><p>
          LAST IN, LAST UNVANISHING. Head index 1 is the nearer first-in; newer indices remain farther toward the vanishing direction. Showing up to 12 original indices of {@g.token_count}; full text/provenance retained. No time-based emergence or acquired standing is performed.
        </p>
      </div>
      <details id="gw-groundside-relations" open>
        <summary>Actual source, candidate field and missing U/window/Seat relationship</summary><pre>{Jason.encode!(%{relations: @g.relations,source: @g.source,aperture: @g.aperture_record,probe_eye: @g.probe_eye,probe_direction: @g.probe_direction,window_world: @g.window_world,native_seat: @g.native_seat},pretty: true)}</pre>
      </details>
    </section>
    """
  end

  def render(assigns) do
    assigns = assign(assigns, :seat_reserve, ApplianceCutaway.model()["reserved_seat"])

    ~H"""
    <Layouts.app flash={@flash} active_locality={:workshop} show_navigation={false}>
      <main id="geometric-workshop" class="gw" data-revision={@model["revision"]}>
        <header class="gw-header">
          <div>
            <p class="gw-eyebrow">
              PUBLIC-SITUATION-MACHINE- / CONSTRUCTION 04 · LOCKED U / QUARTER-TURN CALIBRATION
            </p><h1>
              Geometric workshop
            </h1><p>THE PUBLIC SITUATION MACHINE · structural index · SEEING THROUGHING</p>
          </div>
          <.link navigate={~p"/"} id="gw-exit" class="gw-link">Return to landing
          <.icon name="hero-arrow-up-right" class="size-4" /></.link>
        </header>
        <section class="gw-status" aria-label="Construction status">
          <span id="gw-witness-status">{@loaded}</span>
          <strong id="gw-dirty">{if @baseline == @model && @calibration_baseline == @calibration &&
                                      @inspection_baseline == @inspection &&
                                      @surfacing_baseline == @surfacing,
                                    do:
                                      "No unexported construction / rehearsal / calibration changes",
                                    else: "Unexported construction / rehearsal / calibration changes"}</strong>
          <span id="gw-lock-status">{if @model["lock"],
            do: "LOCKED · revision #{@model["revision"]}",
            else: "Unlocked · revision #{@model["revision"]}"}</span>
        </section>
        <p :if={@message} id="gw-message" role="status" class="gw-message">{@message}</p>
        <section :if={@read_only} id="gw-legacy" class="gw-message">
          Earlier schema-1/2 witness: its geometry, provenance and LOCK are preserved read-only. No rehearsal or projection apparatus has been silently added.
          <button id="gw-migrate" phx-click="migrate-legacy">Create Assignment 03 construction; retain original witness</button>
        </section>
        <p :if={!@read_only} id="gw-assembly-name" class="gw-assembly-name">
          {@model["assembly"]["name"]} · eighteen extents. Projectioning Crossing is the architectural center at X=12–18.
        </p>
        <section :if={!@read_only} id="sf-workshop" class="sf-workshop">
          <header class="sf-heading">
            <div>
              <p class="gw-eyebrow">04B · ORDINARY SURFACING / HUMAN-AUTHORED MATERIAL</p><h2>
                THIS ONE SURFACING STAND
              </h2>
            </div><button :if={!@surfacing} id="sf-open" phx-click="sf-open">Open Surfacing &amp; Consoling Stand</button>
          </header>
          <div :if={@surfacing} id="sf-display" data-revision={@surfacing["revision"]}>
            <p class="sf-identity">STANDING TOWARD STAGING WITHIN THIS ONE SITUATIONING FROM HERE</p>
            <p>
              Locality WITHIN THIS ONE STANDINGING LANDINGING, standing TOWARD THIS ONE CONSTITUTIONING HUMAN FROM HERE. Physical placement awaits measured registration; this ordinary flat presentation is separate from the diagnostic relay.
            </p>
            <div class="sf-offices">
              <section id="sf-human-office" aria-labelledby="sf-quill-heading">
                <p class="sf-office-label">CONSTITUTIONING HUMAN · QUILLING</p><h3 id="sf-quill-heading">
                  Semantical In-Stringing-Mentings
                </h3>
                <p>
                  Authored draft and routing witnesses. Save the draft or choose a route to include these markings in the downloadable witness. Displaying a marking does not Stitch it UPON the Road.
                </p>
                <p :if={@surfacing["revising"]} id="sf-revising">
                  Revising {@surfacing["revising"]}; its earlier witness remains intact.
                </p>
                <.form for={@quill_form} id="sf-quill-form" phx-submit="sf-submit">
                  <.input field={@quill_form[:revision]} type="hidden" />
                  <.input
                    field={@quill_form[:text]}
                    type="textarea"
                    label="Quill / revise the Human's authored material"
                    class="sf-quill"
                    maxlength="12000"
                  />
                  <div class="sf-actions">
                    <button id="sf-save-draft" name="intent" value="draft">Save authored draft</button><button
                      id="sf-route-staging"
                      name="intent"
                      value="staging"
                    >STAGING FOR STANDING</button><button
                      id="sf-route-inquiry"
                      name="intent"
                      value="inquiry"
                    >INQUIRINGINGMENTING</button>
                  </div>
                </.form>
                <button id="sf-new-draft" phx-click="sf-new">New draft · retain witnesses</button>
                <p class="sf-route-note">
                  Staging: TOWARD co-labouring WITH the Co-Situationing Doll in Stitching UPON the Road. The operation remains unfurnished.
                </p>
                <p class="sf-route-note">
                  Inquiry: THROUGHBY TOWARD the Stewardly Co-Captain Co-Bobbining Thing, BY-WAY-OF the appointed COB Consoling Stand.
                </p>
              </section>
              <section id="sf-consoling-stand" aria-labelledby="sf-console-heading">
                <p class="sf-office-label">COB'S DISTINCT FROM · WITHIN SURFACING</p><h3 id="sf-console-heading">
                  THIS ONE COB'S CONSOLING STAND
                </h3>
                <p>
                  STANDING FROM WITHIN THIS ONE SURFACING STAND STANDING HERE FROM UPON THIS ONE STANDINGING LANDINGING.
                </p>
                <p id="sf-console-here">
                  FROM OUT OF THIS HERE APPROACHING LANDINGING. HERE persists; NEXT is not substituted.
                </p>
                <div id="sf-by-way-of">
                  <strong>BY-WAY-OF</strong><p>THIS ONE STEWARDLY CO-CAPTAIN CO-BOBBINING THING</p><p>
                    The registered relation between Human Inquiringingmenting and the COB's IN-QUESTIONINGMENTING office.
                  </p>
                </div>
                <p id="sf-questioning-condition" role="status">
                  {if @inquiry_count > 0,
                    do:
                      "IN-QUESTIONINGMENTING · appointed following the Human's inquiry. No operational questioning, reasoning or answer furnished.",
                    else: "IN-QUESTIONINGMENTING office appointed. No Human inquiry witnessed yet."}
                </p>
                <p>
                  Consoling TOWARD this Human FROM HERE. A relational office, not another Human or an independent agent.
                </p>
                <div id="sf-console-material" phx-update="stream">
                  <article :for={{id, r} <- @streams.console_material} id={id}>
                    <strong>Human inquiry reference · {r["sequence"]}</strong><.semantic_text text={
                      r["text"]
                    } /><small>Author: {r["author"]} · no COB-authored answer</small>
                  </article>
                </div>
              </section>
            </div>
            <section aria-label="Authored material witnesses">
              <h3>Authored material · routes remain distinct</h3><div
                id="sf-material-ledger"
                phx-update="stream"
              >
                <article :for={{id, r} <- @streams.surface_material} id={id} data-route={r["route"]}>
                  <div class="sf-record-heading">
                    <strong>{if r["route"] == "staging",
                      do: "STAGING FOR STANDING",
                      else: "INQUIRINGINGMENTING"}</strong><span>Witness {r["sequence"]} · {r[
                      "author"
                    ]}</span>
                  </div><.semantic_text text={r["text"]} /><p>
                    {if r["route"] == "staging",
                      do: "Road Stitching not performed.",
                      else: "IN-QUESTIONINGMENTING condition appointed; no operational answer."}
                  </p><button
                    id={"sf-revise-#{r["sequence"]}"}
                    phx-click="sf-revise"
                    phx-value-id={r["id"]}
                  >Revise as a new witness</button><details>
                    <summary>Source, destination and provenance</summary><pre>{Jason.encode!(r,pretty: true)}</pre>
                  </details>
                </article>
              </div>
            </section>
            <details id="sf-relations" open>
              <summary>Appointed relations · placement remains unmeasured</summary><div class="sf-relation-buttons">
                <button
                  :for={{key, r} <- Surfacing.registrations()}
                  id={"sf-relation-#{key}"}
                  phx-click="sf-inspect"
                  phx-value-key={key}
                  data-sf-note={r["name"] || r["relation"] || r["destination"] || r["id"]}
                >{key}</button>
              </div><pre id="sf-relation-detail">{Jason.encode!(Surfacing.registrations()[@surfacing_selection],pretty: true)}</pre>
            </details>
          </div>
        </section>
        <section :if={!@read_only} id="ip-workshop" class="ip-panel">
          <header>
            <p class="gw-eyebrow">APPROACHING REGARDING · INSPECTION ONLY</p><h2>
              The letters retain their standing. Change the Regarding.
            </h2>
          </header>
          <nav id="ip-stands" aria-label="Five appointed Regarding stands">
            <button
              :for={i <- Inspection.stands()}
              id={"ip-stand-#{i}"}
              phx-click="inspection-stand"
              phx-value-index={i}
              aria-pressed={
                to_string((@inspection && @inspection["parameters"]["stand"] == i) || false)
              }
            >{Inspection.station(@model, i)["letter"]}{i}</button>
          </nav>
          <p class="ip-note">
            Five-position selection index only. The architectural course remains curved and unequally spaced. Body frames are provisional display geometry inherited from U13 +Z; no new CUBICAL reservations or acquisitions.
          </p>
          <div :if={@inspection} id="ip-controls" data-revision={@inspection["revision"]}>
            <.form for={@locality_form} id="ip-locality-form" phx-change="inspection-focus">
              <.input
                field={@locality_form[:target]}
                type="select"
                label="Approach locality without changing the primary FROM stand"
                options={
                  Enum.map(
                    @model["steeling"]["stations"],
                    &{"Letter #{&1["letter"]}#{&1["index"]}", "letter:#{&1["index"]}"}
                  ) ++
                    Enum.map(Map.values(@model["entities"]), &{&1["name"], "region:#{&1["id"]}"}) ++
                    Enum.map(
                      @inspection_registry["items"],
                      &{"Surface / reference · #{&1["label"]}", "plane:#{&1["id"]}"}
                    )
                }
                class="gw-input"
              />
            </.form>
            <div class="ip-actions">
              <button
                :for={
                  {command, label} <- [
                    {"approach", "Approach TOWARD"},
                    {"withdraw", "Withdraw FROM"},
                    {"along_forward", "ALONG THROUGH →"},
                    {"along_backward", "← ALONG THROUGH"},
                    {"orbit", "AROUND ABOUT target"},
                    {"previous_letter", "Previous letter target"},
                    {"next_letter", "Next letter target"},
                    {"surface_toward", "TOWARD surface"},
                    {"surface_along", "ALONG surface"},
                    {"through_aperture", "THROUGH selected aperture"},
                    {"monitor", "Stand TOWARD monitor"},
                    {"from", "Return to selected FROM"},
                    {"overview", "Return to overview"}
                  ]
                }
                id={"ip-#{command}"}
                disabled={
                  command in ~w(surface_toward surface_along through_aperture) &&
                    !(get_in(@inspection_instrument, ["target", "source", "kind"]) in if(
                        command == "through_aperture",
                        do: ["aperture"],
                        else: ["surface", "aperture"]
                      ))
                }
                phx-click="inspection-command"
                phx-value-command={command}
              >{label}</button>
            </div>
            <.form for={@regarding_form} id="ip-control-form" phx-change="inspection-controls">
              <.input field={@regarding_form[:revision]} type="hidden" />
              <.input
                field={@regarding_form[:distance]}
                type="range"
                class="ip-range"
                label="Target approach distance (extents; physical stand movement)"
                min="0.08"
                max="80"
                step="0.02"
                phx-debounce="100"
              />
              <.input
                field={@regarding_form[:orbit]}
                type="range"
                class="ip-range"
                label="Orbit AROUND ABOUT locality (degrees)"
                min="-180"
                max="180"
                step="1"
                phx-debounce="100"
              />
              <.input
                field={@regarding_form[:elevation]}
                type="range"
                class="ip-range"
                label="Elevation around locality (degrees)"
                min="-89"
                max="89"
                step="1"
                phx-debounce="100"
              />
              <.input
                field={@regarding_form[:turn]}
                type="range"
                class="ip-range"
                label="Turn bearing at the inspection eye (degrees)"
                min="-180"
                max="180"
                step="1"
                phx-debounce="100"
              />
              <.input
                field={@regarding_form[:monitor_offset]}
                type="number"
                label="Monitor normal offset (extents; move stand TOWARD monitor first)"
                min={if @inspection["parameters"]["through"], do: -20, else: 0.08}
                max="120"
                step="0.02"
                class="gw-input"
                phx-debounce="100"
              />
              <.input
                field={@regarding_form[:through]}
                type="checkbox"
                class="ip-check"
                label="Explicit THROUGH-plane inspection (permits signed monitor crossing)"
              />
              <.input
                field={@regarding_form[:treatment]}
                type="select"
                label="Letter presentation"
                options={[
                  {"Solid black block", "solid"},
                  {"Black / white FROM-face registration", "registered"},
                  {"Additional structural lines", "structural"}
                ]}
                class="gw-input"
              />
            </.form>
            <p id="ip-standing">
              Primary FROM: {Inspection.station(@model, @inspection["parameters"]["stand"])["letter"]}{@inspection[
                "parameters"
              ]["stand"]} at {Jason.encode!(@inspection["parameters"]["from"])} · mode {@inspection[
                "parameters"
              ]["mode"]} · orbit {@inspection["parameters"]["orbit"]}° / bearing turn {@inspection[
                "parameters"
              ]["turn"]}°. First inspection FROM remains {Jason.encode!(@inspection["original_from"])}.
            </p>
            <div
              :if={@inspection["parameters"]["mode"] != "overview"}
              id="ip-renderer"
              phx-hook="ApproachingRegarding"
              phx-update="ignore"
              data-model={Jason.encode!(@model)}
              data-registry={Jason.encode!(@inspection_registry)}
              data-inspection={Jason.encode!(@inspection)}
            >
              <p id="ip-pose-readout" role="status"></p>
              <div class="ip-comparison">
                <figure>
                  <figcaption>REGARDING presentation · actual world course</figcaption><svg
                    id="ip-regarding-scene"
                    aria-label="Perspective from the movable inspection stand"
                    role="img"
                  ></svg>
                </figure>
                <figure>
                  <figcaption>FLAT MONITOR · computed projector relay</figcaption><svg
                    id="ip-monitor-scene"
                    aria-label="Computed presentation in the fixed flat monitor frame"
                    role="img"
                  ></svg>
                </figure>
              </div>
              <aside id="ip-outreading-panel" aria-label="Hover focus and pinned outreading">
                <h3>Outreading-mentings · hover / focus / pin</h3>
                <label for="ip-outreading-choice">Registered object (keyboard selection)</label><select
                  id="ip-outreading-choice"
                  class="gw-input"
                ></select>
                <p id="ip-outreading-status" role="status" aria-live="polite"></p>
                <button id="ip-unpin-outreading" type="button">Unpin / resume preview</button><button
                  id="ip-approach-outreading"
                  type="button"
                  disabled
                >Approach the pinned locality</button>
                <pre id="ip-outreading-detail"></pre>
              </aside>
              <div id="ip-outreading-tooltip" role="tooltip" hidden></div>
              <details>
                <summary>Measured stand / provisional optical relay record</summary><pre id="ip-projection-detail"></pre>
              </details>
            </div>
            <p class="ip-note">
              PROVISIONAL optical relay: the Regarding supplies a perspective field (retained while its observer approaches the monitor); the distinct A04 Projectioning Thing projects that field onto the fixed Z=-2 monitor. Near/behind rays and display borders clip. Teal: STANDING FOR STAGING; amber: STAGING FOR STANDING. Black bodies are station presentation, never acquisition. Black letter faces use depth ordering; outlined architecture retains rear edges. Overlapping provisional letter bodies can produce painter-order artifacts. TC illumination is not authorship.
            </p>
            <details id="ip-details" open>
              <summary>Selected locality, decomposition and instrumentation candidates</summary><pre id="ip-locality-detail">{Jason.encode!(@inspection_instrument,pretty: true)}</pre><p>
                Existing surface ≠ candidate aperture ≠ appointed aperture ≠ operational instrument. This inspection creates none. U's 90° architectural limit remains separate from the free inspection camera. PINNING, PIVOTING and PITTONING remain distinct; no operation is invoked.
              </p>
            </details>
          </div>
        </section>
        <section :if={!@read_only} class="gw-quick-rehearsal" aria-label="Quick rehearsal controls">
          <.form for={@pick_form} id="gw-pick-form" phx-change="pick-letter">
            <.input
              field={@pick_form[:index]}
              type="select"
              label="Indexed station"
              options={
                Enum.map(
                  @model["steeling"]["stations"],
                  &{"#{&1["index"]} · #{&1["letter"]} / #{&1["group"]}", &1["index"]}
                )
              }
              class="gw-input"
            />
          </.form>
          <button
            id="gw-quick-collect"
            phx-click="rehearse"
            phx-value-action="collect"
            phx-value-revision={@model["rehearsal"]["revision"]}
            disabled={
              @model["rehearsal"]["ready"] && @letter_index not in @model["rehearsal"]["collected"]
            }
          >Collect selected station</button>
          <strong id="gw-quick-count">{length(@model["rehearsal"]["collected"])} / 5 · {if @model[
                                                                                             "rehearsal"
                                                                                           ]["ready"],
                                                                                           do:
                                                                                             "READY TO STAND TOWARD RE-STEPPING",
                                                                                           else:
                                                                                             "test Situationing"}</strong>
        </section>
        <div class="gw-layout">
          <section class="gw-controls" aria-labelledby="gw-over-across">
            <h2 id="gw-over-across">Toward OVER ACROSS</h2>
            <nav class="gw-views" aria-label="Structural Regardings">
              <button
                :for={{id, label} <- @structural_regards}
                id={"gw-view-#{id}"}
                type="button"
                phx-click="regard"
                phx-value-view={id}
                aria-pressed={to_string(@regard == id)}
              >{label}</button>
            </nav>
            <.form for={@pivot_form} id="gw-pivot-form" phx-change="pivot" class="gw-pivot">
              <.input
                field={@pivot_form[:yaw]}
                type="range"
                label={"Pivot around vertical axis: #{@yaw}°"}
                min="-180"
                max="180"
                step="1"
                phx-debounce="80"
                class="gw-input"
              />
            </.form>
            <div class="gw-selection">
              <button
                :for={
                  {id, label} <- [
                    {"tc", "TC carriage"},
                    {"central", "Crossing"},
                    {"ch", "CH carriage"},
                    {"lower", "Ground / monitor"}
                  ]
                }
                id={"gw-select-#{id}"}
                phx-click="select"
                phx-value-id={id}
                aria-pressed={to_string(@selected == id)}
              >{label}</button>
            </div>
            <details open>
              <summary>Carriage positioning</summary>
              <.form
                :if={@selected in ["ch", "tc"]}
                for={@move_form}
                id="gw-carriage-form"
                phx-submit="move"
              >
                <.input field={@move_form[:id]} type="hidden" /><.input
                  field={@move_form[:revision]}
                  type="hidden"
                />
                <.input
                  field={@move_form[:position]}
                  type="number"
                  label="Start position along rail (0–12)"
                  min="0"
                  max="12"
                  step="0.1"
                  class="gw-input"
                  disabled={@read_only || not is_nil(@model["lock"])}
                />
                <button id="gw-move" disabled={@read_only || not is_nil(@model["lock"])}>Move selected carriage</button>
              </.form>
              <p>
                Travel: each six-extent carriage stays within 0–18. Overlap is permitted and reported. Crossing and lower regions remain fixed.
              </p>
            </details>
          </section>
          <section class="gw-stage" aria-label="Structural Regarding">
            <.draw_out_panel
              :if={@model["projection"] && @inspection_registry}
              mode={@draw_out}
              model={@model}
              registry={@inspection_registry}
              surfacing={@surfacing}
              seat={@seat_reserve}
            />
            <dl id="gw-regarding-relations" class="gw-regarding-relations">
              <div>
                <dt>Stands FROM</dt>
                <dd id="gw-regarding-locality" data-status="unappointed">
                  Unappointed in Snail House geometry
                </dd>
                <dd>Source · Regarding appointments reservation (frame unfurnished)</dd>
              </div>
              <div>
                <dt>Directed TOWARD</dt>
                <dd id="gw-regarding-bearing">
                  {List.keyfind(@structural_regards, @regard, 0) |> elem(1)}
                </dd>
                <dd :if={@selected_station} id="gw-regarding-station">
                  Selected letter station · {@selected_station["letter"]}{@selected_station[
                    "index"
                  ]}
                </dd>
              </div>
              <div>
                <dt>Presentation only</dt>
                <dd id="gw-regarding-pivot">
                  Pivot {@yaw}°. Magnification follows the selected letter or Pretend view. Pan stays within the aperture.
                </dd>
              </div>
            </dl>
            <div
              id="gw-renderer"
              phx-hook="WorkshopRenderer"
              phx-update="ignore"
              data-groundside-diorama={
                Jason.encode!(
                  if(@draw_out == "groundside-diorama" && @model["projection"],
                    do: Groundside.diorama(@model)
                  )
                )
              }
              data-instrument={Jason.encode!(@inspection_instrument)}
              data-model={Jason.encode!(@model)}
              data-calibration={Jason.encode!(@calibration_registry)}
              data-flat-material={
                Jason.encode!(
                  Enum.filter(
                    (@inspection_registry || %{})["items"] || [],
                    &(&1["id"] in ~w(monitor-already-standing monitor-prospective))
                  )
                )
              }
              data-plane={@planar_selection}
              data-regard={@regard}
              data-yaw={@yaw}
              data-letter={@letter_index}
              data-bearing={@bearing}
              data-footing={@footing_sequence}
              data-selected={@selected}
            >
              <section :if={@model["steeling"]} id="gw-pretend-regarding" class="gw-regarding-console">
                <h2>Pretend entry and Regarding Stands</h2>
                <p>
                  From in front of your ordinary monitor, enter at the left as you sit.
                  Imagine the square aperture over the circular wedging and follow the curve
                  already tending XT → YT. Stop at aperture center to register zero,
                  then pull down the pretend donut-helmet.
                </p>
                <button id="gw-pretend-entry" type="button">Register zero and lower helmet</button>
                <p id="gw-entry-status" aria-live="polite">
                  Before entry · before Groundward FROM-standing
                </p>
                <div class="gw-selection" role="group" aria-label="Select Regarding Stand">
                  <button
                    :for={
                      {index, label} <- [
                        {0, "XT → XT entry"},
                        {1, "XT → YT open bend"},
                        {2, "YT → YT sharp turn"},
                        {3, "Descending return"}
                      ]
                    }
                    type="button"
                    data-regarding-stand={index}
                    aria-pressed="false"
                    disabled
                  >{index} · {label}</button>
                </div>
                <p id="gw-stand-source" aria-live="polite"></p>
                <div class="gw-selection" role="group" aria-label="Regarding-only elevator">
                  <button id="gw-elevator-down" type="button" disabled>DOWN</button>
                  <button id="gw-elevator-up" type="button" disabled>UP</button>
                  <output id="gw-elevator-level" aria-live="polite"></output>
                </div>
                <div class="gw-selection" role="group" aria-label="COB placement witness">
                  <button id="gw-place-cob" type="button" disabled>Record COB at selected stand</button>
                  <button id="gw-clear-cob" type="button" disabled>Clear COB stand witness</button>
                </div>
                <p id="gw-cob-stand" aria-live="polite">COB follows the rehearsal course.</p>
                <button
                  id="gw-flat-flip"
                  type="button"
                  aria-expanded="false"
                  aria-controls="gw-flat-page"
                >
                  Flat Page Regarding
                </button>
              </section>
              <section
                id="gw-flat-page"
                class="gw-regarding-console"
                aria-labelledby="gw-flat-heading"
                hidden
              >
                <h2 id="gw-flat-heading">Flat Page Regarding</h2>
                <p>
                  Both entries share the flat-monitor projection and Human calibration provenance.
                  The central vertical Projectioning reference is retained, with the Crossing
                  on the YT side. Material presented through the Crossing stays within its
                  six-extent width.
                </p>
                <div id="gw-flat-material" class="gw-flat-material"></div>
              </section>
              <details :if={@model["projection"]} id="gw-axis-witness" class="gw-axis-witness">
                <summary>Inspect the two axes</summary>
                <div class="gw-axis-readings">
                  <section aria-labelledby="gw-crossing-axis-heading">
                    <h3 id="gw-crossing-axis-heading">Projectioning Crossing · pivot reference</h3>
                    <p>
                      FROM the Crossing center, {inspect(
                        @model["projection"]["vertical"]["presentation_origin"]
                      )}.
                      Direction +Y, the existing Regarding yaw axis. Source · six-extent Crossing
                      and the registered vertical Projectioning centerline.
                    </p>
                    <p>
                      The green dotted outline is the shared Lower Staging source at Y = −3.
                      Both affine Projectioning candidates use its origin. Ground is at Y = −6.
                      A Resolutioning relation is unestablished.
                    </p>
                  </section>
                  <section aria-labelledby="gw-seat-axis-heading">
                    <h3 id="gw-seat-axis-heading">
                      Traversaling Seat · provisional Resolutioning reference
                    </h3>
                    <svg
                      id="gw-seat-axis-diagram"
                      viewBox="0 0 300 106"
                      role="img"
                      aria-label="Seat reserve and provisional inward axis in the separate appliance cutaway frame"
                      data-native-point={Jason.encode!(@seat_reserve["point"])}
                      data-native-direction={Jason.encode!(@seat_reserve["facing"])}
                    >
                      <title>Appliance cutaway · native frame schematic</title>
                      <path d="M 12,74 H 285" class="gw-seat-ground" />
                      <ellipse cx="54" cy="53" rx="18" ry="9" class="gw-seat-reserve" />
                      <path d="M 31,53 H 278 M 270,46 L 278,53 L 270,60" class="gw-seat-direction" />
                      <text x="54" y="35" text-anchor="middle">Seat reserve</text>
                      <text x="272" y="35" text-anchor="end">Inward +Z</text>
                      <text x="12" y="92">Ground reference · native frame</text>
                    </svg>
                    <p>
                      FROM {@seat_reserve["id"]} at {inspect(@seat_reserve["point"])}.
                      Source · {@seat_reserve["source"]}, appliance cutaway.
                      The arrow passes through the reserve marker along its inward facing
                      as a provisional Resolutioning OVER ACROSS direction toward staging.
                      The Seat center, staging intercept, and transform into Workshop coordinates remain unappointed.
                    </p>
                  </section>
                </div>
                <p id="gw-axis-reciprocity">
                  Intended reciprocal bearings · Stand 0 DOWN OVER ACROSS toward Stand 1 ·
                  Stand 1 UP OVER ACROSS toward Stand 0. The outer globular frame and Stand 1 eye
                  frame remain unregistered.
                </p>
              </details>
              <div class="gw-zoom">
                <button id="gw-bring-regarding" type="button">Bring Regarding Toward Me</button>
                <button id="gw-reset-regarding" type="button" disabled>Reset magnification</button>
                <output id="gw-magnification" aria-live="polite">1×</output>
              </div>
              <div
                id="gw-regarding-viewport"
                role="region"
                tabindex="0"
                aria-label="Regarding aperture"
              >
                <svg
                  id="gw-scene"
                  viewBox="0 -200 1100 1100"
                  role="img"
                  aria-label="Seeing THROUGHING structural geometry. All faces are outlines; all edges remain drawn."
                ></svg>
              </div>
            </div>
          </section>
          <section class="gw-controls" aria-labelledby="gw-from-standing">
            <h2 id="gw-from-standing">From-standing outreadings</h2>
            <div class="gw-legend" aria-label="Registered geometry legend">
              <span class="gw-legend-tc">TC · 6 × 6 × 6</span>
              <span class="gw-legend-central">Crossing · 6 × 6 × 6</span>
              <span class="gw-legend-ch">CH · 6 × 6 × 6</span>
              <span class="gw-legend-lower">Lower · 6 × 6 × 6</span>
              <span>Ground: lower bottom / monitor: lower top</span>
            </div>
            <p class="gw-caption">
              All surfaces are outlines. Rear edges remain drawn. View changes and resizing preserve world coordinates.
            </p>
            <p id="gw-overlaps">
              <strong>Overlap observations:</strong> {case Geometry.overlaps(@model["positions"]) do
                [] -> "None (touching boundaries are not overlaps)."
                observations -> Enum.join(observations, "; ")
              end}
            </p>
            <div class="gw-outreadings">
              <div>
                <h2>Selected furnishing</h2>
                <p id="gw-selected">
                  <strong>{@model["entities"][@selected]["name"]}</strong><br />6 × 6 × 6 extents<br />Origin: {Jason.encode!(
                    @model["entities"][@selected]["frame"]["origin"]
                  )}
                </p>
                <h2>Compare &amp; register</h2>
                <dl id="gw-comparison" class="gw-comparison">
                  <dt>TC interval</dt><dd>
                    {@model["positions"]["tc"]}–{@model["positions"]["tc"] + 6}
                  </dd><dt>
                    Crossing interval
                  </dt><dd>
                    {hd(@model["entities"]["central"]["frame"]["origin"])}–{hd(
                      @model["entities"]["central"]["frame"]["origin"]
                    ) + 6}
                  </dd><dt>CH interval</dt><dd>
                    {@model["positions"]["ch"]}–{@model["positions"]["ch"] + 6}
                  </dd><dt>CH minus TC origins</dt><dd>
                    {@model["positions"]["ch"] - @model["positions"]["tc"]} extents
                  </dd>
                </dl>
                <div class="gw-actions">
                  <button
                    id="gw-reset"
                    phx-click="construct"
                    phx-value-action="reset"
                    phx-value-revision={@model["revision"]}
                    disabled={@read_only || not is_nil(@model["lock"])}
                  >Restore initial arrangement</button>
                  <button
                    id="gw-lock"
                    phx-click="construct"
                    phx-value-action="lock"
                    phx-value-revision={@model["revision"]}
                    disabled={@read_only || not is_nil(@model["lock"])}
                  >LOCK arrangement</button>
                  <button
                    id="gw-release"
                    phx-click="construct"
                    phx-value-action="release"
                    phx-value-revision={@model["revision"]}
                    disabled={@read_only || is_nil(@model["lock"])}
                  >Release LOCK</button>
                </div>
                <p id="gw-archive-count">
                  {length(@model["witnesses"])} retained LOCK snapshots. Release preserves these snapshots in subsequent exports.
                </p>
              </div>
              <div>
                <h2>Construction witnesses</h2>
                <p>
                  Download before leaving. A page reload starts a fresh construction; import a witness to resume.
                </p>
                <button id="gw-export" phx-click="export">Download JSON witness</button>
                <.form
                  for={@upload_form}
                  id="gw-file-form"
                  phx-change="upload-change"
                  phx-submit="import-file"
                >
                  <label for={@uploads.witness.ref}>Load JSON file</label><.live_file_input upload={
                    @uploads.witness
                  } />
                  <p :for={error <- upload_errors(@uploads.witness)} class="gw-message">
                    Upload: {error}
                  </p>
                  <div :for={entry <- @uploads.witness.entries}>
                    <span>{entry.client_name} · {entry.progress}%</span><p
                      :for={error <- upload_errors(@uploads.witness, entry)}
                      class="gw-message"
                    >
                      {error}
                    </p>
                  </div>
                  <button id="gw-import-file">Load selected witness</button>
                </.form>
                <details>
                  <summary>Or paste witness JSON</summary><.form
                    for={@import_form}
                    id="gw-import-form"
                    phx-submit="import-json"
                  >
                    <.input
                      field={@import_form[:json]}
                      type="textarea"
                      label="Witness JSON"
                      class="gw-input"
                    /><button id="gw-import-json">Load pasted witness</button>
                  </.form>
                </details>
              </div>
            </div>
          </section>
        </div>
        <section :if={!@read_only} id="gw-calibration" class="gw-calibration">
          <h2>Locked U · quarter-turn Situationing calibration</h2>
          <p>
            Existing U13/N18 and acquisitions remain unchanged. New sizes, axes and attachments are explicit mechanical hypotheses. U stays locked to +Z; the related stage may pivot within 0–90°. Aperture opening is a separate 0–45°.
          </p>
          <button
            :if={!@calibration}
            id="gw-furnish-calibration"
            phx-click="furnish-calibration"
            disabled={!!@model["lock"]}
          >Furnish Assignment 04 calibration witness</button>
          <div
            :if={@calibration}
            id="gw-calibration-controls"
            data-revision={@calibration["revision"]}
          >
            <.form for={@calibration_form} id="gw-calibration-form" phx-submit="calibrate">
              <.input field={@calibration_form[:revision]} type="hidden" />
              <.input
                :for={{id, label, low, high} <- Calibration.parameters()}
                field={@calibration_form[id]}
                type="number"
                label={label}
                min={low}
                max={high}
                step="0.1"
                class="gw-input"
                disabled={!!@model["lock"]}
              />
              <.input
                field={@calibration_form[:axis]}
                type="select"
                label="Hypothesized stage axis (U frame stays fixed)"
                options={[{"X axis", "x"}, {"Z axis", "z"}]}
                class="gw-input"
                disabled={!!@model["lock"]}
              />
              <.input
                field={@calibration_form[:coupling]}
                type="select"
                label="Wishbone coupling hypothesis"
                options={[
                  {"Independent bearings", "independent"},
                  {"Counter-presented bearings", "counter"},
                  {"Linked bearings", "linked"}
                ]}
                class="gw-input"
                disabled={!!@model["lock"]}
              />
              <button id="gw-apply-calibration" disabled={!!@model["lock"]}>Register bounded calibration</button>
            </.form>
            <p id="gw-u-lock">
              U BEARING LOCKED · U13 [15,3,0], +Z transverse · quarter-turn {@calibration[
                "parameters"
              ]["quarter_turn"]}° / 90° · opening {@calibration["parameters"]["opening"]}° / 45°
            </p>
            <p id="gw-zero-status">CAMERA ZERO: {@calibration_registry["camera_zero"]}</p>
            <p>
              THIS ONE FURNISHING COB: current CH-fashioned rehearsal inspected under this role; recorded acquisitions remain verbatim. THIS ONE TRAVERSALING COB and THIS FELLOW TRAVERSALING COB are reserved: NO TRAVERSALING WITHOUT A FURNISHED BY-WAY-OF.
            </p>
            <p>
              Scene labels distinguish STANDING FOR STAGING from STAGING FOR STANDING. TC illumination does not author the material. FOUR/SIX/EIGHT are relative geometric excursions, not acquired purchase or completed turns. A half + half contribution toward ONE remains an authored possibility, not a rule.
            </p>
            <details open id="gw-planar-ledger">
              <summary>Planar Prepositioning Ledger · measured / appointed / provisional</summary>
              <div class="gw-planar-buttons">
                <button
                  :for={item <- @calibration_registry["items"]}
                  id={"gw-inspect-" <> item["id"]}
                  phx-click="select-plane"
                  phx-value-id={item["id"]}
                  aria-pressed={to_string(@planar_selection == item["id"])}
                >{item["label"]}</button>
              </div>
              <button
                :if={@planar_detail}
                id="ip-approach-plane"
                phx-click="inspection-focus"
                phx-value-target={"plane:" <> @planar_selection}
              >Approach this ledger locality</button>
              <pre id="gw-planar-detail">{Jason.encode!(@planar_detail, pretty: true)}</pre>
              <details>
                <summary>Full registry, role appointments and purchase distinctions</summary><pre id="gw-calibration-registry">{Jason.encode!(@calibration_registry, pretty: true)}</pre>
              </details>
            </details>
          </div>
        </section>
        <section
          :if={!@read_only}
          id="gw-rehearsal"
          class="gw-rehearsal"
          data-revision={@model["rehearsal"]["revision"]}
        >
          <div>
            <h2>COB alongside WITH you · five-letter rehearsal</h2>
            <p id="gw-companion" class="gw-companion">{Rehearsal.companion(@model["rehearsal"])}</p>
            <strong id="gw-readiness" data-ready={to_string(@model["rehearsal"]["ready"])}>{if @model[
                                                                                                 "rehearsal"
                                                                                               ][
                                                                                                 "ready"
                                                                                               ],
                                                                                               do:
                                                                                                 "READY TO STAND TOWARD RE-STEPPING",
                                                                                               else:
                                                                                                 "Collect any five distinct indexed stations"}</strong>
            <p>
              This readiness condition was fashioned for this test Situationing. It is not a universal prerequisite or execution of RE-STEP. Local Ground and anchored turning index remain unchanged.
            </p>
            <p id="gw-count">
              Acquired: {length(@model["rehearsal"]["collected"])} / 5 · rehearsal revision {@model[
                "rehearsal"
              ]["revision"]}
            </p>
            <p id="gw-acquisition-order">
              Acquisition order: {Enum.join(@model["rehearsal"]["collected"], " → ")}
            </p>
            <p>
              Selected station: {@letter_index} {if @selected_station, do: @selected_station["letter"]}. Use the 25-letter index below to choose any station.
            </p>
            <div class="gw-actions">
              <button
                id="gw-collect"
                phx-click="rehearse"
                phx-value-action="collect"
                phx-value-revision={@model["rehearsal"]["revision"]}
                disabled={
                  @model["rehearsal"]["ready"] &&
                    @letter_index not in @model["rehearsal"]["collected"]
                }
              >Collect selected station</button><button
                id="gw-reset-rehearsal"
                phx-click="rehearse"
                phx-value-action="reset"
                phx-value-revision={@model["rehearsal"]["revision"]}
              >Reset test Situationing; archive this run</button>
            </div>
            <div id="gw-footings" phx-update="stream" class="gw-footings">
              <button
                :for={{id, f} <- @streams.footings}
                id={id}
                phx-click="select-footing"
                phx-value-sequence={f["sequence"]}
                aria-pressed={to_string(@footing_sequence == f["sequence"])}
              >Footing {f["sequence"]} · {f["letter"]}{f["station_index"]}</button>
            </div>
            <pre id="gw-footing-detail">{Jason.encode!(if(@selected_footing, do: Map.put(@selected_footing, "presentations", Projection.material(@model["projection"], @selected_footing)), else: %{"status" => "No acquired Footing selected"}), pretty: true)}</pre>
            <details>
              <summary>Inspect complete Footing ledger and archived runs</summary><pre id="gw-footing-ledger">{Jason.encode!(@model["rehearsal"], pretty: true)}</pre>
            </details>
            <h2>COB's reference-course position</h2>
            <.form for={@progress_form} id="gw-progress-form" phx-submit="progress">
              <.input field={@progress_form[:revision]} type="hidden" /><.input
                field={@progress_form[:progress]}
                type="number"
                label="Progress t (0–1), independent of acquisitions"
                min="0"
                max="1"
                step="0.01"
                class="gw-input"
              /><button id="gw-set-progress">Move COB's progress witness</button>
            </.form>
            <p id="gw-cob-position">
              {Jason.encode!(Projection.cob(@model["projection"], @model["rehearsal"]["progress"]))}
            </p>
            <p>
              The fixed reference course spans 4.5 extents along +X at constant Y=3. Count never equals physical height. Collecting a letter does not move COB.
            </p>
          </div>
          <div>
            <h2>Lower staging → THROUGH the Crossing</h2>
            <div class="gw-actions" aria-label="Projection bearings">
              <button
                :for={
                  {mode, label} <- [
                    {"vertical", "Vertical departure"},
                    {"oblique", "Oblique reciprocal"},
                    {"both", "Both bearings"}
                  ]
                }
                id={"gw-bearing-#{mode}"}
                phx-click="bearing"
                phx-value-mode={mode}
                aria-pressed={to_string(@bearing == mode)}
              >{label}</button>
            </div>
            <p>
              Same lower staging source. V witnesses translate UP by [0,6,0]; O witnesses translate by [X offset,6,Z offset]. Source and presentation retain the same Footing identity. All outlines stay visible.
            </p>
            <p>
              Staging slots encode acquisition order, not adjacency of the indexed letter stations. Dotted station-to-slot associations are provisional, not mechanical connections.
            </p>
            <.form for={@projection_form} id="gw-projection-form" phx-submit="projection">
              <.input field={@projection_form[:revision]} type="hidden" /><.input
                :for={{id, label, low, high} <- Projection.parameters()}
                field={@projection_form[id]}
                type="number"
                label={"#{label} (#{low}–#{high} extents)"}
                min={low}
                max={high}
                step="0.1"
                class="gw-input"
                disabled={not is_nil(@model["lock"])}
              /><button id="gw-apply-projection" disabled={not is_nil(@model["lock"])}>Register oblique candidate</button>
            </.form>
            <p>
              Geometric LOCK freezes projection parameters; the separate rehearsal may still collect and move its progress witness.
            </p>
            <pre id="gw-bearing-inspection">{Jason.encode!(if(@bearing == "both", do: @model["projection"], else: Map.take(@model["projection"], ["source", @bearing, "course", "height_reference", "attachment"])), pretty: true)}</pre>
            <p>
              Provisional angled bearing and affine presentation, not final Glass, elbow-macaroni or operational Roundabout Gallery geometry.
            </p>
          </div>
        </section>
        <section
          :if={not is_nil(@model["steeling"])}
          class="gw-steeling"
          aria-label="JANUSITE STEELING inspection"
        >
          <div>
            <h2>25-letter structural index · 3 / 6 / 9 / 7</h2>
            <p>
              APPROACH → POTENTIAL FOR NEW STANDING → APPROACH AGAIN. Indices are not spatial extents.
            </p>
            <div id="gw-stations" phx-update="stream" class="gw-stations">
              <button
                :for={{id, station} <- @streams.stations}
                id={id}
                phx-click="select-letter"
                phx-value-index={station["index"]}
                aria-pressed={to_string(@letter_index == station["index"])}
                class={[
                  station["index"] == 13 && "gw-u-button",
                  station["index"] == 18 && "gw-n-button"
                ]}
                title={"#{station["index"]} · #{station["group"]}"}
              >{station["index"]} {station["letter"]}</button>
            </div>
            <pre id="gw-station-details">{Jason.encode!(@selected_station, pretty: true)}</pre>
            <dl id="gw-two-returns">
              <dt>Return A · U13</dt><dd>
                Projectioning center return at {Jason.encode!(@model["steeling"]["u_return"]["point"])}. U-post reference TOWARD the future upper aperture.
              </dd><dt>Return B · N18</dt><dd>
                Ground reference returns TOWARD center. MACHINE inherits its approach from N; outgoing heading {@model[
                  "steeling"
                ]["parameters"]["n_heading"]}° from +X.
              </dd>
            </dl>
          </div>
          <div>
            <h2>Provisional structural hypothesis</h2>
            <.form for={@steeling_form} id="gw-steeling-form" phx-submit="steeling">
              <.input field={@steeling_form[:revision]} type="hidden" />
              <.input
                :for={{id, label, unit, low, high} <- Steeling.parameters()}
                field={@steeling_form[id]}
                type="number"
                label={"#{label} (#{low}–#{high} #{unit})"}
                min={low}
                max={high}
                step="0.1"
                class="gw-input"
                disabled={@read_only || not is_nil(@model["lock"])}
              />
              <button id="gw-apply-steeling" disabled={@read_only || not is_nil(@model["lock"])}>Apply structural parameters</button>
            </.form>
            <button
              id="gw-reset-steeling"
              phx-click="construct"
              phx-value-action="reset-steeling"
              phx-value-revision={@model["revision"]}
              disabled={@read_only || not is_nil(@model["lock"])}
            >Restore initial structural hypothesis</button>
            <p>
              Editable geometry: cubic THE/PUBLIC curve, registered SITUATION polyline and N-derived MACHINE staging. Plane XY at Z=0 is provisional. No 90° corner at N is prescribed.
            </p>
            <details>
              <summary>Inspect curve, stations, returns &amp; attachment references</summary><pre id="gw-course-geometry">{Jason.encode!(@model["steeling"], pretty: true)}</pre>
            </details>
          </div>
        </section>
        <section class="gw-notes">
          <details open>
            <summary>Coordinates &amp; selected registration</summary><p>
              Provisional convention: X along the straight 18-extent rail, TC toward CH; +Y UP; Z transverse. Origin [0,0,0] is the rail start. One extent is a model unit, not physical CH–TC separation.
            </p><p>
              <span :if={@read_only}>Historical schema-1/2 coordinates are displayed verbatim above. Corrected Assignment 02 reservations apply only after explicit migration.</span>
              <span :if={!@read_only}>Assignment 02 initial TC X=0–6, CH X=6–12, Projectioning Crossing X=12–18; Y=0–6, Z=−3–3. Lower X=12–18, Y=−6–0, Z=−3–3. Ground-side is lower Y=−6; monitor-side is Y=0. This opposite-face assignment is provisional.</span>
            </p><pre id="gw-coordinates">{Jason.encode!(@model["entities"][@selected], pretty: true)}</pre>
          </details>
          <details>
            <summary>Reserved interfaces · no geometry appointed</summary><dl>
              <%= for reserve <- @model["reservations"] do %>
                <dt>{reserve["id"]}</dt><dd>{reserve["description"]}</dd>
              <% end %>
            </dl>
          </details>
          <details>
            <summary>Construction provenance &amp; LOCK snapshots</summary><pre id="gw-provenance">{Jason.encode!(%{"provenance" => @model["provenance"], "lock" => @model["lock"], "witnesses" => @model["witnesses"], "legacy_source" => @model["legacy_source"]}, pretty: true)}</pre>
          </details>
          <p>
            Construction movement only. Geometric LOCK records an arrangement; it does not complete the Crossing. Local turn 0 and anchored index 0 remain reserved and unchanged. No constitutional operations are performed.
          </p>
        </section>
      </main>
    </Layouts.app>
    """
  end
end
