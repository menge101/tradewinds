defmodule TradewindsWeb.TrailController do
  use TradewindsWeb, :controller

  alias Tradewinds.Trails
  alias Tradewinds.Trails.Trail
  alias Tradewinds.Trails.Trail.Abilities, as: It

  plug Tradewinds.Plug.Secure

  def index(conn, _params) do
    case conn.assigns.current_user |> It.can?(:list) do
      {:ok, true} ->
        trails = Trails.list_trails()
        render(conn, "index.html", trails: trails)
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def new(conn, _params) do
    case conn.assigns.current_user |> It.can?(:create) do
      {:ok, true} ->
        changeset = Trails.change_trail(%Trail{})
        render(conn, "new.html", changeset: changeset)
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def create(conn, %{"trail" => trail_params}) do
    case conn.assigns.current_user |> It.can?(:create) do
      {:ok, true} ->
        trail_params
        |> Map.put_new("creator", conn.assigns.current_user.id)
        |> Trails.create_trail
        |> case do
          {:ok, trail} ->
            conn
            |> put_flash(:info, "Trail created successfully.")
            |> redirect(to: Routes.trail_path(conn, :show, trail))
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
    case Trails.get_trail(id) do
      {:ok, trail} ->
        case conn.assigns.current_user |> It.can?(:read, trail) do
          {:ok, true} -> render(conn, "show.html", trail: trail)
          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> It.can?(:read, %Trail{}) do
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

  def edit(conn, %{"id" => id}) do
    case Trails.get_trail(id) do
      {:ok, trail} ->
        case conn.assigns.current_user |> It.can?(:write, trail) do
          {:ok, true} ->
            changeset = Trails.change_trail(trail)
            render(conn, "edit.html", trail: trail, changeset: changeset)
          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> It.can?(:read, %Trail{}) do
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

  def update(conn, %{"id" => id, "trail" => trail_params}) do
    case Trails.get_trail(id) do
      {:ok, trail} ->
        case conn.assigns.current_user |> It.can?(:write, trail) do
          {:ok, true} ->
             case Trails.update_trail(trail, trail_params) do
               {:ok, trail} ->
                 conn
                 |> put_flash(:info, "Trail updated successfully.")
                 |> redirect(to: Routes.trail_path(conn, :show, trail))

               {:error, %Ecto.Changeset{} = changeset} ->
                 render(conn, "edit.html", trail: trail, changeset: changeset)
             end
          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> It.can?(:read, %Trail{}) do
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
    case Trails.get_trail(id) do
      {:ok, trail} ->
        case conn.assigns.current_user |> It.can?(:delete, trail) do
          {:ok, true} ->
            case Trails.delete_trail(trail) do
              {:ok, _user} ->
                conn
                |> put_flash(:info, "Trail deleted successfully.")
                |> redirect(to: Routes.trail_path(conn, :index))
              {:error, message} ->
                conn
                |> put_flash(:info, "Error when deleting trail: #{message}")
                |> redirect_back(default: "/")
            end
          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
          case conn.assigns.current_user |> It.can?(:read, %Trail{}) do
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

  def permission_list do
    It.permissions()
  end
end
