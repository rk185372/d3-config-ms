Pod::Spec.new do |s|
  s.name             = 'EmailVerification'
  s.version          = '0.1.0'
  s.summary          = 'A short description of EmailVerification.'
  s.homepage         = 'https://github.com/brandenesmith/EmailVerification'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/EmailVerification.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'EmailVerification/Classes/**/*'
  
  s.resource_bundles = {
    'EmailVerification' => ['EmailVerification/Assets/*.{xib,png}']
  }

  s.dependency 'AuthGenericViewController'
  s.dependency 'CompanyAttributes'
  s.dependency 'ComponentKit'
  s.dependency 'Localization'
  s.dependency 'Logging'
  s.dependency 'Network'
  s.dependency 'PodHelper'
  s.dependency 'PostAuthFlowController'
  s.dependency 'RxSwift'
  s.dependency 'Session'
  s.dependency 'Shimmer'
  s.dependency 'UITableViewPresentation'
  s.dependency 'Utilities'
  s.dependency 'Analytics'
end
