require 'spec_helper'

RSpec.describe MdIntegrations::Resources::Offerings, :mdi do
  let(:offerings) { mdi_client.offerings }
  let(:case_id)   { 'case-1' }
  let(:offer_id)  { 'offer-1' }

  describe 'case-scoped' do
    it 'lists offerings on a case' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/offerings",
                      response_body: { data: [] })

      offerings.list_for_case(case_id)
      expect(stub).to have_been_requested
    end

    it 'finds a single offering on a case' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/offerings/#{offer_id}",
                      response_body: { id: offer_id })

      offerings.find_on_case(case_id, offer_id)
      expect(stub).to have_been_requested
    end

    it 'creates an offering on a case' do
      payload = { offering_id: 'cat-1' }
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/offerings",
                      request_body: payload.to_json,
                      response_body: { id: offer_id })

      offerings.create_on_case(case_id, payload)
      expect(stub).to have_been_requested
    end

    it 'updates an offering on a case' do
      payload = { quantity: 2 }
      stub = stub_mdi(:patch, "/partner/cases/#{case_id}/offerings/#{offer_id}",
                      request_body: payload.to_json,
                      response_body: { ok: true })

      offerings.update_on_case(case_id, offer_id, payload)
      expect(stub).to have_been_requested
    end

    it 'deletes an offering on a case' do
      stub = stub_mdi(:delete, "/partner/cases/#{case_id}/offerings/#{offer_id}",
                      response_body: { ok: true })

      offerings.delete_on_case(case_id, offer_id)
      expect(stub).to have_been_requested
    end

    it 'updates statuses for all case offerings' do
      statuses = [{ id: offer_id, status: 'approved' }]
      stub = stub_mdi(:patch, "/partner/cases/#{case_id}/offerings/status",
                      request_body: { statuses: statuses }.to_json,
                      response_body: { ok: true })

      offerings.update_statuses(case_id, statuses)
      expect(stub).to have_been_requested
    end
  end

  describe 'catalog' do
    it 'lists offerings with optional filters' do
      stub = stub_mdi(:get, '/partner/offerings',
                      query: { specialty_id: 'spec-1' },
                      response_body: { data: [] })

      offerings.list(specialty_id: 'spec-1')
      expect(stub).to have_been_requested
    end
  end
end
