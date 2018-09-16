defprotocol Smcrawl.Lib.Proto.Set do
  def exists?(set, element)

  def put(set, element)

  def delete(set, element)
end
