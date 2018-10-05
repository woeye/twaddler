defmodule Twaddler.Db.UUIDLoader do
  import Ecto.Query
  alias Twaddler.Repo

  def load_by_uuids(entity, uuids) do
    IO.puts "loading #{Kernel.inspect(entity)} by uuids"

    from(e in entity, where: e.uuid in ^MapSet.to_list(uuids))
    |> Repo.all
    |> Enum.reduce(%{}, fn (entity, acc) ->
      Map.put(acc, entity.uuid, entity)
    end)
  end
end
