Pod::Spec.new do |s|
  s.name             = 'Authentication'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Authentication.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/Authentication'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/Authentication.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'Authentication/Classes/**/*'
   s.resource_bundles = {
     'Authentication' => ['Authentication/Assets/**/*.{storyboard,xib,xcassets,jpg,png}']
   }

  s.dependency 'PodHelper'
  s.dependency 'ComponentKit'
  s.dependency 'Localization'
  s.dependency 'Logging'
  s.dependency 'BiometricKeychainAccess', '4.0.2'
  s.dependency 'Network'
  s.dependency 'Dashboard'
  s.dependency 'Wrap'
  s.dependency 'RxSwift'
  s.dependency 'RxRelay'
  s.dependency 'APITransformer'
  s.dependency 'SnapKit'
  s.dependency 'UITableViewPresentation'
  s.dependency 'DeviceInfoService'
  s.dependency 'Biometrics'
  s.dependency 'AuthGenericViewController'
  s.dependency 'UserInteraction'
  s.dependency 'ViewPresentable'
  s.dependency 'ShimmeringData'
  s.dependency 'AuthChallengeNetworkInterceptorApi'
  s.dependency 'ReCaptcha'
  s.dependency 'Views'
  s.dependency 'JVFloatLabeledTextField'
  s.dependency 'LocalizationData'
  
end
