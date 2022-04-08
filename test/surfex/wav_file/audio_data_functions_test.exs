defmodule Surfex.WavFile.AudioDataFunctionsTest do
  use ExUnit.Case, async: true

  import Surfex.WavFile.AudioDataFunctions

  test "splitting mono audio data" do
    wav = Surfex.read("priv/samples/pcm0808m.wav")

    audio_data = split_audio_data_into_channels(wav)

    assert length(audio_data) == 1
    assert length(Enum.at(audio_data, 0)) == byte_size(wav.data)
  end

  test "restoring mono audio data" do
    wav = Surfex.read("priv/samples/pcm0808m.wav")

    split_audio_data = split_audio_data_into_channels(wav)

    restored =
      restore_audio_data_from_channels(split_audio_data, wav.bits_per_sample, wav.audio_format)

    assert restored == wav.data
  end

  test "splitting stereo audio data" do
    wav = Surfex.read("priv/samples/pcm0808s.wav")

    audio_data = split_audio_data_into_channels(wav)

    assert length(audio_data) == 2
    assert length(Enum.at(audio_data, 0)) == byte_size(wav.data) / 2
  end

  test "restoring stereo audio data" do
    wav = Surfex.read("priv/samples/pcm0808s.wav")

    split_audio_data = split_audio_data_into_channels(wav)

    restored =
      restore_audio_data_from_channels(split_audio_data, wav.bits_per_sample, wav.audio_format)

    assert restored == wav.data
  end
end
