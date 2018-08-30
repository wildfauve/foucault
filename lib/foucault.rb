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
  require './lib/foucault/logger'
  require './lib/foucault/logging'

  require './lib/foucault/net'
  require './lib/foucault/circuit'
  require './lib/foucault/configuration'
  require './lib/foucault/http_connection'
  require './lib/foucault/http_port'
  require './lib/foucault/net_response_value'

  require './lib/foucault/kafka_connection'
  require './lib/foucault/kafka_brokers'
  require './lib/foucault/kafka_port'

  Fn = Fn::Fn
  M = Dry::Monads
end
