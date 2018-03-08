module AliyunIot
  module Request
    class HttpClient
      attr_reader :base
      def initialize(base)
        @base = RestClient::Resource.new base
      end

      [:get, :delete, :put, :post].each do |m|
        define_method m do |*args, &block|
          begin
            re = base.send *[m, args[0], args[1]].compact
          rescue RestClient::NotFound => ex
            return nil
          rescue RestClient::Exception => ex
            logger = Logger.new(STDOUT)
            logger.error ex.message
            logger.error ex.backtrace.join("\n")
            raise ex
          end
        end
      end

    end
  end
end
