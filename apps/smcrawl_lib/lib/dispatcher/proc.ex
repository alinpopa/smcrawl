defmodule Smcrawl.Lib.Dispatcher.Proc do
  @behaviour :gen_statem

  defmodule State do
    defstruct max: 3,
              available: 0,
              queue: [],
              url: nil,
              sitemap: nil,
              freq: 0,
              parser: nil,
              set: nil,
              depth: 3
  end

  alias Smcrawl.Lib.Proto.Set
  alias Smcrawl.Lib.SiteMap

  def start_link(req) do
    :gen_statem.start_link(
      __MODULE__,
      %State{
        parser: req.parser,
        set: req.set,
        max: req.workers,
        freq: req.freq,
        depth: req.depth,
        url: req.url,
        sitemap: SiteMap.make()
      },
      []
    )
  end

  def init(state) do
    Process.flag(:trap_exit, true)
    queue = [{1, state.url}]
    sitemap = state.sitemap |> SiteMap.put({1, state.url}, nil)

    {:ok, :ready, %State{state | available: state.max, queue: queue, sitemap: sitemap},
     [{:state_timeout, state.freq, :do}]}
  end

  def callback_mode() do
    :handle_event_function
  end

  def handle_event(
        :state_timeout,
        :do,
        :ready,
        state = %State{available: available, max: max, queue: []}
      )
      when available == max,
      do: {:stop, {:done, state.sitemap}}

  def handle_event(:state_timeout, :do, :ready, state = %State{queue: []}),
    do: {:next_state, :waiting_for_workers, state}

  def handle_event(:state_timeout, :do, :ready, state = %State{available: 0}),
    do: {:next_state, :waiting_for_workers, state}

  def handle_event(:state_timeout, :do, :ready, state) do
    {work, queue} = dequeue(state.queue)
    async(state, work)

    {:keep_state, %State{state | available: state.available - 1, queue: queue},
     [{:state_timeout, state.freq, :do}]}
  end

  def handle_event(:info, {_, {:task_result, nil}}, _, state),
    do: {:keep_state, state}

  def handle_event(:info, {_, {:task_result, work}}, _, state) do
    {queue, set, sitemap} =
      Enum.reduce(work, {state.queue, state.set, state.sitemap}, fn e, {queue, set, sitemap} ->
        sitemap = sitemap |> SiteMap.put({e.level - 1, e.orig_url}, e.url)

        case Set.exists?(set, e.url) do
          true -> {queue, set, sitemap}
          false -> {queue |> enqueue(e, state), Set.put(set, e.url), sitemap}
        end
      end)

    {:keep_state, %State{state | queue: queue, set: set, sitemap: sitemap}}
  end

  def handle_event(:info, {:EXIT, _, _}, _, state),
    do:
      {:next_state, :ready, %State{state | available: state.available + 1},
       [{:state_timeout, state.freq, :do}]}

  def handle_event(:info, {:DOWN, _, :process, _, _}, _, state) do
    {:keep_state, state}
  end

  defp async(state, {level, work}) do
    Task.async(fn ->
      req = %Smcrawl.Lib.Parser.Req{base_url: base_url(work), url: work, level: level}

      case Smcrawl.Lib.Proto.Parse.Run.run(state.parser, req) do
        {:ok, result} ->
          {:task_result, result}

        {:error, reason} ->
          IO.inspect({"Failed to return result", reason})
          {:task_result, nil}
      end
    end)
  end

  defp base_url(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host, port: port} when port == 80 or port == 443 ->
        "#{scheme}://#{host}"

      %URI{scheme: scheme, host: host, port: port} ->
        "#{scheme}://#{host}:#{port}"
    end
  end

  defp enqueue(queue, work_result, state) do
    if work_result.level <= state.depth,
      do: [{work_result.level, work_result.url} | queue],
      else: queue
  end

  defp dequeue([]), do: {nil, []}
  defp dequeue([h | t]), do: {h, t}
end
