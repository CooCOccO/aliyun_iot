module AliyunIot
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Install support files'
      source_root File.expand_path('../templates', __FILE__)

      def copy_config
        template 'config/aliyun_iot.yml'
      end

    end
  end
end
