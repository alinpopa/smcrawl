defmodule Smcrawl.CLI do
  alias Smcrawl.Lib.Crawler
  alias Smcrawl.Lib.Dispatcher
  alias Smcrawl.Lib.Parser
  alias Smcrawl.Lib.SiteMap

  def main(args \\ []) do
    args |> parse() |> exec()
  end

  defp parse(args) do
    available_opts = [
      {:url, :string},
      {:exclude, :string},
      {:depth, :integer},
      {:workers, :integer},
      {:freq, :integer},
      {:help, :boolean}
    ]

    aliases = [
      {:u, :url},
      {:e, :exclude},
      {:d, :depth},
      {:w, :workers},
      {:f, :freq},
      {:h, :help}
    ]

    {opts, _, errs} = OptionParser.parse(args, strict: available_opts, aliases: aliases)
    {opts, errs}
  end

  defp show_help() do
    IO.puts("""

    Usage: ./smcrawl_cli [options]

    Available options:
      -u, --url        - the initial url to crawl
      -e, --exclude    - exclude urls that contain one of given words as part of their name
      -d, --depth      - how deep to go when to crawl the given page (default: 3)
      -w, --workers    - how many concurrent workers to use to crawl the given url (default: 10)
      -f, --freq       - delay (in milliseconds) between each crawl in order to avoid being blocked by the given domain (default: 0)
      -h, --help       - show this help menu

    Examples:

      # Crawl the Twitter website, but excluding all urls containing "red", "blue", "green" in their name
      smcrawl_cli -u "https://twitter.com" -e "red;blue;green"

      # Crawl the Monzo website but don't go more than 3 levels deep (https://monzo.com being consireded level 1)
      smcrawl_cli -u "https://monzo.com" -d 3

      # Crawl the Monzo website with 5 concurrent workers, and don't go deeper than 3 levels
      smcrawl_cli -u "https://monzo.com" -w 5 -d 3

    """)
  end

  defp exec({_opts, errs = [_ | _]}) do
    show_errs(parse_errs(errs))
  end

  defp exec({opts, []}) do
    with {:ok, nil} <- get_help_arg(opts),
         {:ok, url} <- get_url_arg(opts),
         {:ok, exclude} <- get_exclude_arg(opts),
         {:ok, depth} <- get_depth_arg(opts),
         {:ok, workers} <- get_workers_arg(opts),
         {:ok, freq} <- get_freq_arg(opts) do
      parser = %Parser{http: &Smcrawl.Lib.Http.get/1, exclude: exclude}
      set = MapSet.new()

      dispatcher = %Dispatcher{
        url: url,
        frequency: freq,
        parser: parser,
        set: set,
        depth: depth,
        workers: workers
      }

      result =
        Crawler.make()
        |> Crawler.with_dispatcher(dispatcher)
        |> Crawler.sync()

      case result do
        {:ok, sitemap} ->
          SiteMap.render(sitemap)

        {:error, reason} ->
          IO.puts("Error while running crawler: #{inspect(reason)}")
          show_help()
      end
    else
      {:just, :help} ->
        show_help()

      err ->
        show_errs([err])
    end
  end

  defp parse_errs(errs) do
    Enum.map(errs, fn {field, _} ->
      {:error, {:invalid, field}}
    end)
  end

  defp show_errs(errs) do
    msg =
      Enum.reduce(errs, "", fn {:error, {:invalid, field}}, acc ->
        acc <> "\nInvalid #{field}"
      end)

    IO.puts(msg)
    show_help()
  end

  defp get_url_arg(opts) do
    case Keyword.get(opts, :url) do
      nil -> {:error, {:invalid, :url}}
      url -> {:ok, url}
    end
  end

  defp get_help_arg(opts) do
    case Keyword.get(opts, :help) do
      nil -> {:ok, nil}
      false -> {:ok, nil}
      true -> {:just, :help}
    end
  end

  defp get_exclude_arg(opts) do
    case Keyword.get(opts, :exclude) do
      nil ->
        {:ok, []}

      exclude ->
        {:ok, String.split(exclude, ";")}
    end
  end

  defp get_depth_arg(opts) do
    case Keyword.get(opts, :depth) do
      nil ->
        {:ok, 3}

      depth when depth > 0 ->
        {:ok, depth}

      _depth ->
        {:error, {:invalid, :depth}}
    end
  end

  defp get_workers_arg(opts) do
    case Keyword.get(opts, :workers) do
      nil ->
        {:ok, 10}

      workers when workers > 0 ->
        {:ok, workers}

      _workers ->
        {:error, {:invalid, :workers}}
    end
  end

  defp get_freq_arg(opts) do
    case Keyword.get(opts, :freq) do
      nil ->
        {:ok, 0}

      freq when freq >= 0 ->
        {:ok, freq}

      _freq ->
        {:error, {:invalid, :freq}}
    end
  end
end
