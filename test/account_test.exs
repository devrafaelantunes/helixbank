defmodule HelixBank.Internal.AccountTest do
  use ExUnit.Case, async: true

  alias Helixbank.Repo
  alias HelixBank.Internal.Account, as: AccountInternal
  alias HelixBank.Model.Account, as: AccountModel

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Helixbank.Repo)
  end

  @params %{name: "dev01", document: "43082810837", password: "123456"}
  @invalid_document %{document: "12445787493", password: "123456"}
  @params2 %{name: "dev02", document: "43082811809", password: "123456"}

  defp changeset_error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc}#{k}: #{joined_errors}"
    end)
  end

  describe "create an account" do
    test "creating an account with valid input" do
      assert {:ok, account} = AccountInternal.register_account(@params)
      assert account.document == @params.document
      assert account.name == @params.name

      fetched_account =
        AccountInternal.fetch_account_by_number(account.account_number)
        |> Repo.one()

      assert fetched_account.account_number == account.account_number
    end

    test "creating an account with a document that has already been taken" do
      assert {:ok, _} = AccountInternal.register_account(@params)
      assert {:error, changeset} = AccountInternal.register_account(@params)
      assert changeset_error_to_string(changeset) == "document: has already been taken"
    end

    test "creating an account with an invalid document number" do
      new_params = Map.merge(@params, @invalid_document)

      assert {:error, changeset} = AccountInternal.register_account(new_params)
      assert changeset_error_to_string(changeset) == "document: the document is not valid"
    end
    test "creating an account with a short password" do
      new_params = Map.merge(@params, %{password: "1234"})

      assert {:error, changeset} = AccountInternal.register_account(new_params)
      assert changeset_error_to_string(changeset) == "password: should be at least 6 character(s)"
    end
  end

  describe "testing authenticate function" do
    test "creating account and testing the authenticate function with the right password" do
      assert {:ok, changeset} = AccountInternal.register_account(@params)

      assert {:ok, account} = 
        AccountInternal.authenticate_by_document_and_pass(changeset.document, changeset.password)
    end

    test "creating account and testing the authenticate function with a wrong password" do
      assert {:ok, changeset} = AccountInternal.register_account(@params)

      assert {:error, :unauthorized} = 
        AccountInternal.authenticate_by_document_and_pass(changeset.document, "wrongpassword")
    end

    test "trying to authenticate with an unexisting account" do
      assert {:error, :not_found} = 
        AccountInternal.authenticate_by_document_and_pass("12345678910", "somepassword")
    end
  end

  describe "transactions" do
    test "deposit" do
      {:ok, account} = AccountInternal.register_account(@params)

      assert AccountInternal.get_amount_from_account(account.account_number) == 0.0

      assert {:ok, changeset} = AccountInternal.deposit(account.account_number, 100)
      assert AccountInternal.get_amount_from_account(account.account_number) == 100
    end

    test "withdraw" do
      {:ok, account} = AccountInternal.register_account(@params)

      assert AccountInternal.get_amount_from_account(account.account_number) == 0.0
      assert {:ok, changeset} = AccountInternal.deposit(account.account_number, 100)
      assert AccountInternal.get_amount_from_account(account.account_number) == 100
      assert {:ok, changeset} = AccountInternal.withdraw(account.account_number, 100)
      assert AccountInternal.get_amount_from_account(account.account_number) == 0.0
    end

    test "withdraw with no funds"  do
      {:ok, account} = AccountInternal.register_account(@params)

      assert AccountInternal.get_amount_from_account(account.account_number) == 0.0
      assert {:ok, changeset} = AccountInternal.deposit(account.account_number, 100)
      assert AccountInternal.get_amount_from_account(account.account_number) == 100
      assert {:error, :no_funds} = AccountInternal.withdraw(account.account_number, 101)
    end

    test "transfer or withdraw with no funds" do
      {:ok, account} = AccountInternal.register_account(@params)
      {:ok, account2} = AccountInternal.register_account(@params2)

      assert {:error, :no_funds} = AccountInternal.withdraw(account.account_number, 100)

      assert {:error, :no_funds} =
               AccountInternal.transfer(account.account_number, account2.account_number, 100)
    end

    test "transfer or withdraw from an unexisting account" do
      assert {:error, :invalid_account} = AccountInternal.withdraw(1298, 100)
      assert {:error, :invalid_account} = AccountInternal.transfer(1298, 1230, 100)
    end

    test "transfer money" do
      {:ok, account} = AccountInternal.register_account(@params)
      {:ok, account2} = AccountInternal.register_account(@params2)

      assert {:ok, changeset} = AccountInternal.deposit(account.account_number, 100)
      assert AccountInternal.get_amount_from_account(account.account_number) == 100
      assert AccountInternal.get_amount_from_account(account2.account_number) == 0.0

      assert AccountInternal.transfer(account.account_number, account2.account_number, 100)
      assert AccountInternal.get_amount_from_account(account.account_number) == 0.0
      assert AccountInternal.get_amount_from_account(account2.account_number) == 100
    end

  end

end
