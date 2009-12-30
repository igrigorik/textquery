require 'treetop'

# make it utf-8 compatible
if RUBY_VERSION < '1.9'
  require 'active_support'
  $KCODE = 'u'
end

class WordMatch < Treetop::Runtime::SyntaxNode
  def eval(text, opt)
    not text.match("^#{query}#{opt[:delim]}|#{opt[:delim]}#{query}#{opt[:delim]}|#{opt[:delim]}#{query}$|^#{query}$").nil?
  end

  def query
    Regexp.escape(text_value)
  end
end

Treetop.load File.dirname(__FILE__) + "/textquery_grammar"

class TextQuery
  def initialize(query = '', options = {})
    @parser = TextQueryGrammarParser.new
    @query  = nil

    update_options(options)
    parse(query) if not query.empty?
  end

  def parse(query)
    query = query.mb_chars if RUBY_VERSION < '1.9'
    @query = @parser.parse(query)
    if not @query
      puts @parser.terminal_failures.join("\n")
    end
    self
  end

  def eval(input, options = {})
    update_options(options) if not options.empty?

    if @query
      @query.eval(input, @options)
    else
      puts 'no query specified'
    end
  end
  alias :match? :eval

  def terminal_failures
    @parser.terminal_failures
  end

  private

  def update_options(options)
    @options = {:delim => ' '}.merge options
    @options[:delim] = Regexp.escape @options[:delim]
  end

end