# md_integrations_client

Ruby client for the [MD Integrations](https://mdintegrations.com) Partner API. Internal Rugiet wrapper that covers patients, cases, offerings, messages, files, and webhook signature verification.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'md_integrations_client', git: 'https://github.com/MSBHoldingsInc/md_integrations_client.git'
```

Then run:

```bash
$ bundle install
```

## Configuration

```ruby
mdi = MdIntegrations::Client.new(
  client_id:     ENV['MDI_CLIENT_ID'],
  client_secret: ENV['MDI_CLIENT_SECRET'],
  environment:   :sandbox # or :production
)
```

MDI uses the **same base URL** (`https://api.mdintegrations.com`) for both sandbox and production — environment is determined by which credentials you authenticate with.

If you need to point at a different host (testing against a mock), pass `base_url:`:

```ruby
mdi = MdIntegrations::Client.new(
  client_id:     'x',
  client_secret: 'y',
  base_url:      'https://my-mock-server.example.com'
)
```

## Usage

> Payload examples below are taken directly from MD Integrations' Postman collection (Partners > Patients/Cases/Messages/Files). Field names and example values are reproduced as-is from MDI's documentation.

### Patients

```ruby
mdi.patients.create(
  prefix:        'Sr',
  ssn:           '111223333',
  first_name:    'John',
  middle_name:   'Harry',
  last_name:     'Doe',
  gender:        1,
  date_of_birth: '1983-10-17',
  phone_number:  '(816) 679-2211',
  phone_type:    2,
  metadata:      'patient number 200',
  email:         'john@doe.com',
  address: {
    address:    '9071 E. Mississippi Ave',
    address2:   'Apt 6C',
    zip_code:   '80247',
    city_name:  'Tazlima',
    state_name: 'Ohio'
  },
  pregnancy:           false,
  special_necessities: 'Example of a text',
  is_sms_enabled:      true,
  is_email_enabled:    true,
  metafields: [
    { key: 'smoke',       title: 'Does the patient smoke??', value: 'false', type: 'boolean' },
    { key: 'internal_id', title: 'Patient internal ID',      value: 'id-522', type: 'string'  }
  ]
)

mdi.patients.update(patient_id, address: { city_name: 'Tazlima', state_name: 'Ohio' })
mdi.patients.find(patient_id)
```

### Cases

```ruby
mdi.cases.create(
  hold_status:                   false,
  patient_id:                    'a0299125-9d2e-4d73-831f-9f94d5950e86',
  metadata:                      'case number 15',
  is_chargeable:                 true,
  is_additional_approval_needed: true,
  case_files: [],
  case_offerings: [
    {
      offering_id: 'dbcc21c5-53d4-4da2-8cf6-7156563a035c',
      product: {
        dispense_unit:  'tablet',
        pharmacy_notes: 'Notes for the pharmacy.',
        quantity:       4,
        days_supply:    2,
        directions:     'One per day.'
      }
    }
  ],
  case_questions: [
    {
      question:       'Are you pregnant?',
      answer:         'false',
      type:           'boolean',
      important:      true,
      is_critical:    true,
      display_in_pdf: true
    }
  ],
  diseases: [{ disease_id: '32f62f6e-32b7-4145-a375-15a2bd8b8dfa' }],
  tags:     [{ tag_id:     '7366f5c7-9ec4-48c6-a377-f5b4fb3ca6b8' }]
)

# Follow-up / renewal — same payload as Create case, plus `reference_case_id`.
mdi.cases.create_follow_up(
  reference_case_id: 'original-case-uuid',
  patient_id:        'a0299125-9d2e-4d73-831f-9f94d5950e86',
  case_offerings:    [{ offering_id: 'dbcc21c5-53d4-4da2-8cf6-7156563a035c' }]
)
```

### Messages

```ruby
mdi.messages.send_message(
  patient_id: '8e1cb3f5-23ae-465b-9f5d-929b11f97e98',
  channel:    MdIntegrations::Resources::Messages::CHANNEL_PATIENT,
  text:       'Message text.',
  reference_message_id: 'ce36bba7-3932-4197-9d92-4565a890edf8',
  files: [
    { id: 'e30e5ecb-a543-4877-a483-0a1b065bbc59' },
    { id: '3f7b155c-c235-476c-9688-3fa7c1d59ed2' }
  ],
  sender_type: 'patient'
)
```

### Files (upload)

```ruby
File.open('800px-Sunflower_from_Silesia2.jpg', 'rb') do |f|
  mdi.files.upload(
    io:           f,
    filename:     '800px-Sunflower_from_Silesia2.jpg',
    content_type: 'image/jpeg',
    name:         'face - left side',
    type:         MdIntegrations::Resources::Files::TYPE_LAB_RESULT
  )
end
```

### Webhook verification

Per MDI's docs, every webhook delivery includes two security headers and both must be validated:

- `Authorization` — the static token you registered in the MDI Admin Panel.
- `Signature` — `hash_hmac('sha256', json_encode(payload), secret)` computed with the Secret Key you registered.

`construct_event` validates both in a single call (Authorization first as a cheap first line of defense, then the HMAC signature). If either check fails it raises `MdIntegrations::WebhookSignatureError`.

```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :mdi

  def mdi
    event = MdIntegrations::Webhook::Verifier.construct_event(
      payload:             request.raw_post,
      signature:           request.headers['Signature'],
      auth_token:          request.headers['Authorization'],
      secret:              Rails.application.credentials.dig(:mdi, :webhook_secret),
      expected_auth_token: Rails.application.credentials.dig(:mdi, :webhook_auth_token)
    )

    case event.type
    when MdIntegrations::Webhook::EventTypes::OFFERING_SUBMITTED
      OfferingFulfillmentJob.perform_later(event.case_id)
    when MdIntegrations::Webhook::EventTypes::CASE_CANCELLED
      CaseCancelledNotifier.call(event.case_id)
    end

    head :ok
  rescue MdIntegrations::WebhookSignatureError
    head :unauthorized
  end
end
```

If you handle the `Authorization` token at a different layer (e.g. an API gateway) you can omit `auth_token:` / `expected_auth_token:` and the gem will only verify the HMAC signature — but doing both in the gem is strongly recommended.

## Authentication

Token management is fully handled by the gem:

- OAuth2 `client_credentials` grant — sends `grant_type`, `client_id`, `client_secret`, `scope: "*"` (all required by MDI)
- Tokens cached in memory per-process (thread-safe via `Mutex`)
- Honors `expires_in` from the auth response (currently 86400s / 24 hours per MDI)
- Refreshes proactively `REFRESH_BUFFER_SECONDS` (2 hours) before expiry
- Automatic retry on 401 with a fresh token

Tune the buffer in `MdIntegrations::Auth::TokenManager::REFRESH_BUFFER_SECONDS` if MDI changes their recommendation.

## Error Handling

All API errors are raised as typed subclasses of `MdIntegrations::Error`:

| Status | Exception |
|--------|-----------|
| 400    | `BadRequestError`     |
| 401    | `AuthenticationError` |
| 403    | `ForbiddenError`      |
| 404    | `NotFoundError`       |
| 418    | `MaintenanceError`    |
| 422    | `ValidationError`     |
| 429    | `RateLimitError`      |
| 5xx    | `ServerError`         |
| —      | `NetworkError` (timeouts / connection failures) |
| —      | `WebhookSignatureError` |

Each `APIError` exposes `#status` and `#body` for debugging.

## Idempotency and safe retries

The gem's built-in **401 auto-retry is safe** — a 401 means MDI's auth layer rejected the request before any business logic ran, so no MDI-side record was created. The retry produces exactly one side effect.

What the gem does **not** retry automatically is `NetworkError` (timeouts and connection failures). On a write that fails mid-flight, MDI may or may not have already processed the request — we don't know. If your caller (e.g. a Sidekiq job) retries on `NetworkError`, you must make the operation idempotent yourself, because MDI does **not** support idempotency keys.

Recommended pattern: pass your internal identifier as the `metadata` field on creation, and check before re-creating on retry.

```ruby
class CreateMdiCaseJob < ApplicationJob
  retry_on MdIntegrations::NetworkError,
           MdIntegrations::RateLimitError,
           MdIntegrations::ServerError, wait: :exponentially_longer

  discard_on MdIntegrations::ValidationError

  def perform(rugiet_order_id, payload)
    # Dedup check: did a previous attempt already create the case at MDI?
    existing = MDI.cases.by_status(
      MdIntegrations::Resources::Cases::STATUS_CREATED,
      metadata: rugiet_order_id
    )['data']&.first

    return existing['case_id'] if existing

    MDI.cases.create(payload.merge(metadata: rugiet_order_id))
  end
end
```

The same applies to patients (`metadata` field), orders (use your internal order ID), and any other write. Reads (GET) are naturally idempotent — retry freely.

## Development

```bash
bin/setup
bundle exec rspec
```

Run `bin/console` for an interactive Pry session with the gem loaded.

## Smoke test against MDI sandbox

To verify your credentials work end-to-end without writing any test data, hit the `metadata.states` reference endpoint — it requires auth but is read-only and has no side effects:

```bash
MDI_CLIENT_ID=... MDI_CLIENT_SECRET=... bundle exec ruby -e '
require "md_integrations_client"
mdi = MdIntegrations::Client.new(
  client_id:     ENV["MDI_CLIENT_ID"],
  client_secret: ENV["MDI_CLIENT_SECRET"],
  environment:   :sandbox
)
states = mdi.metadata.states
puts "OK: #{states.size} states returned (#{states.count { |s| s["is_sync"] }} sync, #{states.count { |s| s["is_av_flow"] }} AV-flow)"
'
```

Successful output looks like `OK: 115 states returned (5 sync, 11 AV-flow)`. Any auth/network failure will raise the corresponding typed error.

## Releasing

Bump the version in `lib/md_integrations/version.rb`, update `CHANGELOG.md`, tag the commit, and push the gem to the internal RubyGems source (GitHub Packages).

## License

Internal — Rugiet / MSB Holdings Inc.
