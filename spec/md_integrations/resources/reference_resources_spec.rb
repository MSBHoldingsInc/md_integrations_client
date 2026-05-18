require 'spec_helper'

RSpec.describe 'Reference + catalog resources', :mdi do
  describe MdIntegrations::Resources::Diseases do
    let(:diseases) { mdi_client.diseases }

    it 'lists diseases with filters' do
      stub = stub_mdi(:get, '/partner/metadata/diseases',
                      query: { search: 'diab' },
                      response_body: { data: [] })

      diseases.list(search: 'diab')
      expect(stub).to have_been_requested
    end

    it 'finds a single disease' do
      stub = stub_mdi(:get, '/partner/metadata/diseases/d1',
                      response_body: { id: 'd1' })

      diseases.find('d1')
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::Pharmacies do
    let(:pharmacies) { mdi_client.pharmacies }

    it 'lists pharmacies' do
      stub = stub_mdi(:get, '/partner/pharmacies',
                      query: { search: 'TPH' },
                      response_body: { data: [] })

      pharmacies.list(search: 'TPH')
      expect(stub).to have_been_requested
    end

    it 'finds a pharmacy' do
      stub = stub_mdi(:get, '/partner/pharmacies/ph1',
                      response_body: { id: 'ph1' })

      pharmacies.find('ph1')
      expect(stub).to have_been_requested
    end

    it 'lists partner-linked pharmacies with default pagination' do
      stub = stub_mdi(:get, '/partner/linked-pharmacies',
                      query: { page: '1', per_page: '100' },
                      response_body: { data: [] })

      pharmacies.linked
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::DispenseUnits do
    let(:dispense_units) { mdi_client.dispense_units }

    it 'lists dispense units' do
      stub = stub_mdi(:get, '/partner/dispense-units',
                      response_body: { data: [] })

      dispense_units.list
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::Questionnaires do
    let(:questionnaires) { mdi_client.questionnaires }

    it 'lists questionnaires' do
      stub = stub_mdi(:get, '/partner/questionnaires',
                      response_body: { data: [] })

      questionnaires.list
      expect(stub).to have_been_requested
    end

    it 'finds a questionnaire' do
      stub = stub_mdi(:get, '/partner/questionnaires/q1',
                      response_body: { id: 'q1' })

      questionnaires.find('q1')
      expect(stub).to have_been_requested
    end

    it 'lists questions for a questionnaire' do
      stub = stub_mdi(:get, '/partner/questionnaires/q1/questions',
                      response_body: { data: [] })

      questionnaires.questions('q1')
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::Specialties do
    it 'lists specialties' do
      stub = stub_mdi(:get, '/partner/specialties',
                      response_body: { data: [] })

      mdi_client.specialties.list
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::Metadata do
    let(:metadata) { mdi_client.metadata }

    it 'fetches states' do
      stub = stub_mdi(:get, '/partner/metadata/states',
                      response_body: { data: [] })

      metadata.states
      expect(stub).to have_been_requested
    end

    it 'fetches cities for a state without search filter' do
      stub = stub_mdi(:get, '/partner/metadata/states/TX/cities',
                      response_body: { data: [] })

      metadata.cities('TX')
      expect(stub).to have_been_requested
    end

    it 'fetches cities with a search filter' do
      stub = stub_mdi(:get, '/partner/metadata/states/TX/cities',
                      query: { search: 'austin' },
                      response_body: { data: [] })

      metadata.cities('TX', search: 'austin')
      expect(stub).to have_been_requested
    end

    it 'looks up a zipcode' do
      stub = stub_mdi(:get, '/partner/metadata/zipcodes',
                      query: { search: '78701' },
                      response_body: { data: [] })

      metadata.zipcode_lookup('78701')
      expect(stub).to have_been_requested
    end

    it 'lists license types' do
      stub = stub_mdi(:get, '/partner/metadata/license-types',
                      response_body: { data: [] })

      metadata.license_types
      expect(stub).to have_been_requested
    end
  end
end

RSpec.describe 'People resources', :mdi do
  describe MdIntegrations::Resources::Clinicians do
    it 'finds a clinician' do
      stub = stub_mdi(:get, '/partner/clinicians/c1',
                      response_body: { id: 'c1' })

      mdi_client.clinicians.find('c1')
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::SupportStaffs do
    it 'finds a support staff' do
      stub = stub_mdi(:get, '/partner/support-staffs/s1',
                      response_body: { id: 's1' })

      mdi_client.support_staffs.find('s1')
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::InternalSupportStaffs do
    it 'finds an internal support staff' do
      stub = stub_mdi(:get, '/partner/internal-support-staffs/i1',
                      response_body: { id: 'i1' })

      mdi_client.internal_support_staffs.find('i1')
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::MedicalAssistants do
    it 'finds a medical assistant' do
      stub = stub_mdi(:get, '/partner/medical-assistants/m1',
                      response_body: { id: 'm1' })

      mdi_client.medical_assistants.find('m1')
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::Partner do
    it 'fetches the authenticated partner' do
      stub = stub_mdi(:get, '/partner',
                      response_body: { id: 'rugiet' })

      mdi_client.partner.me
      expect(stub).to have_been_requested
    end
  end
