defmodule Smcrawl.Lib.CrawlerTest do
  use ExUnit.Case
  doctest Smcrawl.Lib.Crawler
  alias Smcrawl.Lib.Crawler

  test "create crawler with default values" do
    assert %Crawler{dispatcher: nil} == Crawler.make()
  end

  test "should create crawler with nil dispatcher when passing the unsupported type" do
    assert %Crawler{dispatcher: nil} == Crawler.make() |> Crawler.with_dispatcher([])
  end

  test "should create crawler with custom dispatcher when providing the right protocol implementation" do
    assert %Crawler{dispatcher: %{}} == Crawler.make() |> Crawler.with_dispatcher(%{})
  end

  test "should return an empty sitemap when nothing to crawl" do
    start = fn ->
      task =
        Task.async(fn ->
          Process.exit(self(), {:done, []})
        end)

      task.pid
    end

    result =
      Crawler.make()
      |> Crawler.with_dispatcher(%{start: start})
      |> Crawler.sync()

    assert result == {:ok, []}
  end
end
