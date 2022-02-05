Pod::Spec.new do |s|
  s.name             = 'Navigation'
  s.version          = '0.1.0'
  s.summary          = 'Navigation models and services for d3-next-ios'
  s.homepage         = 'https://github.com/watt/Navigation'
  s.author           = { 'watt' => 'awatt@d3banking.com' }
  s.source           = { :git => 'https://github.com/watt/Navigation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'Navigation/Classes/**/*'
  s.resource_bundles = {
    'Navigation' => ['Navigation/Assets/**/*.{storyboard,xib,xcassets,jpg,png,json}']
  }

  s.dependency 'Utilities'
  s.dependency 'RxSwift'
end
