defmodule PlaylistPal.UserControllerTest do

  use PlaylistPal.ConnCase
  alias PlaylistPal.User

  @valid_attrs %{name: "Eddy Lane", username: "eddy_lane", password: "p@ssw0rd"}
  @invalid_password_attrs %{name: "Eddy Lane", username: "eddy_lane", password: "short"}


  test "GET /new", %{conn: conn} do
    conn = get conn, "/users/new"
    assert html_response(conn, 200) =~ "Register"
  end

  #@TODO Add redirect test
  test "creates new user and redirects", %{conn: conn} do
    count_before = user_count(User)
    post conn, user_path(conn, :create), user: @valid_attrs
    assert user_count(User) == count_before + 1
  end

  test "does not create new user and renders errors when password is too short", %{conn: conn} do
    count_before = user_count(User)
    conn = post conn, user_path(conn, :create), user: @invalid_password_attrs
    assert html_response(conn, 200) =~ "check the errors"
    assert user_count(User) == count_before
  end

  defp user_count(query), do: Repo.one(from u in query, select: count(u.id))

end