defmodule MRnaProcessor2 do

  @stop_codons ~w<UAA UAG UGA>

  def get_genes(input_data_url) do
    IO.puts("Starts processing input...")

    case do_get_genes(input_data_url) do
      {_, []} -> {:ok, "Process ended successfully."}
      {_, list = [_ | _]} ->
        trace = list |> Enum.reverse() |> get_trace()
        {:error, "Unexpected end of gene: STOP codon missing", trace}
      {:error, err, trace} -> {:error, err, trace}
    end
  end

  defp do_get_genes(input_data_url) do
    File.stream!(input_data_url)
    |> Stream.map(&clean_sequence/1)
    |> Stream.flat_map(&String.codepoints/1)
    |> Stream.chunk_every(3)
    |> Stream.map(&Enum.join/1)
    |> Enum.reduce_while({1, []}, fn codon, {counter, acc} ->
        with :ok <- validate_characters(codon), :ok <- validate_length(codon)
        do
          case codon in @stop_codons do
            true -> #gene may be captured at this point
              if (Enum.any?(acc, &(&1 not in @stop_codons))) do # repeated STOP codons discarded here
                Enum.reverse(["STOP(#{codon})" | acc]) |> IO.inspect(label: "gene #{counter}")
              end
              {:cont, { counter + 1, [] }}
            false -> {:cont, { counter, [codon | acc] }}
          end
        else
          {:error, err} ->
            trace = acc |> Enum.reverse() |> get_trace(3)
            {:halt, {:error, err, trace}}
        end
      end)
  end

  defp get_trace(list, elements \\ 3)
  defp get_trace(list, elements) when length(list) > elements,
    do: {:last_sequence_read, ["..."] ++ Enum.take(list, -elements)}
  defp get_trace(list, elements), do: {:last_sequence_read, Enum.take(list, -elements)}

  defp clean_sequence(rna_input) do
    rna_input
    |> String.replace(~r/>(.)*$/m, "") # removes comments
    |> String.replace(~r/\s/, "") # removes whitespace
    |> String.upcase()
  end

  defp validate_characters(sequence) do
    case res = Regex.run(~r/[^UAGC]/, sequence) do
      nil -> :ok
      _ -> {:error, "Invalid DNA: #{res}"}
    end
  end

  defp validate_length(sequence) do
    case String.length(sequence) == 3 do
      true -> :ok
      _ -> {:error, "Unexpected end of gene: #{sequence} is not a valid codon"}
    end
  end
end
