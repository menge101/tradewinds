defmodule TradewindsWeb.RegistrationControllerTest do
  use TradewindsWeb.ConnCase
  import Plug.Test

  alias Tradewinds.Accounts
  alias Tradewinds.Accounts.Registration.Abilities
  alias Tradewinds.Fixtures.User, as: UserFix
  import Tradewinds.Fixtures.Registration

  @user_attrs %{
    auth0_id: "an event user auth0_id",
    name: "some name",
    email: "some@email.com",
    permissions: %{},
    admins: [],
    creator: "exunit tests"
  }

  @create_attrs %{selection: nil, user: @user_attrs}
  @update_attrs %{selection: %{a: "aye"}}
  @invalid_attrs %{selection: nil, event: nil}

  describe "for a user with proper permission" do
    setup [:login_with_permission]

    test "index lists all registrations", %{conn: conn} do
      conn = get(conn, Routes.registration_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Registrations"
    end

    test "new registration renders form", %{conn: conn} do
      conn = get(conn, Routes.registration_path(conn, :new))
      assert html_response(conn, 200) =~ "New Registration"
    end

    test "create registration redirects to show when data is valid", %{conn: conn} do
      attrs = create_attrs(@create_attrs, true)
      conn = post(conn, Routes.registration_path(conn, :create),
        registration: attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.registration_path(conn, :show, id)

      conn = get(conn, Routes.registration_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Registration"
    end

    test "create registration renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), registration: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Registration"
    end
  end

  describe "for a user with permission and an existing registration" do
    setup [:login_with_permission, :create_registration]

    test "edit renders form for editing chosen registration", %{conn: conn, registration: registration} do
      conn = get(conn, Routes.registration_path(conn, :edit, registration))
      assert html_response(conn, 200) =~ "Edit Registration"
    end

    test "update redirects when data is valid", %{conn: conn, registration: registration} do
      conn = put(conn, Routes.registration_path(conn, :update, registration), registration: @update_attrs)
      assert redirected_to(conn) == Routes.registration_path(conn, :show, registration)

      conn = get(conn, Routes.registration_path(conn, :show, registration))
      assert html_response(conn, 200)
    end

    test "delete deletes chosen registration", %{conn: conn, registration: registration} do
      rego = Tradewinds.Repo.preload(registration, [:event, :user])
      conn = delete(conn, Routes.registration_path(conn, :delete, rego))
      assert redirected_to(conn) == Routes.registration_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.registration_path(conn, :show, rego))
      end
    end
  end

  defp create_registration(_) do
    fixture(:registration, %{}, true)
  end

  defp create_user(perms) do
    @user_attrs
    |> Map.put(:permissions, perms)
    |> (fn attrs -> UserFix.fixture(:user, attrs) end).()
    |> (fn user -> {:ok, user: user} end).()
  end

  defp login_user(%{conn: conn}, {:ok, [{:user, user} | _]}) do
    conn
    |> init_test_session(%{current_user: user})
    |> assign(:current_user, user)
    |> (fn conn -> {:ok, conn: conn, user: user} end).()
  end

  defp login_with_permission(context) do
    login_user(context, create_user(%{registration: Abilities.permissions()}))
  end

  defp login_no_permission(context) do
    login_user(context, create_user(%{registration: []}))
  end
end
