defmodule ReadyToChatWeb.Room.NewLive do
  
  use ReadyToChatWeb, :live_view

  alias ReadyToChat.Repo
  alias ReadyToChat.Organizer.Room

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Create A New Room</h1>
    <div>
      <%= form_for @changeset, "#", [phx_change: "validate", phx_submit: "save"], fn f -> %>
        <%= text_input f, :title, placeholder: "Title" %>
        <%= error_tag f, :title %>
        <%= text_input f, :slug, placeholder: "room-slug" %>
        <%= error_tag f, :slug %>
        <%= submit "Save" %>
      <% end %>
    </div>
    """
  end


  #------------------------------------------------------------------------
  # mount/3 
  # Required for LiveView to work. The callback provides the socket.
  # The call to put_changeset/2 will add a new Room changeset to the socket.
  #------------------------------------------------------------------------
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> put_changeset()
    }
  end

  #------------------------------------------------------------------------
  # handle_event/3 
  # Event for validate is called everytime a user input changes
  #------------------------------------------------------------------------
  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    {:ok,
      socket
      |> put_changeset(room_params)
    }
  end

  def handle_event("save", _, %{assigns: %{changeset: changeset}} = socket) do
    case Repo.insert(changeset) do
      {:ok, room} ->
        {:noreply,
          socket
          |> push_redirect(to: Routes.room_show_path(socket, :show, room.slug))
        }
      {:error, changeset} ->
        {:noreply,
          socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, "Room could not be saved.")
        }
    end
  end

  defp put_changeset(socket, params \\ %{}) do
    socket
    |> assign(:changeset, Room.changeset(%Room{}, params))
  end

end