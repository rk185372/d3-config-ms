Pod::Spec.new do |s|
  s.name             = 'SessionExpiration'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SessionExpiration.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/SessionExpiration'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/SessionExpiration.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'SessionExpiration/Classes/**/*'
  s.resource_bundles = {
     'SessionExpiration' => ['SessionExpiration/Assets/*.{storyboard,xib,xcassets,jpg,png}']
  }
  s.dependency 'Utilities'
  s.dependency 'Navigation'
  s.dependency 'RxSwift'
  s.dependency 'RxRelay'
  s.dependency 'Localization'
  s.dependency 'ComponentKit'
  s.dependency 'Logging'
  s.dependency 'Session'
  s.dependency 'UserInteraction'
  s.dependency 'PodHelper'
  s.dependency 'Dip'
  s.dependency 'DependencyContainerExtension'
  s.dependency 'CompanyAttributes'
end
