defmodule MRnaProcessor1Test do
  use ExUnit.Case

  test "get one gene" do
    input = "uuucaugug cccaaaauc cucucaggc acagccuag"
    assert MRnaProcessor1.get_genes(input)
      == {:ok, [["UUU", "CAU", "GUG", "CCC", "AAA", "AUC", "CUC", "UCA", "GGC", "ACA", "GCC", "STOP(UAG)"]]}
  end

  test "get two genes" do
    input = "uuucaugug cccaaaauc acagccuag cucucaggc acagccuag"
    assert MRnaProcessor1.get_genes(input)
      == {:ok, [["UUU", "CAU", "GUG", "CCC", "AAA", "AUC", "ACA", "GCC", "STOP(UAG)"], ["CUC", "UCA", "GGC", "ACA", "GCC", "STOP(UAG)"]]}
  end

  test "get two genes with a commentary in between" do
    input = "uuucaugug cccaaaauc acagccuag
    >commentary
    cucucaggc acagccuag"
    assert MRnaProcessor1.get_genes(input)
      == {:ok, [["UUU", "CAU", "GUG", "CCC", "AAA", "AUC", "ACA", "GCC", "STOP(UAG)"], ["CUC", "UCA", "GGC", "ACA", "GCC", "STOP(UAG)"]]}
  end

  test "remove 'noise' codons from gene" do
    input = ">commentary
    uuucaugug cccaaaauc acagccUAAuagUAAUGA
    cucucaggc acagccuag"
    assert MRnaProcessor1.get_genes(input)
      == {:ok, [["UUU", "CAU", "GUG", "CCC", "AAA", "AUC", "ACA", "GCC", "STOP(UAA)"], ["CUC", "UCA", "GGC", "ACA", "GCC", "STOP(UAG)"]]}
  end

  test "invalid input length" do
    assert MRnaProcessor1.get_genes("UU1U") === {:error, "Invalid input length"}
  end

  test "invalid input length for longer sequence with whitespace" do
    assert MRnaProcessor1.get_genes("uuucaugug cccaaaauc cucucaggc acagccua")
      == {:error, "Invalid input length"}
  end

  test "Invalid DNA" do
    input = "UUUGGY"
    assert MRnaProcessor1.get_genes(input) === {:error, "Invalid DNA: #{input}"}
  end

  test "Unexpected end of gene when no gene captured" do
    assert MRnaProcessor1.get_genes("augaaa") === {:error, "Unexpected end of gene"}
  end

  test "Unexpected end of gene when gene already captured" do
    assert MRnaProcessor1.get_genes("uuucaugug cccaaaauc acagccuag cucucaggc acagccuag augaaa") === {:error, "Unexpected end of gene"}
  end
end
