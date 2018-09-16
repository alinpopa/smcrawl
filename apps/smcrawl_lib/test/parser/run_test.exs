defmodule Smcrawl.Lib.Parser.RunTest do
  use ExUnit.Case
  doctest Smcrawl.Lib.Parser
  alias Smcrawl.Lib.Parser
  alias Smcrawl.Lib.Proto.Parse.Run

  test "should return empty list of urls when getting an empty response body" do
    parser = %Parser{http: fn _ -> {:ok, ""} end}
    req = %Parser.Req{url: "test-url", base_url: "test-url"}
    assert Run.run(parser, req) == {:ok, []}
  end

  test "should return only urls that have not been excluded" do
    body = """
    <a href="/page/one/">...</a>
    <a href="/page/two/">...</a>
    <a href="/page/three/">...</a>
    """

    parser = %Parser{http: fn _ -> {:ok, body} end, exclude: ["/one"]}
    req = %Parser.Req{url: "test-url", base_url: "test-url"}
    {:ok, results} = Run.run(parser, req)
    sorted_results = Enum.sort(results, fn a, b -> a.url < b.url end)
    assert Enum.count(sorted_results) == 2

    assert [%{level: 2, url: "test-url/page/three/"}, %{level: 2, url: "test-url/page/two/"}] =
             sorted_results
  end

  test "should filter out static and binary files" do
    body = """
    <a href="/page/one/">...</a>
    <a href="/page/two/test.pdf">...</a>
    <a href="/page/three/test.jpg">...</a>
    """

    parser = %Parser{http: fn _ -> {:ok, body} end}
    req = %Parser.Req{url: "test-url", base_url: "test-url"}
    {:ok, results} = Run.run(parser, req)
    assert Enum.count(results) == 1
    assert [%{level: 2, url: "test-url/page/one/"}] = results
  end

  test "should filter out links from different domains" do
    body = """
    <a href="/page/one/">...</a>
    <a href="https://twitter.com/page/two/">...</a>
    <a href="/page/three/">...</a>
    <a href="test-url/page/p1">...</a>
    """

    parser = %Parser{http: fn _ -> {:ok, body} end}
    req = %Parser.Req{url: "test-url", base_url: "test-url"}
    {:ok, results} = Run.run(parser, req)
    sorted_results = Enum.sort(results, fn a, b -> a.url < b.url end)
    assert Enum.count(sorted_results) == 3

    assert [
             %{level: 2, url: "test-url/page/one/"},
             %{level: 2, url: "test-url/page/p1"},
             %{level: 2, url: "test-url/page/three/"}
           ] = sorted_results
  end
end
