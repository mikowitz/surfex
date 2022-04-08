defmodule SurfexTestCase do
  @moduledoc false

  import ExUnit.Assertions

  def assert_pcm_metadata(filename) do
    [[_, bit_depth, sample_rate, mono_or_stereo]] = Regex.scan(~r/(\d\d)(\d\d)(m|s)/, filename)

    wav = Surfex.read(filename)

    {expected_bit_depth, ""} = Integer.parse(bit_depth)

    expected_audio_format =
      case expected_bit_depth do
        b when b <= 16 -> 1
        _ -> 0xFFFE
      end

    assert wav.audio_format == expected_audio_format

    expected_num_channels =
      case mono_or_stereo do
        "m" -> 1
        "s" -> 2
      end

    expected_sample_rate =
      case sample_rate do
        "08" -> 8000
        "11" -> 11025
        "22" -> 22050
        "44" -> 44100
      end

    assert wav.num_channels == expected_num_channels
    assert wav.sample_rate == expected_sample_rate
    assert wav.bits_per_sample == expected_bit_depth
    assert wav.bytes_per_second == expected_sample_rate * wav.block_align
  end

  def assert_ieee_metadata(filename) do
    [[_, bit_depth, sample_rate, mono_or_stereo]] = Regex.scan(~r/([a-z]+)(\d\d)(m|s)/, filename)

    wav = Surfex.read(filename)

    expected_bit_depth =
      case bit_depth do
        "sngl" -> 32
        "dbl" -> 64
      end

    expected_audio_format = 0x03

    assert wav.audio_format == expected_audio_format

    expected_num_channels =
      case mono_or_stereo do
        "m" -> 1
        "s" -> 2
      end

    expected_sample_rate =
      case sample_rate do
        "08" -> 8000
        "11" -> 11025
        "22" -> 22050
        "44" -> 44100
      end

    assert wav.num_channels == expected_num_channels
    assert wav.sample_rate == expected_sample_rate
    assert wav.bits_per_sample == expected_bit_depth
    assert wav.bytes_per_second == expected_sample_rate * wav.block_align
  end

  def test_read_write_read(filename) do
    source = "priv/samples/" <> filename
    dest = "example-" <> filename

    wav = Surfex.read(source)

    :ok = Surfex.write(wav, dest)

    wav2 = Surfex.read(dest)

    assert wav == wav2

    :ok = File.rm(dest)
  end

  def hash(file) do
    File.stream!(file)
    |> Enum.reduce(:crypto.hash_init(:sha256), fn line, acc ->
      :crypto.hash_update(acc, line)
    end)
    |> :crypto.hash_final()
  end
end
