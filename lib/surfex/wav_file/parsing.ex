defmodule Surfex.WavFile.Parsing do
  def parse_riff_header(data) do
    <<"RIFF"::binary, file_length::little-32, "WAVE"::binary, rest::binary>> = data

    if check_file_length(file_length - 4, rest) do
      {:ok, %{}, rest}
    else
      {:error, "incorrect file length in header"}
    end
  end

  def parse_fmt_chunk(data) do
    Surfex.WavFile.Parsing.FmtChunk.parse_fmt_chunk(data)
  end

  def parse_audio_data(data) do
    <<
      "data"::binary,
      data_size::little-32,
      rest::binary
    >> = data

    <<
      audio_data::bytes-size(data_size),
      _rest::binary
    >> = rest

    audio_data =
      case rem(data_size, 2) do
        0 -> audio_data
        1 -> audio_data <> <<0>>
      end

    {:ok, %{data: audio_data}}
  end

  def check_file_length(file_length, data) do
    file_length == byte_size(data)
  end

  def check_fmt_values(fmt_data) do
    check_block_align(fmt_data) && check_bytes_per_second(fmt_data)
  end

  def check_block_align(%{
        block_align: block_align,
        num_channels: num_channels,
        bits_per_sample: bits_per_sample
      }) do
    block_align == num_channels * bits_per_sample / 8
  end

  def check_bytes_per_second(%{
        bytes_per_second: bytes_per_second,
        block_align: block_align,
        sample_rate: sample_rate
      }) do
    bytes_per_second == block_align * sample_rate
  end

  def check_audio_data_size(data_size, data) do
    case rem(data_size, 2) do
      0 -> data_size == byte_size(data)
      1 -> data_size + 1 == byte_size(data)
    end
  end
end
