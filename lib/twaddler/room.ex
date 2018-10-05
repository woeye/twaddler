defmodule Twaddler.Room do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end)
  end

  def get_messages(room) do
    Agent.get(room, fn state -> state end)
  end

  def post_message(room, message_data) do
    Agent.get_and_update(room, fn state ->
      {:ok, state ++ [message_data]}
    end)
  end

end
