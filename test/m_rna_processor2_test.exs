defmodule MRnaProcessor2Test do
  use ExUnit.Case

  @tag :skip
  test "ok file" do
    assert MRnaProcessor2.get_genes("./dataset/refMrna.fa.corrected.txt") == {:ok, "Process ended successfully."}
  end

  @tag :skip
  test "file with unexpected exit" do
    assert MRnaProcessor2.get_genes("./dataset/mrna-data.txt") ==
      {:error, "Unexpected end of gene", {:last_sequence_read, ["GGG", "CUC"]}}
  end

  @tag :skip
  test "file with invalid sequence" do
    assert MRnaProcessor2.get_genes("./dataset/refMrna.fa.txt") ==
      {:error, "Invalid DNA: YUU is not a valid codon", {:last_sequence_read, ["...", "CUU", "AGC", "CUC"]}}
  end
end
