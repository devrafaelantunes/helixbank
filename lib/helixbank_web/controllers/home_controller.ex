defmodule HelixbankWeb.HomeController do
  use HelixbankWeb, :controller

  alias HelixBank.Internal.Account

  def index(conn, _params) do
    render(conn, "index.html")
  end


end
