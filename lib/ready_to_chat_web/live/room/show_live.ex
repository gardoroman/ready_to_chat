defmodule ReadyToChatWeb.Room.ShowLive do
  @moduledoc """
  A LiveView for creating and joining chat rooms.
  """

  use ReadyToChatWeb, :live_view
  alias ReadyToChat.Organizer
  alias ReadyToChat.UserServices.ConnectedUser
  alias ReadyToChatWeb.Presence
  alias Phoenix.Socket.Broadcast

  @impl true
  def render(assigns) do
    ~L"""
    <h1><%= @room.title %></h1>
    <h3>Connected Users</h3>
    <ul>
      <%= for uuid <- @connected_users do %>
        <li><%= uuid %></li>
      <% end %>
    </ul>

    <video id="local-video" playsinline autoplay muted width="600"></video>

    <button id="join-call" class="button" phx-hook="JoinCall">Join Call</button>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do

    user = create_connected_user()

    Phoenix.PubSub.subscribe(ReadyToChat.PubSub, "room:" <> slug)
    {:ok, _} = Presence.track(self(), "room:" <> slug, user.uuid, %{})

    case Organizer.get_room(slug) do
      nil ->
        {:ok,
          socket
          |> put_flash(:error, "Room does not exist")
          |> push_redirect(to: Routes.room_new_path(socket, :new))
        }
      room ->
        {:ok,
          socket
          |> assign(:room, room)
          |> assign(:user, user)
          |> assign(:slug, slug)
          |> assign(:connected_users, [])
        }
    end
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply,
      socket
      |> assign(:connected_users, list_present(socket))
    }
  end

  defp list_present(socket) do
    Presence.list("room:" <> socket.assigns.slug)
    |> Enum.map(fn {k, _} -> k end)
  end

  defp create_connected_user, do: %ConnectedUser{uuid: UUID.uuid4()}


end