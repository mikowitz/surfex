defmodule Surfex.WavFile do
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

  defdelegate read(filename), to: Reader
  defdelegate write(wav, filename), to: Writer

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
