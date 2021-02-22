defmodule HelixBank.Internal.AccountTest do
    use ExUnit.Case, async: true

    alias Helixbank.Repo
    alias HelixBank.Internal.Account, as: AccountInternal


    setup do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Helixbank.Repo)
    end
    
    @params %{name: "dev01", document: "43082810837"}


    test "create account" do
        assert {:ok, account} = AccountInternal.create_account(@params)
        assert account.document == @params.document
        assert account.name == @params.name

        fetched_account =
            AccountInternal.fetch_account_by_number(account.account_number)
            |> Repo.one()
        
        assert fetched_account.account_number == account.account_number
    end

    test "error when creating two or more accounts with the same document" do
        assert {:ok, _} = AccountInternal.create_account(@params)
        assert {:error, changeset} = AccountInternal.create_account(@params)

    end








end