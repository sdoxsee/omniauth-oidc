# OmniAuth OpenID Connect Strategy

Strategy to authenticate with OpenID Connect in OmniAuth.

Example config in config/initializers/omniauth.rb:
```
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :oidc, Settings.openid_connect.client_id, Settings.openid_connect.client_secret, {
    :name => :your_oidc_provider,
    :client_options => {
      :site => 'https://yourOidcProvider.com/',
    }
  }
end
```
