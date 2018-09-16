defimpl Smcrawl.Lib.Proto.Set.Validate, for: Any do
  def validate(_set), do: {:error, :invalid_set}
end
