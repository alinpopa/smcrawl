defimpl Smcrawl.Lib.Proto.Dispatch.Validate, for: Smcrawl.Lib.Dispatcher do
  alias Smcrawl.Lib.Dispatcher

  def validate(%Dispatcher{workers: workers})
      when is_nil(workers) or not is_integer(workers) or workers < 1,
      do: {:error, {:invalid_workers, workers}}

  def validate(%Dispatcher{frequency: freq})
      when is_nil(freq) or not is_integer(freq) or freq < 0,
      do: {:error, {:invalid_frequency, freq}}

  def validate(%Dispatcher{parser: nil}),
    do: {:error, :invalid_parser}

  def validate(%Dispatcher{set: nil}),
    do: {:error, :invalid_set}

  def validate(%Dispatcher{depth: depth})
      when is_nil(depth) or not is_integer(depth) or depth < 1,
      do: {:error, {:invalid_depth, depth}}

  def validate(dispatcher) do
    with {:ok, dispatcher} <- validate_url(dispatcher),
         {:ok, parser} <- Smcrawl.Lib.Proto.Parse.Validate.validate(dispatcher.parser),
         {:ok, set} <- Smcrawl.Lib.Proto.Set.Validate.validate(dispatcher.set) do
      {:ok, %Dispatcher{dispatcher | parser: parser, set: set}}
    else
      {:error, _} = err -> err
    end
  end

  defp validate_url(%Dispatcher{url: nil}),
    do: {:error, :invalid_url}

  defp validate_url(dispatcher = %Dispatcher{url: url}) do
    case URI.parse(url) do
      %URI{host: nil} ->
        {:error, :invalid_url}

      %URI{scheme: nil} ->
        {:error, :invalid_url}

      %URI{scheme: scheme} when scheme != "http" and scheme != "https" ->
        {:error, :invalid_url}

      _ ->
        {:ok, dispatcher}
    end
  end
end
