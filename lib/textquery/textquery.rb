require 'treetop'

class WordMatch < Treetop::Runtime::SyntaxNode
  def eval(text)
    not text.match(/^#{query}\s|\s#{query}\s|\s#{query}$|^#{query}$/).nil?
  end

  def query
    Regexp.escape(text_value)
  end
end

Treetop.load File.dirname(__FILE__) + "/textquery_grammar"

class TextQuery
  def initialize(query = '')
    @parser = TextQueryGrammarParser.new
    @query  = nil

    parse(query) if not query.empty?
  end

  def parse(query)
    @query = @parser.parse(query)
    if not @query
      puts @parser.terminal_failures.join("\n")
    end
    @query
  end

  def eval(input)
    if @query
      @query.eval(input)
    else
      puts 'no query specified'
    end
  end
  alias :match? :eval
  
end