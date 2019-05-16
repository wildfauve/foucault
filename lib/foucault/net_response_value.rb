module Foucault

  class NetResponseValue < Dry::Struct

    FAIL                 = :fail
    OK                   = :ok
    UNAUTHORISED         = :unauthorised
    NOT_FOUND            = :not_found
    SYSTEM_FAILURE       = :system_failure
    UNPROCESSABLE_ENTITY = :unprocessable_entity

    NET_STATUS           = Types::Strict::Symbol.enum(OK, FAIL, UNAUTHORISED, NOT_FOUND, SYSTEM_FAILURE, UNPROCESSABLE_ENTITY)

    attribute :status,          NET_STATUS
    attribute :code,            Types::Integer.optional
    attribute :body,            Types::Class

  end

end
