defmodule QRCode do
  @doc """
  Returns QR code as string of {\#, \.}.
  """
  def as_ascii(text) when is_binary(text) do
    {:qrcode, _s, _q, dimension, data} = :qrcode.encode(text)

    nl = "\n"

    data
    |> to_ascii()
    |> Enum.chunk_every(dimension)
    |> Enum.join(nl)
    |> (fn s -> s <> nl end).()
  end

  defp to_ascii(list), do: to_ascii(list, [])

  defp to_ascii(<< 0 :: size(1), tail :: bitstring >>, acc) do
    bg = "."
    to_ascii(tail, [bg | acc])
  end

  defp to_ascii(<< 1 :: size(1), tail :: bitstring >>, acc)  do
    fg = "#"
    to_ascii(tail, [fg | acc])
  end

  defp to_ascii(<<>>, acc) do
    Enum.reverse(acc)
  end

  @doc """
  Return QR code as ANSI escaped string.
  """
  def as_ansi(text) when is_binary(text) do
    {:qrcode, _s, _q, dimension, data} = :qrcode.encode(text)

    nl = IO.ANSI.reset() <> "\n"
    data
    |> to_ansi()
    |> Enum.chunk_every(dimension)
    |> Enum.join(nl)
    |> (fn s -> s <> nl end).()
  end

  defp to_ansi(list), do: to_ansi(list, [])

  defp to_ansi(<< 0 :: size(1), tail :: bitstring >>, acc) do
    bg = IO.ANSI.white_background() <> "  "
    to_ansi(tail, [bg | acc])
  end

  defp to_ansi(<< 1 :: size(1), tail :: bitstring >>, acc)  do
    fg = IO.ANSI.black_background() <> "  "
    to_ansi(tail, [fg | acc])
  end

  defp to_ansi(<<>>, acc) do
    Enum.reverse(acc)
  end

  @doc """
  Return QR code as string in SVG format.
  """
  def as_svg(text, opts \\ []) when is_binary(text) do
    block_size = Keyword.get(opts, :size, 8)
    padding_size = Keyword.get(opts, :padding_size, 16)
    fg_color = Keyword.get(opts, :fg_color, "#000000")
    bg_color = Keyword.get(opts, :bg_color, "#ffffff")

    size = block_size * dimension + 2 * padding_size

    {:qrcode, _s, _q, dimension, data} = :qrcode.encode(text)

    bg = generate_svg_block(0, 0, size, bg_color)
    blocks = data
    |> to_ascii()
    |> Enum.chunk_every(dimension)
    |> Enum.with_index
    |> Enum.map(fn({row, i}) ->
      row
      |> Enum.with_index
      |> Enum.map(fn ({block, j}) -> { block, i, j } end)
    end)
    |> Enum.concat()
    |> Enum.filter(fn ({block, _i, _j}) -> block === "#" end)
    |> Enum.map(fn {_block, i, j} ->
      x = i * block_size + padding_size
      y = j * block_size + padding_size

      generate_svg_block(x, y, block_size, fg_color)
    end)
    |> Enum.join("")

    generate_svg(size, bg, blocks)
  end

  defp generate_svg_block(x, y, block_size, color) do
    """
    <rect x="#{x}" y="#{y}" width="#{block_size}" height="#{block_size}" style="fill: #{color}; shape-rendering: crispEdges;"/>
    """
  end

  defp generate_svg(size, bg, blocks) do
    """
    <?xml version="1.0" standalone="yes"?>
    <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="#{size}" height="#{size}">
    #{bg}
    #{blocks}
    </svg>
    """
  end
end
