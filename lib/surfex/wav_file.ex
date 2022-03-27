defmodule Surfex.WavFile do
  import Surfex.WavFile.Parsing

  defstruct [
    :audio_format,
    :num_channels,
    :sample_rate,
    :bits_per_sample,
    :bytes_per_second,
    :data_size,
    :data,
    :block_align
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
end
