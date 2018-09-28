defprotocol Smcrawl.Lib.Proto.Parse.Run do
  def run(parser, req)
end

defprotocol Smcrawl.Lib.Proto.Parse.Validate do
  @fallback_to_any true
  def validate(parser)
end

defimpl Smcrawl.Lib.Proto.Parse.Validate, for: Any do
  def validate(_parser), do: {:error, :invalid_parser}
end
