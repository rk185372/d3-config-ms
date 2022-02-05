Pod::Spec.new do |s|
  s.name             = 'ProfileIconManager'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ProfileIconManager.'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'smith.brandene@gmail.com' => 'smith.brandene@gmail.com' }
  s.source           = { :git => 'https://github.com/smith.brandene@gmail.com/ProfileIconManager.git', :tag => s.version.to_s }
  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/ProfileIconManager'
  s.summary          = 'A short description of ProfileIconManager.'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'ProfileIconManager/Classes/**/*'

  s.dependency 'Analytics'
  s.dependency 'ComponentKit'
  s.dependency 'DependencyContainerExtension'
  s.dependency 'InAppRatingApi'
  s.dependency 'Localization'
  s.dependency 'Messages'
  s.dependency 'RxSwift'
  s.dependency 'Utilities'
  s.dependency 'Web'
  s.dependency 'SVGKit'
end
