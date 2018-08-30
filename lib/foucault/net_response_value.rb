module Foucault

  class NetResponseValue < Dry::Struct

    FAIL             = :fail
    OK               = :ok
    UNAUTHORISED     = :unauthorised
    SYSTEM_FAILURE   = :system_failure
    NET_STATUS       = Types::Strict::Symbol.enum(OK, FAIL, UNAUTHORISED, SYSTEM_FAILURE)

    attribute :status,          NET_STATUS
    attribute :body,            Types::Class

  end

end
