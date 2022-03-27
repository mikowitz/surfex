defmodule Surfex.WavFile.Parsing.FmtChunk do
  def parse_fmt_chunk(data) do
    <<
      "fmt "::binary,
      fmt_chunk_size::little-32,
      audio_format::little-16,
      rest::binary
    >> = data

    {:ok, fmt_data, rest} =
      case audio_format do
        0x01 -> parse_pcm_fmt_data(rest, fmt_chunk_size)
        0xFFFE -> parse_extensible_fmt_data(rest, fmt_chunk_size)
        _ -> {:error, "can't parse WAV file with audio format #{audio_format}"}
      end

    {:ok, Map.merge(fmt_data, %{audio_format: audio_format}), rest}
  end

  def parse_pcm_fmt_data(data, 16) do
    <<
      num_channels::little-16,
      sample_rate::little-32,
      bytes_per_second::little-32,
      block_align::little-16,
      bits_per_sample::little-16,
      rest::binary
    >> = data

    {:ok,
     %{
       num_channels: num_channels,
       sample_rate: sample_rate,
       bytes_per_second: bytes_per_second,
       block_align: block_align,
       bits_per_sample: bits_per_sample
     }, rest}
  end

  def parse_extensible_fmt_data(data, 40) do
    <<
      num_channels::little-16,
      sample_rate::little-32,
      bytes_per_second::little-32,
      block_align::little-16,
      bits_per_sample::little-16,
      22::little-16,
      _valid_bits_per_sample::little-16,
      channel_mask::little-32,
      subformat::bytes-size(16),
      rest::binary
    >> = data

    {:ok,
     %{
       num_channels: num_channels,
       sample_rate: sample_rate,
       bytes_per_second: bytes_per_second,
       block_align: block_align,
       bits_per_sample: bits_per_sample,
       channel_mask: channel_mask,
       subformat: subformat
     }, rest}
  end
end
