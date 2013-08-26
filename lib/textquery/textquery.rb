require 'rubygems'
require 'treetop'

# make it utf-8 compatible for < 1.9 Ruby
if RUBY_VERSION < '1.9'
  require 'active_support'
  require 'oniguruma'

  include Oniguruma
  $KCODE = 'u'

  RegExp = ORegexp
  RegExp::IGNORECASE = ORegexp::OPTION_IGNORECASE

else
  RegExp = Regexp
  RegExp::IGNORECACASE = Regexp::IGNORECASE
end

FUZZY = RegExp.new('(?:(?<startcount>\d*)(?<startfuzz>~))?(?<text>[^~]+)(?:(?<endfuzz>~)?(?<endcount>\d*))$')

class WordMatch < Treetop::Runtime::SyntaxNode

  @@regex ||= {}
  @@regex_case ||= {}

  def eval(text, opt)
    query = RegExp.escape(text_value)
    qkey  = query + opt[:delim]

    if not @@regex[qkey]
      fuzzy = FUZZY.match(query)

      q = []
      if fuzzy[:startfuzz]
        q.push "."
        q.push fuzzy[:startcount].empty? ? "*" : "{#{fuzzy[:startcount]}}"
      end
      q.push fuzzy[:text]
      if fuzzy[4]
        q.push "."
        q.push fuzzy[:endcount].empty? ? "*" : "{#{fuzzy[:endcount]}}"
      end
      q = q.join

      regex = "(^|#{opt[:delim]})#{q}(#{opt[:delim]}|$)"

      @@regex[qkey] = RegExp.new(regex, :options => RegExp::IGNORECASE)
      @@regex_case[qkey] = RegExp.new(regex, nil)
    end

    if opt[:ignorecase]
      not @@regex[qkey].match(text).nil?
    else
      not @@regex_case[qkey].match(text).nil?
    end
  end

  def accept(&block)
    block.call(:value, text_value)
  end
end

Treetop.load File.dirname(__FILE__) + "/textquery_grammar"

class TextQueryError < RuntimeError
end

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
      raise TextQueryError, "Could not parse query string '#{query}': #{@parser.terminal_failures.inspect}"
    end
    self
  end

  def eval(input, options = {})
    update_options(options) if not options.empty?

    if @query
      @query.eval(input, @options)
    else
      raise TextQueryError, 'no query specified'
    end
  end
  alias :match? :eval

  def accept(options = {}, &block)
    update_options(options) if not options.empty?

    if @query
      @query.accept(&block)
    else
      raise TextQueryError, 'no query specified'
    end
  end

  def terminal_failures
    @parser.terminal_failures
  end

  private

    def update_options(options)
      @options = {:delim => ' '}.merge(options)
      @options[:delim] = "(#{[@options[:delim]].flatten.map { |opt| opt.is_a?(Regexp) ? opt : RegExp.escape(opt) }.join("|")})"
    end
end
