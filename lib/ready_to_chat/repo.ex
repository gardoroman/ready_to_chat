defmodule ReadyToChat.Repo do
  use Ecto.Repo,
    otp_app: :ready_to_chat,
    adapter: Ecto.Adapters.Postgres
end
