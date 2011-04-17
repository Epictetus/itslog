module Itslog
  module BufferedLoggerExtension
    extend ActiveSupport::Concern
    attr_accessor :namespace

    def namespace
      @namespace ||= 'unknown'
    end

    def add_with_format(severity, message = nil, progname = nil, &block)
      return if @level > severity
      colors = ["\e[36m","\e[32m","\e[33m","\e[31m","\e[31m","\e[37m"]
      time   = Time.now.to_s(:db)

      msg = ''
      msg << colors[severity]
      msg << "#{time.split.first} " unless Rails.env.development? || Rails.env.test?
      msg << "#{time.split.last} "
      msg << "#{namespace}: "
      msg << colors[5]
      msg << message.strip

      add_without_format(severity, msg, progname, &block)
    end

    included do
      alias_method_chain :add, :format
    end
  end

  module LogSubscriberExtension
    extend ActiveSupport::Concern

    def call_with_namespace(message, *args)
      logger.namespace = message.split('.').last if logger
      call_without_namespace(message, *args)
    end

    included do
      puts '~> itslog enabled'
      alias_method_chain :call, :namespace
    end
  end
end
