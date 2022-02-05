Pod::Spec.new do |s|
  s.name             = 'AuthFlow'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AuthFlow.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/AuthFlow'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/AuthFlow.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'AuthFlow/Classes/**/*'
  s.resource_bundles = {
      'AuthFlow' => [
        'AuthFlow/Assets/**/*.{storyboard,xib,xcassets,jpg,png}'
      ]
  }

  s.dependency 'AppInitialization'
  s.dependency 'Authentication'
  s.dependency 'ComponentKit'
  s.dependency 'Localization'
  s.dependency 'Logging'
  s.dependency 'Navigation'
  s.dependency 'PodHelper'
  s.dependency 'PostAuthFlow'
  s.dependency 'Session'
  s.dependency 'Snapshot'
  s.dependency 'SnapshotPresentation'
end
