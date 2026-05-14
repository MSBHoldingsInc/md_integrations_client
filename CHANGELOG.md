# Changelog

## [Unreleased]

### Added
- `MdIntegrations::Client` entry point with sandbox/production environment switching (MDI uses the same base URL for both — environment is determined by which credentials authenticate).
- OAuth2 `client_credentials` token manager with 24-hour TTL, 22-hour proactive refresh, random jitter (0–60s) to avoid lockstep refresh across processes, and reactive single-retry on 401.
- Webhook verifier validates BOTH security headers MDI sends per its docs: the static `Authorization` token (constant-time compare against the value you registered in MDI's Admin Panel) AND the `Signature` HMAC-SHA256 over the raw body. `construct_event` does both checks in one call (Authorization first as a cheap first line of defense). Plus `Event` parser + `EventTypes` constants for the canonical MDI status lifecycle.
- Typed error hierarchy: `BadRequestError`, `AuthenticationError`, `ForbiddenError`, `NotFoundError`, `MaintenanceError`, `ValidationError`, `RateLimitError`, `ServerError`, `NetworkError`, `WebhookSignatureError`.
- Resources (20):
  - **Core integration:** Patients, Cases, Offerings, Orders, Messages, Files.
  - **Reference/catalog:** Diseases, Pharmacies, DispenseUnits, Questionnaires, Specialties, Metadata.
  - **People:** Clinicians, SupportStaffs, InternalSupportStaffs, MedicalAssistants, Partner.
  - **Other:** Vouchers, Subscriptions, Tags, Notifications.
- RSpec test suite with WebMock — 162 examples covering every resource, plus auth, configuration, connection logger hygiene, and webhook verifier.
- Proprietary `LICENSE.txt` (all rights reserved, MSB Holdings Inc.).

### Security / log hygiene
- Auth-failure exceptions no longer interpolate the raw `response.body`; only the human-readable `message`/`error` is surfaced.
- Faraday logger middleware redacts `Authorization: "Bearer <token>"` headers and suppresses request/response bodies — passing `logger: Rails.logger` is safe with PHI in flight.
- Auth Faraday connection deliberately attaches no logger so the `client_secret` (in the request body) and `access_token` (in the response body) never reach application logs.

### Fixed
- Token endpoint corrected from `/partner/auth/token` to `/v1/partner/auth/token` after live-API validation against MDI sandbox.
- `Connection#post_multipart` now wraps Faraday timeouts / connection failures as `NetworkError` and retries once on 401 with a fresh token — previously raw `Faraday::*` exceptions could leak through file-upload calls and stale tokens were not auto-recovered for multipart.
- `Auth::TokenManager#fetch_new_token!` now wraps Faraday network errors as `NetworkError` — previously a network failure during auth could raise a raw `Faraday::ConnectionFailed` outside the typed-error contract.

### Validated
- End-to-end auth flow + `GET /v1/partner/metadata/states` confirmed against MDI sandbox: 115 states returned with `is_sync` / `is_av_flow` flags.
