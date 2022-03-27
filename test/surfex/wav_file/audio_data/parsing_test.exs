defmodule Surfex.WavFile.AudioData.ParsingTest do
  use ExUnit.Case, async: true

  alias Surfex.WavFile
  alias WavFile.AudioData.Parsing

  test "splitting mono audio data" do
    wav = WavFile.read("priv/samples/pcm0808m.wav")

    audio_data = Parsing.split_audio_data_into_channels(wav)

    assert length(audio_data) == 1
    assert length(Enum.at(audio_data, 0)) == byte_size(wav.data)
  end

  test "restoring mono audio data" do
    wav = WavFile.read("priv/samples/pcm0808m.wav")

    split_audio_data = Parsing.split_audio_data_into_channels(wav)

    restored = Parsing.restore_audio_data_from_channels(split_audio_data, wav.bits_per_sample)

    assert restored == wav.data
  end

  test "splitting stereo audio data" do
    wav = WavFile.read("priv/samples/pcm0808s.wav")

    audio_data = Parsing.split_audio_data_into_channels(wav)

    assert length(audio_data) == 2
    assert length(Enum.at(audio_data, 0)) == byte_size(wav.data) / 2
  end

  test "restoring stereo audio data" do
    wav = WavFile.read("priv/samples/pcm0808s.wav")

    split_audio_data = Parsing.split_audio_data_into_channels(wav)

    restored = Parsing.restore_audio_data_from_channels(split_audio_data, wav.bits_per_sample)

    assert restored == wav.data
  end
end
