defmodule TradewindsWeb.TrailControllerTest do
  use TradewindsWeb.ConnCase
  import Plug.Test

  alias Tradewinds.Trails
  alias Tradewinds.Accounts

  @create_attrs %{description: "some description", name: "some name", start: ~U[2100-04-17 14:00:00Z]}
  @old_attrs %{description: "old description", name: "old name", start: ~U[2001-04-17 14:00:00Z]}
  @update_attrs %{description: "some updated description", name: "some updated name", start: ~U[2111-05-18 15:01:01Z]}
  @invalid_attrs %{description: nil, name: nil, start: nil}
  @creator_attrs %{auth0_id: "creator auth0_id", name: "some name", email: "creator@email.com", permissions: %{}, creator: "exunit tests"}
  @user_attrs %{auth0_id: "an auth0_id", name: "some name", email: "some@email.com", permissions: %{}, creator: "exunit tests"}

  @no_instance_permission "Current user does not have permission to perform this action on this trail."
  @no_access_permission "Current user does not have permission to access this content"
  @cannot_change_history "Historic records are not editable"

  def fixture(atom, attrs \\ %{})
  def fixture(:trail, attrs) do
    {:ok, trail} = attrs
    |> (fn (precedent_map, other_map) -> Map.merge(other_map, precedent_map) end).(@create_attrs)
    |> create_trail_attrs
    |> Trails.create_trail
    trail
  end

  def fixture(:user, attrs) do
    attrs
    |> (fn (precedent_map, other_map) -> Map.merge(other_map, precedent_map) end).(@user_attrs)
    |> (fn attrs ->
          {:ok, user} = Accounts.create_user(attrs)
          user
        end).()
  end

  def fixture(:creator, _) do
    case Accounts.get_user(@creator_attrs) do
      {:ok, user} -> user
      {:error, _} ->
        {:ok, user} = Accounts.create_user(@creator_attrs)
        user
    end
  end

  describe "for a user with proper permission" do
    setup [:user_with_permission]

    test "index lists all trails", %{conn: conn} do
      conn = get(conn, Routes.trail_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Trails"
    end

    test "new renders new trail form", %{conn: conn} do
      conn = get(conn, Routes.trail_path(conn, :new))
      assert html_response(conn, 200) =~ "New Trail"
    end

    test "create trail redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.trail_path(conn, :create), trail: create_trail_attrs())

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.trail_path(conn, :show, id)

      conn = get(conn, Routes.trail_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Trail"
    end

    test "create trail renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.trail_path(conn, :create), trail: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Trail"
    end
  end

  describe "for a user without proper permission" do
    setup [:user_no_permission]

    test "index lists all trails", %{conn: conn} do
      conn = get(conn, Routes.trail_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Trails"
    end

    test "new redirects to root", %{conn: conn} do
      conn = get(conn, Routes.trail_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_access_permission
    end

    test "create trail redirects to root", %{conn: conn} do
      conn = post(conn, Routes.trail_path(conn, :create), trail: create_trail_attrs())
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_access_permission
    end

    test "create trail redirects to root when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.trail_path(conn, :create), trail: @invalid_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_access_permission
    end
  end

  describe "for a user with proper permission and an existing trail" do
    setup [:user_with_permission, :create_trail]

    test "renders form for editing chosen trail", %{conn: conn, trail: trail} do
      conn = get(conn, Routes.trail_path(conn, :edit, trail))
      assert html_response(conn, 200) =~ "Edit Trail"
    end

    test "redirects when data is valid", %{conn: conn, trail: trail} do
      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: @update_attrs)
      redir_path = redirected_to(conn)
      assert redir_path == Routes.trail_path(conn, :show, trail)
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, trail: trail} do
      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Trail"
    end

    test "deletes chosen trail", %{conn: conn, trail: trail} do
      conn = delete(conn, Routes.trail_path(conn, :delete, trail))
      assert redirected_to(conn) == Routes.trail_path(conn, :index)
    end
  end

  describe "for a user without proper permission and an existing trail" do
    setup [:user_no_permission, :create_trail]

    test "redirects to root when attempting to edit chosen trail", %{conn: conn, trail: trail} do
      conn = get(conn, Routes.trail_path(conn, :edit, trail))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_instance_permission
    end

    test "redirects to root when data is valid", %{conn: conn, trail: trail} do
      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_instance_permission
    end

    test "redirects to root when data is invalid", %{conn: conn, trail: trail} do
      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: @invalid_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_instance_permission
    end

    test "redirects to root when attempting to delete chosen trail", %{conn: conn, trail: trail} do
      conn = delete(conn, Routes.trail_path(conn, :delete, trail))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_instance_permission
    end
  end

  describe "for a user with proper permission and a historical trail" do
    setup [:user_with_permission, :create_old_trail]

    test "renders form for editing chosen trail", %{conn: conn, trail: trail} do
      conn = get(conn, Routes.trail_path(conn, :edit, trail))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @cannot_change_history
    end

    test "redirects when data is valid", %{conn: conn, trail: trail} do
      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: @update_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @cannot_change_history
    end

    test "renders errors when data is invalid", %{conn: conn, trail: trail} do
      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: @invalid_attrs)
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @cannot_change_history
    end

    test "deletes chosen trail", %{conn: conn, trail: trail} do
      conn = delete(conn, Routes.trail_path(conn, :delete, trail))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @cannot_change_history
    end
  end

  defp user_with_permission(context) do
    login_user(context, create_user(%{trail: TradewindsWeb.TrailController.permission_list}))
  end

  defp user_no_permission(context) do
    login_user(context, create_user(%{trail: []}))
  end

  defp create_trail(_) do
    {:ok, trail: fixture(:trail, @create_attrs)}
  end

  defp create_old_trail(_) do
    {:ok, trail: fixture(:trail, @old_attrs)}
  end

  defp login_user(%{conn: conn}, {:ok, [{:user, user} | _]}) do
    conn
    |> init_test_session(%{current_user: user})
    |> assign(:current_user, user)
    |> (fn conn -> {:ok, conn: conn, user: user} end).()
  end

  defp create_user(perms) do
    fixture(:user, @user_attrs)
    |> Map.put(:permissions, perms)
    |> (fn user -> {:ok, user: user} end).()
  end

  defp create_trail_attrs(attrs \\ @create_attrs) do
    user = fixture(:creator, %{})
    Map.put_new(attrs, :creator, user.id)
  end
end
