defmodule Twaddler.Db.UserTest do
  use Twaddler.DataCase
  alias Twaddler.Db.User
  alias Twaddler.Repo

  @valid_attr %{:username => "moo", :email => "moo@foo.net", :password => "12345"}

  test "changeset must catch required fields" do
    changeset = User.changeset(%User{}, %{})
    refute changeset.valid?
  end

  test "changeset properly initializes user struct" do
    changeset = User.changeset(%User{}, @valid_attr)
    assert changeset.valid?

    assert Ecto.Changeset.get_field(changeset, :password_hash) != nil
    assert Ecto.Changeset.get_field(changeset, :uuid) != nil
  end

  test "changeset keeps exiting uuid" do
    changeset = User.changeset(%User{:uuid => "12345"}, @valid_attr)
    assert Ecto.Changeset.get_field(changeset, :uuid) == "12345"
  end

  test "changeset cannot overwrite uuid" do
    changeset = User.changeset(
      %User{:uuid => "12345"},
      Map.merge(@valid_attr, %{:uuid => "54321"})
    )
    assert Ecto.Changeset.get_field(changeset, :uuid) == "12345"
  end

end
