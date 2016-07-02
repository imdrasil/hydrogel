module Hydrogel
  class Config
    DEFAULTS = {
        host: 'http://localhost',
        port: 9200,
        per_page: 10,
        many_size: 1_000,
        default_operator: :must
    }.freeze

    class << self
      attr_accessor :host, :port, :per_page
      attr_reader :base_url

      def reset
        DEFAULTS.each do |attr, value|
          instance_variable_set("@#{attr}", value)
        end
      end

      def host=(value)
        @host = value
        reset_base_url
      end

      def port=(value)
        @port = value
        reset_base_url
      end

      def default_operator=(value)
        temp_value = value.to_sym
        raise ArgumentError, "Default operator cant be #{temp_value}" unless Hydrogel::Query::ALL_OPS.include?(value)
        @default_operator = temp_value
      end

      private

      def reset_base_url
        @base_url = "#{@host}:#{@port}"
      end
    end

    reset
  end
end
