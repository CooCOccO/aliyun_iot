
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "aliyun_iot/version"

Gem::Specification.new do |spec|
  spec.name          = "aliyun_iot"
  spec.version       = AliyunIot::VERSION
  spec.authors       = ["CooCOccO"]
  spec.email         = ["garrus1118@qq.com"]

  spec.summary       = '阿里云物联网套件ruby sdk'
  spec.description   = 'Aliyun IoT sdk'
  spec.homepage      = "https://github.com/CooCOccO/aliyun_iot"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activesupport', '>= 3.2', '<= 7.0'
  spec.add_runtime_dependency 'nokogiri', '>= 1.10.4'
  spec.add_runtime_dependency "rest-client", '>= 1.8.0'
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
