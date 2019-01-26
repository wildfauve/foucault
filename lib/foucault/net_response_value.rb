module Foucault

  class NetResponseValue < Dry::Struct

    FAIL                 = :fail
    OK                   = :ok
    UNAUTHORISED         = :unauthorised
    SYSTEM_FAILURE       = :system_failure
    UNPROCESSABLE_ENTITY = :unprcessable_entity
    NET_STATUS       = Types::Strict::Symbol.enum(OK, FAIL, UNAUTHORISED, SYSTEM_FAILURE)

    attribute :status,          NET_STATUS
    attribute :code,            Types::Integer.optional
    attribute :body,            Types::Class

  end

end
