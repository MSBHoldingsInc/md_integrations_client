require 'openssl'
require 'json'

module MdIntegrations
  module Webhook
    # Verifies MDI webhook deliveries. Every MDI webhook arrives with two
    # security headers, both of which MUST be validated:
    #
    #   1. `Authorization`  — the static token you configured in the MDI Admin
    #      Panel when registering the webhook. Verify with constant-time string
    #      equality against the value you registered.
    #
    #   2. `Signature`      — HMAC-SHA256 of the raw JSON body, computed with
    #      the Secret Key you registered. Per MDI's docs, computed as:
    #          $signature = hash_hmac('sha256', json_encode(payload), secret);
    #
    # `construct_event` performs both checks (Authorization first since it's
    # cheaper and acts as a first line of defense). Use it as the single entry
    # point from a Rails controller:
    #
    #   event = MdIntegrations::Webhook::Verifier.construct_event(
    #     payload:              request.raw_post,
    #     signature:            request.headers['Signature'],
    #     auth_token:           request.headers['Authorization'],
    #     secret:               Rails.application.credentials.dig(:mdi, :webhook_secret),
    #     expected_auth_token:  Rails.application.credentials.dig(:mdi, :webhook_auth_token)
    #   )
    #
    # If either check fails, a `WebhookSignatureError` is raised — respond with
    # `head :unauthorized`. Note: MDI does not include a timestamp/nonce, so
    # replay protection beyond TLS + signature + static token is not possible
    # at this layer.
    class Verifier
      ALGORITHM = 'SHA256'.freeze

      class << self
        # Signature-only verification. Returns true/false. Useful when the
        # Authorization header is enforced at a different layer (e.g. an API
        # gateway). Prefer `construct_event` for the full check.
        def verify(payload:, signature:, secret:)
          return false if payload.to_s.empty? || signature.to_s.empty? || secret.to_s.empty?

          expected = compute_signature(payload, secret)
          secure_compare(expected, signature)
        end

        def construct_event(payload:, signature:, secret:, auth_token: nil, expected_auth_token: nil)
          verify_auth_token!(auth_token, expected_auth_token) if expected_auth_token

          unless verify(payload: payload, signature: signature, secret: secret)
            raise WebhookSignatureError, 'Invalid MDI webhook signature'
          end

          Event.new(JSON.parse(payload))
        rescue JSON::ParserError => e
          raise WebhookSignatureError, "Webhook payload is not valid JSON: #{e.message}"
        end

        private

        def verify_auth_token!(received, expected)
          if received.to_s.empty? || !secure_compare(received.to_s, expected.to_s)
            raise WebhookSignatureError, 'Invalid MDI webhook authorization token'
          end
        end

        def compute_signature(payload, secret)
          OpenSSL::HMAC.hexdigest(ALGORITHM, secret, payload)
        end

        # Constant-time comparison to prevent timing attacks.
        def secure_compare(a, b)
          return false if a.bytesize != b.bytesize

          l = a.unpack("C#{a.bytesize}")
          res = 0
          b.each_byte { |byte| res |= byte ^ l.shift }
          res.zero?
        end
      end
    end
  end
end
