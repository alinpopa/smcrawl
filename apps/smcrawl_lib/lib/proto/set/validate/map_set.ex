defimpl Smcrawl.Lib.Proto.Set.Validate, for: MapSet do
  def validate(set), do: {:ok, set}
end
