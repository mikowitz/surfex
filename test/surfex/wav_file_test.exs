defmodule Surfex.WavFileTest do
  use ExUnit.Case, async: true

  alias Surfex.WavFile

  import SurfexTestCase

  describe "8 bit sample size" do
    assert_pcm_metadata("priv/samples/pcm0808m.wav")
    assert_pcm_metadata("priv/samples/pcm0808s.wav")
    assert_pcm_metadata("priv/samples/pcm0811m.wav")
    assert_pcm_metadata("priv/samples/pcm0811s.wav")
    assert_pcm_metadata("priv/samples/pcm0822m.wav")
    assert_pcm_metadata("priv/samples/pcm0822s.wav")
    assert_pcm_metadata("priv/samples/pcm0844m.wav")
    assert_pcm_metadata("priv/samples/pcm0844s.wav")
  end

  describe "16 bit sample size" do
    assert_pcm_metadata("priv/samples/pcm1608m.wav")
    assert_pcm_metadata("priv/samples/pcm1608s.wav")
    assert_pcm_metadata("priv/samples/pcm1611m.wav")
    assert_pcm_metadata("priv/samples/pcm1611s.wav")
    assert_pcm_metadata("priv/samples/pcm1622m.wav")
    assert_pcm_metadata("priv/samples/pcm1622s.wav")
    assert_pcm_metadata("priv/samples/pcm1644m.wav")
    assert_pcm_metadata("priv/samples/pcm1644s.wav")
  end

  describe "24 bit sample size" do
    assert_pcm_metadata("priv/samples/pcm2408m.wav")
    assert_pcm_metadata("priv/samples/pcm2408s.wav")
    assert_pcm_metadata("priv/samples/pcm2411m.wav")
    assert_pcm_metadata("priv/samples/pcm2411s.wav")
    assert_pcm_metadata("priv/samples/pcm2422m.wav")
    assert_pcm_metadata("priv/samples/pcm2422s.wav")
    assert_pcm_metadata("priv/samples/pcm2444m.wav")
    assert_pcm_metadata("priv/samples/pcm2444s.wav")
  end

  describe "32 bit sample size" do
    assert_pcm_metadata("priv/samples/pcm3208m.wav")
    assert_pcm_metadata("priv/samples/pcm3208s.wav")
    assert_pcm_metadata("priv/samples/pcm3211m.wav")
    assert_pcm_metadata("priv/samples/pcm3211s.wav")
    assert_pcm_metadata("priv/samples/pcm3222m.wav")
    assert_pcm_metadata("priv/samples/pcm3222s.wav")
    assert_pcm_metadata("priv/samples/pcm3244m.wav")
    assert_pcm_metadata("priv/samples/pcm3244s.wav")
  end

  describe "writing to file" do
    test "writing a read file back directly returns the same file" do
      wav = WavFile.read("priv/samples/pcm0808m.wav")

      :ok = WavFile.write(wav, "example-pcm0808m.wav")

      wav2 = WavFile.read("example-pcm0808m.wav")

      assert wav == wav2

      :ok = File.rm("example-pcm0808m.wav")
    end

    test "writing a read stereo file back directly returns the same file" do
      wav = WavFile.read("priv/samples/pcm0808s.wav")

      :ok = WavFile.write(wav, "example-pcm0808s.wav")

      wav2 = WavFile.read("example-pcm0808s.wav")

      assert wav == wav2

      :ok = File.rm("example-pcm0808s.wav")
    end

    test "writing a read mono extensible file back directly returns the same file" do
      wav = WavFile.read("priv/samples/pcm3244m.wav")

      :ok = WavFile.write(wav, "example-pcm3244m.wav")

      wav2 = WavFile.read("example-pcm3244m.wav")

      assert wav == wav2

      :ok = File.rm("example-pcm3244m.wav")
    end

    test "writing a read stereo extensible file back directly returns the same file" do
      wav = WavFile.read("priv/samples/pcm2444s.wav")

      :ok = WavFile.write(wav, "example-pcm2444s.wav")

      wav2 = WavFile.read("example-pcm2444s.wav")

      assert wav == wav2

      :ok = File.rm("example-pcm2444s.wav")
    end
  end

  import WavFile.AudioDataFunctions

  test "splitting mono audio data" do
    wav = WavFile.read("priv/samples/pcm0808m.wav")

    audio_data = split_audio_data_into_channels(wav)

    assert length(audio_data) == 1
    assert length(Enum.at(audio_data, 0)) == byte_size(wav.data)
  end

  test "restoring mono audio data" do
    wav = WavFile.read("priv/samples/pcm0808m.wav")

    split_audio_data = split_audio_data_into_channels(wav)

    restored = restore_audio_data_from_channels(split_audio_data, wav.bits_per_sample)

    assert restored == wav.data
  end

  test "splitting stereo audio data" do
    wav = WavFile.read("priv/samples/pcm0808s.wav")

    audio_data = split_audio_data_into_channels(wav)

    assert length(audio_data) == 2
    assert length(Enum.at(audio_data, 0)) == byte_size(wav.data) / 2
  end

  test "restoring stereo audio data" do
    wav = WavFile.read("priv/samples/pcm0808s.wav")

    split_audio_data = split_audio_data_into_channels(wav)

    restored = restore_audio_data_from_channels(split_audio_data, wav.bits_per_sample)

    assert restored == wav.data
  end
end
