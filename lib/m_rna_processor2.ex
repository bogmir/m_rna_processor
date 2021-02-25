defmodule MRnaProcessor2 do

  @stop_codons ~w<UAA UAG UGA>

  def get_genes(input_data_url) do
    IO.puts("Starts processing input...")

    case do_get_genes(input_data_url) do
      {_, []} -> {:ok, "Process ended successfully."}
      {_, list = [_ | _]} ->
        trace = list |> Enum.reverse() |> get_trace()
        {:error, "Unexpected end of gene", trace}
      {:error, err, trace} -> {:error, err, trace}
    end
  end

  def do_get_genes(input_data_url) do
    File.stream!(input_data_url)
    |> Stream.map(&clean_sequence/1)
    |> Stream.flat_map(&String.codepoints/1)
    |> Stream.chunk_every(3)
    |> Stream.map(&Enum.join/1)
    |> Enum.reduce_while({1, []}, fn codon, {counter, acc} ->
        with :ok <- validate_codon(codon)
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

  def get_trace(list, elements\\3) do
    last_elements_in_list = list |> Enum.take(-elements)

    if length(list) > elements do
      {:last_sequence_read, ["..."] ++ last_elements_in_list}
    else
      {:last_sequence_read, last_elements_in_list}
    end
  end

  defp clean_sequence(rna_input) do
    rna_input
    |> String.replace(~r/>(.)*$/m, "") # removes comments
    |> String.replace(~r/\s/, "") # removes whitespace
    |> String.upcase()
  end

  defp validate_codon(sequence) do
    case Regex.match?(~r/^[UAGC]*$/, sequence) && String.length(sequence) === 3 do
      true -> :ok
      _ -> {:error, "Invalid DNA: #{sequence} is not a valid codon"}
    end
  end
end
