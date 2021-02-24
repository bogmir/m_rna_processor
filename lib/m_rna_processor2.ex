defmodule MRnaProcessor2 do

  @stop_codons ["UAA", "UAG", "UGA"]

  def get_genes(input_data_url) do
    IO.puts("Starts processing input...")

    with [] <- do_get_genes(input_data_url) do
      {:ok, "Process ended successfully."}
    end
  end

  def do_get_genes(input_data_url) do
    File.stream!(input_data_url)
    |> Stream.map(&clean_sequence/1)
    |> Stream.flat_map(&String.codepoints/1)
    |> Stream.chunk_every(3)
    |> Stream.map(&Enum.join/1)
    |> Enum.reduce_while([], fn codon, acc ->
        with :ok <- validate_chars(codon), :ok <- validate_end(codon)
        do
          case codon in @stop_codons do
            true ->
              if (Enum.any?(acc, &(&1 not in @stop_codons))) do    # repeated STOP codons discarded
                Enum.reverse(["STOP(#{codon})" | acc]) |> IO.inspect(label: "gene")
              end
            false -> {:cont, [codon | acc] }
          end
        else
          {:error, err} -> {:halt, {:error, err, acc}}
        end
      end)
  end

  defp clean_sequence(rna_input) do
    rna_input
    |> String.replace(~r/>(.)*$/m, "") # removes comments
    |> String.replace(~r/\s/, "") # removes whitespace
    |> String.upcase()
  end

  defp validate_chars(sequence) do
    case Regex.match?(~r/^[UAGC]*$/, sequence) do
      true -> :ok
      _ -> {:error, "Invalid DNA"}
    end
  end

  defp validate_end(sequence) do
    case String.length(sequence) do
      3 -> :ok
      _ -> {:error, "Unexpected end of gene"}
    end
  end
end
