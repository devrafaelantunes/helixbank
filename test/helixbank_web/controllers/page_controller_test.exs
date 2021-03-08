defmodule HelixbankWeb.PageControllerTest do
  use HelixbankWeb.ConnCase, async: true

  alias HelixbankWeb.UserController, as: Controller
  alias HelixBank.Internal.Account, as: AccountInternal
  alias HelixBankWeb.Auth

  @params %{name: "dev01", document: "43082810837", password: "123456"}

  defp login() do
    AccountInternal.register_account(@params)
    AccountInternal.authenticate_by_document_and_pass(@params.document, @params.password)
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, Routes.page_path(conn, :index))
    assert html_response(conn, 200) =~ "Welcome to HelixBank!"
  end

  test "GET /user/index (not logged in)", %{conn: conn} do
    conn = get(conn, Routes.user_path(conn, :index))
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "GET /user/index (when logged in)", %{conn: conn} do
    {:ok, account} = login()

    conn =
      conn
      |> get("/")
      |> fetch_session()
      |> assign(:current_account, account)
    
    get(conn, Routes.user_path(conn, :index))
    assert html_response(conn, 200)
  end

#  test "GET /user/info (when logged in)", %{conn: conn} do
#    {:ok, account} = login()
#    
#    conn =
#      conn
#       |> get("/")
#       |> fetch_session()
#       |> assign(:current_account, account)
#    
#    #get(conn, Routes.user_path(conn, :info))
#    #assert html_response(conn, 302)
#  end

  test "GET /user/make_deposit", %{conn: conn} do
    conn = get(conn, Routes.user_path(conn, :new_deposit))
    assert html_response(conn, 200) =~ "Make a Deposit"
  end

  test "GET /user/make_withdraw", %{conn: conn} do
    conn = get(conn, Routes.user_path(conn, :new_withdraw))
    assert html_response(conn, 200) =~ "Make a Withdraw"
  end

  test "GET /user/make_transfer", %{conn: conn} do
    conn = get(conn, Routes.user_path(conn, :new_transfer))
    assert html_response(conn, 200) =~ "Transfer Money"
  end
end
