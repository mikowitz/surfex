defmodule Surfex.WavFile.BitstringHelpers do
  @moduledoc false

  @doc """
  Shorthand for an integer encoded in 32 bits in little-endian format
  """
  defmacro l32 do
    quote do: little - 32
  end

  @doc """
  Shorthand for an integer encoded in 16 bits in little-endian format
  """
  defmacro l16 do
    quote do: little - 16
  end
end
