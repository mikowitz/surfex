defmodule Surfex.WavFile do
  import Surfex.WavFile.{AudioDataFunctions, Reader, Writer}

  defstruct [
    :audio_format,
    :num_channels,
    :sample_rate,
    :bits_per_sample,
    :bytes_per_second,
    :data_size,
    :data,
    :block_align,
    :channel_mask,
    :subformat
  ]

  def read(filename) do
    {:ok, data} = File.read(filename)
    {:ok, header_data, data} = parse_riff_header(data)
    {:ok, fmt_data, data} = parse_fmt_chunk(data)
    {:ok, audio_data} = parse_audio_data(data)

    wav_data =
      header_data
      |> Map.merge(fmt_data)
      |> Map.merge(audio_data)

    struct(__MODULE__, wav_data)
  end

  def write(%__MODULE__{} = wav, filename) do
    contents = <<
      construct_riff_header(wav)::binary,
      construct_fmt_chunk(wav)::binary,
      construct_audio_data(wav)::binary
    >>

    File.write(filename, contents)
  end

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
