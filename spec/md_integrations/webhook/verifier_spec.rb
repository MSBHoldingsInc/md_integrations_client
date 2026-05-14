require 'spec_helper'

RSpec.describe MdIntegrations::Webhook::Verifier do
  let(:secret) { 'super-secret-webhook-key' }
  let(:payload_hash) do
    {
      timestamp: 1_700_000_000,
      event_type: 'offering_submitted',
      case_id: 'case-uuid',
      metadata: 'meta'
    }
  end
  let(:payload) { JSON.generate(payload_hash) }
  let(:valid_signature) { OpenSSL::HMAC.hexdigest('SHA256', secret, payload) }

  describe '.verify' do
    it 'returns true for a valid signature' do
      expect(described_class.verify(payload: payload, signature: valid_signature, secret: secret)).to be true
    end

    it 'returns false for a tampered payload' do
      expect(described_class.verify(payload: payload + 'x', signature: valid_signature, secret: secret)).to be false
    end

    it 'returns false for an invalid signature' do
      expect(described_class.verify(payload: payload, signature: 'deadbeef', secret: secret)).to be false
    end

    it 'returns false when secret is empty' do
      expect(described_class.verify(payload: payload, signature: valid_signature, secret: '')).to be false
    end

    it 'returns false when signature is nil' do
      expect(described_class.verify(payload: payload, signature: nil, secret: secret)).to be false
    end
  end

  describe '.construct_event' do
    it 'returns an Event when signature is valid' do
      event = described_class.construct_event(payload: payload, signature: valid_signature, secret: secret)

      expect(event).to be_a(MdIntegrations::Webhook::Event)
      expect(event.type).to eq('offering_submitted')
      expect(event.case_id).to eq('case-uuid')
      expect(event.offering_submitted?).to be true
    end

    it 'raises WebhookSignatureError when signature is invalid' do
      expect {
        described_class.construct_event(payload: payload, signature: 'bad', secret: secret)
      }.to raise_error(MdIntegrations::WebhookSignatureError)
    end

    it 'raises WebhookSignatureError when payload is not valid JSON' do
      bad_payload = 'not-json'
      sig = OpenSSL::HMAC.hexdigest('SHA256', secret, bad_payload)

      expect {
        described_class.construct_event(payload: bad_payload, signature: sig, secret: secret)
      }.to raise_error(MdIntegrations::WebhookSignatureError, /not valid JSON/)
    end

    describe 'authorization token check' do
      let(:auth_token) { 'static-auth-token-from-mdi-admin-panel' }

      it 'returns an Event when both auth_token and signature match' do
        event = described_class.construct_event(
          payload:             payload,
          signature:           valid_signature,
          secret:              secret,
          auth_token:          auth_token,
          expected_auth_token: auth_token
        )

        expect(event).to be_a(MdIntegrations::Webhook::Event)
      end

      it 'raises WebhookSignatureError when auth_token does not match' do
        expect {
          described_class.construct_event(
            payload:             payload,
            signature:           valid_signature,
            secret:              secret,
            auth_token:          'wrong-token',
            expected_auth_token: auth_token
          )
        }.to raise_error(MdIntegrations::WebhookSignatureError, /authorization token/)
      end

      it 'raises WebhookSignatureError when auth_token is missing but expected' do
        expect {
          described_class.construct_event(
            payload:             payload,
            signature:           valid_signature,
            secret:              secret,
            auth_token:          nil,
            expected_auth_token: auth_token
          )
        }.to raise_error(MdIntegrations::WebhookSignatureError, /authorization token/)
      end

      it 'verifies authorization BEFORE signature (auth failure short-circuits)' do
        # Signature is also invalid here; auth check fires first.
        expect {
          described_class.construct_event(
            payload:             payload,
            signature:           'invalid-signature',
            secret:              secret,
            auth_token:          'wrong',
            expected_auth_token: auth_token
          )
        }.to raise_error(MdIntegrations::WebhookSignatureError, /authorization token/)
      end

      it 'skips the auth check when expected_auth_token is not provided' do
        # No expected_auth_token → signature-only verification path.
        event = described_class.construct_event(
          payload:   payload,
          signature: valid_signature,
          secret:    secret
        )

        expect(event).to be_a(MdIntegrations::Webhook::Event)
      end
    end
  end
end
