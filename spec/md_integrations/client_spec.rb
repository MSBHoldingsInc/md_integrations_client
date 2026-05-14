require 'spec_helper'

RSpec.describe MdIntegrations::Client do
  let(:client) do
    described_class.new(
      client_id: 'cid',
      client_secret: 'csecret',
      environment: :sandbox
    )
  end

  ACCESSORS = {
    patients:                MdIntegrations::Resources::Patients,
    cases:                   MdIntegrations::Resources::Cases,
    offerings:               MdIntegrations::Resources::Offerings,
    orders:                  MdIntegrations::Resources::Orders,
    messages:                MdIntegrations::Resources::Messages,
    files:                   MdIntegrations::Resources::Files,
    diseases:                MdIntegrations::Resources::Diseases,
    pharmacies:              MdIntegrations::Resources::Pharmacies,
    dispense_units:          MdIntegrations::Resources::DispenseUnits,
    questionnaires:          MdIntegrations::Resources::Questionnaires,
    specialties:             MdIntegrations::Resources::Specialties,
    metadata:                MdIntegrations::Resources::Metadata,
    clinicians:              MdIntegrations::Resources::Clinicians,
    support_staffs:          MdIntegrations::Resources::SupportStaffs,
    internal_support_staffs: MdIntegrations::Resources::InternalSupportStaffs,
    medical_assistants:      MdIntegrations::Resources::MedicalAssistants,
    partner:                 MdIntegrations::Resources::Partner,
    vouchers:                MdIntegrations::Resources::Vouchers,
    subscriptions:           MdIntegrations::Resources::Subscriptions,
    tags:                    MdIntegrations::Resources::Tags,
    notifications:           MdIntegrations::Resources::Notifications
  }.freeze

  describe 'resource accessors' do
    ACCESSORS.each do |method, klass|
      it "exposes ##{method} as #{klass}" do
        expect(client.public_send(method)).to be_a(klass)
      end
    end
  end

  it 'memoizes resource instances' do
    expect(client.patients.object_id).to eq(client.patients.object_id)
    expect(client.cases.object_id).to eq(client.cases.object_id)
  end

  it 'raises ConfigurationError when client_id is blank' do
    expect {
      described_class.new(client_id: '', client_secret: 'x')
    }.to raise_error(MdIntegrations::ConfigurationError)
  end
end
