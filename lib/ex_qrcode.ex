defmodule QRCode do
  @default_ecc :M

  @doc """
  ## about `version`
  Todo.


  ## about `ecc`
  - 'L': recovers 7% of data
  - 'M': recovers 15% of data (default)
  - 'Q': recovers 25% of data
  - 'H': recovers 30% of data

  ## about `dimension`
  Todo.

  ## about `data`
  Todo.
  """
  defstruct version: nil, ecc: nil, dimension: nil, data: nil

  @doc """
  Encode text as binary according ISO/IEC 18004.
  """
  def encode(text, ecc \\ @default_ecc) when is_binary(text) do
    {:qrcode, version, ecc, dimension, data } = :qrcode.encode(text, ecc)

    %QRCode{
      version: version,
      ecc: ecc,
      dimension: dimension,
      data: data
    }
  end

  @doc """
  Returns QR code as string consists of {\#, \.}.

  ## Examples

      iex> QRCode.as_ascii("Hello, World!", ecc: :M) |> IO.puts
      :ok

  """
  def as_ascii(text, opts \\ []) when is_binary(text) do
    ecc = Keyword.get(opts, :ecc, @default_ecc)
    %QRCode{dimension: dimension, data: data} = encode(text, ecc)

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

  ## Examples

      iex> QRCode.as_ansi("Hello, World!", ecc: :M) |> IO.puts
      :ok

  """
  def as_ansi(text, opts \\ []) when is_binary(text) do
    ecc = Keyword.get(opts, :ecc, @default_ecc)
    %QRCode{dimension: dimension, data: data} = encode(text, ecc)

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

  ## Examples

      iex> QRCode.as_svg("Hello, World!", ecc: :M) |> IO.puts
      :ok

  """
  def as_svg(text, opts \\ []) when is_binary(text) do
    ecc = Keyword.get(opts, :ecc, @default_ecc)
    type = Keyword.get(opts, :type, :file)
    block_size = Keyword.get(opts, :size, 8)
    padding_size = Keyword.get(opts, :padding_size, 16)
    fg_color = Keyword.get(opts, :fg_color, "#000000")
    bg_color = Keyword.get(opts, :bg_color, "#ffffff")

    %QRCode{dimension: dimension, data: data} = encode(text, ecc)

    size = block_size * dimension + 2 * padding_size
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

    generate_svg(size, bg, blocks, type: type)
  end

  defp generate_svg_block(x, y, block_size, color) do
    """
    <rect x="#{x}" y="#{y}" width="#{block_size}" height="#{block_size}" style="fill: #{color}; shape-rendering: crispEdges;"/>
    """
  end

  defp generate_svg(size, bg, blocks, opts) do
    type = Keyword.get(opts, :type)

    header = case type do
      :file ->
        "<?xml version=\"1.0\" standalone=\"yes\"?>\n"
      :embeded ->
        ""
    end

    """
    #{header}<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="#{size}" height="#{size}">
    #{bg}
    #{blocks}
    </svg>
    """
  end
end
