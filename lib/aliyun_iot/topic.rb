require "aliyun_iot/request/xml"

module AliyunIot
  include ERB::Util

  class Topic
    attr_reader :name, :subscription_name
    delegate :to_s, to: :name

    class << self
      def [](name, subscription_name = nil)
        Topic.new(name, subscription_name)
      end

      def topics(opts = {})
        mqs_options = {query: "x-mns-prefix", offset: "x-mns-marker", size: "x-mns-ret-number"}
        mqs_headers = opts.slice(*mqs_options.keys).reduce({}) { |mqs_headers, item| k, v = *item; mqs_headers.merge!(mqs_options[k] => v) }
        response = Request::Xml.get("/topics", mqs_headers: mqs_headers.merge({"x-mns-version" => "2015-06-06"}))
        Hash.xml_array(response, "Topics", "Topic").collect { |item| Topic.new(URI(item["TopicURL"]).path.sub!(/^\/topics\//, "")) }
      end
    end

    def initialize(name, subscription_name = nil)
      @name = name
      @subscription_name = subscription_name
    end

    #创建topic
    def create(opts={})
      Request::Xml.put(topic_path, mqs_headers: {"x-mns-version" => "2015-06-06"}) do |request|
        msg_options = {
            MaximumMessageSize: 65536
        }.merge(opts)
        request.content :Topic, msg_options
      end
    end

    # 删除topic
    def delete
      Request::Xml.delete(topic_path, mqs_headers: {"x-mns-version" => "2015-06-06"})
    end

    # 获取topic属性
    def get_topic_attributes
      topic_hash = Hash.from_xml(Request::Xml.get(topic_path, mqs_headers: {"x-mns-version" => "2015-06-06"}))
      {
          topic_name: topic_hash["Topic"]["TopicName"],
          create_time: topic_hash["Topic"]["CreateTime"],
          last_modify_time: topic_hash["Topic"]["LastModifyTime"],
          maximum_message_size: topic_hash["Topic"]["MaximumMessageSize"],
          message_retention_period: topic_hash["Topic"]["MessageRetentionPeriod"],
          message_ount: topic_hash["Topic"]["MessageCount"],
          logging_enabled: topic_hash["Topic"]["LoggingEnabled"]
      }

    end

    #订阅topic
    def subscribe(opts = {})
      if opts[:Endpoint].nil? || opts[:Endpoint].blank?
        raise Request::XmlException.new(Exception.new("subscribe parameters invalid"))
      else
        Request::Xml.put(subscribe_path, mqs_headers: {"x-mns-version" => "2015-06-06"}) do |request|
          request.content(:Subscription, opts)
        end
      end
    end

    #退订topic
    def unsubscribe
      Request::Xml.delete(subscribe_path, mqs_headers: {"x-mns-version" => "2015-06-06"})
    end

    #发布消息
    def publish_message(opts = {})
      if opts[:MessageBody].nil? || opts[:MessageBody].blank?
        raise Exception.new("publish message parameters invalid")
      else
        Request::Xml.post(message_path, mqs_headers: {"x-mns-version" => "2015-06-06"}) do |request|
          request.content(:Message, opts)
        end
      end
    end

    private

    def topic_path
      "/topics/#{name}"
    end

    def subscribe_path
      "/topics/#{name}/subscriptions/#{subscription_name}"
    end

    def message_path
      "/topics/#{name}/messages"
    end

  end
end
