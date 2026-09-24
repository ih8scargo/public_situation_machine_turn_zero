defmodule PublicSituationMachineTurnZeroWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as tables, forms, and
  inputs. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The foundation for styling is Tailwind CSS, a utility-first CSS framework,
  augmented with daisyUI, a Tailwind CSS plugin that provides UI components
  and themes. Here are useful references:

    * [daisyUI](https://daisyui.com/docs/intro/) - a good place to get
      started and see the available components.

    * [Tailwind CSS](https://tailwindcss.com) - the foundational framework
      we build on. You will use it for layout, sizing, flexbox, grid, and
      spacing.

    * [Heroicons](https://heroicons.com) - see `icon/1` for usage.

    * [Phoenix.Component](https://phoenix-live-view.hexdocs.pm/Phoenix.Component.html) -
      the component system used by Phoenix. Some components, such as `<.link>`
      and `<.form>`, are defined there.

  """
  use Phoenix.Component

  @doc """
  Renders one of the recurring constitutional voices used throughout the appliance.
  """
  attr :id, :string, required: true

  attr :voice, :atom,
    values: [
      :general_stewarding_offices,
      :institutional_standing,
      :appliance_narration,
      :inquiringmenting_appliance,
      :stewardly_guidance
    ],
    required: true

  attr :title, :string, default: nil
  attr :pretitle, :string, default: nil
  slot :inner_block, required: true

  def constitutional_voice(assigns) do
    ~H"""
    <section
      id={@id}
      class={["constitutional-voice", "constitutional-voice--#{@voice}"]}
      aria-labelledby={if(@title, do: "#{@id}-title", else: "#{@id}-kind")}
    >
      <header>
        <p id={"#{@id}-kind"} class="constitutional-voice__kind">
          {constitutional_voice_kind(@voice)}
        </p>
        <p :if={@pretitle} class="constitutional-voice__pretitle">{@pretitle}</p>
        <h3 :if={@title} id={"#{@id}-title"}>{@title}</h3>
      </header>
      <div class="constitutional-voice__body">{render_slot(@inner_block)}</div>
    </section>
    """
  end

  defp constitutional_voice_kind(:general_stewarding_offices),
    do: "The General Stewarding Offices of This Stewardshipmenting Appliance"

  defp constitutional_voice_kind(:institutional_standing), do: "Institutional Standing"
  defp constitutional_voice_kind(:appliance_narration), do: "Appliance Narrationing"
  defp constitutional_voice_kind(:inquiringmenting_appliance), do: "Inquiringmenting Appliance"
  defp constitutional_voice_kind(:stewardly_guidance), do: "Stewardly Guidance"

  attr :id, :string, required: true
  attr :from, :string, default: "Stewardly Availability"
  attr :toward, :string, default: "Stewardly Co-Occupancyingship"
  attr :from_label, :string, default: "Continuing from:"
  attr :toward_label, :string, default: "Continuing toward:"

  def rail_wayfinding_card(assigns) do
    ~H"""
    <section
      id={@id}
      class="field-page__rail-wayfinding-card"
      aria-labelledby={"#{@id}-title"}
    >
      <h3 id={"#{@id}-title"}>The Constitutional Furnishmenting Outer Rail Line</h3>
      <dl>
        <div>
          <strong>XT</strong>
          <dt>{@from_label}</dt>
          <dd>{@from}</dd>
        </div>
        <div>
          <strong>YT</strong>
          <dt>{@toward_label}</dt>
          <dd>{@toward}</dd>
        </div>
      </dl>
    </section>
    """
  end

  attr :id, :string, required: true
  attr :parkinging_stand, :string, required: true
  attr :shackling_pin, :string, required: true
  attr :piece_of_time, :string, required: true
  attr :situationing_piece_of_time, :string, default: nil
  attr :first_appointmenting_piece_of_time, :string, default: nil
  attr :earthly_locality_piece_of_time, :string, default: nil
  attr :pet_name, :string, default: nil
  attr :lanterning_furnished?, :boolean, default: false
  attr :earthly_locality, :string, default: nil
  attr :cabinet_id, :string, default: nil
  attr :stand_id, :string, default: nil
  attr :pin_id, :string, default: nil
  attr :time_id, :string, default: nil
  attr :standing_copy, :string, default: nil
  attr :sittinging_cabinets, :any, default: MapSet.new()

  def leashing_locality(assigns) do
    ~H"""
    <section
      id={@id}
      class="field-page__leashing-locality"
      phx-hook=".CopyFurnishing"
      aria-labelledby={"#{@id}-title"}
    >
      <header class="field-page__sittinging-heading">
        <h2 id={"#{@id}-title"}>The Sittinging-In Room</h2>
        <p class="field-page__sittinging-subtitle">
          The Zeroeth Constitutional Locality of This One Tuple Ship
        </p>
      </header>

      <div class="field-page__sittinging-voices field-page__sittinging-inquiry-voice">
        <.constitutional_voice
          id={"#{@id}-inquiringmenting-appliance"}
          voice={:inquiringmenting_appliance}
        >
          <p>
            As a Constitutioning Human, what am I Sittinging-In with in my Situationings Here, upon This One Piece of Time?
          </p>
        </.constitutional_voice>
      </div>

      <h3 class="field-page__human-affordmentings-title">
        This Constitutioning Human's Stewardly Affordmentings
      </h3>

      <div class="field-page__sittinging-cabinets">
        <section
          id={"#{@id}-sittinging-xt-cabinet"}
          class="field-page__sittinging-cabinet"
          aria-labelledby={"#{@id}-sittinging-xt-cabinet-title"}
        >
          <p class="field-page__relation-label">XT</p>
          <h3 id={"#{@id}-sittinging-xt-cabinet-title"}>This One Presence Cabinet</h3>
          <button
            id={"#{@id}-toggle-sittinging-xt-cabinet"}
            type="button"
            class="field-page__cabinet-door"
            aria-expanded={to_string(MapSet.member?(@sittinging_cabinets, :xt))}
            phx-click="toggle-sittinging-cabinet"
            phx-value-cabinet="xt"
          >
            {if MapSet.member?(@sittinging_cabinets, :xt),
              do: "Close XT Cabinet",
              else: "Open XT Cabinet"}
          </button>
          <p
            :if={MapSet.member?(@sittinging_cabinets, :xt)}
            class="field-page__cabinet-inquiry"
          >
            What is feeling Present to me Here?
          </p>
        </section>

        <section
          id={"#{@id}-sittinging-yt-cabinet"}
          class="field-page__sittinging-cabinet"
          aria-labelledby={"#{@id}-sittinging-yt-cabinet-title"}
        >
          <p class="field-page__relation-label">YT</p>
          <h3 id={"#{@id}-sittinging-yt-cabinet-title"}>This One Absence Cabinet</h3>
          <button
            id={"#{@id}-toggle-sittinging-yt-cabinet"}
            type="button"
            class="field-page__cabinet-door"
            aria-expanded={to_string(MapSet.member?(@sittinging_cabinets, :yt))}
            phx-click="toggle-sittinging-cabinet"
            phx-value-cabinet="yt"
          >
            {if MapSet.member?(@sittinging_cabinets, :yt),
              do: "Close YT Cabinet",
              else: "Open YT Cabinet"}
          </button>
          <p
            :if={MapSet.member?(@sittinging_cabinets, :yt)}
            class="field-page__cabinet-inquiry"
          >
            What is feeling Absent to me Here within what is Present to me Here?
          </p>
        </section>
      </div>

      <div
        class="field-page__constitutional-divider field-page__sittinging-divider"
        aria-hidden="true"
      >
      </div>

      <section
        id={"#{@id}-instrumentation"}
        class="field-page__captain-shelves field-page__instrumentation-shelves"
        aria-labelledby={"#{@id}-instrumentation-title"}
      >
        <h5 id={"#{@id}-instrumentation-title"}>Stewardly Instrumentationing</h5>
        <div class="field-page__shelf-column-headings">
          <section><strong>XT</strong><span>Constitutioning Human Affordmentings</span></section>
          <section><strong>YT</strong><span>Stewardly Furnishingments</span></section>
        </div>
        <ol>
          <li
            :for={{{affordmenting, purpose}, index} <- Enum.with_index(formed_human_affordmentings())}
            class="field-page__constitutional-shelf"
          >
            <section class="field-page__shelf-half" aria-label="XT">
              <strong>{affordmenting}</strong>
              <span class="field-page__appointmenting-purpose">{purpose}</span>
            </section>
            <section class="field-page__shelf-half" aria-label="YT">
              <strong :if={index == 0}>The Zeroeth Stewardly Furnishingment</strong>
              <span :if={index == 0} class="field-page__appointmenting-purpose">
                This Stewardly Captain COB
              </span>
            </section>
          </li>
        </ol>
      </section>

      <header class="field-page__constitutional-locality-heading">
        <p>This One Tuple Ship</p>
        <span>Standing within OUR CANONICAL TUPLE</span>
      </header>
      <section :if={@pet_name || @earthly_locality} class="field-page__formed-tuple-relations">
        <p :if={@pet_name}>{@pet_name}</p>
        <div :if={@earthly_locality}>
          <strong>Visionizingmentablement</strong>
          <p>{@earthly_locality}</p>
        </div>
      </section>
      <div class="field-page__constitutional-divider" aria-hidden="true"></div>

      <div class="field-page__captain-shelves" aria-labelledby={"#{@id}-shelving-title"}>
        <h5 id={"#{@id}-shelving-title"}>THIS STEWARDLY CAPTAIN COB'S SHELVES</h5>
        <div class="field-page__shelf-column-headings">
          <section>
            <strong>XT</strong>
            <span>Stewardly Captain COB Appointmentings</span>
          </section>
          <section>
            <strong>YT</strong>
            <span>Stewardly Furnishingments</span>
          </section>
        </div>
        <ol>
          <li
            :for={
              {{appointmenting, purpose}, index} <- Enum.with_index(formed_tuple_appointmentings())
            }
            class="field-page__constitutional-shelf"
          >
            <section class="field-page__shelf-half" aria-label="XT">
              <strong>{appointmenting}</strong>
              <span class="field-page__appointmenting-purpose">{purpose}</span>
            </section>
            <section class="field-page__shelf-half" aria-label="YT">
              <strong :if={index == 0}>The Zeroeth Stewardly Furnishingment</strong>
              <span :if={index == 0} class="field-page__appointmenting-purpose">
                This One Spoolinging Ratchetingable Unicycle with a Single Pedal Revolvinging about its Central Axis
              </span>
            </section>
          </li>
        </ol>
      </div>
      <p :if={@standing_copy} class="field-page__leashing-standing-copy">{@standing_copy}</p>

      <section
        id={@time_id}
        class="field-page__locality-commencement field-page__credentials-ground field-page__re-shackling-time-ground"
      >
        <span>THIS ONE PIECE OF TIME</span>
        <strong>{@piece_of_time}</strong>
      </section>

      <header class="field-page__leashing-landing-heading">
        <h3>This One Leashing Landing</h3>
      </header>

      <div class="field-page__leashing-instruments">
        <section class="field-page__instrument field-page__instrument--stand" aria-label="XT">
          <span class="field-page__artifact-relation">XT</span>
          <span>Parkinginging Stand Number</span>
          <strong id={@stand_id} data-value={@parkinging_stand}>{@parkinging_stand}</strong>
          <button
            type="button"
            data-copy={@parkinging_stand}
            aria-label="Copy Parkinginging Stand Number"
            title="Copy Parkinginging Stand Number"
          >
            <.icon name="hero-document-duplicate" class="size-4" />
          </button>
          <p data-copy-status aria-live="polite"></p>
        </section>

        <section
          class="field-page__secret-cabinet field-page__secret-cabinet--fixed"
          aria-label="YT"
        >
          <span class="field-page__artifact-relation">YT</span>
          <details id={@cabinet_id || "#{@id}-secret-cabinet"}>
            <summary>▸ This One Secret Cabinet</summary>
            <div class="field-page__secret-cabinet-interior">
              <span>This One Shackling Pin</span>
              <strong id={@pin_id} data-value={@shackling_pin}>{@shackling_pin}</strong>
            </div>
          </details>
          <button
            type="button"
            data-copy={@shackling_pin}
            aria-label="Copy Shackling Pin"
            title="Copy Shackling Pin"
          >
            <.icon name="hero-document-duplicate" class="size-4" />
          </button>
          <p data-copy-status aria-live="polite"></p>
        </section>
      </div>

      <details id={"#{@id}-utility"} class="field-page__leashing-utility">
        <summary>Utility</summary>
        <div>
          <p>
            This One Terrestrial Computer Free Parkinginging Stand Number need not be kept secret.
          </p>
          <p>This One Shackling Pin should be preserved in a Secret Some Place.</p>
        </div>
      </details>

      <script :type={Phoenix.LiveView.ColocatedHook} name=".CopyFurnishing">
        export default {
          mounted() {
            this.el.addEventListener("click", async (event) => {
              const button = event.target.closest("[data-copy]")
              if (!button) return

              const locality = button.closest(".field-page__instrument, .field-page__secret-cabinet")
              const status = locality?.querySelector("[data-copy-status]")

              try {
                await navigator.clipboard.writeText(button.dataset.copy)
                if (status) status.textContent = "Copiedmenting ✓"
              } catch (_error) {
                if (status) status.textContent = "Copy unavailable."
              }
            })
          }
        }
      </script>
    </section>
    """
  end

  defp formed_tuple_appointmentings do
    [
      {"The Zeroeth Appointmenting", "This One Situationing"},
      {"The First Appointmenting", "Encounteringmentablement"},
      {"The Second Appointmenting", "Distinguishingmenting"},
      {"The Third Appointmenting", "Roomingmentingableroomingablement"},
      {"The Fourth Appointmenting", "This One Purchase Surface"},
      {"The Fifth Appointmenting", "Excursioningmenting"},
      {"The Sixth Appointmenting", "Embroideringmentingenablementingedably"}
    ]
  end

  defp formed_human_affordmentings do
    [
      {"The Zeroeth Affordmenting", "The Ability to Regard"},
      {"The First Affordmenting", "The Ability to Encounter"},
      {"The Second Affordmenting", "The Ability to Distinguish"},
      {"The Third Affordmenting", "The Ability to Make Room"},
      {"The Fourth Affordmenting", "The Ability to Gain Purchase"},
      {"The Fifth Affordmenting", "The Ability to Excursion"},
      {"The Sixth Affordmenting", "The Ability to Embroiderize"}
    ]
  end

  use Gettext, backend: PublicSituationMachineTurnZeroWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash
        id="welcome-back"
        kind={:info}
        phx-mounted={show("#welcome-back") |> JS.remove_attribute("hidden")}
        hidden
      >
        Welcome Back!
      </.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="toast toast-top toast-end z-50"
      {@rest}
    >
      <div class={[
        "alert w-80 sm:w-96 max-w-80 sm:max-w-96 text-wrap",
        @kind == :info && "alert-info",
        @kind == :error && "alert-error"
      ]}>
        <.icon :if={@kind == :info} name="hero-information-circle" class="size-5 shrink-0" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle" class="size-5 shrink-0" />
        <div>
          <p :if={@title} class="font-semibold">{@title}</p>
          <p>{msg}</p>
        </div>
        <div class="flex-1" />
        <button type="button" class="group self-start cursor-pointer" aria-label={gettext("close")}>
          <.icon name="hero-x-mark" class="size-5 opacity-40 group-hover:opacity-70" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Renders a button with navigation support.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" variant="primary">Send!</.button>
      <.button navigate={~p"/"}>Home</.button>
  """
  attr :rest, :global, include: ~w(href navigate patch method download name value disabled)
  attr :class, :any
  attr :variant, :string, values: ~w(primary)
  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    variants = %{"primary" => "btn-primary", nil => "btn-primary btn-soft"}

    assigns =
      assign_new(assigns, :class, fn ->
        ["btn", Map.fetch!(variants, assigns[:variant])]
      end)

    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link class={@class} {@rest}>
        {render_slot(@inner_block)}
      </.link>
      """
    else
      ~H"""
      <button class={@class} {@rest}>
        {render_slot(@inner_block)}
      </button>
      """
    end
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as radio, are best
  written directly in your templates.

  ## Examples

  ```heex
  <.input field={@form[:email]} type="email" />
  <.input name="my-input" errors={["oh no!"]} />
  ```

  ## Select type

  When using `type="select"`, you must pass the `options` and optionally
  a `value` to mark which option should be preselected.

  ```heex
  <.input field={@form[:user_type]} type="select" options={["Admin": "admin", "User": "user"]} />
  ```

  For more information on what kind of data can be passed to `options` see
  [`options_for_select`](https://phoenix-html.hexdocs.pm/Phoenix.HTML.Form.html#options_for_select/2).
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week hidden)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :class, :any, default: nil, doc: "the input class to use over defaults"
  attr :error_class, :any, default: nil, doc: "the input error class to use over defaults"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={@value} {@rest} />
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="fieldset mb-2">
      <label for={@id}>
        <input
          type="hidden"
          name={@name}
          value="false"
          disabled={@rest[:disabled]}
          form={@rest[:form]}
        />
        <span class="label">
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value="true"
            checked={@checked}
            class={@class || "checkbox checkbox-sm"}
            {@rest}
          />{@label}
        </span>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class="fieldset mb-2">
      <label for={@id}>
        <span :if={@label} class="label mb-1">{@label}</span>
        <select
          id={@id}
          name={@name}
          class={[@class || "w-full select", @errors != [] && (@error_class || "select-error")]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class="fieldset mb-2">
      <label for={@id}>
        <span :if={@label} class="label mb-1">{@label}</span>
        <textarea
          id={@id}
          name={@name}
          class={[
            @class || "w-full textarea",
            @errors != [] && (@error_class || "textarea-error")
          ]}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div class="fieldset mb-2">
      <label for={@id}>
        <span :if={@label} class="label mb-1">{@label}</span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            @class || "w-full input",
            @errors != [] && (@error_class || "input-error")
          ]}
          {@rest}
        />
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # Helper used by inputs to generate form errors
  defp error(assigns) do
    ~H"""
    <p class="mt-1.5 flex gap-2 items-center text-sm text-error">
      <.icon name="hero-exclamation-circle" class="size-5" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", "pb-4"]}>
      <div>
        <h1 class="text-lg font-semibold leading-8">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="text-sm text-base-content/70">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc """
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <table class="table table-zebra">
      <thead>
        <tr>
          <th :for={col <- @col}>{col[:label]}</th>
          <th :if={@action != []}>
            <span class="sr-only">{gettext("Actions")}</span>
          </th>
        </tr>
      </thead>
      <tbody id={@id} phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}>
        <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
          <td
            :for={col <- @col}
            phx-click={@row_click && @row_click.(row)}
            class={@row_click && "hover:cursor-pointer"}
          >
            {render_slot(col, @row_item.(row))}
          </td>
          <td :if={@action != []} class="w-0 font-semibold">
            <div class="flex gap-4">
              <%= for action <- @action do %>
                {render_slot(action, @row_item.(row))}
              <% end %>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <ul class="list">
      <li :for={item <- @item} class="list-row">
        <div class="list-col-grow">
          <div class="font-bold">{item.title}</div>
          <div>{render_slot(item)}</div>
        </div>
      </li>
    </ul>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in `assets/vendor/heroicons.js`.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(
        PublicSituationMachineTurnZeroWeb.Gettext,
        "errors",
        msg,
        msg,
        count,
        opts
      )
    else
      Gettext.dgettext(PublicSituationMachineTurnZeroWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
