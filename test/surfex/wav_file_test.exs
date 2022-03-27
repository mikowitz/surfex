defmodule Surfex.WavFileTest do
  use ExUnit.Case, async: true

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
end
