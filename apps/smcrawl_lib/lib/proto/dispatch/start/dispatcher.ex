defimpl Smcrawl.Lib.Proto.Dispatch.Start, for: Smcrawl.Lib.Dispatcher do
  def start(dispatcher) do
    {:ok, dispatcher}
  end
end
