defmodule Invoice.HelpersTest do
  use ExUnit.Case

  alias Invoice.Helpers

  @tag :wipa
  test "calculate_items_amount/1 calculates proper amount" do
    items = [
      %{
        quantity: 2,
        price: 30.5
      },
      %{
        quantity: 1,
        price: 15
      }
    ]

    assert Helpers.calculate_items_amount(items) === 76.0

    items = tl(items)
    assert Helpers.calculate_items_amount(items) === 15
  end
end
