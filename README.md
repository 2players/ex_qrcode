# ex_qrcode

Utils for generating QR code in Elixir.

## Features

- based on battle-tested [komone/qrcode](https://github.com/komone/qrcode)
- support 3 format: SVG / ANSI escaped code / ASCII

> Why not PNG? PNG isn't vector image format. Stretching makes it fuzzy.

## Installation

This package is [available in Hex](https://hex.pm/docs/publish). Install it by adding `ex_qrcode` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_qrcode, "~> 0.1.0"}
  ]
end
```

## Usage

```sh
iex> QRCode.encode("Hello, World!")
%QRCode{version: 1, ecc: :M, dimension: 29, data: <<...>>}

iex> content = QRCode.as_svg("Hello, World!")
iex> File.write("path/to/file.svg", content)
```

## Others

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_qrcode](https://hexdocs.pm/ex_qrcode).
