Pod::Spec.new do |s|
  s.name             = 'PostAuthFlow'
  s.version          = '0.1.0'
  s.summary          = 'A short description of PostAuthFlow.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/PostAuthFlow'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/PostAuthFlow.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'PostAuthFlow/Classes/**/*'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.dependency 'PodHelper'
  s.dependency 'ComponentKit'
  s.dependency 'Localization'
  s.dependency 'TermsOfService'
  s.dependency 'EDocs'
  s.dependency 'PostAuthFlowController'
  s.dependency 'CompanyAttributes'
  s.dependency 'Enablement'
  s.dependency 'Biometrics'
  s.dependency 'SecurityQuestions'
  s.dependency 'Session'
  s.dependency 'OutOfBand'
end
