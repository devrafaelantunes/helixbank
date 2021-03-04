defmodule HelixbankWeb.SessionController do
  use HelixbankWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(
        conn,
        %{"session" => %{"document" => document, "password" => pass}}
      ) do
    case HelixBank.Internal.Account.authenticate_by_document_and_pass(document, pass) do
      {:ok, account} ->
        conn
        |> HelixBankWeb.Auth.login(account)
        |> put_flash(:info, "Welcome back #{account.name}!")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid document/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> HelixBankWeb.Auth.logout()
    |> put_flash(:info, "You finished your online banking session!")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
