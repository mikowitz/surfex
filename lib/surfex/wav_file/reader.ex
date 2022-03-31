defmodule Surfex.WavFile.Reader do
  @moduledoc false

  import Surfex.WavFile.BitstringHelpers

  def read(filename) do
    with {:ok, data} <- File.read(filename),
         {:ok, header_data, data} <- parse_riff_header(data),
         {:ok, fmt_data, data} <- parse_fmt_chunk(data),
         {:ok, audio_data} <- parse_audio_data(data) do
      wav_data =
        header_data
        |> Map.merge(fmt_data)
        |> Map.merge(audio_data)

      struct(Surfex.WavFile, wav_data)
    end
  end

  defp parse_riff_header(data) do
    <<"RIFF"::binary, file_length::l32(), "WAVE"::binary, rest::binary>> = data

    if check_file_length(file_length - 4, rest) do
      {:ok, %{}, rest}
    else
      {:error, "incorrect file length in header"}
    end
  end

  defp parse_fmt_chunk(data) do
    <<
      "fmt "::binary,
      fmt_chunk_size::l32(),
      audio_format::l16(),
      rest::binary
    >> = data

    case audio_format do
      0x01 -> parse_pcm_fmt_data(rest, fmt_chunk_size)
      0xFFFE -> parse_extensible_fmt_data(rest, fmt_chunk_size)
      _ -> {:error, "can't parse WAV file with audio format #{audio_format}"}
    end
  end

  defp parse_pcm_fmt_data(data, 16) do
    <<
      num_channels::l16(),
      sample_rate::l32(),
      bytes_per_second::l32(),
      block_align::l16(),
      bits_per_sample::l16(),
      rest::binary
    >> = data

    {:ok,
     %{
       num_channels: num_channels,
       sample_rate: sample_rate,
       bytes_per_second: bytes_per_second,
       block_align: block_align,
       bits_per_sample: bits_per_sample,
       audio_format: 0x01
     }, rest}
  end

  defp parse_extensible_fmt_data(data, 40) do
    <<
      num_channels::l16(),
      sample_rate::l32(),
      bytes_per_second::l32(),
      block_align::l16(),
      bits_per_sample::l16(),
      22::l16(),
      _valid_bits_per_sample::l16(),
      channel_mask::l32(),
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
       subformat: subformat,
       audio_format: 0xFFFE
     }, rest}
  end

  defp parse_audio_data(data) do
    <<
      "data"::binary,
      data_size::l32(),
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

  defp check_file_length(file_length, data) do
    file_length == byte_size(data)
  end
end
