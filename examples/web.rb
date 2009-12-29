require "rubygems"
require "sinatra"
require "textquery"
require "erb"

$KCODE = 'u'

get "/" do
  params['textstring'] = 'some random text'
  params['query'] = 'some AND (text AND NOT (random OR match OR word))'
  @result = TextQuery.new(params['query']).eval(params['textstring'])

  erb :test
end

post "/" do
  @result = TextQuery.new(params['query']).eval(params['textstring'])
  erb :test
end

__END__

@@ test
<p>Result: <strong><%= @result ? "Matched" : "No match" %></strong></p>

<form action="/" method="post">
  <label>Text</label><br />
  <textarea name="textstring" cols="100" rows="6"><%= params['textstring'] %></textarea><br />

  <label>Query</label><br />
  <textarea name="query" cols="100" rows="2"><%= params['query'] %></textarea><br />

  <br />
  <input type="submit">
</form>

<pre style="background-color:#ccc; padding:2em;">
Supported operators and rules:
 * AND (spaces are implicit AND’s)
 * OR
 * NOT ('-' is an alias)
 * 'quoted strings'

Examples queries:
 * 'to be' OR NOT 'to_be'
 * -omitstring
 * a AND b
 * a AND (b AND NOT (c OR d))
</pre>
