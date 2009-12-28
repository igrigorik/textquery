require 'treetop'

class TextQuery
  def initialize(query = '')
    Treetop.load File.dirname(__FILE__) + "/textquery_grammar"
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