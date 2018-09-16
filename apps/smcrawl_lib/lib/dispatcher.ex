defmodule Smcrawl.Lib.Dispatcher do
  defstruct url: nil,
            workers: 10,
            frequency: 0,
            parser: nil,
            depth: 3,
            set: nil,
            pid: nil
end
