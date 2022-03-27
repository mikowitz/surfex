defmodule Surfex do
  alias Surfex.WavFile
  alias Surfex.WavFile.AudioData.Parsing

  def lower_volume(infile, outfile, percentage \\ 0.5) do
    wav = WavFile.read(infile)

    channels = Parsing.split_audio_data_into_channels(wav)

    channels =
      Enum.map(channels, fn channel ->
        Enum.map(channel, fn i -> round(i * percentage) end)
      end)

    audio_data = Parsing.restore_audio_data_from_channels(channels, wav.bits_per_sample)

    new_wav = %{wav | data: audio_data}

    WavFile.write(new_wav, outfile)
  end
end
