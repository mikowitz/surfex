defmodule Surfex do
  alias Surfex.WavFile

  def lower_volume(infile, outfile, percentage \\ 0.5) do
    process(infile, outfile, fn channels ->
      Enum.map(channels, fn channel ->
        Enum.map(channel, fn i -> round(i * percentage) end)
      end)
    end)
  end

  def reverse(infile, outfile) do
    process(infile, outfile, fn channels ->
      Enum.map(channels, &Enum.reverse/1)
    end)
  end

  def process(infile, outfile, processing_function) do
    infile
    |> WavFile.read()
    |> WavFile.process(processing_function)
    |> WavFile.write(outfile)
  end
end
