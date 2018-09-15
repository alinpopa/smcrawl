defmodule Smcrawl.Lib.Crawler do
  defstruct url: nil,
            frequency: 0,
            depth: 10,
            parser: nil,
            dispatcher: nil

  alias Smcrawl.Lib.Crawler

  def make(),
    do: %Crawler{}

  def set_url(crawler, url),
    do: %Crawler{crawler | url: url}

  def set_frequency(crawler, freq),
    do: %Crawler{crawler | frequency: freq}

  def set_depth(crawler, depth),
    do: %Crawler{crawler | depth: depth}

  def with_dispatcher(crawler, dispatcher) do
    dispatcher = Smcrawl.Lib.Proto.Dispatch.With.with(dispatcher)
    %Crawler{crawler | dispatcher: dispatcher}
  end

  def with_parser(crawler, parser) do
    parser = Smcrawl.Lib.Proto.Parse.With.with(parser)
    %Crawler{crawler | parser: parser}
  end

  def async(_crawler) do
    Task.async(fn ->
      :ok
    end)
  end
end
