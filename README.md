# TextQuery

Does it match? When regular expressions are not enough, textquery is the answer. For
example, regular expressions cannot evaluate recursive rules and often result in
overly verbose and complicated expressions.

Textquery is a simple PEG grammar with support for:

- AND (spaces are implicit AND's)
- OR
- NOT (- is an alias)
- 'quoted strings'
- fuzzy matching
- case (in)sensitive
- custom delimeters

## Example

```ruby
TextQuery.new("'to be' OR NOT 'to_be'").match?("to be")   # => true

TextQuery.new("-test").match?("some string of text")      # => true
TextQuery.new("NOT test").match?("some string of text")   # => true

TextQuery.new("a AND b").match?("b a")                    # => true
TextQuery.new("a AND b").match?("a c")                    # => false

q = TextQuery.new("a AND (b AND NOT (c OR d))")
q.match?("d a b")                                         # => false
q.match?("b")                                             # => false
q.match?("a b cdefg")                                     # => true

TextQuery.new("a~").match?("adf")                         # => true
TextQuery.new("~a").match?("dfa")                         # => true
TextQuery.new("~a~").match?("daf")                        # => true
TextQuery.new("2~a~1").match?("edaf")                     # => true
TextQuery.new("2~a~2").match?("edaf")                     # => false

TextQuery.new("a", :ignorecase => true).match?("A b cD")  # => true
```

## License

The MIT License - Copyright (c) 2011 Ilya Grigorik