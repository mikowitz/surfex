![CI badge](https://github.com/mikowitz/surfex/actions/workflows/ci.yml/badge.svg)

# Surfex

`Surfex` is a library for manipulating WAV files. It can handle uncompressed
PCM bit depths of 8, 16, 24, or 32, with any number of channels. It cannot
currently handle compressed WAV files.

The public API is contained in this `Surfex` module. It currently provides
functions for reading a WAV file into a data structure in memory, writing
a struct back to disk, and manipulating the audio data while loaded in
memory.

## Reading and writing files.

`Surfex.read/1` and `Surfex.write/2` comprise the public API for reading and
writing WAV files to and from disk.

`Surfex.read/1` takes a filename as its argument and returns a `Surfex.WavFile`
struct if the given file contains data that is parseable by `Surfex`, or else an
error explaining why it cannot be parsed.

`Surfex.write/2` takes as its arguments a `Surfex.WavFile` struct and a filename
and attempts to write the data out to the given path on disk. It returns `:ok` or
a POSIX error as defined by `t:File.posix/0`

## Manipulating audio data

The `Surfex.process/3` function provides the API for manipulating audio data.
It takes as its arguments a source file, a target destination filename, and a
processing function. This function expects as its single argument a list of
channels, each of the type `t:channel/0`.

Assuming a multichannel WAV file, the following example randomly shuffles
the order of the channels:

```
Surfex.process("original.wav", "shuffled.wav", fn channels ->
  Enum.shuffle(channels)
end)
```

This example reverses the content of each audio channel

```
Surfex.process("original.wav", "reversed.wav", fn channels ->
  Enum.map(channels, fn channel -> Enum.reverse(channel) end)
end)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `surfex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:surfex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/surfex>.

