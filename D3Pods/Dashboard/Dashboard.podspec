Pod::Spec.new do |s|
  s.name             = 'Dashboard'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Dashboard.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/Dashboard'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/Dashboard.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'Dashboard/Classes/**/*'
   s.resource_bundles = {
     'Dashboard' => ['Dashboard/Assets/**/*.{storyboard,xib,xcassets,png}']
   }
  s.dependency 'PodHelper'
  s.dependency 'RootViewController'
  s.dependency 'Utilities'
  s.dependency 'Navigation'
  s.dependency 'ComponentKit'
  s.dependency 'Session'
  s.dependency 'Localization'
  s.dependency 'Messages'
  s.dependency 'Offline'
  s.dependency 'SessionExpiration'
  s.dependency 'InAppRatingApi'
  s.dependency 'Views'
end
