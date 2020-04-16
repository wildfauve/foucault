require "bundler/setup"
require "foucault"
require 'pry'

M = Dry::Monads
Fn = Funcify::Fn

class TestLogger
  def debug(msg); puts msg; end
  def info(msg); puts msg; end
  def error(msg); puts msg; end
end

Foucault::Configuration.configure do |config|
  config.logger = TestLogger.new
  config.logging_level = :info
end


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
