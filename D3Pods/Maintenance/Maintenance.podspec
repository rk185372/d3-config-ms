Pod::Spec.new do |s|
  s.name             = 'Maintenance'
  s.version          = '0.1.0'
  s.summary          = 'Maintenance models and services for d3-next-ios'
  s.homepage         = 'https://github.com/watt/Maintenance'
  s.author           = { 'watt' => 'awatt@d3banking.com' }
  s.source           = { :git => 'https://github.com/watt/Maintenance.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'Maintenance/Classes/**/*'
  s.resource_bundles = {
    'Maintenance' => ['Maintenance/Assets/**/*.{storyboard,xib,xcassets,jpg,png,json}']
  }

  s.dependency 'ComponentKit'
  s.dependency 'Navigation'
  s.dependency 'Network'
  s.dependency 'PodHelper'
  s.dependency 'RxSwift'
  s.dependency 'Utilities'
  s.dependency 'Analytics'
end
