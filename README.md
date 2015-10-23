# OmniAuth OpenID Connect Strategy

Strategy to authenticate with OpenID Connect in OmniAuth largely based a generalized implementation of https://github.com/zquestz/omniauth-google-oauth2

Apologies that tests and documentation are sparse. If you have questions, create an issue. Thanks!

Example config in config/initializers/omniauth.rb:
```
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :oidc, Settings.openid_connect.client_id, Settings.openid_connect.client_secret, {
    :name => :your_oidc_provider,
    :scope => 'openid profile email offline_access',
    :client_options => {
      :site => 'https://yourOidcProvider.com/',
      :authorize_url => 'connect/authorize',
      :token_url => 'connect/token',
      :userinfo_url => 'connect/userinfo'
    }
  }
end
```
