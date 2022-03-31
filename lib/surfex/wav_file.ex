defmodule Surfex.WavFile do
  @moduledoc """

  """

  import Surfex.WavFile.{AudioDataFunctions}
  alias Surfex.WavFile.{Reader, Writer}

  defstruct [
    :audio_format,
    :num_channels,
    :sample_rate,
    :bits_per_sample,
    :bytes_per_second,
    :data,
    :block_align,
    :channel_mask,
    :subformat
  ]

  @type t :: %__MODULE__{
          audio_format: integer(),
          num_channels: integer(),
          sample_rate: integer(),
          bits_per_sample: integer(),
          bytes_per_second: integer(),
          data: binary(),
          block_align: integer(),
          channel_mask: integer() | nil,
          subformat: binary() | nil
        }

  @doc """
  Attempts to read a WAV file into a `WavFile` struct in memory.
  """
  @spec read(String.t()) :: __MODULE__.t() | {:error, String.t()}
  defdelegate read(filename), to: Reader

  @doc """
  Attempts to write a `WavFile` struct to disk at the given filename
  """
  @spec write(__MODULE__.t(), String.t()) :: Surfex.file_write_response()
  defdelegate write(wav, filename), to: Writer

  @spec process(__MODULE__.t(), (Surfex.channels() -> Surfex.channels())) :: __MODULE__.t()
  def process(%__MODULE__{} = wav, processing_function) do
    channels = split_audio_data_into_channels(wav)

    processed_audio_data = processing_function.(channels)

    audio_data =
      restore_audio_data_from_channels(
        processed_audio_data,
        wav.bits_per_sample
      )

    %{wav | data: audio_data}
  end
end
