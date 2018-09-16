defprotocol Smcrawl.Lib.Proto.Parse.Validate do
  @fallback_to_any true
  def validate(parser)
end
