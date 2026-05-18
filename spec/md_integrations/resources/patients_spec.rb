require 'spec_helper'

RSpec.describe MdIntegrations::Resources::Patients, :mdi do
  let(:patients)   { mdi_client.patients }
  let(:patient_id) { 'pat-uuid-1' }

  describe '#create' do
    it 'POSTs to /v1/partner/patients' do
      payload = { first_name: 'John', last_name: 'Doe', email: 'j@d.co' }
      stub = stub_mdi(:post, '/v1/partner/patients',
                      request_body: payload.to_json,
                      response_body: { id: patient_id })

      expect(patients.create(payload)).to eq('id' => patient_id)
      expect(stub).to have_been_requested
    end
  end

  describe '#update' do
    it 'PATCHes /v1/partner/patients/:id' do
      payload = { address: { city_name: 'Austin' } }
      stub = stub_mdi(:patch, "/v1/partner/patients/#{patient_id}",
                      request_body: payload.to_json,
                      response_body: { id: patient_id })

      patients.update(patient_id, payload)
      expect(stub).to have_been_requested
    end
  end

  describe '#find' do
    it 'GETs /v1/partner/patients/:id' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}",
                      response_body: { id: patient_id })

      expect(patients.find(patient_id)).to include('id' => patient_id)
      expect(stub).to have_been_requested
    end
  end

  describe '#search' do
    it 'POSTs to /v1/partner/patients/search with filters' do
      filters = { email: 'j@d.co' }
      stub = stub_mdi(:post, '/v1/partner/patients/search',
                      request_body: filters.to_json,
                      response_body: { data: [] })

      patients.search(filters)
      expect(stub).to have_been_requested
    end
  end

  describe '#cases' do
    it 'GETs /v1/partner/patients/:id/cases with params' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/cases",
                      query: { status: 'completed' },
                      response_body: { data: [] })

      patients.cases(patient_id, status: 'completed')
      expect(stub).to have_been_requested
    end
  end

  describe '#events' do
    it 'GETs /v1/partner/patients/:id/events with default pagination' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/events",
                      query: { page: '1', per_page: '50' },
                      response_body: { data: [] })

      patients.events(patient_id)
      expect(stub).to have_been_requested
    end
  end

  describe 'workflow URLs' do
    it 'GETs drivers-license' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/drivers-license",
                      query: { fullscreen: 'true' },
                      response_body: { url: 'https://x' })

      patients.drivers_license_url(patient_id)
      expect(stub).to have_been_requested
    end

    it 'GETs intro-video' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/intro-video",
                      query: { fullscreen: 'true' },
                      response_body: { url: 'https://x' })

      patients.intro_video_url(patient_id)
      expect(stub).to have_been_requested
    end

    it 'GETs messaging auth url with case_id when given' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/auth",
                      query: { full: 'true', fullscreen: 'true', case_id: 'c1' },
                      response_body: { url: 'https://x' })

      patients.messaging_app_url(patient_id, case_id: 'c1')
      expect(stub).to have_been_requested
    end

    it 'GETs file-url' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/file-url",
                      query: { fullscreen: 'true' },
                      response_body: { url: 'https://x' })

      patients.file_request_url(patient_id)
      expect(stub).to have_been_requested
    end
  end

  describe 'preferred pharmacies' do
    it 'lists preferred pharmacies' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/pharmacies",
                      query: { sort: 'updated_at', order: 'desc' },
                      response_body: { data: [] })

      patients.preferred_pharmacies(patient_id)
      expect(stub).to have_been_requested
    end

    it 'POSTs to add a preferred pharmacy' do
      stub = stub_mdi(:post, "/v1/partner/patients/#{patient_id}/pharmacies/ph1",
                      response_body: { ok: true })

      patients.add_preferred_pharmacy(patient_id, 'ph1')
      expect(stub).to have_been_requested
    end

    it 'DELETEs to remove a preferred pharmacy' do
      stub = stub_mdi(:delete, "/v1/partner/patients/#{patient_id}/pharmacies/ph1",
                      response_body: { ok: true })

      patients.remove_preferred_pharmacy(patient_id, 'ph1')
      expect(stub).to have_been_requested
    end
  end

  describe '2FA' do
    it 'sends an OTP' do
      payload = { patient_id: patient_id }
      stub = stub_mdi(:post, '/partner/patients/auth/2fa',
                      request_body: payload.to_json,
                      response_body: { ok: true })

      patients.send_otp(payload)
      expect(stub).to have_been_requested
    end

    it 'validates an OTP' do
      payload = { patient_id: patient_id, otp: '123456' }
      stub = stub_mdi(:post, '/partner/patients/auth/2fa/validate',
                      request_body: payload.to_json,
                      response_body: { ok: true })

      patients.validate_otp(payload)
      expect(stub).to have_been_requested
    end
  end

  describe 'exams' do
    it 'lists exams' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/exams",
                      response_body: { data: [] })

      patients.exams(patient_id)
      expect(stub).to have_been_requested
    end

    it 'fetches a single exam' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/exams/ex1",
                      response_body: { id: 'ex1' })

      patients.exam(patient_id, 'ex1')
      expect(stub).to have_been_requested
    end
  end

  describe '#vouchers' do
    it 'GETs /v1/partner/patients/:id/vouchers' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/vouchers",
                      response_body: { data: [] })

      patients.vouchers(patient_id)
      expect(stub).to have_been_requested
    end
  end

  describe 'DoseSpot' do
    it 'fetches formulary coverage' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/dosespot/formulary",
                      query: { ndc: '00000-0000-00' },
                      response_body: { data: [] })

      patients.dosespot_coverage(patient_id, ndc: '00000-0000-00')
      expect(stub).to have_been_requested
    end

    it 'fetches medications history' do
      stub = stub_mdi(:get, "/v1/partner/patients/#{patient_id}/dosespot/medications/history",
                      response_body: { data: [] })

      patients.dosespot_medications_history(patient_id)
      expect(stub).to have_been_requested
    end
  end

  describe 'tags' do
    it 'attaches a tag' do
      stub = stub_mdi(:post, "/v1/partner/patients/#{patient_id}/tags/tag1",
                      response_body: { ok: true })

      patients.attach_tag(patient_id, 'tag1')
      expect(stub).to have_been_requested
    end

    it 'detaches a tag' do
      stub = stub_mdi(:delete, "/v1/partner/patients/#{patient_id}/tags/tag1",
                      response_body: { ok: true })

      patients.detach_tag(patient_id, 'tag1')
      expect(stub).to have_been_requested
    end

    it 'updates a tag note' do
      payload = { note: 'VIP' }
      stub = stub_mdi(:patch, "/v1/partner/patients/#{patient_id}/tags/tag1",
                      request_body: payload.to_json,
                      response_body: { ok: true })

      patients.update_tag_note(patient_id, 'tag1', payload)
      expect(stub).to have_been_requested
    end
  end

  describe '#subscriptions' do
    it 'GETs /partner/patients/:id/subscriptions with default pagination' do
      stub = stub_mdi(:get, "/partner/patients/#{patient_id}/subscriptions",
                      query: { page: '1', per_page: '15' },
                      response_body: { data: [] })

      patients.subscriptions(patient_id)
      expect(stub).to have_been_requested
    end
  end

  describe 'compliance / GDPR' do
    it 'requests data with patient_email' do
      payload = { patient_email: 'j@d.co' }
      stub = stub_mdi(:post, '/partner/patients/data',
                      request_body: payload.to_json,
                      response_body: { ok: true })

      patients.request_data(patient_email: 'j@d.co')
      expect(stub).to have_been_requested
    end

    it 'requests data deletion' do
      stub = stub_mdi(:delete, "/v1/partner/patients/#{patient_id}",
                      response_body: { ok: true })

      patients.request_data_deletion(patient_id)
      expect(stub).to have_been_requested
    end
  end
end
