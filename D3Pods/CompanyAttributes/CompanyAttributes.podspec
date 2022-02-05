Pod::Spec.new do |s|
  s.name             = 'CompanyAttributes'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CompanyAttributes.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/CompanyAttributes'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/CompanyAttributes.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.watchos.deployment_target = '5.0'
  s.swift_version = '4.2'
  s.source_files = 'CompanyAttributes/Classes/**/*'

  s.dependency 'RxRelay'
end
