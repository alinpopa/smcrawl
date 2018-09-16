defmodule Smcrawl.Lib.Parser.ValidateTest do
  use ExUnit.Case
  doctest Smcrawl.Lib.Parser
  alias Smcrawl.Lib.Parser
  alias Smcrawl.Lib.Proto.Parse.Validate

  test "should validate missing http module" do
    parser = %Parser{}
    assert {:error, :invalid_http_get} == Validate.validate(parser)
  end

  test "should pass validation when using a valid parser" do
    parser = %Parser{http: :not_nil}
    assert {:ok, %Parser{}} = Validate.validate(parser)

    parser = %Parser{http: :not_nil}
    assert {:ok, %Parser{}} = Validate.validate(parser)
  end
end
