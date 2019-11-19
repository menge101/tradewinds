defmodule TradewindsWeb.TrailController do
  use TradewindsWeb, :controller

  alias Tradewinds.Trails
  alias Tradewinds.Trails.Trail

  plug :secure

  defp secure(conn, _params) do
    user = get_session(conn, :current_user)
    case user do
     nil ->
         conn |> redirect(to: "/auth/auth0") |> halt
     _ ->
       conn
       |> assign(:current_user, user)
    end
  end

  def index(conn, _params) do
    trails = Trails.list_trails()
    render(conn, "index.html", trails: trails)
  end

  def new(conn, _params) do
    changeset = Trails.change_trail(%Trail{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"trail" => trail_params}) do
    case Trails.create_trail(trail_params) do
      {:ok, trail} ->
        conn
        |> put_flash(:info, "Trail created successfully.")
        |> redirect(to: Routes.trail_path(conn, :show, trail))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    trail = Trails.get_trail!(id)
    render(conn, "show.html", trail: trail)
  end

  def edit(conn, %{"id" => id}) do
    trail = Trails.get_trail!(id)
    changeset = Trails.change_trail(trail)
    render(conn, "edit.html", trail: trail, changeset: changeset)
  end

  def update(conn, %{"id" => id, "trail" => trail_params}) do
    trail = Trails.get_trail!(id)

    case Trails.update_trail(trail, trail_params) do
      {:ok, trail} ->
        conn
        |> put_flash(:info, "Trail updated successfully.")
        |> redirect(to: Routes.trail_path(conn, :show, trail))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", trail: trail, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    trail = Trails.get_trail!(id)
    {:ok, _trail} = Trails.delete_trail(trail)

    conn
    |> put_flash(:info, "Trail deleted successfully.")
    |> redirect(to: Routes.trail_path(conn, :index))
  end
end