end

RSpec.describe 'Vouchers, Subscriptions, Tags, Notifications', :mdi do
  describe MdIntegrations::Resources::Vouchers do
    let(:vouchers) { mdi_client.vouchers }

    it 'lists vouchers with default expired filter' do
      stub = stub_mdi(:get, '/partner/vouchers',
                      query: { expired: '0' },
                      response_body: { data: [] })

      vouchers.list
      expect(stub).to have_been_requested
    end

    it 'finds a voucher' do
      stub = stub_mdi(:get, '/partner/vouchers/v1',
                      response_body: { id: 'v1' })

      vouchers.find('v1')
      expect(stub).to have_been_requested
    end

    it 'creates a voucher' do
      payload = { code: 'WELCOME' }
      stub = stub_mdi(:post, '/partner/vouchers',
                      request_body: payload.to_json,
                      response_body: { id: 'v1' })

      vouchers.create(payload)
      expect(stub).to have_been_requested
    end

    it 'expires a voucher' do
      stub = stub_mdi(:post, '/partner/vouchers/v1/expire',
                      response_body: { ok: true })

      vouchers.expire('v1')
      expect(stub).to have_been_requested
    end

    it 'deletes a voucher' do
      stub = stub_mdi(:delete, '/partner/vouchers/v1',
                      response_body: { ok: true })

      vouchers.delete('v1')
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::Subscriptions do
    let(:subs) { mdi_client.subscriptions }

    it 'lists with default pagination' do
      stub = stub_mdi(:get, '/partner/subscriptions',
                      query: { page: '1', per_page: '15' },
                      response_body: { data: [] })

      subs.list
      expect(stub).to have_been_requested
    end

    it 'finds a subscription' do
      stub = stub_mdi(:get, '/partner/subscriptions/sub1',
                      response_body: { id: 'sub1' })

      subs.find('sub1')
      expect(stub).to have_been_requested
    end

    it 'creates a subscription' do
      payload = { patient_id: 'p1' }
      stub = stub_mdi(:post, '/partner/subscriptions',
                      request_body: payload.to_json,
                      response_body: { id: 'sub1' })

      subs.create(payload)
      expect(stub).to have_been_requested
    end

    it 'updates a subscription' do
      payload = { status: 'paused' }
      stub = stub_mdi(:patch, '/partner/subscriptions/sub1',
                      request_body: payload.to_json,
                      response_body: { ok: true })

      subs.update('sub1', payload)
      expect(stub).to have_been_requested
    end

    it 'cancels a subscription' do
      payload = { reason: 'patient request' }
      stub = stub_mdi(:post, '/partner/subscriptions/sub1/cancel',
                      request_body: payload.to_json,
                      response_body: { ok: true })

      subs.cancel('sub1', payload)
      expect(stub).to have_been_requested
    end

    it 'deletes a subscription' do
      stub = stub_mdi(:delete, '/partner/subscriptions/sub1',
                      response_body: { ok: true })

      subs.delete('sub1')
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::Tags do
    let(:tags) { mdi_client.tags }

    it 'lists with default pagination and global type' do
      stub = stub_mdi(:get, '/partner/tags',
                      query: { page: '1', per_page: '15', type: 'global' },
                      response_body: { data: [] })

      tags.list
      expect(stub).to have_been_requested
    end

    it 'finds a tag' do
      stub = stub_mdi(:get, '/partner/tags/t1',
                      response_body: { id: 't1' })

      tags.find('t1')
      expect(stub).to have_been_requested
    end

    it 'creates a tag' do
      payload = { name: 'VIP' }
      stub = stub_mdi(:post, '/partner/tags',
                      request_body: payload.to_json,
                      response_body: { id: 't1' })

      tags.create(payload)
      expect(stub).to have_been_requested
    end

    it 'updates a tag' do
      payload = { name: 'VIP2' }
      stub = stub_mdi(:patch, '/partner/tags/t1',
                      request_body: payload.to_json,
                      response_body: { ok: true })

      tags.update('t1', payload)
      expect(stub).to have_been_requested
    end

    it 'deletes a tag' do
      stub = stub_mdi(:delete, '/partner/tags/t1',
                      response_body: { ok: true })

      tags.delete('t1')
      expect(stub).to have_been_requested
    end
  end

  describe MdIntegrations::Resources::Notifications do
    let(:notifications) { mdi_client.notifications }

    it 'lists notifications' do
      stub = stub_mdi(:get, '/partner/notifications',
                      query: { type: 'sms' },
                      response_body: { data: [] })

      notifications.list(type: 'sms')
      expect(stub).to have_been_requested
    end

    it 'finds a notification' do
      stub = stub_mdi(:get, '/partner/notifications/n1',
                      response_body: { id: 'n1' })

      notifications.find('n1')
      expect(stub).to have_been_requested
    end
  end
end
