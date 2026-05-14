require 'bundler/setup'
require 'md_integrations_client'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = '.rspec_status'
end
