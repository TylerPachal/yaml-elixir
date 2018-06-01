defmodule YamlElixir do
  alias YamlElixir.Mapper

  @yamerl_options [
    detailed_constr: true,
    str_node_as_binary: true
  ]

  defp read(method, source, options) do
    ensure_yamerl_started()
    processed_options = merge_options(options)

    yamerl_constr(method, source, processed_options)
    |> extract_data(processed_options)
    |> Mapper.process(options)
  end

  defp merge_options(options),
    do: Keyword.merge(options, @yamerl_options)

  defp yamerl_constr(:file, path, options), do: :yamerl_constr.file(path, options)
  defp yamerl_constr(:string, data, options), do: :yamerl_constr.string(data, options)

  defp extract_data(data, options) do
    if Keyword.get(options, :one_result) do
      List.last(data)
    else
      data
    end
  end

  def read_all_from_file!(path, options \\ []),
    do: read(:file, path, options)

  def read_all_from_file(path, options \\ []) do
    {:ok, read_all_from_file!(path, options)}
  catch
    _, _ -> {:error, "malformed yaml"}
  end

  def read_from_file!(path, options \\ []),
    do: read(:file, path, Keyword.put(options, :one_result, true))

  def read_from_file(path, options \\ []) do
    {:ok, read_from_file!(path, options)}
  catch
    _, _ -> {:error, "malformed yaml"}
  end

  def read_all_from_string!(string, options \\ []),
    do: read(:string, string, options)

  def read_all_from_string(string, options \\ []) do
    {:ok, read_all_from_string!(string, options)}
  catch
    _, _ -> {:error, "malformed yaml"}
  end

  def read_from_string!(string, options \\ []),
    do: read(:string, string, Keyword.put(options, :one_result, true))

  def read_from_string(string, options \\ []) do
    {:ok, read_from_string!(string, options)}
  catch
    _, _ -> {:error, "malformed yaml"}
  end

  defp ensure_yamerl_started, do: Application.start(:yamerl)
end
