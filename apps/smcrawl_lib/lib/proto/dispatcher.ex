defprotocol Smcrawl.Lib.Proto.Dispatch.Start do
  def start(dispatcher)
end

defprotocol Smcrawl.Lib.Proto.Dispatch.Validate do
  def validate(dispatcher)
end

defprotocol Smcrawl.Lib.Proto.Dispatch.With do
  @fallback_to_any true
  def with(dispatcher)
end

defimpl Smcrawl.Lib.Proto.Dispatch.With, for: Any do
  def with(_dispatcher), do: nil
end
