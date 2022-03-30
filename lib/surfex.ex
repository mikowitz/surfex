defmodule Surfex do
  @moduledoc """
  `Surfex` is a library for manipulating WAV files. It can handle uncompressed PCM bit depths of 8, 16, 24, or 32, with any number of channels. It cannot currently handle compressed WAV files.

  The top-level `Surfex` module provides wrapper functions to perform various manipulations on WAV files, as well as a generic wrapper to create your own processing functions. The `Surfex.WavFile` module provides lower-level functions for interacting with the WAV audio data.

  ## Examples

  Lowering the volume of a WAV file (keep in mind that human hearing is a logarithmic function, so "lowering" the volume by 50% will not result in a perceived 50% drop in volume)

      iex> Surfex.lower_volume("loud.wav", "softer.wav")

  Reversing the raw audio data

      iex> Surfex.reverse("forward.wav", "backward.wav")

  A user-provided function to randomly shuffle the order of the channels in a multi-channel WAV file

      iex> Surfex.process("multi-channel.wav", "shuffled.wav", fn channels -> Enum.shuffle(channels) end)

  """
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
