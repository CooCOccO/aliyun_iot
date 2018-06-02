require "aliyun_iot/request/json"

module AliyunIot
  include ERB::Util

  class Product
    attr_reader :key
    delegate :to_s, to: :key

    class << self
      def [](key)
        Product.new(key)
      end

      def create(name)
        params = { Name: name }
        execute params, 'CreateProduct'
      end

      def check_regist_state(apply_id)
        params = { ApplyId: apply_id }
        execute params, 'QueryApplyStatus'
      end

      def list_regist_info(apply_id, page_size, current_page)
        params = { ApplyId: apply_id, PageSize: page_size, CurrentPage: current_page }
        execute params, 'QueryPageByApplyId'
      end

      def execute(params = {}, actiont)
        Request::Json.post(params.merge({ Action: actiont }))
      end
    end

    def initialize(key)
      @key = key
    end

    def update(params = {})
      execute params, 'UpdateProduct'
    end

    def list(params = {})
      execute params, 'QueryDevice'
    end

    def regist_device(params = {})
      execute params, 'RegistDevice'
    end

    def regist_devices(params = {})
      execute params, 'ApplyDeviceWithNames'
    end
    
    def device_state(params = {})
      execute params, 'GetDeviceStatus'
    end

    def pub(params = {})
      raise RequestException.new(Exception.new("message MessageContent is empty!")) if params[:MessageContent].nil?
      default_params = { Qos: '0' }
      default_params.merge!({ Qos: '0' }) if params[:Qos].nil?
      params[:MessageContent] = Base64.urlsafe_encode64(params[:MessageContent]).chomp
      execute params.merge(default_params), 'Pub'
    end

    def sub(params = {})
      execute params, 'Sub'
    end

    def rrpc(params = {})
      execute params, 'RRpc'
    end

    private

    def execute(res_params, action)
      Request::Json.post(res_params.merge({ ProductKey: @key, Action: action }))
    end
  end
end
