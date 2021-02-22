defmodule HelixBank.Internal.Account do
    import Ecto.{Query, Changeset}
    alias HelixBank.Model.Account
    alias Helixbank.Repo

    def create_account(params) do
        account_number = generate_account_number()
        
        new_params =
            %{account_number: account_number, agency_id: 0001, amount: 0}
            |> Map.merge(params)

        new_params
        |> Account.create_changeset()
        |> Repo.insert

    end

    def deposit(account_number, amount) do
        if account_exists?(account_number) do
            old_value = 
                account_number
                |> get_amount_from_account() ## tiurar isso fazer um proprio e colocar select
            
            fetch_account_by_number(account_number)
            |> Repo.one()
            |> Account.update_amount(old_value + amount)
            |> Repo.update()
        
        
        else
            raise "the account number does not exist"
        end
    end

    def transfer(account_number, to_account, amount) do
        if account_exists?(account_number) and account_exists?(to_account) do
            if get_amount_from_account(account_number) >= amount do
                withdraw(account_number, amount)
                deposit(to_account, amount)
            else
                raise "you have no funds"
            end

        else
            raise "the account does not exist"
        end


    end 

    def withdraw(account_number, amount) do
        if account_exists?(account_number) do
            old_value = 
                account_number
                |> get_amount_from_account()

            fetch_account_by_number(account_number)
            |> Repo.one()
            |> Account.update_amount(old_value - amount)
            |> Repo.update()
        else
            raise "the account number does not exist"

        end

    
    end

    defp get_amount_from_account(account_number) do
        query = 
            from(a in Account,
                where: a.account_number == ^account_number,
                select: a.amount)

        Repo.one(query)

    end

    defp generate_account_number() do
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
            where: a.account_number == ^acc_number)
    end

end