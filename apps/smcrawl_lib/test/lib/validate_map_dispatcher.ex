defimpl Smcrawl.Lib.Proto.Dispatch.Validate, for: Map do
  def validate(dispatcher), do: {:ok, dispatcher}
end
