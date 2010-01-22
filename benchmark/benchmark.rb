require 'benchmark'
require 'lib/textquery.rb'

queries = []
queries << TextQuery.new("イケア OR イケヤ")
queries << TextQuery.new("obama 'health care' michel OR obama -tax")

text = ""
File.open('benchmark/sample.txt').each_line{ |s|
  text << s
}

n = 500000
Benchmark.bm do |x|
  x.report do
    queries.each do |q|
      q.match?(text)
    end
  end
end
