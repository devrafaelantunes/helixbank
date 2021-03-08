defmodule HelixbankWeb.UserController do
  use HelixbankWeb, :controller

  alias HelixBank.Utils
  alias HelixBank.Internal.Account, as: AccountInternal
  alias HelixBank.Model.Account, as: Account
  alias Helixbank.Repo
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

    render(conn, "info.html",
      amount: amount,
      account_number: account_number,
      agency_number: agency_id,
      name: name,
      document: document
    )
  end

  def create(conn, %{"account" => user_params}) do
    params = Utils.atomify_map(user_params)

    case AccountInternal.register_account(params) do
      {:ok, user} ->
        conn
        |> HelixBankWeb.Auth.login(user)
        |> put_flash(:info, "Your Account was created! Check Account Information for more info! ")
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
    params = Utils.atomify_map(params)

    if params.deposit.amount == "" do
      conn
      |> put_flash(:error, "It cannot be blank")
      |> render("new_deposit.html")

    else
      account_number = conn.assigns.current_account.account_number

      amount = String.to_integer(params.deposit.amount)

      AccountInternal.deposit(account_number, amount)

      conn
      |> put_flash(:info, "You deposited R$#{amount} in your account!")
      |> redirect(to: Routes.user_path(conn, :info))
    end
  end

  def new_withdraw(conn, _) do
    render(conn, "new_withdraw.html")
  end

  def make_withdraw(conn, params) do
    params = Utils.atomify_map(params)

    if params.withdraw.amount == "" do
      conn
      |> put_flash(:error, "It cannot be blank")
      |> render("new_withdraw.html")

    else

      account_number = conn.assigns.current_account.account_number

      amount = String.to_integer(params.withdraw.amount)

      if amount <= AccountInternal.get_amount_from_account(account_number) and amount > 0 do
        AccountInternal.withdraw(account_number, amount)

        conn
        |> put_flash(:info, "You took R$#{amount} out of your account!")
        |> redirect(to: Routes.user_path(conn, :info))
      else
        conn
        |> put_flash(:error, "You have no funds!")
        |> render("new_withdraw.html")
      end
    end
  end

  def new_transfer(conn, _) do
    render(conn, "new_transfer.html")
  end

  def raise_error(conn, error_description) do
    conn
    |> put_flash(:error, error_description)
    |> render("new_transfer.html")
  end


  def make_transfer(conn, params) do
    account_number = conn.assigns.current_account.account_number
    params = Utils.atomify_map(params)
    agreement = params.transfer.agreement

    if params.transfer.recipient_account_number == "" or params.transfer.amount == "" do
        raise_error(conn, "It cannot be blank")
    else
      recipient_account_number = String.to_integer(params.transfer.recipient_account_number)
      amount = String.to_integer(params.transfer.amount)
      name = AccountInternal.get_account_name(recipient_account_number)

      cond do
        agreement == "false" ->
          raise_error(conn, "You must agree with the fee")

        name == nil or recipient_account_number == account_number ->
          raise_error(conn, "The account does not exist or it is your own")

        amount + 1 > AccountInternal.get_amount_from_account(account_number) or amount < 0 ->
          raise_error(conn, "You have no funds")

        true ->
          Repo.transaction(fn ->
            Ecto.Adapters.SQL.query(__MODULE__, "SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")
            AccountInternal.transfer(account_number, recipient_account_number, amount)
            AccountInternal.withdraw(account_number, 1)
          end)

          conn
          |> put_flash(:info, "You transfered R$#{amount} to #{name}'s account!")
          |> redirect(to: Routes.user_path(conn, :info))
      end
    end
  end
end



  # def make_transfer2(conn, params) do
  #   account_number = conn.assigns.current_account.account_number
  #   params = Utils.atomify_map(params)
  #   agreement = params.transfer.agreement

  #   if params.transfer.recipient_account_number == "" or params.transfer.amount == "" do
  #     conn
  #     |> put_flash(:error, "It cannot be blank")
  #     |> render("new_transfer.html")
  #   else

  #     recipient_account_number = String.to_integer(params.transfer.recipient_account_number)
  #     amount = String.to_integer(params.transfer.amount)
  #     name = AccountInternal.get_account_name(recipient_account_number)

  #     if agreement == "false" do
  #       conn
  #       |> put_flash(:error, "You must agree with the fee.")
  #       |> render("new_transfer.html")
  #     else
  #       if name == nil or amount < 0 or recipient_account_number == account_number do
  #         conn
  #         |> put_flash(:error, "The account does not exist or it is your own.")
  #         |> render("new_transfer.html")
  #       else
  #         if amount + 1 > AccountInternal.get_amount_from_account(account_number) do
  #           conn
  #           |> put_flash(:error, "You have no funds!")
  #           |> render("new_transfer.html")
  #         else
  #           AccountInternal.transfer(account_number, recipient_account_number, amount)



  #           AccountInternal.withdraw(account_number, 1)

  #           conn
  #           |> put_flash(:info, "You transferred R$#{amount} to #{name}'s account!")
  #           |> redirect(to: Routes.user_path(conn, :info))
  #         end
  #       end
  #     end
  #   end
  # end
