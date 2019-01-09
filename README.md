# Oauthsocial

Welcome to Oauthsocial! This gem can be used for Twitter 3 step authentication log in.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oauthsocial', git: "https://github.com/MirzaObaidSE/Oauthsocial.git"MirzaObaidSE/Oauthsocialhttps://github.com
```

And then execute:

    $ bundle
    
## Usage
Creating a Twitter Application

 Log in to your Twitter account and browse to the url 
```
 https://apps.twitter.com
```
On the Twitter apps page, click the Create New App button.
Fill in the Name, Description, and Website fields.
Enter ```http://localhost:3000/twitter/callback``` 
in the Callback URL field.Accept the Developer Agreement and click the Create your Twitter application button.On the application page, that is shown next, click the Settings tab.

Enter a mock url in the Privacy Policy URL, and Terms of Service URL field and click the Update Settings button.
Click the Permissions tab and change the Access type to Read only.

Check the Request email addresses from users field under the Additional Permissions section and click the Update Settings button.
Click the Keys and Access Tokens tab.

Note down the Consumer Key (API Key), and Consumer Secret (API Secret) shown on the page as they will be needed later.

Add Consumer key and Consumer Secret in ```Config/application.yml ```
```
CONSUMER_KEY: "Consumer Api key"
CONSUMER_SECRET: "Consumer Api Secret"

```                                                        
To Add provider and uid to User table
```
rails g migration add_provider_and_uid_to_users provider:string, uid:integer
```
and run
```
rails db:migrate
```
Add route to your app to login to Twitter account and Add that link to your Page where you want o add this link

```
<%= link_to 'Twitter Login', twitter_login_path %>
```
In Action of this routes just add following line

```
redirect_to TwitterAuthenticate.login_to_twitter_account

```
It will take user to Twitter Login page after Login it will send an callback to your application callback route
which was added while creating twitter application. 
In callback Action Will be like this 

```ruby
def callback
    user = TwitterAuthenticate.twitter_callback(params)
    @user = User.create_from_provider_data(user , 'twitter')
    if @user.persisted?
      sign_in_and_redirect @user
    else
      flash[:error] = 'There was a problem signing you in through Twitter. Please register or try signing in later.'
      redirect_to new_user_registration_url
    end
end
```

And file Add create_from_provider_data Method In User Model

```ruby
def self.create_from_provider_data(provider_data , provider)
      where(provider: provider, uid: provider_data['id']).first_or_create do | user |
        user.password = Devise.friendly_token[0, 20]
        email = "#{provider_data['screen_name']}@#{provider}.com"
        user.email = email
      end
end

```

It will create user and redirect to your logged in home

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/oauthsocial. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

