defmodule HelixBank.SessionController do
  use HelixbankWeb, :controller


  def new(conn, _) do
    render(conn, "new.html")
  end
end
