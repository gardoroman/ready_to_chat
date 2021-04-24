defmodule ReadyToChatWeb.Presence do
  use Phoenix.Presence,
    otp_app: :ready_to_chat,
    pubsub_server: ReadyToChat.PubSub
end