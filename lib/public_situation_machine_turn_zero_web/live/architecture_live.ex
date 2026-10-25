defmodule PublicSituationMachineTurnZeroWeb.ArchitectureLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.Architecture, as: Architecture
  alias PublicSituationMachineTurnZero.Architecture.{Store, Seed, Projection}
  alias PublicSituationMachineTurnZeroWeb.ArchitectureScene, as: Scene

  def mount(_, _, socket) do
    {:ok,
     socket
     |> stream_configure(:materials, dom_id: fn item -> "architecture-material-#{item["id"]}" end)
     |> assign(
       lab: Architecture.new(),
       record: nil,
       editing: "this-place",
       toy_id: "dispensationaling",
       message: "Composing prototype / first architectural slice"
     )
     |> refresh()}
  end

  def handle_params(params, _, socket) do
    case params do
      %{"id" => id} ->
        case Store.fetch(id) do
          {:ok, record} ->
            {:noreply,
             socket
             |> assign(record: record, lab: Architecture.restore(record.standing))
             |> refresh()}

          _ ->
            {:noreply,
             assign(socket,
               record: nil,
               message:
                 "Record not found. Open /experiments/architecture/engineering to begin a new composition."
             )}
        end

      _ ->
        if connected?(socket) do
          record = Store.create()

          {:noreply,
           push_patch(socket, to: ~p"/experiments/architecture/engineering?id=#{record.id}")}
        else
          {:noreply, socket}
        end
    end
  end

  def handle_event("wheel", %{"angle" => angle}, socket), do: wheel(socket, angle)

  def handle_event("wheel-input", %{"wheel" => %{"angle" => angle}}, socket),
    do: wheel(socket, angle)

  def handle_event("approach-material", %{"id" => id}, socket),
    do: apply_result(socket, Architecture.operate(socket.assigns.lab, {:approach, id}))

  def handle_event("read-nav", %{"op" => op}, socket) do
    operation =
      case op do
        "back" -> :back_regard
        "left" -> {:read_nav, -1, 0}
        "right" -> {:read_nav, 1, 0}
        "up" -> {:read_nav, 0, -1}
        "down" -> {:read_nav, 0, 1}
        _ -> :invalid
      end

    apply_result(socket, Architecture.operate(socket.assigns.lab, operation))
  end

  def handle_event("point-artifact", %{"id" => id}, socket),
    do: apply_result(socket, Architecture.operate(socket.assigns.lab, {:craft, {:point, id}}))

  def handle_event("craft-pose", %{"x" => x, "y" => y, "turn" => turn}, socket) do
    with {:ok, x} <- number(x), {:ok, y} <- number(y), {:ok, turn} <- number(turn) do
      apply_result(
        socket,
        Architecture.operate(socket.assigns.lab, {:craft, {:pose, x, y, turn}})
      )
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("craft", %{"op" => op}, socket) do
    operation =
      case op do
        "open" -> :open
        "draw-pointer" -> :draw_pointer
        "box" -> :box
        "next-piece" -> :next_piece
        "calibrate" -> :calibrate
        "grasp" -> :grasp
        "lift" -> :lift
        "turn" -> {:turn, 30}
        "toward" -> :toward
        "align" -> :align
        "seat" -> :seat
        "wrap" -> :wrap
        "buckle" -> :buckle
        "release" -> :release
        _ -> :invalid
      end

    apply_result(socket, Architecture.operate(socket.assigns.lab, {:craft, operation}))
  end

  def handle_event("operation", %{"op" => op}, socket) do
    operation =
      case op do
        "projection" -> :projection
        "flat" -> :flat
        "calibrate" -> :calibrate
        "position" -> :position
        "appoint" -> :appoint
        "step" -> :step
        "forward" -> {:nav, 1}
        "backward" -> {:nav, -1}
        _ -> :invalid
      end

    apply_result(socket, Architecture.operate(socket.assigns.lab, operation))
  end

  def handle_event("pivot", %{"bearing" => bearing}, socket),
    do: apply_result(socket, Architecture.operate(socket.assigns.lab, {:pivot, bearing}))

  def handle_event("fixture", _, socket),
    do:
      apply_result(
        socket,
        Architecture.fixture_enclosure(
          socket.assigns.lab,
          !Architecture.quiet_complete?(socket.assigns.lab)
        )
      )

  def handle_event("choose-material", %{"selection" => %{"id" => id}}, socket) do
    if Map.has_key?(socket.assigns.lab.standing["materials"], id) do
      {:noreply, socket |> assign(editing: id) |> refresh()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("inspect-material", %{"id" => id}, socket) do
    if Map.has_key?(socket.assigns.lab.standing["materials"], id),
      do: {:noreply, socket |> assign(editing: id) |> refresh()},
      else: {:noreply, socket}
  end

  def handle_event("new-material", _, socket) do
    {:noreply, socket |> assign(editing: Ecto.UUID.generate()) |> refresh()}
  end

  def handle_event("save-material", %{"material" => attrs}, socket) do
    case Architecture.compose(socket.assigns.lab, socket.assigns.editing, attrs) do
      {:error, %Ecto.Changeset{} = cs} ->
        {:noreply, assign(socket, material_form: changeset_form(cs, :material))}

      result ->
        apply_result(socket, result)
    end
  end

  def handle_event("choose-toy", %{"toy_selection" => %{"id" => id}}, socket) do
    if Map.has_key?(socket.assigns.lab.standing["toys"], id),
      do: {:noreply, socket |> assign(toy_id: id) |> refresh()},
      else: {:noreply, socket}
  end

  def handle_event("save-toy", %{"toy" => attrs}, socket) do
    case Architecture.compose_toy(socket.assigns.lab, socket.assigns.toy_id, attrs) do
      {:error, %Ecto.Changeset{} = cs} ->
        {:noreply, assign(socket, toy_form: changeset_form(cs, :toy))}

      result ->
        apply_result(socket, result)
    end
  end

  defp wheel(socket, value) do
    case number(value) do
      {:ok, angle} ->
        apply_result(socket, Architecture.operate(socket.assigns.lab, {:wheel, angle}))

      _ ->
        {:noreply, socket}
    end
  end

  defp number(value) when is_number(value), do: {:ok, value}

  defp number(value) when is_binary(value) do
    case Float.parse(value) do
      {n, ""} -> {:ok, n}
      _ -> :error
    end
  end

  defp number(_), do: :error

  defp apply_result(%{assigns: %{record: nil}} = socket, _), do: {:noreply, socket}

  defp apply_result(socket, {:ok, lab}) do
    result =
      if lab.standing == socket.assigns.lab.standing,
        do: {:ok, socket.assigns.record},
        else: Store.save(socket.assigns.record, lab.standing)

    case result do
      {:ok, record} ->
        {:noreply,
         socket
         |> assign(
           lab: lab,
           record: record,
           message:
             "#{if lab.standing == socket.assigns.lab.standing, do: "Regard changed. Standing holds.", else: "Standing saved."}"
         )
         |> refresh()}

      {:error, _} ->
        {:noreply,
         assign(socket, message: "Another composer changed this record. Reload before writing.")}
    end
  end

  defp apply_result(socket, {:error, _}),
    do:
      {:noreply,
       assign(socket,
         message: "Operation unavailable from the present standing. No change saved."
       )}

  # This project has Ecto but no phoenix_ecto FormData adapter. Derive the map
  # form and validation errors from the authoritative schemaless changeset.
  defp changeset_form(cs, name) do
    data =
      Ecto.Changeset.apply_changes(cs)
      |> Map.new(fn {key, value} -> {Atom.to_string(key), value} end)

    to_form(Map.merge(data, cs.params || %{}),
      as: name,
      errors: if(cs.action, do: cs.errors, else: [])
    )
  end

  defp refresh(socket) do
    lab = socket.assigns.lab

    item =
      lab.standing["materials"][socket.assigns.editing] ||
        %{
          "title" => "",
          "text" => "",
          "location" => "ZEROETH",
          "origin" => "ZEROETH",
          "bearing" => "wallward",
          "region" => "locality",
          "course" => 0,
          "categories" => ["Approach Noticingments"],
          "dependencies" => []
        }

    socket
    |> assign(
      wheel_form: to_form(%{"angle" => to_string(round(lab.wheel))}, as: :wheel),
      material_form: changeset_form(Architecture.material_changeset(lab, item), :material),
      selection_form: to_form(%{"id" => socket.assigns.editing}, as: :selection),
      toy_selection_form: to_form(%{"id" => socket.assigns.toy_id}, as: :toy_selection),
      toy_form:
        changeset_form(
          Architecture.toy_changeset(lab, lab.standing["toys"][socket.assigns.toy_id]),
          :toy
        ),
      material_options:
        lab.standing["materials"]
        |> Map.values()
        |> Enum.sort_by(& &1["title"])
        |> Enum.map(&{&1["title"], &1["id"]}),
      toy_options:
        lab.standing["toys"]
        |> Map.values()
        |> Enum.sort_by(& &1["label"])
        |> Enum.map(&{&1["label"], &1["id"]}),
      inherited:
        lab.standing["relations"]
        |> Map.values()
        |> Enum.filter(&(&1["origin"] == "ZEROETH"))
        |> Enum.sort_by(& &1["id"])
    )
    |> stream(:materials, Projection.materials(lab), reset: true)
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:architecture_experiment} show_navigation={false}>
      <main id="architecture-lab" class="architecture-page toy-pass">
        <header class="architecture-terrestrial">
          <p>ORDINARY TERRESTRIAL WEBPAGE / COMPUTERING LOCALITY</p><nav aria-label="Engineering benches">
            <.link :if={@record} navigate={~p"/experiments/architecture?id=#{@record.id}"}>Public bodily drive</.link>
            <.link navigate={~p"/experiments/motor"}>Motor</.link><.link navigate={
              ~p"/experiments/instrumentation"
            }>Instrumentation</.link><a href="#composement">Engineering ledger</a>
          </nav>
        </header>
        <section
          id="architecture-cabinet"
          class="architecture-cabinet"
          aria-label="PUBLIC-SITUATION-MACHINE- cabinet"
        >
          <header class="architecture-nameplate">
            <div>
              <p>PUBLIC-SITUATION-MACHINE-</p><h1>Toy craft / roundabout / from-within passage</h1>
            </div><span>COMPOSING PROTOTYPE / 02</span>
          </header>
          <div class="architecture-aperture-rim">
            <div class="architecture-aperture-label">
              <span>GRAND APERTURE</span><span>{cond do
                @lab.craft.open? -> "COMPOSEMENTING LOCALITY"
                Architecture.stepped?(@lab) -> "FROM-WITHIN TUNNELING"
                true -> "ZEROETH / ROUNDABOUT"
              end}</span>
            </div>
            <Scene.aperture
              :if={@lab.projection?}
              lab={@lab}
              materials={@streams.materials}
              inherited={@inherited}
            />
            <div
              :if={!@lab.projection?}
              id="projection-extinguished"
              class="architecture-dark-aperture"
            >
              <span>PROJECTIONING-ER OFF</span>
            </div>
          </div>
          <div class="toy-appliance-instruments">
            <div class="toy-wheel-assembly">
              <div
                id="regarding-wheel"
                phx-hook="RegardingWheel"
                phx-update="ignore"
                data-angle={@lab.wheel}
                data-disabled={to_string(!@lab.projection? || !@record)}
                class="toy-regarding-wheel"
              >
                <svg
                  viewBox="0 0 200 200"
                  role="slider"
                  tabindex="0"
                  aria-label="Turn the Free Wheeling Free Turning Thing"
                  aria-valuemin="0"
                  aria-valuemax="359"
                  aria-valuenow={round(@lab.wheel)}
                  aria-valuetext={"#{round(@lab.wheel)} degrees of Regard"}
                >
                  <circle cx="100" cy="100" r="88" class="toy-wheel-rim" /><g
                    data-wheel-rotor="true"
                    transform={"rotate(#{@lab.wheel} 100 100)"}
                  >
                    <path
                      d="M100 18 V182 M18 100 H182 M42 42 L158 158 M42 158 L158 42"
                      class="toy-wheel-spokes"
                    /><circle cx="100" cy="20" r="10" class="toy-wheel-handle" />
                  </g><circle cx="100" cy="100" r="22" class="toy-wheel-hub" />
                </svg>
              </div>
              <.form for={@wheel_form} id="wheel-input-form" phx-change="wheel-input">
                <.input
                  field={@wheel_form[:angle]}
                  id="wheel-angle"
                  type="range"
                  min="0"
                  max="359"
                  step="1"
                  label="THIS ONE FREE WHEELING FREE TURNING THING FOR REGARDING THROUGHING ALONG THROUGH"
                  disabled={!@lab.projection? || !@record}
                />
              </.form>
            </div>
            <div class="toy-local-controls">
              <button
                :if={@lab.projection? && !Architecture.stepped?(@lab)}
                id="composement-toggle"
                phx-click="craft"
                phx-value-op="open"
                disabled={!@record}
              >{if @lab.craft.open?,
                do: "Return toward backed-up Roundabout Regard",
                else: "Bring Composementing locality TOWARD"}</button>
              <div :if={@lab.projection? && !Architecture.stepped?(@lab)} id="first-step-instrument">
                <p :if={Architecture.next(@lab)} id="first-landing">
                  THIS NEXT APPROACHINGING LANDINGING / TOWARD ONE
                </p>
                <button
                  id="first-step"
                  phx-click="operation"
                  phx-value-op="step"
                  disabled={!Architecture.available?(@lab, :step) || !@record}
                >STEP <.icon name="hero-arrow-long-right" class="size-5" /></button>
              </div>
              <div
                :if={@lab.projection? && Architecture.stepped?(@lab)}
                id="tunnel-nav"
                class="architecture-button-row"
              >
                <button
                  id="nav-backward"
                  phx-click="operation"
                  phx-value-op="backward"
                  disabled={@lab.nav == 0}
                >← NAV-STEP</button><span id="nav-position">ALONG THROUGH / {@lab.nav}</span><button
                  id="nav-forward"
                  phx-click="operation"
                  phx-value-op="forward"
                  disabled={@lab.nav == 6}
                >NAV-STEP →</button>
              </div>
              <div class="architecture-button-row">
                <button
                  id="projection-toggle"
                  phx-click="operation"
                  phx-value-op="projection"
                  disabled={!@record}
                  aria-pressed={to_string(@lab.projection?)}
                >Projectioning-er {if @lab.projection?, do: "OFF", else: "ON"}</button><button
                  id="flat-toggle"
                  phx-click="operation"
                  phx-value-op="flat"
                  disabled={!@lab.projection? || !@record || @lab.craft.open?}
                >{if @lab.flat?, do: "Diorama Regard", else: "Flat / relational Regard"}</button>
              </div>
            </div>
          </div>
          <p id="architecture-status" role="status">{@message}</p>
        </section>
        <div class="architecture-bench-footing">
          <p id="architecture-from">CONSEQUENTIAL FROM / {@lab.standing["from"]}</p><p id="architecture-passage">
            STEP ancestry / {length(@lab.standing["passages"])}
          </p><p>Save this URL to resume Standing. Handling and Regard reset on reload.</p>
        </div>
        <details id="development-instruments" class="architecture-dev">
          <summary>Engineering instruments / earlier constitutional test controls</summary><p>
            These controls preserve the first-pass domain test bench. The toy craft above is the bodily rehearsal.
          </p><div class="architecture-button-row">
            <button
              :for={
                {op, label} <- [
                  {"calibrate", "Exercise Pointing-able calibration"},
                  {"position", "Place projected TC in Little Square Chair"},
                  {"appoint", "Appoint projected TC FOR actual TC"}
                ]
              }
              id={"zeroeth-#{op}"}
              phx-click="operation"
              phx-value-op={op}
              disabled={!Architecture.available?(@lab, labor(op)) || !@record}
            >{label}</button>
          </div><button
            id="quiet-enclosure-fixture"
            phx-click="fixture"
            disabled={!Architecture.zeroeth_complete?(@lab) || !@record}
          >Compose FROM ONE: {if Architecture.quiet_complete?(@lab), do: "remove", else: "furnish"} receiving enclosure fixture</button><p>
            Development fixture only. No constitutional repair labor is performed from within the Tunnel.
          </p>
        </details>
        <.composer
          lab={@lab}
          record={@record}
          editing={@editing}
          material_form={@material_form}
          selection_form={@selection_form}
          material_options={@material_options}
          toy_form={@toy_form}
          toy_id={@toy_id}
          toy_selection_form={@toy_selection_form}
          toy_options={@toy_options}
        />
      </main>
    </Layouts.app>
    """
  end

  defp labor("calibrate"), do: :calibrate
  defp labor("position"), do: :position
  defp labor("appoint"), do: :appoint

  defp composer(assigns) do
    ~H"""
    <section id="composement" class="architecture-composer" aria-labelledby="composement-title">
      <header>
        <p>ENGINEERING / COMPOSEMENTING LABORATORY</p><h2 id="composement-title">Material ledger</h2><p>
          Author material FROM a Stationing locality. Placement does not furnish its consequential dependencies.
        </p>
      </header>
      <.form for={@selection_form} id="material-selection" phx-change="choose-material">
        <.input
          field={@selection_form[:id]}
          type="select"
          label="Registered material"
          options={@material_options}
        />
      </.form>
      <button id="material-new" phx-click="new-material" disabled={!@record}>Register new material</button>
      <.form
        for={@material_form}
        id="material-editor"
        phx-submit="save-material"
        class="architecture-editor"
      >
        <.input field={@material_form[:title]} label="Inscription / title" />
        <.input
          field={@material_form[:text]}
          type="textarea"
          rows="5"
          label="Material / revisable language"
        />
        <div class="architecture-editor-grid">
          <.input
            field={@material_form[:origin]}
            type="select"
            label="Authored FROM locality"
            options={Seed.localities()}
          />
          <.input
            field={@material_form[:location]}
            type="select"
            label="Placement / locality or Tunnel"
            options={Seed.localities() ++ Enum.sort(Map.keys(@lab.standing["tunnels"]))}
          />
          <.input
            field={@material_form[:region]}
            type="select"
            label="Material region"
            options={Seed.regions()}
          />
          <.input
            field={@material_form[:bearing]}
            type="select"
            label="Regarding bearing (projection hint)"
            options={Seed.bearings()}
          />
          <.input
            field={@material_form[:course]}
            type="number"
            min="0"
            max="6"
            label="Tunnel course position (0–6)"
          />
          <.input type="hidden" name="material[categories][]" id="empty-material-categories" value="" />
          <.input
            field={@material_form[:categories]}
            type="select"
            multiple
            options={Seed.categories()}
            label="Responsibilities / choose one or more"
          />
          <.input
            type="hidden"
            name="material[dependencies][]"
            id="empty-material-dependencies"
            value=""
          />
          <.input
            field={@material_form[:dependencies]}
            type="select"
            multiple
            options={Architecture.dependency_ids(@lab)}
            label="Actual relation dependencies (optional)"
          />
        </div>
        <button id="material-save" disabled={!@record}>Save material and placement</button>
      </.form>
      <details id="material-provenance">
        <summary>Selected material provenance</summary>
        <p :for={entry <- get_in(@lab.standing, ["materials", @editing, "provenance"]) || []}>
          Revision {entry["revision"]} / FROM {entry["origin"]} / {entry["action"]}
        </p>
      </details>
      <details id="toy-box-ledger">
        <summary>Canonical Toy Box / {map_size(@lab.standing["toys"])} shared items</summary>
        <.form for={@toy_selection_form} id="toy-selection" phx-change="choose-toy">
          <.input
            field={@toy_selection_form[:id]}
            type="select"
            options={@toy_options}
            label="Apparatus identity"
          />
        </.form>
        <.form for={@toy_form} id="toy-editor" phx-submit="save-toy" class="architecture-editor">
          <.input field={@toy_form[:label]} label="Apparatus / working morphology" />
          <.input
            field={@toy_form[:encounter]}
            type="select"
            options={Seed.localities()}
            label="Current encounter / locality"
          />
          <.input field={@toy_form[:aim]} label="Stationing Aim / furnished job or branding" />
          <.input type="hidden" name="toy[dependencies][]" id="empty-toy-dependencies" value="" />
          <.input
            field={@toy_form[:dependencies]}
            type="select"
            multiple
            options={Architecture.dependency_ids(@lab)}
            label="Dependencies"
          />
          <.input field={@toy_form[:pretendingable]} type="checkbox" label="Pretendingable furnished" />
          <.input
            field={@toy_form[:usingable]}
            type="checkbox"
            label="Usingable furnished (also requires actual dependencies)"
          />
          <.input field={@toy_form[:job]} type="textarea" label="Consequential job" />
          <.input field={@toy_form[:provenance]} type="textarea" label="Provenance" />
          <.input field={@toy_form[:notes]} type="textarea" label="Notes / unresolved morphology" />
          <p id="toy-availability">
            {if @lab.standing["toys"][@toy_id]["usingable"] &&
                  Architecture.dependencies_hold?(
                    @lab,
                    @lab.standing["toys"][@toy_id]["dependencies"]
                  ),
                do: "Usingable",
                else: "Inspectable / Usingability not furnished"}
          </p>
          <button id="toy-save" disabled={!@record}>Save shared apparatus record</button>
        </.form>
      </details>
      <details id="locality-register">
        <summary>Seven locality identities / composing conjectures</summary><dl>
          <div :for={id <- Seed.localities()}>
            <dt>{id}</dt><dd>{@lab.standing["localities"][id]["aim"]}</dd>
          </div>
        </dl><p>
          Rail order does not establish dependency. Only the ZEROETH → ONE slice is driveable.
        </p>
      </details>
    </section>
    """
  end
end
