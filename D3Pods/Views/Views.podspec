Pod::Spec.new do |s|
  s.name             = 'Views'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Views.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/Utilities'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chris Carranza' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/Views.git', :tag => s.version.to_s }
  s.source_files = 'Views/Classes/**/*'
  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'Views/Classes/**/*.{swift}'
  s.resource_bundles = {
      'Views' => [
          'Views/Classes/**/*.{storyboard,xib,xcassets}',
          'Views/Assets/**/*.{storyboard,xib,xcassets}'
      ]
  }

  s.dependency 'ComponentKit'
  s.dependency 'PodHelper'
  s.dependency 'SnapKit'
end
