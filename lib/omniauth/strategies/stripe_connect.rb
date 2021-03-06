require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class StripeConnect < OmniAuth::Strategies::OAuth2
      option :name, 'stripe_connect'

      option :client_options, {
        :site => 'https://connect.stripe.com'
      }

      option :authorize_options, [:scope]

      uid { raw_info[:stripe_user_id] }

      info do
        {
          :scope => raw_info[:scope],
          :livemode => raw_info[:livemode],
          :stripe_publishable_key => raw_info[:stripe_publishable_key]
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        @raw_info ||= deep_symbolize(access_token.params)
      end

      def build_access_token
        headers = {
          :headers => {
            'Authorization' => "Bearer #{client.secret}"
          }
        }
        verifier = request.params['code']
        client.auth_code.get_token(verifier, {:redirect_uri => callback_url}.merge(token_params.to_hash(:symbolize_keys => true)).merge(headers))
      end

      alias :old_request_phase :request_phase
      def request_phase
        options[:authorize_params].merge!(
          :stripe_landing => session["omniauth.params"]["stripe_landing"],
          :stripe_user => session["omniauth.params"]["stripe_user"]
        )
        p options
        old_request_phase
      end
    end
  end
end
