module CanvasApi
require "uri"
require "net/http"

  def self.post(endpoint, params={})
    post = Net::HTTP.post_form(URI.parse(endpoint), params)
    JSON.parse(post.body)
  end

  def self.retrieve_access_token(code, callback_url, client_id, secret, request_uri)
    raise "client_id required for oauth flow" unless client_id
    raise "secret required for oauth flow" unless secret
    raise "code required" unless code
    raise "callback_url required" unless callback_url
    raise "invalid callback_url" unless (URI.parse(callback_url) rescue nil)
    @token = "ignore"
    res = post(request_uri + "/login/oauth2/token", :grant_type => "authorization_code", :client_id => client_id, :redirect_uri => callback_url, :client_secret => secret, :code => code, :replace_tokens => true)
    if res['access_token']
        @token = res['access_token']
    end
    res
  end
end
