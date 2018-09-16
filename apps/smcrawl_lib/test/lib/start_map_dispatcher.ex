defimpl Smcrawl.Lib.Proto.Dispatch.Start, for: Map do
  def start(dispatcher) do
    start = dispatcher.start
    pid = start.()
    {:ok, %{pid: pid}}
  end
end
