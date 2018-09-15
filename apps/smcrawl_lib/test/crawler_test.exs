defmodule Smcrawl.Lib.CrawlerTest do
  use ExUnit.Case
  doctest Smcrawl.Lib.Crawler
  alias Smcrawl.Lib.Crawler

  test "create crawler with default values" do
    assert %Crawler{depth: 10, frequency: 0, dispatcher: nil, parser: nil, url: nil} ==
             Crawler.make()
  end

  test "should create crawler with nil dispatcher when passing the unsupported type" do
    assert %Crawler{dispatcher: nil} == Crawler.make() |> Crawler.with_dispatcher([])
  end

  test "should create crawler with custom dispatcher when providing the right protocol implementation" do
    assert %Crawler{dispatcher: %{}} == Crawler.make() |> Crawler.with_dispatcher(%{})
  end

  test "should create crawler with nil parser when passing the unsupported type" do
    assert %Crawler{parser: nil} == Crawler.make() |> Crawler.with_parser([])
  end

  test "should create crawler with custom parser when providing the right protocol implementation" do
    assert %Crawler{parser: %{}} == Crawler.make() |> Crawler.with_parser(%{})
  end
end
