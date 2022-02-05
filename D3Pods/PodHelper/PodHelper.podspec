Pod::Spec.new do |s|
  s.name             = 'PodHelper'
  s.version          = '0.1.0'
  s.summary          = 'A short description of PodHelper.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/ccarranzaD3/PodHelper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/PodHelper.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.3'
  s.swift_version = '4.2'
  s.source_files = 'PodHelper/Classes/**/*'
end
