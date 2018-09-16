defimpl Smcrawl.Lib.Proto.Parse.Validate, for: Any do
  def validate(_parser), do: {:error, :invalid_parser}
end
