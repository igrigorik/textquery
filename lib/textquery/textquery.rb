require 'rubygems'
require 'treetop'
require 'oniguruma'

include Oniguruma

# make it utf-8 compatible
if RUBY_VERSION < '1.9'
  require 'active_support'
  $KCODE = 'u'
end

FUZZY = ORegexp.new('(\d)*(~)?([^~]+)(~)?(\d)*$')

class WordMatch < Treetop::Runtime::SyntaxNode
  
  @@regex ||= {}
  @@regex_case ||= {}
  
  def eval(text, opt)
    
    fuzzy = FUZZY.match(query)

    q = []
    q.push "."                                    if fuzzy[2]
    q.push fuzzy[1].nil? ? "*" : "{#{fuzzy[1]}}"  if fuzzy[2]
    q.push fuzzy[3]
    q.push "."                                    if fuzzy[4]
    q.push fuzzy[5].nil? ? "*" : "{#{fuzzy[5]}}"  if fuzzy[4]
    q = q.join
    
    regex = "(^|#{opt[:delim]})#{q}(#{opt[:delim]}|$)"
    
    unless @@regex[regex] then
      @@regex[regex] = ORegexp.new(regex, :options => OPTION_IGNORECASE)
      @@regex_case[regex] = ORegexp.new(regex, nil)
    end

    if opt[:ignorecase]
      not @@regex[regex].match(text).nil?
    else
      not @@regex_case[regex].match(text).nil?
    end
  end
  
  def query
    ORegexp.escape(text_value)
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
    @options[:delim] = "(#{[@options[:delim]].flatten.map { |opt| ORegexp.escape(opt) }.join("|")})"
  end
end