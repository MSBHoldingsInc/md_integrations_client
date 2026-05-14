require 'spec_helper'

RSpec.describe MdIntegrations::Resources::Orders, :mdi do
  let(:orders)   { mdi_client.orders }
  let(:case_id)  { 'case-1' }
  let(:order_id) { 'order-1' }

  it 'lists orders on a case' do
    stub = stub_mdi(:get, "/partner/cases/#{case_id}/orders",
                    response_body: { data: [] })

    orders.list(case_id)
    expect(stub).to have_been_requested
  end

  it 'lists order events with default pagination' do
    stub = stub_mdi(:get, "/partner/cases/#{case_id}/orders/#{order_id}/events",
                    query: { page: '1', per_page: '15' },
                    response_body: { data: [] })

    orders.events(case_id, order_id)
    expect(stub).to have_been_requested
  end

  it 'submits an order with tracking payload' do
    payload = { tracking_number: '1Z999' }
    stub = stub_mdi(:post, "/partner/cases/#{case_id}/orders/#{order_id}/submit",
                    request_body: payload.to_json,
                    response_body: { ok: true })

    orders.submit(case_id, order_id, payload)
    expect(stub).to have_been_requested
  end

  it 'cancels an order' do
    payload = { reason: 'patient cancelled' }
    stub = stub_mdi(:post, "/partner/cases/#{case_id}/orders/#{order_id}/cancel",
                    request_body: payload.to_json,
                    response_body: { ok: true })

    orders.cancel(case_id, order_id, payload)
    expect(stub).to have_been_requested
  end

  it 'updates an order' do
    payload = { notes: 'shipped' }
    stub = stub_mdi(:patch, "/partner/cases/#{case_id}/orders/#{order_id}",
                    request_body: payload.to_json,
                    response_body: { ok: true })

    orders.update(case_id, order_id, payload)
    expect(stub).to have_been_requested
  end
end
