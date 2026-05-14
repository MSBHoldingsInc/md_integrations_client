require 'spec_helper'

RSpec.describe MdIntegrations::Resources::Cases, :mdi do
  let(:cases)   { mdi_client.cases }
  let(:case_id) { 'case-uuid-1' }

  describe '#create' do
    it 'POSTs to /partner/cases' do
      payload = { patient_id: 'p1', questionnaire_id: 'q1', case_offerings: [{ offering_id: 'o1' }] }
      stub = stub_mdi(:post, '/partner/cases',
                      request_body: payload.to_json,
                      response_body: { id: case_id })

      expect(cases.create(payload)).to include('id' => case_id)
      expect(stub).to have_been_requested
    end
  end

  describe '#find' do
    it 'GETs /partner/cases/:id' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}",
                      response_body: { id: case_id })

      cases.find(case_id)
      expect(stub).to have_been_requested
    end
  end

  describe '#by_status' do
    it 'POSTs to /partner/cases/status/:status' do
      filters = { case_type: 'New' }
      stub = stub_mdi(:post, '/partner/cases/status/completed',
                      request_body: filters.to_json,
                      response_body: { data: [] })

      cases.by_status(described_class::STATUS_COMPLETED, filters)
      expect(stub).to have_been_requested
    end
  end

  describe '#status_count' do
    it 'GETs /partner/statistics/count/cases-by-status' do
      stub = stub_mdi(:get, '/partner/statistics/count/cases-by-status',
                      query: { from: '2026-01-01' },
                      response_body: { created: 5 })

      cases.status_count(from: '2026-01-01')
      expect(stub).to have_been_requested
    end
  end

  describe '#create_follow_up' do
    it 'POSTs to /partner/cases with reference_case_id merged in' do
      stub = stub_mdi(:post, '/partner/cases',
                      request_body: {
                        patient_id: 'p1',
                        questionnaire_id: 'q1',
                        reference_case_id: 'prior-case'
                      }.to_json,
                      response_body: { id: case_id })

      cases.create_follow_up(
        reference_case_id: 'prior-case',
        patient_id: 'p1',
        questionnaire_id: 'q1'
      )
      expect(stub).to have_been_requested
    end
  end

  describe 'status transitions' do
    it 'cancels a case' do
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/cancel",
                      request_body: { reason: 'x' }.to_json,
                      response_body: { ok: true })

      cases.cancel(case_id, reason: 'x')
      expect(stub).to have_been_requested
    end

    it 'sends a case to support' do
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/support",
                      response_body: { ok: true })

      cases.send_to_support(case_id)
      expect(stub).to have_been_requested
    end

    it 'marks a case assigned' do
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/assigned",
                      response_body: { ok: true })

      cases.set_assigned(case_id)
      expect(stub).to have_been_requested
    end

    it 'sends a case to processing' do
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/processing",
                      response_body: { ok: true })

      cases.send_to_processing(case_id)
      expect(stub).to have_been_requested
    end

    it 'updates hold status via PATCH' do
      stub = stub_mdi(:patch, "/partner/cases/#{case_id}/status",
                      request_body: { hold_status: true }.to_json,
                      response_body: { ok: true })

      cases.update_hold_status(case_id, hold: true)
      expect(stub).to have_been_requested
    end

    it 'lists status history' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/statuses",
                      response_body: { data: [] })

      cases.statuses(case_id)
      expect(stub).to have_been_requested
    end

    it 'lists case events with default pagination' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/events",
                      query: { page: '1', per_page: '50' },
                      response_body: { data: [] })

      cases.events(case_id)
      expect(stub).to have_been_requested
    end
  end

  describe 'files' do
    it 'lists case files' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/files",
                      response_body: { data: [] })

      cases.files(case_id)
      expect(stub).to have_been_requested
    end

    it 'PATCHes the full file set' do
      stub = stub_mdi(:patch, "/partner/cases/#{case_id}/files",
                      request_body: { files: %w[f1 f2] }.to_json,
                      response_body: { ok: true })

      cases.update_files(case_id, %w[f1 f2])
      expect(stub).to have_been_requested
    end

    it 'attaches a single file' do
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/files/f1",
                      response_body: { ok: true })

      cases.attach_file(case_id, 'f1')
      expect(stub).to have_been_requested
    end

    it 'detaches a single file' do
      stub = stub_mdi(:delete, "/partner/cases/#{case_id}/files/f1",
                      response_body: { ok: true })

      cases.detach_file(case_id, 'f1')
      expect(stub).to have_been_requested
    end
  end

  describe 'diseases' do
    it 'lists diseases' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/diseases",
                      response_body: { data: [] })

      cases.diseases(case_id)
      expect(stub).to have_been_requested
    end

    it 'attaches diseases' do
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/diseases",
                      request_body: { diseases: %w[d1 d2] }.to_json,
                      response_body: { ok: true })

      cases.attach_diseases(case_id, %w[d1 d2])
      expect(stub).to have_been_requested
    end

    it 'detaches a disease' do
      stub = stub_mdi(:delete, "/partner/cases/#{case_id}/diseases/d1",
                      response_body: { ok: true })

      cases.detach_disease(case_id, 'd1')
      expect(stub).to have_been_requested
    end

    it 'sets a primary disease' do
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/diseases/d1/primary",
                      response_body: { ok: true })

      cases.set_primary_disease(case_id, 'd1')
      expect(stub).to have_been_requested
    end
  end

  describe 'notes' do
    it 'lists notes' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/notes",
                      response_body: { data: [] })

      cases.notes(case_id)
      expect(stub).to have_been_requested
    end

    it 'creates a note' do
      payload = { note: 'hello' }
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/notes",
                      request_body: payload.to_json,
                      response_body: { id: 'n1' })

      cases.create_note(case_id, payload)
      expect(stub).to have_been_requested
    end
  end

  describe 'questions' do
    it 'lists questions' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/questions",
                      response_body: { data: [] })

      cases.questions(case_id)
      expect(stub).to have_been_requested
    end

    it 'posts a question' do
      payload = { question: 'why?' }
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/questions",
                      request_body: payload.to_json,
                      response_body: { id: 'q1' })

      cases.post_question(case_id, payload)
      expect(stub).to have_been_requested
    end
  end

  describe 'tags' do
    it 'attaches a tag' do
      stub = stub_mdi(:post, "/partner/cases/#{case_id}/tags/t1",
                      response_body: { ok: true })

      cases.attach_tag(case_id, 't1')
      expect(stub).to have_been_requested
    end

    it 'detaches a tag' do
      stub = stub_mdi(:delete, "/partner/cases/#{case_id}/tags/t1",
                      response_body: { ok: true })

      cases.detach_tag(case_id, 't1')
      expect(stub).to have_been_requested
    end

    it 'updates a tag note' do
      payload = { note: 'VIP' }
      stub = stub_mdi(:patch, "/partner/cases/#{case_id}/tags/t1",
                      request_body: payload.to_json,
                      response_body: { ok: true })

      cases.update_tag_note(case_id, 't1', payload)
      expect(stub).to have_been_requested
    end

    it 'lists historical tags' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/tags/historical",
                      response_body: { data: [] })

      cases.historical_tags(case_id)
      expect(stub).to have_been_requested
    end
  end

  describe 'PDFs' do
    it 'fetches services PDF' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/pdf",
                      response_body: { url: 'https://x' })

      cases.services_pdf(case_id)
      expect(stub).to have_been_requested
    end

    it 'fetches offerings PDF' do
      stub = stub_mdi(:get, "/partner/cases/#{case_id}/offerings/pdf",
                      response_body: { url: 'https://x' })

      cases.offerings_pdf(case_id)
      expect(stub).to have_been_requested
    end
  end
end
