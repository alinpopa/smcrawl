defimpl Smcrawl.Lib.Proto.Set, for: MapSet do
  def exists?(set, element), do: MapSet.member?(set, element)

  def put(set, element), do: MapSet.put(set, element)

  def delete(set, element), do: MapSet.delete(set, element)
end
