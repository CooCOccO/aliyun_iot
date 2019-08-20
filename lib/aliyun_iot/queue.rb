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
        response = Request::Xml.get("/queues", mqs_headers)
        Hash.xml_array(response, "Queues", "Queue").collect { |item| Queue.new(URI(item["QueueURL"]).path.sub!(/^\/queues\//, "")) }
      end
    end

    def initialize(name)
      @name = name
      @pk = product_key
    end

    #创建队列
    def create(opts = {})
      Request::Xml.put(queue_path) do |request|
        msg_options = {
            :VisibilityTimeout => 30,
            :DelaySeconds => 0,
            :MaximumMessageSize => 65536,
            :MessageRetentionPeriod => 345600,
            :PollingWaitSeconds => 0
        }.merge(opts)
        request.content(:Queue, msg_options)
      end
    end

    #查看消息
    def peek
      Request::Xml.get(messages_path, query: {peekonly: true})
    end

    #删除队列
    def delete
      Request::Xml.delete queue_path
    end

    #发送消息
    def send_message(message, opts = {})
      Request::Xml.post(messages_path) do |request|
        msg_options = {
            :DelaySeconds => 0,
            :Priority => 8
        }.merge(opts)
        request.content(:Message, msg_options.merge(:MessageBody => message.to_s))
      end
    end

    #消费消息
    def receive_message(wait_seconds = 3)
      result = Request::Xml.get(messages_path, query: {waitseconds: wait_seconds})
      return nil if result.nil?
      Result.new(self, result).get_message
    end
    
    #批量消费消息
    def batch_receive_message(num = 16, wait_seconds = 3)
      result = Request::Xml.get(messages_path, query: {waitseconds: wait_seconds, numOfMessages: num})
      return nil if result.nil?
      Result.new(self, result, "Messages", "Message").get_message
    end
    
    #设置队列属性
    def set_attr(opts = {})
      Request::Xml.put(queue_path, query: {Metaoverride: true}) do |request|
        request.content(:Queue, opts)
      end
    end

    #批量消费消息
    def batch_receive_message(num = 16, wait_seconds = 3)
      result = Request::Xml.get(messages_path, query: {waitseconds: wait_seconds, numOfMessages: num})
      return nil if result.nil?
      Result.new(self, result, "Messages", "Message").get_message
    end

    #设置队列属性
    def set_attr(opts = {})
      Request::Xml.put(queue_path, query: {Metaoverride: true}) do |request|
        request.content(:Queue, opts)
      end
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
