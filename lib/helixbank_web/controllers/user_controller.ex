defmodule HelixbankWeb.UserController do
  use HelixbankWeb, :controller

  alias HelixBank.Utils
  alias HelixBank.Internal.Account, as: AccountInternal
  alias HelixBank.Model.Account, as: Account
  plug :authenticate when action in [:index]

  defp authenticate(conn, _opts) do
    if conn.assigns.current_account do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to acess that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end


  end
  def new(conn, _params) do
    changeset = Account.change_registration(%Account{})
    render(conn, "create.html", changeset: changeset)
  end

  def index(conn, _params) do

    IO.inspect(conn)

    render(conn, "index.html")
  end

  def create(conn, %{"account" => user_params}) do
    params = Utils.atomify_map(user_params)

    case AccountInternal.register_account(params) do
      {:ok, user} ->
        conn
        |> HelixBankWeb.Auth.login(user)
        |> put_flash(:info, "Account number: #{user.account_number} was created! It belongs to: #{user.name}, document: #{user.document}")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        render(conn, "create.html", changeset: changeset)
    end
  end
end
