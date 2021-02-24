defmodule MRnaProcessor2Test do
  use ExUnit.Case

  @input_data_url "./dataset/mrna-data.txt";
  #@tag :pending
  test "take input from stream" do
    assert MRnaProcessor2.get_genes(@input_data_url) == :fail
  end

end
