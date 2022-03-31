defmodule Surfex do
  @moduledoc """
  `Surfex` is a library for manipulating WAV files. It can handle uncompressed
  PCM bit depths of 8, 16, 24, or 32, with any number of channels. It cannot
  currently handle compressed WAV files.

  The public API is contained in this `Surfex` module. It currently provides
  functions for reading a WAV file into a data structure in memory, writing
  a struct back to disk, and manipulating the audio data while loaded in
  memory.

  ## Reading and writing files.

  `Surfex.read/1` and `Surfex.write/2` comprise the public API for reading and
  writing WAV files to and from disk.

  `Surfex.read/1` takes a filename as its argument and returns a `Surfex.WavFile`
  struct if the given file contains data that is parseable by `Surfex`, or else an
  error explaining why it cannot be parsed.

  `Surfex.write/2` takes as its arguments a `Surfex.WavFile` struct and a filename
  and attempts to write the data out to the given path on disk. It returns `:ok` or
  a POSIX error as defined by `t:File.posix/0`

  ## Manipulating audio data

  The `Surfex.process/3` function provides the API for manipulating audio data.
  It takes as its arguments a source file, a target destination filename, and a
  processing function. This function expects as its single argument a list of
  channels, each of the type `t:channel/0`.

  Assuming a multichannel WAV file, the following example randomly shuffles
  the order of the channels:

  ```
  Surfex.process("original.wav", "shuffled.wav", fn channels ->
    Enum.shuffle(channels)
  end)
  ```

  This example reverses the content of each audio channel

  ```
  Surfex.process("original.wav", "reversed.wav", fn channels ->
    Enum.map(channels, fn channel -> Enum.reverse(channel) end)
  end)
  ```
  """
  alias Surfex.WavFile

  @typedoc """
  A list of integers representing the audio data stored in a single channel of a WAV file
  """
  @type channel :: [integer()]

  @typedoc """
  A list of channels comprising the total audio data of a WAV file.
  """
  @type channels :: [channel()]

  @typedoc """
  Shorthand for the union of the possible return types for `File.write/3`.
  """
  @type file_write_response :: :ok | {:error, File.posix()}

  @doc """
  Attempts to read a WAV file from disk at `filename` to a `Surfex.WavFile` struct in memory

  ## Example

      iex> Surfex.read("test.wav")
      %Surfex.WavFile{ ... }

  """
  @spec read(String.t()) :: WavFile.t() | {:error, String.t()}
  defdelegate read(filename), to: WavFile.Reader

  @doc """
  Attempts to write data from a `Surfex.WavFile` (`wav_data`) to disk at `filename`

  ## Example

      iex> wav = Surfex.read("test.wav")
      %Surfex.WavFile{ ... }
      iex> Surfex.write(wav, "out.wav")
      :ok

  """
  @spec write(WavFile.t(), String.t()) :: file_write_response()
  defdelegate write(wav_data, filename), to: WavFile.Writer

  @doc """
  Reads data from `infile`, processes the audio data via `processing_function`
  and writes the resulting WAV data to `outfile`.

  `proccessing_function` should be a function that acts on a list of channels of audio
  data. It takes as its single argument a list of channels and returns a list of channels.

  ## Example

  This function would reduce the amplitude of the audio data by 50% (Remember that volume
  is on a logarithmic scale so this does _not_ mean a 50% reduction in perceived volume).

  ```
  Surfex.process("original-file.wav", "softer.wav", fn channels ->
    Enum.map(channels, fn channel ->
      Enum.map(channel, fn i -> round(i * 0.5) end)
    end)
  end)
  ```
  """
  @spec process(String.t(), String.t(), (channels() -> channels())) :: file_write_response()
  def process(infile, outfile, processing_function) do
    infile
    |> read()
    |> WavFile.process(processing_function)
    |> write(outfile)
  end
end
