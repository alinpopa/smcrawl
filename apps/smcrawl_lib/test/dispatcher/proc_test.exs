defmodule Smcrawl.Lib.Dispatcher.ProcTest do
  use ExUnit.Case
  doctest Smcrawl.Lib.Dispatcher
  alias Smcrawl.Lib.Dispatcher
  alias Smcrawl.Lib.SiteMap

  defp async(dispatcher) do
    Task.async(fn ->
      Process.flag(:trap_exit, true)
      Smcrawl.Lib.Proto.Dispatch.Start.start(dispatcher)

      receive do
        {:EXIT, _, {:done, sitemap}} ->
          {:ok, sitemap}

        msg ->
          {:error, msg}
      end
    end)
  end

  test "return a sitemap with the original url when no valid urls are returned" do
    run = fn _req -> [] end
    parser = %Smcrawl.Lib.Test.Parser{run: run}
    dispatcher = %Dispatcher{parser: parser, url: "http://test"}

    result =
      async(dispatcher)
      |> Task.await(:infinity)

    assert {:ok, %SiteMap{urls: %{{1, "http://test"} => %MapSet{}}}} == result
  end

  test "return a sitemap with a single link for the given url" do
    links = %{
      "http://test" => [%{orig_url: "http://test", url: "one1", level: 2}],
      "one" => []
    }

    run = fn req -> Map.get(links, req.url, []) end
    parser = %Smcrawl.Lib.Test.Parser{run: run}
    dispatcher = %Dispatcher{parser: parser, url: "http://test", set: MapSet.new()}

    result =
      async(dispatcher)
      |> Task.await(:infinity)

    {:ok, %SiteMap{urls: %{{1, "http://test"} => links}}} = result
    assert MapSet.size(links) == 1
    assert MapSet.member?(links, "one1")
  end

  test "should parse all available urls as long as the given depth was not reached" do
    links = %{
      "http://test" => [%{orig_url: "http://test", url: "one1", level: 2}],
      "one1" => [%{orig_url: "one1", url: "one2", level: 3}]
    }

    run = fn req -> Map.get(links, req.url, []) end
    parser = %Smcrawl.Lib.Test.Parser{run: run}
    dispatcher = %Dispatcher{parser: parser, url: "http://test", set: MapSet.new()}

    result =
      async(dispatcher)
      |> Task.await(:infinity)

    {:ok, %SiteMap{urls: %{{1, "http://test"} => links1, {2, "one1"} => links2}}} = result
    assert MapSet.size(links1) == 1
    assert MapSet.member?(links1, "one1")
    assert MapSet.size(links2) == 1
    assert MapSet.member?(links2, "one2")
  end

  test "should not parse urls that have been parsed before" do
    links = %{
      "http://test" => [%{orig_url: "http://test", url: "one1", level: 2}],
      "one1" => [%{orig_url: "one1", url: "one2", level: 3}]
    }

    run = fn req -> Map.get(links, req.url, []) end
    parser = %Smcrawl.Lib.Test.Parser{run: run}

    dispatcher = %Dispatcher{
      parser: parser,
      url: "http://test",
      set: MapSet.new() |> MapSet.put("one1")
    }

    result =
      async(dispatcher)
      |> Task.await(:infinity)

    {:ok, %SiteMap{urls: urls = %{{1, "http://test"} => links}}} = result
    assert Enum.count(Map.keys(urls)) == 1
    assert MapSet.size(links) == 1
    assert MapSet.member?(links, "one1")
  end

  test "should not parse urls bellow the specified depth" do
    links = %{
      "http://test" => [%{orig_url: "http://test", url: "one1", level: 2}],
      "one1" => [%{orig_url: "one1", url: "one2", level: 3}],
      "one2" => [%{orig_url: "one2", url: "one3", level: 4}],
      "one3" => [%{orig_url: "one3", url: "one4", level: 5}]
    }

    run = fn req -> Map.get(links, req.url, []) end
    parser = %Smcrawl.Lib.Test.Parser{run: run}
    dispatcher = %Dispatcher{parser: parser, url: "http://test", set: MapSet.new(), depth: 3}

    result =
      async(dispatcher)
      |> Task.await(:infinity)

    {:ok, %SiteMap{urls: urls = %{{1, "http://test"} => links1, {2, "one1"} => links2, {3, "one2"} => links3}}} =
      result

    assert Enum.count(Map.keys(urls)) == 3
    assert MapSet.size(links1) == 1
    assert MapSet.member?(links1, "one1")
    assert MapSet.size(links2) == 1
    assert MapSet.member?(links2, "one2")
    assert MapSet.size(links3) == 1
    assert MapSet.member?(links3, "one3")
  end
end
