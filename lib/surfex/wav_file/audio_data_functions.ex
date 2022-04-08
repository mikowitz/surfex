defmodule Surfex.WavFile.AudioDataFunctions do
  @moduledoc false

  @doc """
  Splits raw audio binary data into its component channels, decoded into integers.
  """
  @spec split_audio_data_into_channels(Surfex.WavFile.t()) :: Surfex.channels()
  def split_audio_data_into_channels(
        %{data: data, bits_per_sample: bits_per_sample, audio_format: audio_format} = wav
      ) do
    sample_size = round(bits_per_sample * wav.num_channels / 8)

    samples = for <<sample::binary-size(sample_size) <- data>>, do: sample

    reduce_fn = build_reduce_function(bits_per_sample, audio_format)

    interleaved_samples =
      Enum.map(samples, fn sample ->
        {<<>>, samples} = Enum.reduce(1..wav.num_channels, {sample, []}, reduce_fn)
        Enum.reverse(samples)
      end)

    interleaved_samples
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  @doc """
  Takes a list of channels of audio data and reconstitutes them into a single block
  of binary data that can be written to a WAV file.
  """
  @spec restore_audio_data_from_channels(Surfex.channels(), integer(), integer()) :: binary()
  def restore_audio_data_from_channels(channels, bits_per_sample, audio_format) do
    interleaved_samples =
      Enum.zip(channels)
      |> Enum.map(&Tuple.to_list/1)

    interleave_fn = build_interleave_function(bits_per_sample, audio_format)

    Enum.map(interleaved_samples, fn samples ->
      Enum.map(samples, interleave_fn)
      |> Enum.reduce(<<>>, &(&2 <> &1))
    end)
    |> Enum.reduce(<<>>, &(&2 <> &1))
  end

  defp build_interleave_function(8, _) do
    fn i -> <<i::little-unsigned-size(8)>> end
  end

  defp build_interleave_function(32, 0x03) do
    fn i -> <<i::little-signed-float-32>> end
  end

  defp build_interleave_function(64, 0x03) do
    fn i -> <<i::little-signed-float-64>> end
  end

  defp build_interleave_function(bps, 0x01) do
    fn i -> <<i::little-signed-size(bps)>> end
  end

  defp build_reduce_function(8, _) do
    fn _, {sample, sample_split_by_channel} ->
      <<sample_for_next_channel::little-unsigned-size(8), remaining_samples::binary>> = sample

      {remaining_samples, [sample_for_next_channel | sample_split_by_channel]}
    end
  end

  defp build_reduce_function(32, 0x03) do
    fn _, {sample, sample_split_by_channel} ->
      <<sample_for_next_channel::little-signed-float-32, remaining_samples::binary>> = sample

      {remaining_samples, [sample_for_next_channel | sample_split_by_channel]}
    end
  end

  defp build_reduce_function(64, 0x03) do
    fn _, {sample, sample_split_by_channel} ->
      <<sample_for_next_channel::little-signed-float-64, remaining_samples::binary>> = sample

      {remaining_samples, [sample_for_next_channel | sample_split_by_channel]}
    end
  end

  defp build_reduce_function(bps, 0x01) do
    fn _, {sample, sample_split_by_channel} ->
      <<sample_for_next_channel::little-signed-size(bps), remaining_samples::binary>> = sample

      {remaining_samples, [sample_for_next_channel | sample_split_by_channel]}
    end
  end
end
