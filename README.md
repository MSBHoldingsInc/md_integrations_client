 # md_integrations_client

  Ruby client for the [MD Integrations](https://mdintegrations.com) Partner API.

  ## Installation
  
  Add this line to your application's Gemfile:

  ```ruby
  gem 'md_integrations_client'
  ```
  
  And then execute:

  ```bash
  $ bundle install
  ```

  ## Usage

  ```ruby
  mdi = MdIntegrations::Client.new(
    client_id: ENV['MDI_CLIENT_ID'],
    client_secret: ENV['MDI_CLIENT_SECRET'],
    environment: :sandbox
  )

  # Create a patient
  mdi.patients.create(payload)

  # Create a case
  mdi.cases.create(payload)
  ```

  ## Module Structure
  
  ```ruby
  module MdIntegrations
    class Client
      # ...
    end
  end
  ```

  ## Development

  After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

  ## License
  
  Internal — Rugiet / MSB Holdings Inc.

  Just copy this whole block into README.md at the root of your repo. Adjust the license line and any internal links as needed.
