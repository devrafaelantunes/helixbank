defmodule HelixBank.Model.Account do
    use Ecto.Schema
    import Ecto.Changeset

    alias HelixBank.Internal.Account, as: Internal

    @primary_key {:account_id, :id, autogenerate: true}
    schema "account" do
        field :name, :string
        field :document, :string
        field :amount, :float
        field :agency_id, :integer
        field :account_number, :integer

        timestamps()
    end

    def change_account(%__MODULE__{} = account) do
        create_changeset(account, %{})
    end

    def create_changeset(account, params) do
        account_number = Internal.generate_account_number()

        new_params =
            %{"account_number" => account_number, "agency_id" => 0001, "amount" => 0}
            |> Map.merge(params)

        account
        |> cast(new_params, [:name, :document, :amount, :agency_id, :account_number])
        |> validate_required([:name, :document, :agency_id, :account_number])
        |> unique_constraint(:document)
        |> validate_length(:document, min: 11, max: 11)
        #|> validate_document(:document)
    end

    def validate_document(changeset, param) do
        valid_sum =
            [22,33,44,55,66,77,88,99]

        valid_param =
            String.to_integer(param)
            |> Integer.digits()
            |> Enum.sum()

        if Enum.member?(valid_sum, valid_param) do
            changeset
        else
            add_error(changeset, :document, "the document is not valid")
        end
    end

    def update_amount(account, new_value) do
        change(account, amount: new_value)
    end
end
