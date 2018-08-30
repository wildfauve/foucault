require "foucault/version"
require 'dry/monads/result'
require 'dry/monads/maybe'
require 'dry-struct'
require 'dry-types'
require 'dry-configurable'
require 'fn'
require 'nokogiri'
require 'ruby-kafka'
require 'zk'


module Types
  include Dry::Types.module
end

module Foucault
  require 'foucault/logger'
  require 'foucault/logging'

  require 'foucault/net'
  require 'foucault/circuit'
  require 'foucault/configuration'
  require 'foucault/http_connection'
  require 'foucault/http_port'
  require 'foucault/net_response_value'

  require 'foucault/kafka_connection'
  require 'foucault/kafka_brokers'
  require 'foucault/kafka_port'

  Fn = Fn::Fn
  M = Dry::Monads
end
