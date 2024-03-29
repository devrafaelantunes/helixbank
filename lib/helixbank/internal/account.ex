defmodule HelixBank.Internal.Account do
  import Ecto.{Query, Changeset}
  alias HelixBank.Model.Account
  alias Helixbank.Repo

  def create_account(params) do
    %Account{}
    |> Account.create_changeset(params)
    |> Repo.insert()
  end

  def register_account(params) do
    %Account{}
    |> Account.create_registration(params)
    |> Repo.insert()
  end

  def authenticate_by_document_and_pass(document, given_pass) do
    account = get_account_by(document: document)

    cond do
      account && Pbkdf2.verify_pass(given_pass, account.password_hash) ->
        {:ok, account}

      account ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end

  def deposit(account_number, amount) do
    if account_exists?(account_number) do
      old_value =
        account_number
        ## tiurar isso fazer um proprio e colocar select
        |> get_amount_from_account()

      fetch_account_by_number(account_number)
      |> Repo.one()
      |> Account.update_amount(old_value + amount)
      |> Repo.update()
    else
      {:error, :invalid_account}
    end
  end

  def transfer(account_number, to_account, amount) do
    if account_exists?(account_number) and account_exists?(to_account) do
      if get_amount_from_account(account_number) >= amount do
        withdraw(account_number, amount)
        deposit(to_account, amount)
      else
        {:error, :no_funds}
      end
    else
      {:error, :invalid_account}
    end
  end

  def withdraw(account_number, amount) do
    if account_exists?(account_number) do
      if get_amount_from_account(account_number) >= amount do
        old_value =
          account_number
          |> get_amount_from_account()

        fetch_account_by_number(account_number)
        |> Repo.one()
        |> Account.update_amount(old_value - amount)
        |> Repo.update()
      else
        {:error, :no_funds}
      end
    else
      {:error, :invalid_account}
    end
  end

  def get_amount_from_account(account_number) do
    query =
      from(a in Account,
        where: a.account_number == ^account_number,
        select: a.amount
      )

    Repo.one(query)
  end

  def generate_account_number() do
    acc_number = Enum.random(2222..9999)

    if account_exists?(acc_number) do
      generate_account_number()
    else
      acc_number
    end
  end

  defp account_exists?(acc_number) when is_integer(acc_number) do
    fetch_account_by_number(acc_number)
    |> Repo.exists?()
  end

  def fetch_account_by_number(acc_number) do
    from(a in Account,
      where: a.account_number == ^acc_number
    )
  end

  def list_accounts() do
    # SELECT NAME FROM ACCOUNTS
    from(a in Account,
      select: {a.name, a.document, a.account_number, a.amount}
    )
  end

  def get_account(id) do
    Repo.get(Account, id)
  end

  def get_account_by(params) do
    Repo.get_by(Account, params)
  end

  def get_account_name(account_number) do
    from(a in Account,
      where: a.account_number == ^account_number,
      select: a.name
    )
    |> Repo.one()
  end
end
