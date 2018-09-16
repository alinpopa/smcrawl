defimpl Smcrawl.Lib.Proto.Parse.Validate, for: Map do
  def validate(parser), do: {:ok, parser}
end
