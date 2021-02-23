defmodule HelixBank.Internal.AccountTest do
    use ExUnit.Case, async: true

    alias Helixbank.Repo
    alias HelixBank.Internal.Account, as: AccountInternal

    setup do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Helixbank.Repo)
    end

    @params %{name: "dev01", document: "43082810837"}
    @invalid_document %{document: "12445787493"}
    @params2 %{name: "dev02", document: "43082811809"}


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
            assert {:ok, account} = AccountInternal.create_account(@params)
            assert account.document == @params.document
            assert account.name == @params.name

            fetched_account =
                AccountInternal.fetch_account_by_number(account.account_number)
                |> Repo.one()

            assert fetched_account.account_number == account.account_number
        end

        test "creating an account with a document that has already been taken" do
            assert {:ok, _} = AccountInternal.create_account(@params)
            assert {:error, changeset} = AccountInternal.create_account(@params)
            assert changeset_error_to_string(changeset) == "document: has already been taken"

        end

        test "creating an account with an invalid document number" do
            new_params = Map.merge(@params, @invalid_document)

            assert {:error, changeset} = AccountInternal.create_account(new_params)
            assert changeset_error_to_string(changeset) == "document: the document is not valid"
        end
    end

    describe "transactions" do
        test "deposit" do
            {:ok, account} = AccountInternal.create_account(@params)

            assert AccountInternal.get_amount_from_account(account.account_number) == 0.0

            assert {:ok, changeset} = AccountInternal.deposit(account.account_number, 100)
            assert AccountInternal.get_amount_from_account(account.account_number) == 100

        end

        test "withdraw" do
            {:ok, account} = AccountInternal.create_account(@params)

            assert AccountInternal.get_amount_from_account(account.account_number) == 0.0
            assert {:ok, changeset} = AccountInternal.deposit(account.account_number, 100)
            assert AccountInternal.get_amount_from_account(account.account_number) == 100
            assert {:ok, changeset} = AccountInternal.withdraw(account.account_number, 100)
            assert AccountInternal.get_amount_from_account(account.account_number) == 0.0
        end

        test "transfer or withdraw with no funds" do
            {:ok, account} = AccountInternal.create_account(@params)
            {:ok, account2} = AccountInternal.create_account(@params2)

            assert {:error, :no_funds} = AccountInternal.withdraw(account.account_number, 100)
            assert {:error, :no_funds} = AccountInternal.transfer(account.account_number, account2.account_number, 100)
        end

        test "transfer or withdraw from an unexisting account" do
            assert {:error, :invalid_account} = AccountInternal.withdraw(1298, 100)
            assert {:error, :invalid_account} = AccountInternal.transfer(1298, 1230, 100)
        end

        test "transfer money" do
            {:ok, account} = AccountInternal.create_account(@params)
            {:ok, account2} = AccountInternal.create_account(@params2)

            assert {:ok, changeset} = AccountInternal.deposit(account.account_number, 100)
            assert AccountInternal.get_amount_from_account(account.account_number) == 100
            assert AccountInternal.get_amount_from_account(account2.account_number) == 0.0

            assert AccountInternal.transfer(account.account_number, account2.account_number, 100)
            assert AccountInternal.get_amount_from_account(account.account_number) == 0.0
            assert AccountInternal.get_amount_from_account(account2.account_number) == 100

        end
    end
end
