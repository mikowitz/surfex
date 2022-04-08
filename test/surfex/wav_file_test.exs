defmodule Surfex.WavFileTest do
  use ExUnit.Case, async: true

  import SurfexTestCase

  test "PCM metadata" do
    for bit_depth <- ~w(08 16 24 32),
        sample_rate <- ~w(08 11 22 44),
        channels <- ~w(s m) do
      assert_pcm_metadata("priv/samples/pcm#{bit_depth}#{sample_rate}#{channels}.wav")
    end
  end

  test "IEEE metadata" do
    for bit_depth <- ~w(sngl dbl), sample_rate <- ~w(08 11 22 44), channels <- ~w(s m) do
      assert_ieee_metadata("priv/samples/#{bit_depth}#{sample_rate}#{channels}.wav")
    end
  end

  describe "writing to file" do
    test "integer-encoded audio data" do
      for bit_depth <- ~w(08 16 24 32),
          sample_rate <- ~w(08 11 22 44),
          channels <- ~w(s m) do
        test_read_write_read("pcm#{bit_depth}#{sample_rate}#{channels}.wav")
      end
    end

    test "float-encoded audio data" do
      for bit_depth <- ~w(sngl dbl), sample_rate <- ~w(08 11 22 44), channels <- ~w(s m) do
        test_read_write_read("#{bit_depth}#{sample_rate}#{channels}.wav")
      end
    end
  end
end
