defimpl Smcrawl.Lib.Proto.Parse.Run, for: Smcrawl.Lib.Test.Parser do
  def run(parser, req), do: {:ok, parser.run.(req)}
end
