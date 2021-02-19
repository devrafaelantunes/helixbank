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

    def create_changeset(params) do
        %__MODULE__{}
        |> cast(params, [:name, :document, :amount, :agency_id, :account_number])
        |> validate_required([:name, :document, :agency_id, :account_number])
        |> unique_constraint(:document)
        |> validate_length(:document, min: 11)
        |> validate_document(params.document)
    end

    defp validate_document(changeset, param) do
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