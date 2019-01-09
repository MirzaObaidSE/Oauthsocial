class TwitterAuthenticate

  CONSUMER__API_URL  =  "https://api.twitter.com"

  require "oauth"
  require "oauthsocial/version"

  def self.login_to_twitter_account

    response = TwitterAuthenticate.client.request(:get, "https://api.twitter.com/oauth/request_token")
    tokens = TwitterAuthenticate.parse_string(response.body)
    TwitterAuthenticate.create_session(tokens['oauth_token'] , tokens['oauth_token_secret'])


    "https://api.twitter.com/oauth/authorize?#{response.body}"
  end


  def self.client

    OAuth::Consumer.new( ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'], { :site => CONSUMER__API_URL, :scheme => :header })

  end

  def self.set_access_token(oauth_token, oauth_token_secret)

    token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
    OAuth::AccessToken.from_hash(client, token_hash )

  end

  def self.twitter_callback(params)

    access_token = set_access_token(TwitterAuthenticate.get_oauth_token , TwitterAuthenticate.get_oauth_token_secret)
    result = access_token.request(:post, "https://api.twitter.com/oauth/access_token?oauth_verifier=#{params[:oauth_verifier]}")
    response = TwitterAuthenticate.parse_string(result.body)
    TwitterAuthenticate.get_user(response["oauth_token"], response["oauth_token_secret"])

  end

  def self.get_user(oauth_token , oauth_token_secret)
    access_token = set_access_token(oauth_token, oauth_token_secret)
    user_data  = access_token.request(:get, "https://api.twitter.com/1.1/account/verify_credentials.json")
    JSON.parse(user_data.body)
  end

  private

  def self.create_session(oauth_token , oauth_token_secret)
    Rails.application.config.session_options[:oauth_token] = oauth_token
    Rails.application.config.session_options[:oauth_token_secret] = oauth_token_secret
  end

  def self.get_oauth_token
    Rails.application.config.session_options[:oauth_token]
  end

  def self.get_oauth_token_secret
    Rails.application.config.session_options[:oauth_token_secret]
  end

  def self.parse_string(str)
    ret = {}
    str.split('&').each do |pair|
      key_and_val = pair.split('=')
      ret[key_and_val[0]] = key_and_val[1]
    end
    ret
  end

end
