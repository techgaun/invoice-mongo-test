defmodule Invoice.Helpers do
  @moduledoc """
  Helper functions for Invoice system
  """

  @day_seconds 86_400

  @doc """
  Shift current date time by given number of days
  """
  @spec iso_date_with_shift(Keyword.t) :: String.t
  def iso_date_with_shift(days: days) do
    DateTime.utc_now()
    |> DateTime.to_unix()
    |> Kernel.+(@day_seconds * days)
    |> DateTime.from_unix!()
    |> DateTime.to_iso8601()
  end

  @doc """
  Calculates total amounts based on amount and quantity of each item
  """
  @spec calculate_items_amount(list) :: number
  def calculate_items_amount(items) do
    items
    |> Stream.map(& &1.quantity * &1.price)
    |> Enum.sum()
  end
end
