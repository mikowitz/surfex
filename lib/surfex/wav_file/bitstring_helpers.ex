defmodule Surfex.WavFile.BitstringHelpers do
  defmacro l32 do
    quote do: little - 32
  end

  defmacro l16 do
    quote do: little - 16
  end

  defmacro little(bit_size) do
    quote do: little - unquote(bit_size)
  end
end
