Pod::Spec.new do |s|
  s.name             = 'FIS'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FIS.'
  s.homepage         = 'https://github.com/brandenesmith/FIS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/FIS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'Classes/**/*'
  s.ios.vendored_frameworks = 'Frameworks/*'

  s.resource_bundles = {
    'FIS' => ['Assets/*.{xib,png}']
  }
end
