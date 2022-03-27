defmodule Surfex.WavFileTest do
  use ExUnit.Case, async: true

  alias Surfex.WavFile

  describe "8 bit sample size" do
    test "8000 Hz mono" do
      test_wav_file_metadata("priv/samples/pcm0808m.wav", 1, 8000)
    end

    test "8000 Hz stereo" do
      test_wav_file_metadata("priv/samples/pcm0808s.wav", 2, 8000)
    end

    test "11025 Hz mono" do
      test_wav_file_metadata("priv/samples/pcm0811m.wav", 1, 11025)
    end

    test "11025 Hz stereo" do
      test_wav_file_metadata("priv/samples/pcm0811s.wav", 2, 11025)
    end

    test "22050 Hz mono" do
      test_wav_file_metadata("priv/samples/pcm0822m.wav", 1, 22050)
    end

    test "22050 Hz stereo" do
      test_wav_file_metadata("priv/samples/pcm0822s.wav", 2, 22050)
    end

    test "44100 Hz mono" do
      test_wav_file_metadata("priv/samples/pcm0844m.wav", 1, 44100)
    end

    test "44100 Hz stereo" do
      test_wav_file_metadata("priv/samples/pcm0844s.wav", 2, 44100)
    end
  end

  def test_wav_file_metadata(filename, num_channels, sample_rate) do
    wav = WavFile.read(filename)

    assert wav.audio_format == 0x01
    assert wav.num_channels == num_channels
    assert wav.sample_rate == sample_rate
    assert wav.bits_per_sample == 8
    assert wav.bytes_per_second == sample_rate * num_channels
  end
end
