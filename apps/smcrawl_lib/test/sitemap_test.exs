defmodule Smcrawl.Lib.SiteMapTest do
  use ExUnit.Case
  doctest Smcrawl.Lib.SiteMap
  alias Smcrawl.Lib.SiteMap

  test "create empty sitemap" do
    assert %SiteMap{urls: %{}} == SiteMap.make()
  end

  test "should not add a nil link" do
    assert %SiteMap{urls: %{"url1" => MapSet.new()}} == SiteMap.make() |> SiteMap.put("url1", nil)
  end

  test "should not allow links duplication" do
    sitemap =
      SiteMap.make()
      |> SiteMap.put("url", "link1")
      |> SiteMap.put("url", "link1")

    %SiteMap{urls: %{"url" => links}} = sitemap
    assert MapSet.size(links) == 1
    assert MapSet.member?(links, "link1")
  end

  test "should allow multiple links for the same url" do
    sitemap =
      SiteMap.make()
      |> SiteMap.put("url", "link1")
      |> SiteMap.put("url", "link2")

    %SiteMap{urls: %{"url" => links}} = sitemap
    assert MapSet.size(links) == 2
    assert MapSet.member?(links, "link1")
    assert MapSet.member?(links, "link2")
  end

  test "should allow multiple urls, each with multiple links" do
    sitemap =
      SiteMap.make()
      |> SiteMap.put("url", "link1")
      |> SiteMap.put("url", "link2")
      |> SiteMap.put("url2", "link1")
      |> SiteMap.put("url2", "link2")
      |> SiteMap.put("url2", "link3")

    %SiteMap{urls: %{"url" => links1, "url2" => links2}} = sitemap
    assert MapSet.size(links1) == 2
    assert MapSet.member?(links1, "link1")
    assert MapSet.member?(links1, "link2")
    assert MapSet.size(links2) == 3
    assert MapSet.member?(links2, "link1")
    assert MapSet.member?(links2, "link2")
    assert MapSet.member?(links2, "link3")
  end
end
