defmodule Surfex.WavFile.AudioDataFunctions do
  def split_audio_data_into_channels(%{data: data, bits_per_sample: bits_per_sample} = wav) do
    sample_size = round(wav.bits_per_sample * wav.num_channels / 8)

    samples = for <<sample::binary-size(sample_size) <- data>>, do: sample

    interleaved_samples =
      Enum.map(samples, fn sample ->
        {<<>>, samples} =
          Enum.reduce(1..wav.num_channels, {sample, []}, fn _,
                                                            {sample, sample_split_by_channel} ->
            <<sample_for_next_channel::size(bits_per_sample), remaining_samples::binary>> = sample
            {remaining_samples, [sample_for_next_channel | sample_split_by_channel]}
          end)

        Enum.reverse(samples)
      end)

    interleaved_samples
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def restore_audio_data_from_channels(channels, bits_per_sample) do
    interleaved_samples =
      Enum.zip(channels)
      |> Enum.map(&Tuple.to_list/1)

    Enum.map(interleaved_samples, fn samples ->
      Enum.map(samples, fn i -> <<i::size(bits_per_sample)>> end)
      |> Enum.reduce(<<>>, &(&2 <> &1))
    end)
    |> Enum.reduce(<<>>, &(&2 <> &1))
  end
end
