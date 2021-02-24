defmodule HelixbankWeb.UserController do
  use HelixbankWeb, :controller

  alias HelixBank.Utils
  alias HelixBank.Internal.Account, as: AccountInternal
  alias HelixBank.Model.Account, as: Account


  def new(conn, _params) do
    changeset = Account.change_account(%Account{})
    render(conn, "create.html", changeset: changeset)
  end

  def create(conn, %{"account" => user_params}) do
    params = Utils.atomify_map(user_params)

    case AccountInternal.create_account(params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Account number: #{user.account_number} was created! It belongs to: #{user.name}, document: #{user.document}")
        |> redirect(to: Routes.home_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        render(conn, "create.html", changeset: changeset)
    end
  end

end
