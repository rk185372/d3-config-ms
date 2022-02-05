Pod::Spec.new do |s|
  s.name             = 'TermsOfService'
  s.version          = '0.1.0'
  s.summary          = 'A short description of TermsOfService.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/TermsOfService'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/TermsOfService.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.framework = 'WebKit'
  s.source_files = 'TermsOfService/Classes/**/*'
  s.resource_bundles = {
      'TermsOfService' => [ 'TermsOfService/Assets/**/*.{storyboard,xib,xcassets}' ]
  }
  s.dependency 'Alamofire'
  s.dependency 'Utilities'
  s.dependency 'Logging'
  s.dependency 'Network'
  s.dependency 'PodHelper'
  s.dependency 'Analytics'
  s.dependency 'Localization'
  s.dependency 'ComponentKit'
  s.dependency 'AuthGenericViewController'
  s.dependency 'SnapKit'
  s.dependency 'PostAuthFlowController'
  s.dependency 'OpenLinkManager'
  s.dependency "SimpleMarkdownParser"
  s.dependency "Views"
end
