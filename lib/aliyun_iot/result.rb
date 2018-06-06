module AliyunIot
  class Result
    
    attr_reader :h, :queue
    
    def initialize(queue, content, *path)
      @queue = queue
      @h = path.blank? ? Hash.xml_object(content, "Message") : Hash.xml_array(content, *path)
    end
    
    def get_message
      h.is_a?(Array) ? h.map{ |message| Message.new(queue, message) } : Message.new(queue, h)
    end

  end
end
