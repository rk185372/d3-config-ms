Pod::Spec.new do |s|
  s.name             = 'Messages'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Messages.'
  s.homepage         = 'https://github.com/brandenesmith/Messages'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/Messages.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'Messages/Classes/**/*'
  s.dependency 'Network'
  s.dependency 'Session'
end
