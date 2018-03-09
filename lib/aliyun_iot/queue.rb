require "aliyun_iot/request/xml"

module AliyunIot
  class Queue
    require_relative 'message'
    attr_reader :name

    delegate :to_s, to: :name
    delegate :product_key, to: :configuration

    class << self
      def [](name)
        Queue.new(name)
      end

      def queues(opts = {})
        mqs_options = {query: "x-mns-prefix", offset: "x-mns-marker", size: "x-mns-ret-number"}
        mqs_headers = opts.slice(*mqs_options.keys).reduce({}) { |mqs_headers, item| k, v = *item; mqs_headers.merge!(mqs_options[k] => v) }
        response = Request::Xml.get("/queues", mqs_headers: mqs_headers.merge({"x-mns-version" => "2015-06-06"}))
        Hash.xml_array(response, "Queues", "Queue").collect { |item| Queue.new(URI(item["QueueURL"]).path.sub!(/^\/queues\//, "")) }
      end
    end

    def initialize(name)
      @name = name
      @pk = product_key
    end

    #创建队列
    def create(opts = {})
      Request::Xml.put(queue_path, mqs_headers: {"x-mns-version" => "2015-06-06"}) do |request|
        msg_options = {
            :VisibilityTimeout => 30,
            :DelaySeconds => 0,
            :MaximumMessageSize => 65536,
            :MessageRetentionPeriod => 345600,
            :PollingWaitSeconds => 0
        }.merge(opts)
        request.content_xml(:Queue, msg_options)
      end
    end

    #查看消息
    def peek
      request_opts = {mqs_headers: {"x-mns-version" => "2015-06-06"}, query: {peekonly: true}}
      Request::Xml.get(messages_path, request_opts)
    end

    #删除队列
    def delete
      Request::Xml.delete(queue_path, mqs_headers: {"x-mns-version" => "2015-06-06"})
    end

    #发送消息
    def send_message(message, opts = {})
      Request::Xml.post(messages_path, mqs_headers: {"x-mns-version" => "2015-06-06"}) do |request|
        msg_options = {
            :DelaySeconds => 0,
            :Priority => 8
        }.merge(opts)
        request.content_xml(:Message, msg_options.merge(:MessageBody => message.to_s))
      end
    end

    #消费消息
    def receive_message(wait_seconds = nil)
      request_opts = {mqs_headers: {"x-mns-version" => "2015-06-06"}}
      request_opts.merge!(query: {waitseconds: wait_seconds}) if wait_seconds
      result = Request::Xml.get(messages_path, request_opts)
      return nil if result.nil?
      Message.new(self, result)
    end

    def queue_path
      "/queues/#{name}"
    end

    def messages_path
      "/queues/#{name}/messages"
    end

    def device_msg_path(device_name)
      "/#{pk}/#{device_name}/get"
    end

    private
    def configuration
      AliyunIot.configuration
    end

  end
end
