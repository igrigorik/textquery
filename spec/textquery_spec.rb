require "rubygems"
require "treetop"
require "pp"
require "ruby-debug"
require "spec"

# Resources:
# - http://github.com/nathansobo/treetop
# - http://github.com/nathansobo/treetop/blob/master/examples/lambda_calculus/arithmetic.treetop
# - http://snippets.dzone.com/tag/Treetop
# - http://treetop.rubyforge.org/index.html
#

Treetop.load "textquery"

describe TextQueryParser do
  before(:all) do
    @parser = TextQueryParser.new
  end

  def parse(input)
    result = @parser.parse(input)
    unless result
      puts @parser.terminal_failures.join("\n")
    end
    result
  end

  it "should accept any non space separated sequence" do
    %w[query 123 text123 #tag $%*].each do |input|
      @parser.parse(input).text_value.should == input
      parse(input).eval(input).should be_true
    end
  end

  it "should look for exact word boundary match" do
    parse("text").eval("textstring").should be_false
    parse("text").eval("stringtext").should be_false
    parse("text").eval("some textstring").should be_false
    parse("text").eval("string of texts stuff").should be_false
    parse("$^").eval("string of $^* stuff").should be_false
  end

  it "should accept logical AND" do
    parse("a AND b").eval("c").should be_false
    parse("a AND b").eval("a").should be_false
    parse("a AND b").eval("b").should be_false

    parse("a AND b").eval("a b").should be_true
    parse("a AND b").eval("a c b").should be_true
  end
end
