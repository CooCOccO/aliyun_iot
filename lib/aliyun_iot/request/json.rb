require 'base64'
require 'securerandom'
require_relative 'http_client'

module AliyunIot
  module Request
    class Json
      attr_reader :url, :method, :body, :params, :client
      delegate :access_key_id, :access_key_secret, :base_url, :region_id, to: :configuration

      class << self
        [:get, :delete, :put, :post].each do |m|
          define_method m do |*args, &block|
            options = {method: m, params: args[0]}
            request = Request::Json.new(options)
            request.execute
          end
        end
      end

      def initialize(method: "post", params: {})
        @params = params
        @method = method
        @client = HttpClient.new(base_url)
      end

      def execute
        ts = Time.now.utc.strftime('%FT%TZ')
        base_params = {
            Format: 'JSON',
            Version: '2018-01-20',
            AccessKeyId: access_key_id,
            SignatureMethod: 'HMAC-SHA1',
            Timestamp: ts,
            SignatureVersion: '1.0',
            SignatureNonce: SecureRandom.uuid,
            RegionId: region_id,
            ServiceCode: 'iot',
        }
        exec_params = encode base_params.merge!(params)
        begin
          JSON.parse client.send(method, exec_params).body
        rescue => e
          logger = Logger.new(STDOUT)
          logger.error e.message
          logger.error e.backtrace.join("\n")
          raise e
        end
      end

      private

      def configuration
        AliyunIot.configuration
      end

      def encode(encode_params)
        str = ERB::Util.url_encode(encode_params.to_param)
        string_to_sign = "#{method.upcase}&%2F&#{str}"
        sign = Base64.encode64(OpenSSL::HMAC.digest("sha1", "#{access_key_secret}&", string_to_sign)).chop
        encode_params.merge({ Signature: sign })
      end

    end
  end
end
