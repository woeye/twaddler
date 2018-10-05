defmodule Twaddler.Db.RoleTest do
  use Twaddler.DataCase
  alias Twaddler.Db.Role
  alias Twaddler.Repo

  @valid_attr %{:name => "moo"}

  test "changeset must catch required fields" do
    changeset = Role.changeset(%Role{}, %{})
    refute changeset.valid?
  end

  test "changeset properly initializes role struct" do
    changeset = Role.changeset(%Role{}, @valid_attr)
    assert changeset.valid?

    assert Ecto.Changeset.get_field(changeset, :uuid) != nil
  end

end
