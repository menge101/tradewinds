defmodule TradewindsWeb.EventController do
  use TradewindsWeb, :controller

  alias Tradewinds.Events
  alias Tradewinds.Events.Event
  import Tradewinds.Events.Event.Abilities

  plug Tradewinds.Plug.Secure

  def index(conn, _params) do
    case conn.assigns.current_user |> can?(:list, Event) do
      {:ok, true} ->
        events = Events.list_events()
        render(conn, "index.html", events: events)
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def new(conn, _params) do
    case conn.assigns.current_user |> can?(:create, Event) do
      {:ok, true} ->
        changeset = Events.change_event(%Event{})
        render(conn, "new.html", changeset: changeset)
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect_back(default: "/")
    end
  end

  def create(conn, %{"event" => event_params}) do
    case conn.assigns.current_user |> can?(:create, Event) do
      {:ok, true} ->
        case Events.create_event(event_params) do
          {:ok, event} ->
            conn
            |> put_flash(:info, "Event created successfully.")
            |> redirect(to: Routes.event_path(conn, :show, event))
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
    case Events.get_event(id) do
      {:ok, event} ->
        case conn.assigns.current_user |> can?(:read, event) do
          {:ok, true} ->
            render(conn, "show.html", event: event)
          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> can?(:read, %Event{}) do
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
    case Events.get_event(id) do
      {:ok, event} ->
        case conn.assigns.current_user |> can?(:write, event) do
          {:ok, true} ->
            changeset = Events.change_event(event)
            render(conn, "edit.html", event: event, changeset: changeset)
          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> can?(:read, %Event{}) do
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

  def update(conn, %{"id" => id, "event" => event_params}) do
    case Events.get_event(id) do
      {:ok, event} ->
        case conn.assigns.current_user |> can?(:write, event) do
          {:ok, true} ->
            case Events.update_event(event, event_params) do
              {:ok, event} ->
                conn
                |> put_flash(:info, "Event updated successfully.")
                |> redirect(to: Routes.event_path(conn, :show, event))
              {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "edit.html", event: event, changeset: changeset)
            end
          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> can?(:read, %Event{}) do
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
    case Events.get_event(id) do
      {:ok, event} ->
        case conn.assigns.current_user |> can?(:delete, event) do
          {:ok, true} ->
            case Events.delete_event(event) do
              {:ok, _event} ->
                conn
                |> put_flash(:info, "Event deleted successfully.")
                |> redirect(to: Routes.event_path(conn, :index))
              {:error, message} ->
                conn
                |> put_flash(:info, "Error when deleting user: #{message}")
                |> redirect_back(default: "/")
            end

          {:error, message} ->
            conn
            |> put_flash(:info, message)
            |> redirect_back(default: "/")
        end
      {:error, message} ->
        case conn.assigns.current_user |> can?(:read, %Event{}) do
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
end
