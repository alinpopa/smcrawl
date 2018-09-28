defprotocol Smcrawl.Lib.Proto.Set do
  def exists?(set, element)

  def put(set, element)

  def delete(set, element)
end

defprotocol Smcrawl.Lib.Proto.Set.Validate do
  @fallback_to_any true
  def validate(set)
end

defimpl Smcrawl.Lib.Proto.Set, for: MapSet do
  def exists?(set, element), do: MapSet.member?(set, element)

  def put(set, element), do: MapSet.put(set, element)

  def delete(set, element), do: MapSet.delete(set, element)
end

defimpl Smcrawl.Lib.Proto.Set.Validate, for: MapSet do
  def validate(set), do: {:ok, set}
end

defimpl Smcrawl.Lib.Proto.Set.Validate, for: Any do
  def validate(_set), do: {:error, :invalid_set}
end
