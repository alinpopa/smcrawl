defmodule Smcrawl.Lib.Crawler do
  defstruct dispatcher: nil

  alias Smcrawl.Lib.Crawler
  alias Smcrawl.Lib.Proto.Dispatch

  def make(),
    do: %Crawler{}

  def with_dispatcher(crawler, dispatcher) do
    dispatcher = Smcrawl.Lib.Proto.Dispatch.With.with(dispatcher)
    %Crawler{crawler | dispatcher: dispatcher}
  end

  def async(crawler) do
    Smcrawl.Lib.Proc.async(fn ->
      with {:ok, crawler} <- validate(crawler),
           {:ok, dispatcher} <- Dispatch.Validate.validate(crawler.dispatcher),
           {:ok, dispatcher} <- Dispatch.Start.start(dispatcher) do
        {:ok, dispatcher.pid}
      else
        {:error, _} = err -> err
      end
    end)
  end

  def sync(crawler) do
    async(crawler) |> Task.await(:infinity)
  end

  defp validate(%Crawler{dispatcher: nil}),
    do: {:error, :invalid_dispatcher}

  defp validate(crawler),
    do: {:ok, crawler}
end
