defmodule MRnaProcessor do

  def get_genes(input) do
    if File.exists?(input) do
      MRnaProcessor2.get_genes(input)
    else
      MRnaProcessor1.get_genes(input)
    end
  end
end
