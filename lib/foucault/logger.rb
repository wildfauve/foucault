module Foucault

  class Logger

    FILTERS = ["password"]

    def call(level, message)
      logger.send(level, filtered(message)) if ( logger && logger.respond_to?(level) )
    end

    def configured_logger
      logger
    end

    private

    def logger
      @logger ||= configuration.config.logger
    end

    def filtered(msg)
      return unless msg.instance_of?(String)
      filters = FILTERS.map { |f| msg.downcase.include? f }
      if filters.any?
        "[FILTERED]"
      else
        msg
      end
    end

    def configuration
      Configuration
    end

  end

end
