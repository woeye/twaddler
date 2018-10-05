defmodule Twaddler.ChatStore do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def create_room(uuid) do
    Agent.update(__MODULE__, fn state -> Map.put(state, uuid, []) end)
  end

  def get_messages(room) do
    Agent.get(__MODULE__, fn state -> state[room] end)
  end

  def post_message(room, message_data) do
    Agent.update(__MODULE__, fn state -> Map.update!(state, room, &(&1 ++ [message_data])) end)
  end
end