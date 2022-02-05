Pod::Spec.new do |s|
  s.name             = 'ViewPresentable'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ViewPresentable.'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/ViewPresentable'
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/ViewPresentable.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'ViewPresentable/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ViewPresentable' => ['ViewPresentable/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
