defmodule TradewindsWeb.UserController do
  use TradewindsWeb, :controller

  import Canada, only: [can?: 2]
  require Logger

  alias Tradewinds.Accounts
  alias Tradewinds.Accounts.User

  plug Tradewinds.Plug.Secure

  @permissions [:index, :new, :create, :edit, :update, :delete, :show]

  def index(conn, _params) do
    case conn.assigns.current_user |> can?(index(User)) do
      {:ok, true} ->
        users = Accounts.list_users()
        render(conn, "index.html", users: users)
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def new(conn, _params) do
    case conn.assigns.current_user |> can?(new(User)) do
      {:ok, true} ->
        changeset = Accounts.change_user(%User{})
        render(conn, "new.html", changeset: changeset)
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def create(conn, %{"user" => user_params}) do
    case conn.assigns.current_user |> can?(create(User)) do
      {:ok, true} ->
        case Accounts.create_user(user_params) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User created successfully.")
            |> redirect(to: Routes.user_path(conn, :show, user))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    case conn.assigns.current_user |> can?(show(user)) do
      {:ok, true} -> render(conn, "show.html", user: user)
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    case conn.assigns.current_user |> can?(edit(user)) do
      {:ok, true} ->
        changeset = Accounts.change_user(user)
        render(conn, "edit.html", user: user, changeset: changeset)
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case conn.assigns.current_user |> can?(edit(user)) do
      {:ok, true} ->
        case Accounts.update_user(user, user_params) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User updated successfully.")
            |> redirect(to: Routes.user_path(conn, :show, user))

           {:error, %Ecto.Changeset{} = changeset} ->
             render(conn, "edit.html", user: user, changeset: changeset)
        end
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def delete(conn, %{"id" => id}) do
    target_user = Accounts.get_user!(id)

    case conn.assigns.current_user |> can?(delete(target_user)) do
      {:ok, true} ->
        case Accounts.delete_user(target_user) do
          {:ok, _user} ->
            conn
            |> put_flash(:info, "User deleted successfully.")
            |> redirect(to: Routes.user_path(conn, :index))
          {:error, message} ->
            conn
            |> put_flash(:info, "Error when deleting user: #{message}")
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect_back(default: "/")
    end
  end
end
