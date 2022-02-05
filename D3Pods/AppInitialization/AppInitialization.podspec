Pod::Spec.new do |s|
  s.name             = 'AppInitialization'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AppInitialization.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/brandenesmith/AppInitialization'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/AppInitialization.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true

  s.source_files = 'AppInitialization/Classes/**/*'
  
  s.resource_bundles = {
    'AppInitialization' => [
      'AppInitialization/Classes/**/*.{storyboard,xib,xcassets,png}',
      'AppInitialization/Assets/**/*.{storyboard,xib,xcassets,png}'
    ]
  }

  s.dependency 'Dip'
  s.dependency 'GBVersionTracking'
  s.dependency 'Wrap'

  s.dependency 'Authentication'
  s.dependency 'CompanyAttributes'
  s.dependency 'Localization'
  s.dependency 'Logging'
  s.dependency 'Navigation'
  s.dependency 'Network'
  s.dependency 'Offline'
  s.dependency 'PodHelper'
  s.dependency 'RootViewController'
  s.dependency 'Biometrics'
  s.dependency 'Analytics'

end
