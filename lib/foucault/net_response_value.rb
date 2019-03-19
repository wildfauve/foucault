module Foucault

  class NetResponseValue < Dry::Struct

    FAIL                 = :fail
    OK                   = :ok
    UNAUTHORISED         = :unauthorised
    SYSTEM_FAILURE       = :system_failure
    UNPROCESSABLE_ENTITY = :unprocessable_entity
    
    NET_STATUS           = Types::Strict::Symbol.enum(OK, FAIL, UNAUTHORISED, SYSTEM_FAILURE, UNPROCESSABLE_ENTITY)

    attribute :status,          NET_STATUS
    attribute :code,            Types::Integer.optional
    attribute :body,            Types::Class

  end

end
