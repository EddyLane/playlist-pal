defmodule PlaylistPal.AccountsTest do
  use PlaylistPal.DataCase

  alias PlaylistPal.Accounts

  describe "users_new" do
    alias PlaylistPal.Accounts.UserNew

    @valid_attrs %{email: "some email"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def user_new_fixture(attrs \\ %{}) do
      {:ok, user_new} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_new()

      user_new
    end

    test "list_users_new/0 returns all users_new" do
      user_new = user_new_fixture()
      assert Accounts.list_users_new() == [user_new]
    end

    test "get_user_new!/1 returns the user_new with given id" do
      user_new = user_new_fixture()
      assert Accounts.get_user_new!(user_new.id) == user_new
    end

    test "create_user_new/1 with valid data creates a user_new" do
      assert {:ok, %UserNew{} = user_new} = Accounts.create_user_new(@valid_attrs)
      assert user_new.email == "some email"
    end

    test "create_user_new/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_new(@invalid_attrs)
    end

    test "update_user_new/2 with valid data updates the user_new" do
      user_new = user_new_fixture()
      assert {:ok, user_new} = Accounts.update_user_new(user_new, @update_attrs)
      assert %UserNew{} = user_new
      assert user_new.email == "some updated email"
    end

    test "update_user_new/2 with invalid data returns error changeset" do
      user_new = user_new_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_new(user_new, @invalid_attrs)
      assert user_new == Accounts.get_user_new!(user_new.id)
    end

    test "delete_user_new/1 deletes the user_new" do
      user_new = user_new_fixture()
      assert {:ok, %UserNew{}} = Accounts.delete_user_new(user_new)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_new!(user_new.id) end
    end

    test "change_user_new/1 returns a user_new changeset" do
      user_new = user_new_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_new(user_new)
    end
  end
end
