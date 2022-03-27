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
    <<
      "fmt "::binary,
      16::little-32,
      audio_format::little-16,
      num_channels::little-16,
      sample_rate::little-32,
      bytes_per_second::little-32,
      block_align::little-16,
      bits_per_sample::little-16,
      rest::binary
    >> = data

    fmt_data = %{
      audio_format: audio_format,
      num_channels: num_channels,
      sample_rate: sample_rate,
      bits_per_sample: bits_per_sample,
      bytes_per_second: bytes_per_second,
      block_align: block_align
    }

    if check_fmt_values(fmt_data) do
      {:ok, fmt_data, rest}
    else
      {:error, "error parsing format chunk"}
    end
  end

  def parse_audio_data(data) do
    <<
      "data"::binary,
      data_size::little-32,
      data::binary
    >> = data

    if check_audio_data_size(data_size, data) do
      {:ok, %{data: data, data_size: data_size}}
    else
      {:error, "incorrect audio data size"}
    end
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
