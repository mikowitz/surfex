defmodule Surfex.WavFile.Writer do
  @moduledoc false

  import Surfex.WavFile.BitstringHelpers

  def write(%Surfex.WavFile{} = wav, filename) do
    contents = <<
      construct_riff_header(wav)::binary,
      construct_fmt_chunk(wav)::binary,
      construct_audio_data(wav)::binary
    >>

    File.write(filename, contents)
  end

  defp construct_riff_header(wav) do
    filesize = calculate_filesize(wav)

    <<
      "RIFF"::binary,
      filesize::l32(),
      "WAVE"::binary
    >>
  end

  defp construct_fmt_chunk(%{audio_format: 0x01} = wav) do
    construct_common_fmt_chunk(wav)
  end

  defp construct_fmt_chunk(%{audio_format: 0x03} = wav) do
    common_data = construct_common_fmt_chunk(wav)

    <<
      common_data::binary(),
      0x00::l16()
    >>
  end

  defp construct_fmt_chunk(%{audio_format: 0xFFFE} = wav) do
    common_data = construct_common_fmt_chunk(wav)

    <<
      common_data::binary(),
      22::l16(),
      wav.bits_per_sample::l16(),
      wav.channel_mask::l32(),
      wav.subformat::bytes-size(16)
    >>
  end

  defp construct_common_fmt_chunk(%{audio_format: audio_format} = wav) do
    <<
      "fmt "::binary,
      fmt_chunk_size(wav)::l32(),
      audio_format::l16(),
      wav.num_channels::l16(),
      wav.sample_rate::l32(),
      wav.bytes_per_second::l32(),
      wav.block_align::l16(),
      wav.bits_per_sample::l16()
    >>
  end

  defp construct_audio_data(wav) do
    <<
      "data"::binary,
      byte_size(wav.data)::l32(),
      wav.data::binary
    >>
  end

  defp calculate_filesize(wav) do
    riff_header_counted_size = 4

    fmt_size =
      case wav.audio_format do
        0x01 -> 24
        0x03 -> 26
        0xFFFE -> 48
      end

    data_chunk_size = byte_size(wav.data) + 8

    riff_header_counted_size + fmt_size + data_chunk_size
  end

  defp fmt_chunk_size(%{audio_format: 0x01}), do: 16
  defp fmt_chunk_size(%{audio_format: 0x03}), do: 18
  defp fmt_chunk_size(%{audio_format: 0xFFFE}), do: 40
end
