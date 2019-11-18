defmodule TradewindsWeb.PageController do
  use TradewindsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
