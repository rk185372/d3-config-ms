Pod::Spec.new do |s|
  s.name             = 'Biometrics'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Biometrics.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/Biometrics'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/Biometrics.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5'
  s.static_framework = true
  
  s.source_files = 'Biometrics/Classes/**/*'
  s.framework = 'LocalAuthentication'
  s.dependency 'RxSwift'
  s.dependency 'CompanyAttributes'
  s.dependency 'BiometricKeychainAccess', '4.0.2'
  s.dependency 'DeviceInfoService'
  s.dependency 'Utilities'
  s.dependency 'Network'
  s.dependency 'Dip'
  s.dependency 'DependencyContainerExtension'
  s.dependency 'EnablementNetworkInterceptorApi'
  
end
