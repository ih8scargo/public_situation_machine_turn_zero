defmodule PublicSituationMachineTurnZeroWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use PublicSituationMachineTurnZeroWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  attr :active_locality, :atom, required: true

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header id="site-navigation" class="site-navigation">
      <nav aria-label="Primary navigation" class="site-navigation__inner">
        <.link
          navigate={~p"/"}
          class={["site-navigation__link", @active_locality == :landinging && "is-active"]}
          aria-current={@active_locality == :landinging && "page"}
        >
          This Landinging Page
        </.link>
        <.link
          navigate={~p"/our-canonical-tuple"}
          class={["site-navigation__link", @active_locality == :canonical_tuple && "is-active"]}
          aria-current={@active_locality == :canonical_tuple && "page"}
        >
          OUR CANONICAL TUPLE
        </.link>
        <.link
          navigate={~p"/the-appliance"}
          class={[
            "site-navigation__link",
            "site-navigation__link--appliance",
            @active_locality == :appliance && "is-active"
          ]}
          aria-current={@active_locality == :appliance && "page"}
        >
          THE APPLIANCE
        </.link>
        <.link
          navigate={~p"/this-tuple-ship-field"}
          class={["site-navigation__link", @active_locality == :tuple_ship_field && "is-active"]}
          aria-current={@active_locality == :tuple_ship_field && "page"}
        >
          This Tuple Ship Field
        </.link>
        <.link
          navigate={~p"/constitutioning-bearingings"}
          class={[
            "site-navigation__link",
            @active_locality == :constitutioning_bearingings && "is-active"
          ]}
          aria-current={@active_locality == :constitutioning_bearingings && "page"}
        >
          Constitutioning Bearingings
        </.link>
        <.link
          navigate={~p"/correspondencingments"}
          class={[
            "site-navigation__link",
            @active_locality == :correspondencingments && "is-active"
          ]}
          aria-current={@active_locality == :correspondencingments && "page"}
        >
          Correspondencingments
        </.link>
      </nav>
    </header>

    {render_slot(@inner_block)}

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Renders the shared constitutional threshold used at the top of every locality.
  """
  attr :title, :string, required: true
  attr :id, :string, required: true
  attr :reading, :string, default: "The Bearinging of Continuity Possibility"

  slot :description

  def locality_threshold(assigns) do
    ~H"""
    <div id={@id} class="locality-threshold">
      <header class="psm-masthead">
        <p class="psm-masthead__machine-name">PUBLIC-SITUATION-MACHINE-</p>
        <div class="psm-masthead__lower">
          <h1>{@title}</h1>
          <p>General Purpose Situationing Appliance</p>
        </div>
      </header>

      <section class="psm-oag" aria-labelledby={"#{@id}-orientationing-title"}>
        <div class="psm-oag__instrument-plate">
          <p class="psm-oag__eyebrow">
            The Same General Civilizationalizing Constitutioningable Geometry of Stewardly Inhabitationingment
          </p>
          <h2 id={"#{@id}-orientationing-title"}>Standinging in Regard</h2>
          <p class="psm-oag__reading">{@reading}</p>
        </div>

        <div class="psm-oag__description">
          <%= if @description != [] do %>
            {render_slot(@description)}
          <% else %>
            <p>By itself, the PUBLIC-SITUATION-MACHINE- cannot tell what is true.</p>
            <p>It may only ask what continues Holdinging.</p>
            <p>
              The appliance starts and ends by seatinging This Stewardly Captain COB to stand in Regard toward one lawful Situationing. Its instrumentationing distinguishes what continues Holdinging, what is becoming, and what stands ready for Traversaling through the next Discrete Turn.
            </p>
          <% end %>
        </div>
      </section>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 [[data-theme-source=system]_&]:!left-0 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
