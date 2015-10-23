# OmniAuth OpenID Connect Strategy

Strategy to authenticate with OpenID Connect in OmniAuth largely based a generalized implementation of https://github.com/zquestz/omniauth-google-oauth2. I had been using https://github.com/jjbohn/omniauth-openid-connect but it hadn't been updated in a while and each release was giving me trouble. This gem doesn't do discovery or anything fancy but it'll get back your id_token, access_token, and refresh_token...which is what I needed.

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
