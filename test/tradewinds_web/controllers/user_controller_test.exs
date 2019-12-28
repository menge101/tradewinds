defmodule TradewindsWeb.UserControllerTest do
  use TradewindsWeb.ConnCase
  require Logger
  import Plug.Test

  alias Tradewinds.Accounts

  @create_attrs %{auth0_id: "some auth0_id", name: "some name", email: "some@email.com", permissions: %{}, creator: "exunit tests", owner: nil}
  @alt_attrs %{auth0_id: "some other auth0_id", name: "some name", email: "some2@email.com", permissions: %{}, creator: "exunit tests", owner: nil}
  @update_attrs %{auth0_id: "some updated auth0_id", email: "someupdated@email.com", name: "some updated name", permissions: %{}, creator: "exunit tests", owner: nil}
  @invalid_attrs %{auth0_id: nil, email: nil, name: nil, permissions: nil, creator: nil, owner: nil}
  @nonexistent_id 999_999

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  def fixture(:alt_user) do
    {:ok, user} = Accounts.create_user(@alt_attrs)
    user
  end

  describe "User has no permissions" do
    setup [:user_without_permission]

    test "show self is successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "show other user directed to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "show non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "edit self successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "edit other redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "edit non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :edit, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update self is successful", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated auth0_id"
    end

    test "update other user redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update non-existent user redirected to root", %{conn: conn} do
      conn = put(conn, Routes.user_path(conn, :update, @nonexistent_id), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete user redirects to root, user cannot delete self", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "You cannot delete yourself"
    end

    test "delete other user redirects to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete non-existent user redirects to root", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end
  end

  describe "User has :list permissions" do
    setup [:user_with_list_permission]

    test "show self is successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "show other user directed to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "show non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "list users successful", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "edit self successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "edit other redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "edit non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :edit, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update self is successful", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated auth0_id"
    end

    test "update other user redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update non-existent user redirected to root", %{conn: conn} do
      conn = put(conn, Routes.user_path(conn, :update, @nonexistent_id), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete user redirects to root, user cannot delete self", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "You cannot delete yourself"
    end

    test "delete other user redirects to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete non-existent user redirects to root", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end
  end

  describe "User has only :create permission" do
    setup [:user_with_create_permission]

    test "show self is successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "show other user directed to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "show non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end

    test "create user is successful", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @alt_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)
    end

    test "edit self successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "edit other redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "edit non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :edit, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update self is successful", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated auth0_id"
    end

    test "update other user redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update non-existent user redirected to root", %{conn: conn} do
      conn = put(conn, Routes.user_path(conn, :update, @nonexistent_id), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete user redirects to root, user cannot delete self", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "You cannot delete yourself"
    end

    test "delete other user redirects to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete non-existent user redirects to root", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end
  end

  describe "User has only :read permissions" do
    setup [:user_with_read_permission]

    test "show self is successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "show other user directed to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "show non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "User with ID: #{@nonexistent_id} not found"
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "edit self successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "edit other redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "edit non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :edit, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update self is successful", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated auth0_id"
    end

    test "update other user redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update non-existent user redirected to root", %{conn: conn} do
      conn = put(conn, Routes.user_path(conn, :update, @nonexistent_id), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete user redirects to root, user cannot delete self", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "You cannot delete yourself"
    end

    test "delete other user redirects to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete non-existent user redirects to root", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end
  end

  describe "User has only :write permissions" do
    setup [:user_with_write_permission]

    test "show self is successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "show other user directed to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "show non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "edit self successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "edit other redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "edit non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :edit, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "User with ID: #{@nonexistent_id} not found"
    end

    test "update self is successful", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated auth0_id"
    end

    test "update other successful with valid data", %{conn: conn} do
      user = fixture(:alt_user)
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
    end

    test "update other renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "update non-existent user redirected to root", %{conn: conn} do
      conn = put(conn, Routes.user_path(conn, :update, @nonexistent_id), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "User with ID: #{@nonexistent_id} not found"
    end

    test "delete user redirects to root, user cannot delete self", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "You cannot delete yourself"
    end

    test "delete other user redirects to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete non-existent user redirects to root", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end
  end

  describe "User has only :delete permissions" do
    setup [:user_with_delete_permission]

    test "show self is successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "show other user directed to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :show, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "show non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "list users redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "new user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "create user redirected to root", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "edit self successful", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "edit other redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = get(conn, Routes.user_path(conn, :edit, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "edit non-existent user redirected to root", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :edit, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update self is successful", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated auth0_id"
    end

    test "update other user redirected to root", %{conn: conn} do
      user = fixture(:alt_user)
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "update non-existent user redirected to root", %{conn: conn} do
      conn = put(conn, Routes.user_path(conn, :update, @nonexistent_id), user: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to perform this action on this user."
    end

    test "delete user redirects to root, user cannot delete self", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "You cannot delete yourself"
    end

    test "delete other user is successful, redirects to user list", %{conn: conn} do
      user = fixture(:alt_user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert "/users" =~ redir_path
      conn = get(recycle(conn), redir_path)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Current user does not have permission to access this content"
    end

    test "delete non-existent user redirects to root", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, @nonexistent_id))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "User with ID: #{@nonexistent_id} not found"
    end
  end

  describe "User has delete and list privilege" do
    setup [:user_with_delete_list_permissions]

    test "delete properly navigates to the index", %{conn: conn} do
      user = fixture(:alt_user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      redir_path = redirected_to(conn, 302)
      assert Routes.user_path(conn, :index) =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "user has update and show permission" do
    setup [:user_with_write_read_permissions]

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

  defp user_with_list_permission(context) do
    login_user(context, create_user(%{user: [:list]}))
  end

  defp user_with_create_permission(context) do
    login_user(context, create_user(%{user: [:create]}))
  end

  defp user_with_read_permission(context) do
    login_user(context, create_user(%{user: [:read]}))
  end

  defp user_with_write_permission(context) do
    login_user(context, create_user(%{user: [:write]}))
  end

  defp user_with_delete_permission(context) do
    login_user(context, create_user(%{user: [:delete]}))
  end

  defp user_with_delete_list_permissions(context) do
    login_user(context, create_user(%{user: [:delete, :list]}))
  end

  defp user_with_write_read_permissions(context) do
    login_user(context, create_user(%{user: [:write, :read]}))
  end

  defp login_user(%{conn: conn}, {:ok, [{:user, user} | _]}) do
    conn
    |> init_test_session(%{current_user: user})
    |> assign(:current_user, user)
    |> (fn conn -> {:ok, conn: conn, user: user} end).()
  end
end
