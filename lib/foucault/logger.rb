module Foucault

  class Logger

    FILTERS = ["password"]

    def call(level, message)
      logger.send(level, filtered(message)) if ( logger && logger.respond_to?(level) )
    end

    private

    def logger
      @logger ||= configuration.config.logger
    end

    def filtered(msg)
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
