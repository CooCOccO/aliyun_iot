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
        warn "WARNING: Product.list_regist_info is deprecated. Please, use Product.query_page_by_apply_id instead"
        query_page_by_apply_id(apply_id, page_size, current_page)
      end

      def query_page_by_apply_id(apply_id, page_size, current_page)
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
      execute params, 'RegisterDevice'
    end

    def query_device_detail_by_name(device_name)
      execute({DeviceName: device_name}, 'QueryDeviceDetail')
    end

    def regist_devices(params = {})
      warn "WARNING: Product#regist_devices is deprecated. Please, use Product#batch_check_device_names instead"
      batch_check_device_names params
    end

    def batch_check_device_names(params = {})
      execute params, 'BatchCheckDeviceNames'
    end

    def batch_register_device_with_apply_id(apply_id)
      execute({ApplyId: apply_id}, 'BatchRegisterDeviceWithApplyId')
    end

    def query_batch_register_status(apply_id)
      execute({ApplyId: apply_id}, 'QueryBatchRegisterDeviceStatus')
    end

    def pub(params = {})
      raise ParamsError, "message MessageContent is empty!" if params[:MessageContent].nil?
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
