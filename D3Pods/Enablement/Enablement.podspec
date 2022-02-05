Pod::Spec.new do |s|
  s.name             = 'Enablement'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Enablement.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/Enablement'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/Enablement.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  s.framework = 'WebKit'
  
  s.source_files = 'Enablement/Classes/**/*'
  s.resource_bundles = {
      'Enablement' => [
          'Enablement/Classes/**/*.{storyboard,xib,xcassets}',
          'Enablement/Assets/**/*.{storyboard,xib,xcassets}'
      ]
  }
  s.dependency 'Utilities'
  s.dependency 'Network'
  s.dependency 'PodHelper'
  s.dependency 'Analytics'
  s.dependency 'Wrap'
  s.dependency 'Localization'
  s.dependency 'Logging'
  s.dependency 'LegalContent'
  s.dependency 'ComponentKit'
  s.dependency 'SnapKit'
  s.dependency 'AuthGenericViewController'
  s.dependency 'PostAuthFlowController'
  s.dependency 'DeviceInfoService'
  s.dependency 'Biometrics'
  s.dependency 'EnablementNetworkInterceptorApi'
  
end
