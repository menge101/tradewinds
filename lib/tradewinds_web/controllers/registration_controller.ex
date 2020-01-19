defmodule TradewindsWeb.RegistrationController do
  use TradewindsWeb, :controller

  alias Tradewinds.Accounts
  alias Tradewinds.Accounts.Registration
  import Tradewinds.Accounts.Registration.Abilities

  plug Tradewinds.Plug.Secure

  def index(conn, _params) do
    case conn.assigns.current_user |> can?(:list) do
      {:ok, true} ->
        regos = Accounts.list_registrations()
        render(conn, "index.html", registrations: regos)
      {:error, message} ->
        conn
        |> put_flash(:warning, message)
        |> redirect_back(default: "/")
    end
  end

  def new(conn, _params) do
    case conn.assigns.current_user |> can?(:create) do
      {:ok, true} ->
        changeset = Accounts.change_registration(%Registration{})
        render(conn, "new.html", changeset: changeset)
      {:error, message} ->
        conn
        |> put_flash(:warning, message)
        |> redirect_back(default: "/")
    end
  end

  def create(conn, %{"registration" => registration_params}) do
    case conn.assigns.current_user |> can?(:create) do
      {:ok, true} ->
        case Accounts.create_registration(registration_params) do
          {:ok, registration} ->
            conn
            |> put_flash(:info, "Registration created successfully.")
            |> redirect(to: Routes.registration_path(conn, :show, registration))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      {:error, message} ->
        conn
        |> put_flash(:warning, message)
        |> redirect_back(defaults: "/")
    end
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_registration(id) do
      {:ok, rego} ->
        loaded_rego = Tradewinds.Repo.preload(rego, [:event, :user])
        case conn.assigns.current_user |> can?(:read, loaded_rego) do
          {:ok, true} -> render(conn, "show.html", registration: rego)
          {:error, message} ->
            conn
            |> put_flash(:warning, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> can?(:read, %Registration{}) do
          {:ok, true} ->
            conn
            |> put_flash(:error, message)
            |> redirect_back(default: "/")
          {:error, perm_message} ->
            conn
            |> put_flash(:warning, perm_message)
            |> redirect_back(default: "/")
        end
    end
  end

  def edit(conn, %{"id" => id}) do
    case Accounts.get_registration(id) do
      {:ok, rego} ->
        loaded_rego = Tradewinds.Repo.preload(rego, [:event, :user])
        case conn.assigns.current_user |> can?(:write, loaded_rego) do
          {:ok, true} ->
            changeset = Accounts.change_registration(rego)
            render(conn, "edit.html", registration: rego, changeset: changeset)
          {:error, message} ->
            conn
            |> put_flash(:warning, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> can?(:read, %Registration{}) do
          {:ok, true} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
          {:error, perm_message} ->
            conn
            |> put_flash(:info, perm_message)
            |> redirect_back(default: "/")
        end
    end

  end

  def update(conn, %{"id" => id, "registration" => registration_params}) do
    case Accounts.get_registration(id) do
      {:ok, rego} ->
        loaded_rego = Tradewinds.Repo.preload(rego, [:event, :user])
        case conn.assigns.current_user |> can?(:write, loaded_rego) do
          {:ok, true} ->
            case Accounts.update_registration(loaded_rego, registration_params) do
              {:ok, rego} ->
                conn
                |> put_flash(:info, "Registration updated successfully.")
                |> redirect(to: Routes.registration_path(conn, :show, rego))
              {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "edit.html", registration: rego, changeset: changeset)
            end
          {:error, message} ->
            conn
            |> put_flash(:warning, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> can?(:read, %Registration{}) do
          {:ok, true} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
          {:error, perm_message} ->
            conn
            |> put_flash(:info, perm_message)
            |> redirect_back(default: "/")
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case Accounts.get_registration(id) do
      {:ok, rego} ->
        loaded_rego = Tradewinds.Repo.preload(rego, [:event, :user])
        case conn.assigns.current_user |> can?(:delete, loaded_rego) do
          {:ok, true} ->
            case Accounts.delete_registration(rego) do
              {:ok, _user} ->
                conn
                |> put_flash(:info, "Registration deleted successfully.")
                |> redirect(to: Routes.registration_path(conn, :index))
              {:error, message} ->
                conn
                |> put_flash(:error, "Error when deleting registration: #{message}")
                |> redirect_back(default: "/")
            end
          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> can?(:read, %Registration{}) do
          {:ok, true} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
          {:error, perm_message} ->
            conn
            |> put_flash(:warning, perm_message)
            |> redirect_back(default: "/")
        end
    end
  end
end
