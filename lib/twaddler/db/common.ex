defmodule Twaddler.Db.Common do
  import Ecto.Changeset

  def check_uuid(changeset) do
    case get_field(changeset, :uuid) do
      nil -> put_change(changeset, :uuid, UUID.uuid4())
      _ -> changeset
    end
  end
end
