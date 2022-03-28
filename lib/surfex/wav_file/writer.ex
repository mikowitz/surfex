defmodule Surfex.WavFile.Writer do
  def construct_riff_header(wav) do
    filesize = calculate_filesize(wav)

    <<
      "RIFF"::binary,
      filesize::little-32,
      "WAVE"::binary
    >>
  end

  def construct_fmt_chunk(%{audio_format: 0x01} = wav) do
    <<
      "fmt "::binary,
      16::little-32,
      1::little-16,
      wav.num_channels::little-16,
      wav.sample_rate::little-32,
      wav.bytes_per_second::little-32,
      wav.block_align::little-16,
      wav.bits_per_sample::little-16
    >>
  end

  def construct_fmt_chunk(%{audio_format: 0xFFFE} = wav) do
    <<
      "fmt "::binary,
      40::little-32,
      0xFFFE::little-16,
      wav.num_channels::little-16,
      wav.sample_rate::little-32,
      wav.bytes_per_second::little-32,
      wav.block_align::little-16,
      wav.bits_per_sample::little-16,
      22::little-16,
      wav.bits_per_sample::little-16,
      wav.channel_mask::little-32,
      wav.subformat::bytes-size(16)
    >>
  end

  def construct_audio_data(wav) do
    <<
      "data"::binary,
      byte_size(wav.data)::little-32,
      wav.data::binary
    >>
  end

  def calculate_filesize(wav) do
    riff_header_counted_size = 4

    fmt_size =
      case wav.audio_format do
        0x01 -> 24
        0xFFFE -> 48
      end

    data_chunk_size = byte_size(wav.data) + 8

    riff_header_counted_size + fmt_size + data_chunk_size
  end
end
