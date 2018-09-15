defprotocol Smcrawl.Lib.Proto.Parse.With do
  @fallback_to_any true
  def with(parser)
end
