defmodule Smcrawl.Lib.SiteMap do
  defstruct urls: %{}

  alias Smcrawl.Lib.SiteMap

  def make(), do: %SiteMap{}

  def put(sitemap, url, nil) do
    urls =
      case Map.get(sitemap.urls, url) do
        nil -> Map.put(sitemap.urls, url, MapSet.new())
        _ -> sitemap.urls
      end

    %SiteMap{sitemap | urls: urls}
  end

  def put(sitemap, url, link) do
    urls =
      case Map.get(sitemap.urls, url) do
        nil -> Map.put(sitemap.urls, url, MapSet.new() |> MapSet.put(link))
        links -> Map.put(sitemap.urls, url, links |> MapSet.put(link))
      end

    %SiteMap{sitemap | urls: urls}
  end

  def render(sitemap) do
    sitemap.urls
    |> Map.to_list()
    |> Enum.sort(fn {{level_a, _}, _}, {{level_b, _}, _} ->
      level_a < level_b
    end)
    |> Enum.each(fn {{_level, url}, links} ->
      IO.puts("📄 #{url}")
      links |> Enum.each(&IO.puts("   🔗 #{&1}"))
    end)
  end
end
