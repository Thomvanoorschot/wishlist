defmodule CadeauCompas.Helpers.StringHelpers do
  @doc """
  Takes a string and transforms it into slug format.

  Examples:

      iex> SlugHelper.slugify("  Hello, World!  ")
      "hello-world"

      iex> SlugHelper.slugify("Elixir/Phoenix 1.14")
      "elixir-phoenix-1-14"
  """
  def slugify(string) when is_binary(string) do
    string
    |> String.trim()
    |> String.downcase()
    # Replace groups of non-alphanumeric chars (including underscores, punctuation, etc.) with a single hyphen
    |> String.replace(~r/[^\p{L}\p{N}]+/u, "-")
    # Remove hyphens at the start or end
    |> String.replace(~r/^-+|-+$/, "")
  end
end
