Pod::Spec.new do |s|
  s.name             = 'ShimmeringData'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ShimmeringData.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/ShimmeringData'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/ShimmeringData.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.watchos.deployment_target = '5.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'ShimmeringData/Classes/**/*'
  s.resource_bundles = {
    'ShimmeringData' => [
      'ShimmeringData/Classes/**/*.{storyboard,xib,xcassets}',
      'ShimmeringData/Assets/**/*.{storyboard,xib,xcassets}'
    ]
  }
  s.dependency 'ComponentKit'
  s.dependency 'Shimmer', '1.0.2'
  s.dependency 'UITableViewPresentation'
  s.dependency 'PodHelper'
  s.dependency 'ViewPresentable'
end
