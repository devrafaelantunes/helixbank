defmodule HelixBankWeb.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    account_id = get_session(conn, :account_id)
    account = account_id && HelixBank.Internal.Account.get_account(account_id)
    assign(conn, :current_account, account)
  end

  def login(conn, account) do
    conn
    |> assign(:current_account, account)
    |> put_session(:account_id, account.account_id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
end
