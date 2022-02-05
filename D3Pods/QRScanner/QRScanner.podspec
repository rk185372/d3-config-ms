Pod::Spec.new do |s|
  s.name             = 'QRScanner'
  s.version          = '0.1.0'
  s.summary          = 'A short description of QRScanner.'
  s.homepage         = 'https://github.com/brandenesmith/QRScanner'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/QRScanner.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true

  s.source_files = 'QRScanner/Classes/**/*'
  
  s.resource_bundles = {
    'QRScanner' => ['QRScanner/Assets/*.{xib,png}']
  }

  s.dependency 'PodHelper'
  s.dependency 'ComponentKit'
  
end
