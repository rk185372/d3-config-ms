Pod::Spec.new do |s|
  s.name             = 'InAppRating'
  s.version          = '0.3.0'
  s.summary          = 'A short description of InAppRating.'
  s.description      = 'Module that handles Apptentive and Medallia code.'

  s.homepage         = 'https://github.com/ccarranzaD3/InAppRating'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/InAppRating.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.subspec 'Standard' do |ss|
    ss.source_files = 'InAppRating/Standard/Classes/**/*'
  end
  
  s.subspec 'None' do |ss|
    ss.source_files = 'InAppRating/None/Classes/**/*'
  end

  s.subspec 'Apptentive' do |ss|
    ss.source_files = 'InAppRating/Apptentive/Classes/**/*'

    s.dependency 'AppConfiguration'
    s.dependency 'CompanyAttributes'
    ss.dependency 'apptentive-ios', '5.3.1'
  end
  
  s.framework = 'LocalAuthentication'
  s.dependency 'Localization'
  s.dependency 'Logging'
  s.dependency 'Utilities'
  s.dependency 'Network'
  s.dependency 'RxSwift'
  s.dependency 'RxRelay'
  s.dependency 'DependencyContainerExtension'
  s.dependency 'InAppRatingApi'
end
