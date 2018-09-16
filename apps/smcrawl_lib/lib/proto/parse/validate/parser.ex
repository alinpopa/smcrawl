defimpl Smcrawl.Lib.Proto.Parse.Validate, for: Smcrawl.Lib.Parser do
  alias Smcrawl.Lib.Parser

  def validate(%Parser{http: nil}),
    do: {:error, :invalid_http_get}

  def validate(parser),
    do: {:ok, parser}
end
