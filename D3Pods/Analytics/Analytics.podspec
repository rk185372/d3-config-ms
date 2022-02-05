Pod::Spec.new do |s|
  s.name             = 'Analytics'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Analytics.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/Analytics'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/Analytics.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.source_files = 'Analytics/Classes/**/*'
  s.dependency 'Aspects', '1.4.1'
end
