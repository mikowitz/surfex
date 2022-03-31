defmodule Surfex.WavFile do
  @moduledoc """

  """

  import Surfex.WavFile.{AudioDataFunctions}

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
  Splits the audio data stored in the struct into its constituent channels,
  run those channels through the given `processing_function`, reconstitutes
  them into a single block of binary audio data, and returns a new `WavFile`
  struct containing the new audio data.

  ## Example

  This example reverses only the even (0-indexed) channels of a WAV file.

  ```
  wav = Surfex.read("original.wav")
  Surfex.WavFile.process(wav, fn channels ->
    channels
    |> Enum.with_index()
    |> Enum.map(fn {channel, index} ->
      case rem(index, 0) do
        0 -> Enum.reverse(channel)
        1 -> channel
      end
    end)
  end)
  ```

  """
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
