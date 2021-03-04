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
    render(conn, "index.html")

  end

  def info(conn, _params) do
    amount = conn.assigns.current_account.amount
    account_number = conn.assigns.current_account.account_number
    agency_id = conn.assigns.current_account.agency_id
    name = conn.assigns.current_account.name
    document = conn.assigns.current_account.document

    render(conn, "info.html", amount: amount, account_number: account_number, agency_number: agency_id, name: name, document: document)
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

  def new_deposit(conn, _) do
    render(conn, "new_deposit.html")
  end

  def make_deposit(conn, params) do
    account_number = conn.assigns.current_account.account_number
    params = Utils.atomify_map(params)
    amount = String.to_integer(params.deposit.amount)

    AccountInternal.deposit(account_number, amount)

    conn
    |> put_flash(:info, "You deposited R$#{amount} in your account!")
    |> redirect(to: Routes.user_path(conn, :info))
  end
end
