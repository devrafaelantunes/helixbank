defmodule HelixBank.Internal.Account do
    import Ecto.Query
    alias HelixBank.Model.Account
    alias Helixbank.Repo


    def get_account_number() do
        acc_number = Enum.random(2222..9999)

        if Repo.get_by(Account, account_number: acc_number) do
            acc_number
        else
            get_account_number()
        end
    end
end