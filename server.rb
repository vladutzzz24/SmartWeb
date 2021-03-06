require 'bundler/setup'
require 'sinatra'
require 'oauth2'
require 'json'
require "net/http"
require "uri"

# Our client ID and secret, used to get the access token
#CLIENT_ID = '9cb3070a-8972-4e1d-91af-b249562f019e'
#CLIENT_SECRET = 'b3aa5ca9-c240-4cfe-b856-62b70421470a'

CLIENT_ID = '0fd091f7-4f90-426a-aed8-1b57825fff44'
CLIENT_SECRET = '362eafdf-5979-48c3-9397-5ed5fd78c577'
uri = ''






# We'll store the access token in the session
use Rack::Session::Pool, :cookie_only => false
def authenticated?
    session[:access_token]
end

# This is the URI that will be called with our access
# code after we authenticate with our SmartThings account
redirect_uri = 'http://localhost:4567/oauth/callback'

# This is the URI we will use to get the endpoints once we've received our token
endpoints_uri = 'https://graph.api.smartthings.com/api/smartapps/endpoints'

options = {
  site: 'https://graph.api.smartthings.com',
  authorize_url: '/oauth/authorize',
  token_url: '/oauth/token'
}

# use the OAuth2 module to handle OAuth flow
client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, options)

# helper method to know if we have an access token
def authenticated?
  session[:access_token]
end

# handle requests to the application root
get '/' do
  %(<a href="/authorize">Connect with SmartThings</a>)
end

# handle requests to /authorize URL
get '/authorize' do
  url = client.auth_code.authorize_url(redirect_uri: redirect_uri, scope: 'app')
redirect url
end

# hanlde requests to /oauth/callback URL. We
# will tell SmartThings to call this URL with our
# authorization code once we've authenticated.
get '/oauth/callback' do
  #The callback is called with a "code" URL parameter
# This is the code we can use to get our access token
code = params[:code]

# Use the code to get the token.
response = client.auth_code.get_token(code, redirect_uri: redirect_uri, scope: 'app')

# now that we have the access token, we will store it in the session
session[:access_token] = response.token

# debug - inspect the running console for the
# expires in (seconds from now), and the expires at (in epoch time)
puts 'TOKEN EXPIRES IN ' + response.expires_in.to_s
puts 'TOKEN EXPIRES AT ' + response.expires_at.to_s
redirect '/getswitch'
end


#PUT getSwitch=on

# handle requests to the /getSwitch URL. This is where
# we will make requests to get information about the configured
# switch.
get '/getswitch' do
  # If we get to this URL without having gotten the access token
  # redirect back to root to go through authorization
  if !authenticated?
    redirect '/'
  end


  token = session[:access_token]

  # make a request to the SmartThins endpoint URI, using the token,
  # to get our endpoints
  url = URI.parse(endpoints_uri)
  req = Net::HTTP::Get.new(url.request_uri)

  # we set a HTTP header of "Authorization: Bearer <API Token>"
  req['Authorization'] = 'Bearer ' + token

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == "https")

  response = http.request(req)
  json = JSON.parse(response.body)

  # debug statement





  puts json

  # get the endpoint from the JSON:
uri = json[0]['uri']


puts uri


  [%(<a href="/ON">Outlett on</a><br>),
  %(<a href="/OFF">Outlett off</a>),%(<br><a href="/page">Redirect</a><br>),%(<br><a href="/listM">Motion</a><br>)]




end








  get '/ON' do

    switchUrl = uri + '/switches/on'
    token = session[:access_token]
    getSwitchURL = URI.parse(switchUrl)
    getSwitchReq = Net::HTTP::Put.new(getSwitchURL.request_uri)
    getSwitchReq['Authorization'] = 'Bearer ' + token


    getSwitchHttp = Net::HTTP.new(getSwitchURL.host, getSwitchURL.port)
    getSwitchHttp.use_ssl = true

    switchStatus = getSwitchHttp.request(getSwitchReq)



    ######################################################

    switchUrlon = uri + '/switches'
    token = session[:access_token]
    getSwitchURLon = URI.parse(switchUrlon)
    getSwitchReqon = Net::HTTP::Get.new(getSwitchURLon.request_uri)
    getSwitchReqon['Authorization'] = 'Bearer ' + token


    getSwitchHttpon = Net::HTTP.new(getSwitchURLon.host, getSwitchURLon.port)
    getSwitchHttpon.use_ssl = true

    switchStatuson = getSwitchHttpon.request(getSwitchReqon)
    '<h3>Response Code</h3>' + switchStatuson.code + '<br/><h3>Response Headers</h3>' + switchStatuson.to_hash.inspect + '<br/><h3>Response Body</h3>' + switchStatuson.body+%(<br><a href="/back">Back</a>)

end



  get '/OFF' do

    switchUrl = uri + '/switches/off'
    token = session[:access_token]
    getSwitchURL = URI.parse(switchUrl)
    getSwitchReq = Net::HTTP::Put.new(getSwitchURL.request_uri)
    getSwitchReq['Authorization'] = 'Bearer ' + token


    getSwitchHttp = Net::HTTP.new(getSwitchURL.host, getSwitchURL.port)
    getSwitchHttp.use_ssl = true

    switchStatus = getSwitchHttp.request(getSwitchReq)

######################################################

switchUrloff = uri + '/switches'
token = session[:access_token]
getSwitchURLoff = URI.parse(switchUrloff)
getSwitchReqoff = Net::HTTP::Get.new(getSwitchURLoff.request_uri)
getSwitchReqoff['Authorization'] = 'Bearer ' + token


getSwitchHttpoff = Net::HTTP.new(getSwitchURLoff.host, getSwitchURLoff.port)
getSwitchHttpoff.use_ssl = true

switchStatusoff = getSwitchHttpoff.request(getSwitchReqoff)
'<h3>Response Code</h3>' + switchStatusoff.code + '<br/><h3>Response Headers</h3>' + switchStatusoff.to_hash.inspect + '<br/><h3>Response Body</h3>' + switchStatusoff.body+ %(<br><a href="/back">Back</a>)



  end








get '/page' do
  redirect_uri='index'
end


get '/back' do

  redirect '/getswitch'

end
