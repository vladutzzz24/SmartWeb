require 'bundler/setup'
require 'sinatra'
require 'oauth2'
require 'json'
require "net/http"
require "uri"

# Our client ID and secret, used to get the access token
CLIENT_ID = '88a37b2d-1f96-4e15-a0fc-e0ec63b84f3b'
CLIENT_SECRET = '75ce0970-b3da-4c43-aaaf-2d9313575541'
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
redirect '/temperature'
end


#PUT getSwitch=on

# handle requests to the /getSwitch URL. This is where
# we will make requests to get information about the configured
# switch.
get '/temperature' do
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
  #  switchStatus = getSwitchHttp.request(getSwitchReq)
  #  [%(<p>switchStatus.code</p><br>),%(<p>switchStatus.to_hast.inspect</p><br>),%(<p>switchStatus.body</p>)]



  %(<a href="/temp">Details</a><br>)




  end








  get '/temp' do

  #  switchUrl = uri + '/switches/'
  #  token = session[:access_token]
  #  getSwitchURL = URI.parse(switchUrl)
  #  getSwitchReq = Net::HTTP::Put.new(getSwitchURL.request_uri)
  #  getSwitchReq['Authorization'] = 'Bearer ' + token


  #  getSwitchHttp = Net::HTTP.new(getSwitchURL.host, getSwitchURL.port)
  #  getSwitchHttp.use_ssl = true

  #  switchStatus = getSwitchHttp.request(getSwitchReq)



    ######################################################

    switchUrlon = uri + '/switchesTemp'
    token = session[:access_token]
    getSwitchURLon = URI.parse(switchUrlon)
    getSwitchReqon = Net::HTTP::Get.new(getSwitchURLon.request_uri)
    getSwitchReqon['Authorization'] = 'Bearer ' + token


    getSwitchHttpon = Net::HTTP.new(getSwitchURLon.host, getSwitchURLon.port)
    getSwitchHttpon.use_ssl = true

    switchStatuson = getSwitchHttpon.request(getSwitchReqon)
    '<h3>Response Body</h3>' + switchStatuson.body+%(<br><a href="/back">Back</a>)
  #  tempSwitchURL=Net::HTTP::Get.new(tempSwitchURL.listTemp)
  end




  get '/back' do

  redirect '/temperature'

  end