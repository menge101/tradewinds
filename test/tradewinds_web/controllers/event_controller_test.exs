defmodule TradewindsWeb.EventControllerTest do
  use TradewindsWeb.ConnCase
  import Tradewinds.Fixtures.Event
  import Plug.Test

  @no_access_permission "Current user does not have permission to access this content"

  describe "for a user with proper permission" do
    setup [:login_with_permission]

    test "index lists all events", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Events"
    end

    test "new event renders form", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :new))
      assert html_response(conn, 200) =~ "New Event"
    end

    test "create event redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.event_path(conn, :create), event: create_attrs())
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.event_path(conn, :show, id)
      conn = get(conn, Routes.event_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Event"
    end

    test "create event renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.event_path(conn, :create), event: invalid_attrs())
      assert html_response(conn, 200) =~ "New Event"
    end
  end

  describe "for a user with permission and an existing event" do
    setup [:login_with_permission, :create_event]

    test "renders form for editing chosen event", %{conn: conn, event: event} do
      conn = get(conn, Routes.event_path(conn, :edit, event))
      assert html_response(conn, 200) =~ "Edit Event"
    end

    test "update event redirects when data is valid", %{conn: conn, event: event} do
      conn = put(conn, Routes.event_path(conn, :update, event), event: update_attrs())
      assert redirected_to(conn) == Routes.event_path(conn, :show, event)

      conn = get(conn, Routes.event_path(conn, :show, event))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "update event renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, Routes.event_path(conn, :update, event), event: invalid_attrs())
      assert html_response(conn, 200) =~ "Edit Event"
    end

    test "delete event deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, Routes.event_path(conn, :delete, event))
      assert redirected_to(conn) == Routes.event_path(conn, :index)
      conn = get(conn, Routes.event_path(conn, :show, event))
      assert redirected_to(conn) == "/"
    end
  end

  describe "for a user without permission" do
    setup [:login_with_no_permission]

    test "index lists all events", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :index))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_access_permission
    end

    test "new event renders form", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :new))
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_access_permission
    end

    test "create event redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.event_path(conn, :create), event: create_attrs())
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_access_permission
    end

    test "create event renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.event_path(conn, :create), event: invalid_attrs())
      redir_path = redirected_to(conn, 302)
      assert "/" =~ redir_path
      conn = get(recycle(conn), redir_path)
      assert html_response(conn, 200) =~ @no_access_permission
    end
  end

  defp create_event(_), do: fixture(:event, %{}, true)

  defp login_user(%{conn: conn}, {:ok, [{:user, user} | _]}) do
    conn
    |> init_test_session(%{current_user: user})
    |> assign(:current_user, user)
    |> (fn conn -> {:ok, conn: conn, user: user} end).()
  end

  defp login_with_permission(context) do
    login_user(context, create_user(%{event: permission_list()}))
  end

  defp login_with_no_permission(context) do
    login_user(context, create_user(%{event: []}))
  end
end
