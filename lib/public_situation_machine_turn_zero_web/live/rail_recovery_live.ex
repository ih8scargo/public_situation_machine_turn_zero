defmodule PublicSituationMachineTurnZeroWeb.RailRecoveryLive do
  use PublicSituationMachineTurnZeroWeb, :live_view
  alias PublicSituationMachineTurnZero.Workshop.RailRecovery, as: Recovery

  @stands ~w(overview ordinary upstanding rim-seat table-plan table-section axle TC THREE FOUR corner cubical deformation tunneling pointer N-M-before N-M-within N-M-after)
  def mount(_, _, socket) do
    {:ok,
     socket |> assign(:page_title, "Rail and half-twist recovery") |> put_model(1, "overview")}
  end

  def handle_event("inspect", %{"inspection" => p}, socket) do
    if p["stand"] in @stands and p["hand"] in ["1", "-1"] do
      {:noreply, put_model(socket, String.to_integer(p["hand"]), p["stand"])}
    else
      {:noreply, put_flash(socket, :error, "Choose an available inspection stand and candidate.")}
    end
  end

  defp put_model(socket, hand, stand) do
    m = Recovery.model(hand)

    assign(socket,
      model: m,
      stand: stand,
      stands: @stands,
      inspection: to_form(%{"hand" => "#{hand}", "stand" => stand}, as: :inspection),
      views: Enum.map(~w(plan section located), &scene(m, &1, stand))
    )
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_locality={:appliance} show_navigation={false}>
      <main id="rail-recovery" class="rr-workshop" data-authority="engineering-only">
        <header>
          <p class="rr-eyebrow">Engineering Hall · recovery candidates</p>
          <h1>Rail line / wedgings / ribbon</h1>
          <p>25 retained identities. One N → M half-twist. Handedness unappointed.</p>
          <.link navigate={~p"/workshop/wedging-geometry"}>Return to the preserved Snail House workshop →</.link>
        </header>
        <aside id="rr-registration-warning">
          Metric registration is blocked. The existing trial letter course is unchanged;
          unit CUBICAL boundaries and occupied appliance profiles below are engineering candidates.
          The source curve has no confirmed transform into the octagonal Gallery.
        </aside>
        <.form for={@inspection} id="rr-inspection" phx-change="inspect" class="rr-controls">
          <.input
            field={@inspection[:stand]}
            type="select"
            label="Repeatable Regarding stand"
            options={@stands}
          />
          <.input
            field={@inspection[:hand]}
            type="select"
            label="Half-twist candidate, about forward tangent"
            options={[{"+180° candidate", "1"}, {"−180° candidate", "-1"}]}
          />
        </.form>
        <p id="rr-standing" data-index="unchanged">
          Inspection only · no RE-STEP · no new Footing · fixed Table and HERE · NEXT remains distinct.
        </p>
        <section class="rr-views" aria-label="Paired source-world Regards">
          <article :for={v <- @views}>
            <h2>{v.kind} · {@stand}</h2>
            <p>Camera eye {coord(v.eye)} · target {coord(v.target)}</p>
            <svg
              id={"rr-#{v.kind}"}
              viewBox="0 0 760 520"
              role="img"
              aria-label={"#{v.kind} registered candidate geometry"}
            >
              <polygon
                :for={f <- v.faces}
                points={f.points}
                fill={f.color}
                fill-opacity="0.72"
                stroke="#a5adb8"
                stroke-width="0.4"
              >
                <title>{f.title}</title>
              </polygon>
              <path :for={l <- v.lines} d={l.path} stroke={l.color} fill="none" stroke-width="1">
                <title>{l.title}</title>
              </path>
              <g :for={l <- v.labels} tabindex="0" role="img" aria-label={l.title}>
                <circle cx={l.x} cy={l.y} r="8" fill="transparent" />
                <text x={l.x} y={l.y} fill="#f7f7f7" font-size="11">{l.text}</text>
                <title>{l.title}</title>
              </g>
            </svg>
          </article>
        </section>
        <section id="rr-orientation">
          <h2>N → M Half-Twist inspection stand</h2>
          <p>
            The roll is confined to source purchases 17.5–18.5: the last half of N18 and first half of M19. This span is a trial support length, not a new letter extent. No straight section is inserted.
          </p>
          <p>
            Blue and amber indicate the material face relative to the rotation-minimizing transported frame. They do not exchange HEAD and TAIL.
          </p>
          <div class="rr-scroll">
            <table>
              <thead>
                <tr>
                  <th>Purchase</th><th>Source point</th><th>Roll</th><th>Face / transported frame</th>
                </tr>
              </thead><tbody>
                <tr :for={f <- @model.ribbon.twist} id={"rr-roll-#{f.purchase}"} data-roll={f.roll}>
                  <td>{f.purchase}</td><td>{coord(f.point)}</td><td>
                    {Float.round(f.roll * 180 / :math.pi(), 2)}°
                  </td><td>{Float.round(Recovery.dot(f.across, f.base), 5)}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p id="rr-clearance">
            Both candidates remain unqualified. Selected candidate's minimum octagonal identity-overlay support margin: {Float.round(
              @model.ribbon.clearance.minimum_identity_overlay_gallery_margin,
              6
            )} source units.
            Negative means outside that trial overlay. This is not a physically registered Gallery clearance.
            Support contact is intended; support strain, ribbon self-intersection and finite passage remain uncertified.
          </p>
        </section>
        <section>
          <h2>25 letter identities / candidate bounded extents</h2>
          <div class="rr-scroll">
            <table id="rr-letters">
              <thead>
                <tr>
                  <th>Ordinal</th><th>Letter / word</th><th>Source center</th><th>
                    Predecessor → successor
                  </th>
                </tr>
              </thead><tbody>
                <tr :for={l <- @model.letters} id={"rr-letter-#{l.ordinal}"} data-source={l.id}>
                  <td>{l.ordinal}</td><td>{l.letter} / {l.word}</td><td>{coord(l.center)}</td><td>
                    {l.predecessor} → {l.successor}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <p id="rr-corner">
            THE → PUBLIC: indexed 90° bearing fixture retained separately. The original source remains curved; it has not been silently replaced.
          </p>
        </section>
        <section id="rr-appliance">
          <h2>Seated appliance: candidate occupied profiles</h2>
          <p>
            Ground is independently Y=0 in this trial frame. The fixed Table is diameter 3; its trial slab is Y=−0.1..0. Human eye TWO=[0,0,−1.5], monitor THREE=[0,0,−0.5], Wall FOUR=[0,0,0.5]. Eye/monitor separation is one extent. These assignments do not transform the old Snail body.
          </p>
          <p>
            XT at the left elbow: clockwise looking from Human toward the gear face (+Z). YT below: counterclockwise in that same convention. Profiles reserve finite occupancy; no meshing, transmission or earned rotation is claimed.
          </p>
          <ul>
            <li :for={o <- @model.apparatus}>
              {o.id}: center {coord(o.center)}, full dimensions {coord(Recovery.scale(o.half, 2))} · {o.kind}
            </li>
          </ul>
          <h3>Trial solid collisions</h3>
          <ul id="rr-collisions">
            <li :for={c <- @model.collisions}>{c.a} ↔ {c.b}: {c.classification}</li>
          </ul>
          <p>
            Reservations are not solids. Table uses a separate round slab; interfaces with it remain unresolved, not certified clear by the box test.
          </p>
        </section>
        <section id="rr-material">
          <h2>Material / pointer ancestry</h2>
          <p>
            Ribbon {@model.ribbon.id} · HEAD {@model.ribbon.head} → TAIL {@model.ribbon.tail}. 200 support intervals retain source purchase order, independent of the 25 letter identities.
          </p>
          <p>
            Pointer {@model.pointer.id}: material {@model.pointer.material}, support {@model.pointer.support}, FROM {coord(
              @model.pointer.from
            )} TOWARD {coord(@model.pointer.toward)}. {@model.pointer.turn}. Public authority withheld.
          </p>
          <p>
            Quilling, Needle surrender, gathering, Road material, JANUSITE carrier, PINNING and fashioned Ribbonating remain separate offices in the preserved workshop. This mesh does not supply a payout mechanism, Gallery Door ownership, correspondencing eligibility, or a lawful RE-STEP.
          </p>
        </section>
        <section id="rr-yellow">
          <h2>Yellow / blocked relationships</h2><ul>
            <li :for={b <- @model.blockers}>{b}</li>
          </ul>
        </section>
      </main>
    </Layouts.app>
    """
  end

  defp coord(p), do: "[" <> Enum.map_join(p, ", ", &to_string(Float.round(&1 * 1.0, 4))) <> "]"

  def scene(m, kind, stand) do
    apparatus? =
      stand in ~w(ordinary upstanding rim-seat table-plan table-section axle TC THREE FOUR)

    focus =
      cond do
        stand == "N-M-before" -> 17.5
        stand == "N-M-within" -> 18.0
        stand == "N-M-after" -> 18.5
        stand == "tunneling" -> 18.0
        stand == "corner" -> 3.0
        stand == "cubical" -> 12.5
        stand == "deformation" -> 14.0
        stand == "pointer" -> 17.5
        true -> nil
      end

    target =
      cond do
        focus -> Recovery.source_sample(m.source, focus).point
        stand == "TC" -> [-8, 3, 0]
        apparatus? -> [0, 0, 0]
        true -> [1.6, 1.6, 1.6]
      end

    eye =
      cond do
        kind == "plan" or stand == "table-plan" -> Recovery.add(target, [0, 20, 0])
        kind == "section" or stand == "table-section" -> Recovery.add(target, [20, 0, 0])
        stand in ~w(ordinary rim-seat) -> [0, 0, -1.5]
        stand == "upstanding" -> [0, 0.6, -1.5]
        focus -> Recovery.add(target, [1.4, 0.7, -1.4])
        true -> Recovery.add(target, [14, 10, -16])
      end

    forward = Recovery.unit(Recovery.sub(target, eye))
    ref = if kind == "plan" or stand == "table-plan", do: [0, 0, 1], else: [0, 1, 0]
    right = Recovery.unit(Recovery.cross(forward, ref))
    up = Recovery.cross(right, forward)

    factor =
      cond do
        focus -> 225
        apparatus? -> 27
        true -> 70
      end

    project = fn p ->
      d = Recovery.sub(p, target)
      # Deliberately orthographic: no fake perspective or viewport-derived world units.
      [380 + factor * Recovery.dot(d, right), 260 - factor * Recovery.dot(d, up)]
    end

    polygon = fn points ->
      Enum.map_join(points, " ", fn p ->
        [x, y] = project.(p)
        "#{x},#{y}"
      end)
    end

    line = fn a, b, color, title ->
      [x, y] = project.(a)
      [u, v] = project.(b)
      %{path: "M#{x},#{y} L#{u},#{v}", color: color, title: title}
    end

    {faces, lines, labels} =
      if apparatus? do
        lines =
          for o <- m.apparatus,
              {a, b} <- Recovery.edges(),
              do:
                line.(
                  Enum.at(o.points, a),
                  Enum.at(o.points, b),
                  if(o.kind == :reservation, do: "#727780", else: "#d9c38e"),
                  o.id
                )

        rim =
          Enum.map(0..64, fn i ->
            a = 2 * :math.pi() * i / 64
            [1.5 * :math.cos(a), 0, 1.5 * :math.sin(a)]
          end)

        bottom = Enum.map(rim, &Recovery.add(&1, [0, -0.1, 0]))

        slab = [
          %{
            points: polygon.(rim),
            color: "#759aa1",
            title: "Fixed Table: diameter 3, trial thickness 0.1; Ground independent"
          },
          %{points: polygon.(bottom), color: "#51656d", title: "Table underside candidate"}
        ]

        labels =
          Enum.map(m.apparatus, fn o ->
            [x, y] = project.(o.center)

            %{
              x: x,
              y: y,
              text: o.id,
              title: o.id <> " " <> coord(o.center) <> " · " <> o.provenance
            }
          end)

        wheels =
          for o <- m.apparatus, o.id in ["XT-left-elbow", "YT-below-XT", "Steering-passage"] do
            radius = if o.id == "Steering-passage", do: 0.55, else: 0.3

            points =
              Enum.map(0..40, fn i ->
                a = i * 2 * :math.pi() / 40

                if o.id == "Steering-passage" do
                  Recovery.add(o.center, [radius * :math.cos(a), 0, radius * :math.sin(a)])
                else
                  Recovery.add(o.center, [radius * :math.cos(a), radius * :math.sin(a), 0])
                end
              end)

            %{
              points: polygon.(points),
              color: "#ba9366",
              title:
                o.id <>
                  " wheel silhouette within trial assembly; coupling and rim clearance unapproved"
            }
          end

        {slab ++ wheels, lines, labels}
      else
        selected =
          if focus,
            do: Enum.filter(m.ribbon.faces, &(&1.from >= focus - 1.5 and &1.to <= focus + 1.5)),
            else: m.ribbon.faces

        faces =
          Enum.flat_map(selected, fn f ->
            frame = Enum.at(m.ribbon.frames, round(f.from * 8))
            color = if Recovery.dot(frame.across, frame.base) >= 0, do: "#69b7d2", else: "#e2ac68"

            [
              %{
                points: polygon.(f.points),
                color: color,
                title: "#{f.material} #{f.from}→#{f.to}",
                depth:
                  Enum.map(f.points, &Recovery.dot(Recovery.sub(&1, eye), forward)) |> Enum.sum()
              },
              %{
                points: polygon.(f.back),
                color: "#986b46",
                title: f.material <> " finite back face",
                depth:
                  Enum.map(f.back, &Recovery.dot(Recovery.sub(&1, eye), forward)) |> Enum.sum()
              }
            ] ++
              Enum.map(
                [
                  [0, 1, 3, 2],
                  [4, 6, 7, 5],
                  [0, 4, 5, 1],
                  [2, 3, 7, 6],
                  [0, 2, 6, 4],
                  [1, 5, 7, 3]
                ],
                fn indices ->
                  %{
                    points: polygon.(Enum.map(indices, &Enum.at(f.support_points, &1))),
                    color: "#728174",
                    title: f.support <> " trial support volume",
                    depth:
                      Enum.map(indices, fn i ->
                        Recovery.dot(Recovery.sub(Enum.at(f.support_points, i), eye), forward)
                      end)
                      |> Enum.sum()
                  }
                end
              )
          end)

        letters =
          if focus, do: Enum.filter(m.letters, &(abs(&1.ordinal - focus) <= 2)), else: m.letters

        lines =
          for l <- letters,
              {a, b} <- Recovery.edges(),
              do:
                line.(
                  Enum.at(l.points, a),
                  Enum.at(l.points, b),
                  "#737b8a",
                  l.id <> " unit boundary candidate; metric fit blocked"
                )

        labels =
          Enum.map(letters, fn l ->
            [x, y] = project.(l.center)

            %{
              x: x,
              y: y,
              text: "#{l.letter}#{l.ordinal}",
              title: l.id <> " " <> coord(l.center) <> " · " <> l.provenance
            }
          end)

        gallery =
          Enum.chunk_every(m.gallery ++ [hd(m.gallery)], 2, 1, :discard)
          |> Enum.map(fn [a, b] ->
            line.(
              a,
              b,
              "#e6cb6c",
              "Original octagon; identity overlay only, transform unregistered"
            )
          end)

        fixture =
          if stand == "corner" do
            [
              line.(
                m.corner.incoming,
                m.corner.origin,
                "#faf2b3",
                "Independent indexed 90-degree fixture; not joined to curved source"
              ),
              line.(
                m.corner.origin,
                m.corner.outgoing,
                "#faf2b3",
                "Independent indexed 90-degree fixture; placement blocked"
              )
            ]
          else
            []
          end

        orientation =
          if focus do
            for f <- m.ribbon.twist,
                {v, color, name} <- [
                  {f.base, "#f5e2a8", "transported transverse"},
                  {f.across, "#e87ca0", "material transverse"}
                ] do
              line.(
                f.point,
                Recovery.add(f.point, Recovery.scale(v, 0.3)),
                color,
                "#{name} at #{f.purchase}"
              )
            end
          else
            []
          end

        {faces, lines ++ gallery ++ fixture ++ orientation, labels}
      end

    %{
      kind: kind,
      eye: eye,
      target: target,
      faces: Enum.sort_by(faces, &(-Map.get(&1, :depth, 0))),
      lines: lines,
      labels: labels
    }
  end
end
