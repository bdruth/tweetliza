require 'sinatra'
require 'dm-core'
require 'appengine-apis/memcache'
require 'java'
java_import 'Eliza.ElizaMain'

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

# Create your model class
class Shout
  include DataMapper::Resource
  
  property :id, Serial
  property :message, Text
end

# Make sure our template can use <%=h
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  erb :index
end

def eliza 
  memcache = AppEngine::Memcache.new
  unless memcache[:eliza].nil? 
    return memcache[:eliza]
  end
  eliza = ElizaMain.new
  eliza.readScript(false, "http://chayden.org/eliza/script")
  memcache[:eliza] = eliza
end

post '/' do
  unless params[:input].nil?
    @elResponse = eliza.processInput(params[:input])
  else
    @elResponse = eliza.processInput("Hello")
  end
  erb :index
end

__END__

@@ index
<html>
  <head>
    <title>JEliza on Sinatra + JRuby!</title>
  </head>
  <body style="font-family: sans-serif;">
    <h1>JEliza on Sinatra + JRuby</h1>

    <form method=post>
      <input type="text" name="input"></input>Ask a question.
      <input type="submit" value="submit">
    </form>
    <p><%=h @elResponse %></p>

    <div style="position: absolute; bottom: 20px; right: 20px;">
    <img src="/images/appengine.gif"></div>
  </body>
</html>
