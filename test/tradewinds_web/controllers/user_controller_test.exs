defmodule TradewindsWeb.UserControllerTest do
  use TradewindsWeb.ConnCase
  require Logger
  import Plug.Test

  alias Tradewinds.Accounts

  @create_attrs %{auth0_id: "some auth0_id", name: "some name", email: "some@email.com", permissions: %{}}
  @deletable_attrs %{auth0_id: "some other auth0_id", name: "some name", email: "some2@email.com", permissions: %{}}
  @update_attrs %{auth0_id: "some updated auth0_id", email: "someupdated@email.com", name: "some updated name", permissions: %{}}
  @invalid_attrs %{auth0_id: nil, email: nil, name: nil, permissions: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  def fixture(:deletable_user) do
    {:ok, user} = Accounts.create_user(@deletable_attrs)
    user
  end

  describe "User has no permissions" do
    setup [:user_without_permission]

    test "show user displays the user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "edit user redirected to root", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "update user redirected to root", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "delete user redirects to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end
  end

  describe "User has :index permissions" do
    setup [:user_with_index_permission]

    test "show user displays the user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "edit user redirected to root", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "update user redirected to root", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "delete user redirects to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end
  end

  describe "User has only :new permission" do
    setup [:user_with_new_permission]

    test "show user redirected to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "edit user redirected to root", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "update user redirected to root", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "delete user redirects to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end
  end

  describe "User has only :show permissions" do
    setup [:user_with_show_permission]

    test "show user displays the user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "edit user redirected to root", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "update user redirected to root", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "delete user redirects to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end
  end

  describe "User has only :edit permissions" do
    setup [:user_with_edit_permission]

    test "show user redirected to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "edit user successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "update user redirected to root", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "delete user redirects to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end
  end

  describe "User has only :update permissions" do
    setup [:user_with_update_permission]

    test "show user redirected to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "edit user redirected to root", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "update is successful", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "update renders error for invalid data", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "delete user redirects to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end
  end

  describe "User has only :delete permissions" do
    setup [:user_with_delete_permission]

    test "show user redirected to root", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "edit user redirected to root", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "update is redirected to root", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end

    test "delete user is successful", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Tradewinds · Phoenix Framework"
    end
  end

  describe "User has delete and index privilege" do
    setup [:user_with_delete_index_permissions]

    test "delete properly navigates to the index", %{conn: conn} do
      user = fixture(:deletable_user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert Routes.user_path(conn, :index) =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "user has update and show permission" do
    setup [:user_with_update_show_permissions]

    test "update properly navigates to show", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated auth0_id"
    end
  end

  defp create_user(perms) do
    fixture(:user)
    |> Map.put(:permissions, perms)
    |> (fn user -> {:ok, user: user} end).()
  end

  defp user_without_permission(context) do
    login_user(context, create_user(%{}))
  end

  defp user_with_index_permission(context) do
    login_user(context, create_user(%{user: [:index]}))
  end

  defp user_with_new_permission(context) do
    login_user(context, create_user(%{user: [:new]}))
  end

  defp user_with_show_permission(context) do
    login_user(context, create_user(%{user: [:show]}))
  end

  defp user_with_edit_permission(context) do
    login_user(context, create_user(%{user: [:edit]}))
  end

  defp user_with_update_permission(context) do
    login_user(context, create_user(%{user: [:update]}))
  end

  defp user_with_delete_permission(context) do
    login_user(context, create_user(%{user: [:delete]}))
  end

  defp user_with_delete_index_permissions(context) do
    login_user(context, create_user(%{user: [:delete, :index]}))
  end

  defp user_with_update_show_permissions(context) do
    login_user(context, create_user(%{user: [:update, :show]}))
  end

  defp login_user(%{conn: conn}, {:ok, [{:user, user} | _]}) do
    conn
    |> init_test_session(%{current_user: user})
    |> assign(:current_user, user)
    |> (fn conn -> {:ok, conn: conn, user: user} end).()
  end
end
