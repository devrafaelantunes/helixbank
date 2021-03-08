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
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  def change_account(%__MODULE__{} = account) do
    change(account)
    create_changeset(account, %{})
  end

  def change_registration(%__MODULE__{} = account) do
    change(account)
  end

  def create_changeset(account, params) do
    account_number = Internal.generate_account_number()

    new_params =
      %{account_number: account_number, agency_id: 0001, amount: 0}
      |> Map.merge(params)

    account
    |> cast(new_params, [:name, :document, :amount, :agency_id, :account_number])
    |> validate_required([:name, :document, :agency_id, :account_number])
    |> unique_constraint(:document)
    |> validate_length(:document, min: 11, max: 11)
    |> validate_document(params.document)
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end

  def create_registration(account, params) do
    account
    |> create_changeset(params)
    |> cast(params, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  def validate_document(changeset, cpf) do
    if Integer.parse(cpf) == :error do
      changeset
    else
      valid_sum = [22, 33, 44, 55, 66, 77, 88, 99]

      valid_cpf =
        String.to_integer(cpf)
        |> Integer.digits()
        |> Enum.sum()

      if Enum.member?(valid_sum, valid_cpf) do
        changeset
      else
        add_error(changeset, :document, "the document is not valid")
      end
    end
  end

  def update_amount(account, new_value) do
    change(account, amount: new_value)
  end
end
