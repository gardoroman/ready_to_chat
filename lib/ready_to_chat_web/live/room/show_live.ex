defmodule ReadyToChatWeb.Room.ShowLive do
  @moduledoc """
  A LiveView for creating and joining chat rooms.
  """

  use ReadyToChatWeb, :live_view
  alias ReadyToChat.Organizer
  alias ReadyToChat.UserServices.ConnectedUser
  alias ReadyToChatWeb.Presence

  @impl true
  def render(assigns) do
    ~L"""
    <h1><%= @room.title %></h1>
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
        }
    end
  end

  defp create_connected_user, do: %ConnectedUser{uuid: UUID.uuid4()}


end