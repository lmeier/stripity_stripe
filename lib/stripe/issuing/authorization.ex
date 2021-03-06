defmodule Stripe.Issuing.Authorization do
  @moduledoc """
  Work with Stripe Issuing authorization objects.

  You can:

  - Retrieve an authorization
  - Update an authorization
  - Approve an authorization
  - Decline an authorization
  - List all authorizations

  Stripe API reference: https://stripe.com/docs/api/issuing/authorizations
  """

  use Stripe.Entity
  import Stripe.Request

  @type pending_request :: %{
          amount: integer,
          currency: String.t(),
          is_amount_controllable: boolean,
          merchant_amount: integer,
          merchant_currency: String.t()
        }

  @type request_history :: %{
          approved: boolean,
          authorized_amount: integer,
          authorized_currency: String.t(),
          created: Stripe.timestamp(),
          held_amount: integer,
          held_currency: String.t(),
          reason: String.t()
        }

  @type verification_data :: %{
          address_line1_check: String.t(),
          address_zip_check: String.t(),
          cvc_check: String.t()
        }

  @type t :: %__MODULE__{
          id: Stripe.id(),
          object: String.t(),
          amount: integer,
          approved: boolean,
          authorization_method: String.t(),
          balance_transactions: Stripe.List.t(Stripe.BalanceTransaction.t()),
          card: Stripe.Issuing.Card.t(),
          cardholder: Stripe.id() | Stripe.Issuing.Cardholder.t(),
          created: Stripe.timestamp(),
          currency: String.t(),
          livemode: boolean,
          merchant_amount: integer,
          merchant_currency: String.t(),
          merchant_data: Stripe.Issuing.Types.merchant_data(),
          metadata: Stripe.Types.metadata(),
          pending_request: pending_request() | nil,
          request_history: Stripe.List.t(request_history()),
          status: String.t(),
          transactions: Stripe.List.t(Stripe.Issuing.Transaction.t()),
          verification_data: verification_data(),
          wallet: String.t() | nil
        }

  defstruct [
    :id,
    :object,
    :amount,
    :approved,
    :authorization_method,
    :balance_transactions,
    :card,
    :cardholder,
    :created,
    :currency,
    :livemode,
    :merchant_amount,
    :merchant_currency,
    :merchant_data,
    :metadata,
    :pending_request,
    :request_history,
    :status,
    :transactions,
    :verification_data,
    :wallet
  ]

  @plural_endpoint "issuing/authorizations"

  @doc """
  Retrieve an authorization.
  """
  @spec retrieve(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def retrieve(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:get)
    |> make_request()
  end

  @doc """
  Update an authorization.
  """
  @spec update(Stripe.id() | t, params, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:metadata) => Stripe.Types.metadata()
               }
               | %{}
  def update(id, params, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  Approve an authorization.
  """
  @spec approve(Stripe.id() | t, params, Stripe.options()) ::
          {:ok, t} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:held_amount) => non_neg_integer
               }
               | %{}
  def approve(id, params \\ %{}, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}" <> "/approve")
    |> put_method(:post)
    |> put_params(params)
    |> make_request()
  end

  @doc """
  Decline an authorization.
  """
  @spec decline(Stripe.id() | t, Stripe.options()) :: {:ok, t} | {:error, Stripe.Error.t()}
  def decline(id, opts \\ []) do
    new_request(opts)
    |> put_endpoint(@plural_endpoint <> "/#{get_id!(id)}" <> "/decline")
    |> put_method(:post)
    |> make_request()
  end

  @doc """
  List all authorizations.
  """
  @spec list(params, Stripe.options()) :: {:ok, Stripe.List.t(t)} | {:error, Stripe.Error.t()}
        when params:
               %{
                 optional(:card) => Stripe.Issuing.Card.t() | Stripe.id(),
                 optional(:cardholder) => Stripe.Issuing.Cardholder.t() | Stripe.id(),
                 optional(:created) => String.t() | Stripe.date_query(),
                 optional(:ending_before) => t | Stripe.id(),
                 optional(:limit) => 1..100,
                 optional(:starting_after) => t | Stripe.id(),
                 optional(:status) => String.t()
               }
               | %{}
  def list(params \\ %{}, opts \\ []) do
    new_request(opts)
    |> prefix_expansions()
    |> put_endpoint(@plural_endpoint)
    |> put_method(:get)
    |> put_params(params)
    |> cast_to_id([:card, :cardholder, :ending_before, :starting_after])
    |> make_request()
  end
end
