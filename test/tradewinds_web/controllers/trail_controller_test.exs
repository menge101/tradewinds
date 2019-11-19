defmodule TradewindsWeb.TrailControllerTest do
  use TradewindsWeb.ConnCase

  alias Tradewinds.Trails

  @create_attrs %{desription: "some desription", name: "some name", start: ~N[2010-04-17 14:00:00]}
  @update_attrs %{desription: "some updated desription", name: "some updated name", start: ~N[2011-05-18 15:01:01]}
  @invalid_attrs %{desription: nil, name: nil, start: nil}

  def fixture(:trail) do
    {:ok, trail} = Trails.create_trail(@create_attrs)
    trail
  end

  setup do
    session_opts = Plug.Session.init(
      store: :cookie,
      key: "foobar",
      encryption_salt: "encrypted cookie salt",
      signing_salt: "signing salt",
      log: false,
      encrypt: false
    )
    conn = build_conn()
        |> Plug.Session.call(session_opts)
        |> fetch_session
        |> put_session(:current_user, 'hi')
    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all trails", %{conn: conn} do
      conn = get(conn, Routes.trail_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Trails"
    end
  end

  describe "new trail" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.trail_path(conn, :new))
      assert html_response(conn, 200) =~ "New Trail"
    end
  end

  describe "create trail" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.trail_path(conn, :create), trail: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.trail_path(conn, :show, id)

      conn = get(conn, Routes.trail_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Trail"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.trail_path(conn, :create), trail: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Trail"
    end
  end

  describe "edit trail" do
    setup [:create_trail]

    test "renders form for editing chosen trail", %{conn: conn, trail: trail} do
      conn = get(conn, Routes.trail_path(conn, :edit, trail))
      assert html_response(conn, 200) =~ "Edit Trail"
    end
  end

  describe "update trail" do
    setup [:create_trail]

    test "redirects when data is valid", %{conn: conn, trail: trail} do
      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: @update_attrs)
      assert redirected_to(conn) == Routes.trail_path(conn, :show, trail)

      conn = get(conn, Routes.trail_path(conn, :show, trail))
      assert html_response(conn, 200) =~ "some updated desription"
    end

    test "renders errors when data is invalid", %{conn: conn, trail: trail} do
      conn = put(conn, Routes.trail_path(conn, :update, trail), trail: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Trail"
    end
  end

  describe "delete trail" do
    setup [:create_trail]

    test "deletes chosen trail", %{conn: conn, trail: trail} do
      conn = delete(conn, Routes.trail_path(conn, :delete, trail))
      assert redirected_to(conn) == Routes.trail_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.trail_path(conn, :show, trail))
      end
    end
  end

  defp create_trail(_) do
    trail = fixture(:trail)
    {:ok, trail: trail}
  end
end
