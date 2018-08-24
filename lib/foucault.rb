require "foucault/version"
require 'dry/monads/result'
require 'dry-configurable'
require 'stoplight'
require 'fn'

module Foucault
  require './lib/foucault/logger'
  require './lib/foucault/logging'

  require './lib/foucault/net'
  require './lib/foucault/circuit'
  require './lib/foucault/configuration'

  Fn = Fn::Fn
  M = Dry::Monads
end
