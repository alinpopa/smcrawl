defmodule Smcrawl.Lib.Dispatcher.ValidateTest do
  use ExUnit.Case
  doctest Smcrawl.Lib.Dispatcher
  alias Smcrawl.Lib.Dispatcher
  alias Smcrawl.Lib.Proto.Dispatch.Validate

  test "should validate unsupported parsers" do
    dispatcher = %Dispatcher{parser: [], set: MapSet.new(), url: "http://aaa"}
    assert {:error, :invalid_parser} == Validate.validate(dispatcher)
  end

  test "should pass validation when using all valid fields" do
    dispatcher = %Dispatcher{parser: %{}, set: MapSet.new(), url: "http://aaa"}
    assert {:ok, %Dispatcher{}} = Validate.validate(dispatcher)
  end

  test "should validate unsupported sets" do
    dispatcher = %Dispatcher{set: [], parser: %{}, url: "http://aaa"}
    assert {:error, :invalid_set} == Validate.validate(dispatcher)
  end

  test "should validate non http urls" do
    parser = %Dispatcher{url: nil, parser: %{}, set: MapSet.new()}
    assert {:error, :invalid_url} == Validate.validate(parser)

    parser = %Dispatcher{url: "string here", parser: %{}, set: MapSet.new()}
    assert {:error, :invalid_url} == Validate.validate(parser)

    parser = %Dispatcher{url: "htt://host here", parser: %{}, set: MapSet.new()}
    assert {:error, :invalid_url} == Validate.validate(parser)
  end

  test "should validate missing hosts" do
    parser = %Dispatcher{url: "http://", parser: %{}, set: MapSet.new()}
    assert {:error, :invalid_url} == Validate.validate(parser)
  end

  test "should validate incorrect frequency" do
    dispatcher = %Dispatcher{frequency: nil, parser: %{}}
    assert {:error, {:invalid_frequency, nil}} == Validate.validate(dispatcher)

    dispatcher = %Dispatcher{frequency: "test", parser: %{}}
    assert {:error, {:invalid_frequency, "test"}} == Validate.validate(dispatcher)

    dispatcher = %Dispatcher{frequency: -5, parser: %{}}
    assert {:error, {:invalid_frequency, -5}} == Validate.validate(dispatcher)
  end

  test "should validate incorrect number of workers" do
    dispatcher = %Dispatcher{workers: nil, parser: %{}}
    assert {:error, {:invalid_workers, nil}} == Validate.validate(dispatcher)

    dispatcher = %Dispatcher{workers: "test", parser: %{}}
    assert {:error, {:invalid_workers, "test"}} == Validate.validate(dispatcher)

    dispatcher = %Dispatcher{workers: -5, parser: %{}}
    assert {:error, {:invalid_workers, -5}} == Validate.validate(dispatcher)
  end
end
