Pod::Spec.new do |s|
  s.name             = 'LocalizationData'
  s.version          = '0.1.0'
  s.summary          = 'A short description of LocalizationData.'
  s.homepage         = 'https://github.com/brandenesmith/LocalizationData'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/LocalizationData.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'LocalizationData/Classes/**/*'
  
  s.resource_bundles = {
    'LocalizationData' => ['LocalizationData/Assets/*.{json}']
  }

  s.dependency 'PodHelper'
end
