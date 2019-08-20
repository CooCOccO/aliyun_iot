require "aliyun_iot/request/xml"
module AliyunIot
  class Message
    attr_reader :h, :queue, :id, :body_md5, :body, :receipt_handle, :enqueue_at, :first_enqueue_at, :next_visible_at, :dequeue_count, :priority

    def initialize(queue, h)
      @h = h
      @queue = queue
      set_message_info
    end

    #删除消息
    def delete
      check_receipt_handle
      data = set_data({ReceiptHandle: receipt_handle})
      Request::Xml.delete(queue.messages_path, data)
    end

    #修改消息可见时间
    def change_visibility(seconds)
      check_receipt_handle
      data = set_data({ReceiptHandle: receipt_handle, VisibilityTimeout: seconds})
      Request::Xml.put(queue.messages_path, data)
    end

    def get_data
      data = JSON.parse(Base64.decode64 body)
    end

    def to_s
      s = {
          "队列" => queue.name,
          "ID" => id,
          "MD5" => body_md5,
          "Receipt handle" => receipt_handle,
          "Enqueue at" => enqueue_at,
          "First enqueue at" => first_enqueue_at,
          "Next visible at" => next_visible_at,
          "Dequeue count" => dequeue_count,
          "Priority" => priority
      }.collect { |k, v| "#{k}: #{v}" }

      sep = "\n=============================================>"
      s.unshift sep
      s << sep
      s << body
      puts s.join("\n")
    end

    private
    
    def set_message_info
      @id = h["MessageId"]
      @body_md5 = h["MessageBodyMD5"]
      @body = h["MessageBody"]
      @enqueue_at = Time.at(h["EnqueueTime"].to_i/1000.0)
      @first_enqueue_at = Time.at(h["FirstDequeueTime"].to_i/1000.0)
      @dequeue_count = h["DequeueCount"].to_i
      @priority = h["Priority"].to_i
      @receipt_handle = h["ReceiptHandle"]
      @next_visible_at = Time.at(h["NextVisibleTime"].to_i/1000.0)      
    end

    def set_data(query)
      {mqs_headers: {"x-mns-version" => "2015-06-06"}, query: query}
    end

    def check_receipt_handle
      raise "No receipt handle for this operation" unless receipt_handle
    end
  end
end
