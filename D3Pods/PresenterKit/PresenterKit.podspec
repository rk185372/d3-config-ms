Pod::Spec.new do |s|
  s.name             = 'PresenterKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of PresenterKit.'
  s.homepage         = 'https://github.com/smith.brandene@gmail.com/PresenterKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'smith.brandene@gmail.com' => 'smith.brandene@gmail.com' }
  s.source           = { :git => 'https://github.com/smith.brandene@gmail.com/PresenterKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'PresenterKit/Classes/**/*'
  
  s.resource_bundles = {
    'PresenterKit' => ['PresenterKit/Assets/*.{png,xib}']
  }

  s.dependency 'ComponentKit'
  s.dependency 'PodHelper'
  s.dependency 'UITableViewPresentation'
end
