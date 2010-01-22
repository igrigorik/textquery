require 'rubygems'
require 'treetop'

# make it utf-8 compatible
if RUBY_VERSION < '1.9'
  require 'active_support'
  $KCODE = 'u'
end


BLAH = Regexp.new("(\d)*(~)?([^~]+)(~)?(\d)*$")


class WordMatch < Treetop::Runtime::SyntaxNode
  
  @@regex ||= {}
  @@regex_case ||= {}
  
  def eval(text, opt)
 
    fuzzy = query.match(BLAH)

    q = []
    q.push "."                                    if fuzzy[2]
    q.push fuzzy[1].nil? ? "*" : "{#{fuzzy[1]}}"  if fuzzy[2]
    q.push fuzzy[3]
    q.push "."                                    if fuzzy[4]
    q.push fuzzy[5].nil? ? "*" : "{#{fuzzy[5]}}"  if fuzzy[4]
    q = q.join
    
    regex = "^#{q}#{opt[:delim]}|#{opt[:delim]}#{q}#{opt[:delim]}|#{opt[:delim]}#{q}$|^#{q}$"
    
    unless @@regex[regex] then
      @@regex[regex] = Regexp.new(regex, Regexp::IGNORECASE)
      @@regex_case[regex] = Regexp.new(regex, nil)
    end

    if opt[:ignorecase]
      not text.match(@@regex[regex]).nil?
    else
      not text.match(@@regex_case[regex]).nil?
    end
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
    @options = {:delim => ' '}.merge(options)
    @options[:delim] = "(#{[@options[:delim]].flatten.map { |opt| Regexp.escape(opt) }.join("|")})"
  end
end