Pod::Spec.new do |s|
  s.name             = 'Offline'
  s.version          = '0.1.0'
  s.summary          = 'Offline models and services for d3-next-ios'
  s.homepage         = 'https://github.com/watt/Offline'
  s.author           = { 'watt' => 'awatt@d3banking.com' }
  s.source           = { :git => 'https://github.com/watt/Offline.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'Offline/Classes/**/*'
  s.resource_bundles = {
    'Offline' => ['Offline/Assets/**/*.{storyboard,xib,xcassets,jpg,png,json}']
  }

  s.dependency 'RxSwift'
  s.dependency 'RxRelay'

  s.dependency 'AppConfiguration'
  s.dependency 'ComponentKit'
  s.dependency 'PodHelper'
  s.dependency 'Logging'
  s.dependency 'Network'
  s.dependency 'Utilities'
end
