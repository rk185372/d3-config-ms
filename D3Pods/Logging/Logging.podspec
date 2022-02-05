Pod::Spec.new do |s|
  s.name             = 'Logging'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Logging.'
  s.homepage         = 'https://github.com/brandenesmith/Logging'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/Logging.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.watchos.deployment_target = '5.0'
  s.static_framework = true

  s.source_files = 'Logging/Classes/**/*'
  s.ios.source_files = 'Logging/iOS/Classes/**/*'
  
  s.ios.dependency 'Firebase/Crashlytics'
  s.dependency 'SwiftyBeaver'
end
