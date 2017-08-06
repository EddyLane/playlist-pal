defmodule PlaylistPalWeb.UserNewControllerTest do
  use PlaylistPalWeb.ConnCase

  alias PlaylistPal.Accounts
  alias PlaylistPal.Accounts.UserNew

  @create_attrs %{email: "some email"}
  @update_attrs %{email: "some updated email"}
  @invalid_attrs %{email: nil}

  def fixture(:user_new) do
    {:ok, user_new} = Accounts.create_user_new(@create_attrs)
    user_new
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users_new", %{conn: conn} do
      conn = get conn, user_new_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_new" do
    test "renders user_new when data is valid", %{conn: conn} do
      conn = post conn, user_new_path(conn, :create), user_new: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, user_new_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "email" => "some email"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_new_path(conn, :create), user_new: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_new" do
    setup [:create_user_new]

    test "renders user_new when data is valid", %{conn: conn, user_new: %UserNew{id: id} = user_new} do
      conn = put conn, user_new_path(conn, :update, user_new), user_new: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, user_new_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "email" => "some updated email"}
    end

    test "renders errors when data is invalid", %{conn: conn, user_new: user_new} do
      conn = put conn, user_new_path(conn, :update, user_new), user_new: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_new" do
    setup [:create_user_new]

    test "deletes chosen user_new", %{conn: conn, user_new: user_new} do
      conn = delete conn, user_new_path(conn, :delete, user_new)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, user_new_path(conn, :show, user_new)
      end
    end
  end

  defp create_user_new(_) do
    user_new = fixture(:user_new)
    {:ok, user_new: user_new}
  end
end
