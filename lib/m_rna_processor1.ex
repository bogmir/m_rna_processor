defmodule MRnaProcessor1 do

  @stop_codons ["UAA", "UAG", "UGA"]

  def get_genes(rna_input) do
    sequence =
      rna_input
      |> clean_sequence

    with :ok <- validate_length(sequence), :ok <- validate_chars(sequence)
    do
      do_get_genes(sequence)
    end
  end

  defp clean_sequence(rna_input) do
    rna_input
    |> String.replace(~r/>(.)*$/m, "") # removes comments
    |> String.replace(~r/\s/, "") # removes whitespace
    |> String.upcase() # all nucleotides in uppercase
  end

  defp validate_length(sequence) do
    valid = sequence
    |> String.length
    |> rem(3) == 0

    if valid, do: :ok, else: {:error, "Invalid input length"}
  end

  defp validate_chars(sequence) do
    case Regex.match?(~r/^[UAGC]*$/, sequence) do
      true -> :ok
      _ -> {:error, "Invalid DNA: #{sequence}"}
    end
  end

  #sequence traversal starts
  defp do_get_genes(sequence), do: do_get_genes(sequence, [], [])

  defp do_get_genes(<<codon::binary-size(3)>> <> rest, acc, acc_genes) do
    case codon in @stop_codons do
      true ->
        #when STOP codon add to total accumulator and reset current accumulator
        if acc != [],
          do: do_get_genes(rest, [], acc_genes ++ [acc ++ ["STOP(#{codon})"]]),
          #when STOP codon and current gene accumulator is empty, skip codon
          else: do_get_genes(rest, [], acc_genes)
      #add codon only to current accumulator
      false -> do_get_genes(rest, acc ++ [codon], acc_genes)
    end
  end

  #sequence traversal ends
  defp do_get_genes("", acc, acc_genes) do
    if length(acc) > 0,
      do: {:error, "Unexpected end of gene"},
    else: {:ok, acc_genes}
  end
end
