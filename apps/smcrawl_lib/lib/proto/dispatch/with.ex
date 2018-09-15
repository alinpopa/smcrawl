defprotocol Smcrawl.Lib.Proto.Dispatch.With do
  @fallback_to_any true
  def with(dispatcher)
end
