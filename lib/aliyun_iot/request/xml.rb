require 'base64'
require_relative 'http_client'
module AliyunIot
  module Request

    class RequestException < Exception
      attr_reader :content
      delegate :[], to: :content

      def initialize(ex)
        @content = Hash.xml_object(ex.to_s, "Error")
      rescue
        @content = {"Message" => ex.message}
      end
    end

    class Xml
      attr_reader :uri, :method, :body, :content_md5, :content_type, :content_length, :mqs_headers, :client
      delegate :access_key_id, :access_key_secret, :end_point, to: :configuration
      class << self
        [:get, :delete, :put, :post].each do |m|
          define_method m do |*args, &block|
            options = {method: m, path: args[0], mqs_headers: {}, query: {}}
            options.merge!(args[1]) if args[1].is_a?(Hash)

            request = Request::Xml.new(options)
            block.call(request) if block
            request.execute
          end
        end
      end

      def initialize(method: "get", path: "/", mqs_headers: {}, query: {})
        conf = {
            host: end_point,
            path: path
        }
        conf.merge!(query: query.to_query) unless query.empty?
        @uri = URI::HTTP.build(conf)
        @method = method
        @client = HttpClient.new(@uri.to_s)
        @mqs_headers = mqs_headers.merge("x-mns-version" => "2015-06-06")
      end

      def content(type, values={})
        ns = "http://mns.aliyuncs.com/doc/v1/"
        builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.send(type.to_sym, xmlns: ns) do |b|
            values.each { |k, v| b.send k.to_sym, v }
          end
        end
        @body = builder.to_xml
        @content_md5 = Base64::encode64(Digest::MD5.hexdigest(body)).chop
        @content_length = body.size
        @content_type = "text/xml;charset=utf-8"
      end

      def execute
        date = DateTime.now.httpdate
        headers = {
            "Authorization" => authorization(date),
            "Content-Length" => content_length || 0,
            "Content-Type" => content_type,
            "Content-MD5" => content_md5,
            "Date" => date,
            "Host" => uri.host
        }.merge(mqs_headers).reject { |k, v| v.nil? }
        client.send *[method, body, headers].compact
      end

      private

      def configuration
        AliyunIot.configuration
      end

      def authorization(date)
        canonical_resource = [uri.path, uri.query].compact.join("?")
        canonical_mq_headers = mqs_headers.sort.collect { |k, v| "#{k.downcase}:#{v}" }.join("\n")
        method = self.method.to_s.upcase
        signature = [method, content_md5 || "", content_type || "", date, canonical_mq_headers, canonical_resource].join("\n")
        sha1 = OpenSSL::HMAC.digest("sha1", access_key_secret, signature)
        "MNS #{access_key_id}:#{Base64.encode64(sha1).chop}"
      end

    end
  end
end
