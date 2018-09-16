defmodule Smcrawl.Lib.Http do
  def get(url) do
    case HTTPoison.get(url, [], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: status}} when status != 200 ->
        {:ok, ""}

      {:ok, %HTTPoison.Response{body: body}} when is_binary(body) ->
        {:ok, body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
