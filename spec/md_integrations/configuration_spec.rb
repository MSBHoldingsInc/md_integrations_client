require 'spec_helper'

RSpec.describe MdIntegrations::Configuration do
  let(:valid_args) do
    { client_id: 'id', client_secret: 'secret', environment: :sandbox }
  end

  describe '#initialize' do
    it 'defaults base_url to MDI production host (v1)' do
      config = described_class.new(**valid_args)
      expect(config.base_url).to eq('https://api.mdintegrations.com/v1')
    end

    it 'accepts an explicit base_url override' do
      config = described_class.new(**valid_args, base_url: 'https://staging.example.com')
      expect(config.base_url).to eq('https://staging.example.com')
    end

    it 'raises ConfigurationError when client_id is missing' do
      expect {
        described_class.new(**valid_args.merge(client_id: ''))
      }.to raise_error(MdIntegrations::ConfigurationError, /client_id/)
    end

    it 'raises ConfigurationError when client_secret is missing' do
      expect {
        described_class.new(**valid_args.merge(client_secret: nil))
      }.to raise_error(MdIntegrations::ConfigurationError, /client_secret/)
    end

    it 'raises ConfigurationError for unknown environment' do
      expect {
        described_class.new(**valid_args.merge(environment: :staging))
      }.to raise_error(MdIntegrations::ConfigurationError, /Unknown environment/)
    end
  end

  describe '#sandbox? / #production?' do
    it 'reflects the environment' do
      sandbox = described_class.new(**valid_args)
      production = described_class.new(**valid_args.merge(environment: :production))

      expect(sandbox.sandbox?).to be true
      expect(sandbox.production?).to be false
      expect(production.production?).to be true
    end
  end
end
