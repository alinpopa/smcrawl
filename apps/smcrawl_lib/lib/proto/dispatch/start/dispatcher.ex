defimpl Smcrawl.Lib.Proto.Dispatch.Start, for: Smcrawl.Lib.Dispatcher do
  alias Smcrawl.Lib.Dispatcher

  def start(dispatcher) do
    req = %{
      parser: dispatcher.parser,
      set: dispatcher.set,
      workers: dispatcher.workers,
      freq: dispatcher.frequency,
      depth: dispatcher.depth,
      url: dispatcher.url
    }

    {:ok, pid} = Dispatcher.Proc.start_link(req)
    {:ok, %Dispatcher{dispatcher | pid: pid}}
  end
end
