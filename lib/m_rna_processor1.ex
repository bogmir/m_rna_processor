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
    |> String.upcase()
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

  defp do_get_genes(sequence), do: do_get_genes(sequence, [], [])
  defp do_get_genes(<<codon::binary-size(3)>> <> rest, [], acc_genes) when codon in @stop_codons do
    do_get_genes(rest, [], acc_genes)
  end
  defp do_get_genes(<<codon::binary-size(3)>> <> rest, acc, acc_genes) when codon in @stop_codons do
    do_get_genes(rest, [], [["STOP(#{codon})" | acc] | acc_genes])
  end

  defp do_get_genes(<<codon::binary-size(3)>> <> rest, acc, acc_genes) do
    do_get_genes(rest, [codon | acc], acc_genes)
  end

  defp do_get_genes("", _, []), do: {:error, "Unexpected end of gene"}
  defp do_get_genes("", _, acc_genes) do
    acc_genes
    |> Enum.reverse()
    |> Enum.map(&Enum.reverse/1)
  end

end
