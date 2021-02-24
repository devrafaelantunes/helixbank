defmodule HelixbankWeb.UserController do
  use HelixbankWeb, :controller

  alias HelixBank.Internal.Account, as: AccountInternal
  alias HelixBank.Model.Account, as: Account


  def new(conn, _params) do
    changeset = Account.change_account(%Account{})
    render(conn, "create.html", changeset: changeset)
  end

  def create(conn, %{"account" => user_params}) do
    case AccountInternal.create_account(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: Routes.home_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "create.html", changeset: changeset)
    end
  end

end
