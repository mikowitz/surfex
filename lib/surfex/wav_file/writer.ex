defmodule Surfex.WavFile.Writer do
  import Surfex.WavFile.BitstringHelpers

  def write(%Surfex.WavFile{} = wav, filename) do
    contents = <<
      construct_riff_header(wav)::binary,
      construct_fmt_chunk(wav)::binary,
      construct_audio_data(wav)::binary
    >>

    File.write(filename, contents)
  end

  def construct_riff_header(wav) do
    filesize = calculate_filesize(wav)

    <<
      "RIFF"::binary,
      filesize::l32(),
      "WAVE"::binary
    >>
  end

  def construct_fmt_chunk(%{audio_format: 0x01} = wav) do
    <<
      "fmt "::binary,
      16::l32(),
      1::l16(),
      wav.num_channels::l16(),
      wav.sample_rate::l32(),
      wav.bytes_per_second::l32(),
      wav.block_align::l16(),
      wav.bits_per_sample::l16()
    >>
  end

  def construct_fmt_chunk(%{audio_format: 0xFFFE} = wav) do
    <<
      "fmt "::binary,
      40::l32(),
      0xFFFE::l16(),
      wav.num_channels::l16(),
      wav.sample_rate::l32(),
      wav.bytes_per_second::l32(),
      wav.block_align::l16(),
      wav.bits_per_sample::l16(),
      22::l16(),
      wav.bits_per_sample::l16(),
      wav.channel_mask::l32(),
      wav.subformat::bytes-size(16)
    >>
  end

  def construct_audio_data(wav) do
    <<
      "data"::binary,
      byte_size(wav.data)::l32(),
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
