require 'multi_json'
require 'jwt'
require 'omniauth/strategies/oauth2'
require 'addressable/uri'

module OmniAuth
  module Strategies
    class Oidc < OmniAuth::Strategies::OAuth2

      option :skip_jwt, false
      option :authorize_options, [:access_type, :hd, :login_hint, :prompt, :request_visible_actions, :scope, :state, :redirect_uri, :include_granted_scopes, :openid_realm]
      option :scope, "openid email profile address offline_access"

      option :client_options, {
        :site          => 'https://op.com/',
        :authorize_url => 'authorize',
        :token_url     => 'token',
        :userinfo_url  => 'userinfo',
        :introspection_url => 'introspect'
      }

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end

          params[:scope] = options[:scope]

          session['omniauth.state'] = params[:state] if params['state']
        end
      end

      uid { raw_info['sub'] || verified_email }

      info do
        prune!({
          :name       => raw_info['name'],
          :email      => raw_info['email'],
          :first_name => raw_info['given_name'],
          :last_name  => raw_info['family_name']
        })
      end

      extra do
        hash = {}
        hash[:id_token] = access_token['id_token']
        if !options[:skip_jwt] && !access_token['id_token'].nil?
          hash[:id_info] = JWT.decode(
            access_token['id_token'], nil, false, {
              :verify_iss => true,
              'iss' => options[:client_options][:site],
              :verify_aud => true,
              'aud' => options.client_id,
              :verify_sub => false,
              :verify_expiration => true,
              :verify_not_before => true,
              :verify_iat => true,
              :verify_jti => false
            }).first
        end
        hash[:raw_info] = raw_info unless skip_info?
        prune! hash
      end

      def raw_info
        @raw_info ||= access_token.get(options[:client_options][:site] + options[:client_options][:userinfo_url]).parsed
      end

      def custom_build_access_token
        if request.xhr? && request.params['code']
          verifier = request.params['code']
          client.auth_code.get_token(verifier, get_token_options('postmessage'), deep_symbolize(options.auth_token_params || {}))
        elsif request.params['code'] && request.params['redirect_uri']
          verifier = request.params['code']
          redirect_uri = request.params['redirect_uri']
          client.auth_code.get_token(verifier, get_token_options(redirect_uri), deep_symbolize(options.auth_token_params || {}))
        elsif verify_token(request.params['id_token'], request.params['access_token'])
          ::OAuth2::AccessToken.from_hash(client, request.params.dup)
        else
          orig_build_access_token
        end
      end
      alias_method :orig_build_access_token, :build_access_token
      alias_method :build_access_token, :custom_build_access_token

      private

      def callback_url
        full_host + script_name + callback_path
      end
      
      def get_token_options(redirect_uri)
        { :redirect_uri => redirect_uri }.merge(token_params.to_hash(:symbolize_keys => true))
      end

      def prune!(hash)
        hash.delete_if do |_, v|
          prune!(v) if v.is_a?(Hash)
          v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end

      def verified_email
        raw_info['email_verified'] ? raw_info['email'] : nil
      end

      def strip_unnecessary_query_parameters(query_values)
        # strip `sz` parameter (defaults to sz=50) which overrides `image_size` options
        return nil unless query_values

        query_hash = query_values.delete_if { |key, value| key == "sz" }

        # an empty Hash would cause a ? character in the URL: http://image.url?
        return nil if query_hash.empty?

        query_hash
      end

      def verify_token(id_token, access_token)
        return false unless (id_token && access_token)

        raw_response = client.request(:get, options[:client_options][:site] + options[:client_options][:introspection_url], :params => {
          :id_token => id_token,
          :access_token => access_token
        }).parsed
        raw_response['issued_to'] == options.client_id
      end
    end
  end
end
