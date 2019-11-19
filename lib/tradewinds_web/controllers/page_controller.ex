defmodule TradewindsWeb.PageController do
  use TradewindsWeb, :controller
  alias Tradewinds.Trails

  def index(conn, _params) do
    trails = Trails.list_future_trails
    render conn, "index.html", trails: trails, current_user: get_session(conn, :current_user)
  end
end
