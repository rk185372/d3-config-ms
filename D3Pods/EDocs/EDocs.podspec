Pod::Spec.new do |s|
  s.name             = 'EDocs'
  s.version          = '0.1.0'
  s.summary          = 'A short description of EDocs.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/EDocs'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/EDocs.git', :tag => s.version.to_s }
  s.source_files = 'EDocs/Classes/**/*'
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true

  s.source_files = 'EDocs/Classes/**/*.{swift}'
  
  s.resource_bundles = {
      'EDocs' => [
          'EDocs/Classes/**/*.{storyboard,xib,xcassets}',
          'EDocs/Assets/**/*.{storyboard,xib,xcassets}'
      ]
  }

  
  s.dependency 'Analytics'
  s.dependency 'CompanyAttributes'
  s.dependency 'ComponentKit'
  s.dependency 'LegalContent'
  s.dependency 'Logging'
  s.dependency 'Network'
  s.dependency 'PodHelper'
  s.dependency 'PostAuthFlowController'
  s.dependency 'ShimmeringData'
  s.dependency 'UITableViewPresentation'
  s.dependency 'Utilities'
  s.dependency 'ViewPresentable'
end
