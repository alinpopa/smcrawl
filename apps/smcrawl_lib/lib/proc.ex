defmodule Smcrawl.Lib.Proc do
  def async(f) do
    Task.async(fn ->
      Process.flag(:trap_exit, true)

      case f.() do
        {:ok, pid} ->
          loop(pid)

        {:error, _} = err ->
          err
      end
    end)
  end

  defp loop(pid) do
    receive do
      {:EXIT, ^pid, {:done, results}} ->
        {:ok, results}

      {:EXIT, ^pid, reason} ->
        {:error, reason}

      msg ->
        IO.inspect({"Unexpected message, ignoring", msg})
        loop(pid)
    end
  end
end
