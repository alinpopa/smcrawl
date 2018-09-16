defimpl Smcrawl.Lib.Proto.Parse.Run, for: Smcrawl.Lib.Parser do
  def run(parser, req) do
    url = req.url
    http = parser.http

    case http.(url) do
      {:ok, body} ->
        {:ok, get_urls(req, body, parser.exclude)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_urls(req, body, exclude) do
    Floki.find(body, "a")
    |> Floki.attribute("href")
    |> Enum.filter(fn value ->
      valid_url?(req.base_url, value)
    end)
    |> Enum.filter(fn value ->
      not String.ends_with?(value, [".pdf", ".jpg", ".jpeg", ".png", ".js", ".css"])
    end)
    |> Enum.filter(fn value ->
      not String.contains?(value, exclude)
    end)
    |> Enum.map(fn value ->
      url =
        case String.starts_with?(value, req.base_url) do
          true -> value
          false -> "#{req.base_url}#{value}"
        end

      %{level: req.level + 1, url: url, orig_url: req.url}
    end)
  end

  defp valid_url?(url, result) do
    predicates = [
      &(String.starts_with?(&1, url) and &1 != url),
      &(String.starts_with?(&1, "/") and &1 != "/")
    ]

    Enum.any?(predicates, fn predicate -> predicate.(result) end)
  end
end
