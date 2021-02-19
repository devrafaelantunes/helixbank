defmodule HelixBank.Model.Account do
    use Ecto.Schema
    
    alias HelixBank.Internal.Account, as: Internal

    @primary_key {:account_id, :id, autogenerate: true}
    schema "account" do
        field :name, :string
        field :document, :string
        field :amount, :float, default: 0
        field :agency_id, :integer, default: 0001
        field :account_number, :integer, default: Internal.get_account_number()

        timestamps()
    end

    #def changeset(params) do
    #    %__MODULE__{}
#
#
#
 #   end







end