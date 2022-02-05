Pod::Spec.new do |s|
  s.name             = 'DeviceInfoService'
  s.version          = '0.1.0'
  s.summary          = 'A short description of DeviceInfoService.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/DeviceInfoService'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/DeviceInfoService.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'DeviceInfoService/Classes/**/*'
  s.dependency 'Network'
  s.dependency 'Utilities'
  s.dependency 'RxSwift'
  s.dependency 'RxRelay'
end
