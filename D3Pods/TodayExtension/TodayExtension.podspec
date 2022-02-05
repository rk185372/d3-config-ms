Pod::Spec.new do |s|
  s.name             = 'TodayExtension'
  s.version          = '0.1.0'
  s.summary          = 'A short description of TodayExtension.'
  s.homepage         = 'https://github.com/brandenesmith/TodayExtension'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'smith.brandene@gmail.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/TodayExtension.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'TodayExtension/Classes/**/*'
  
  s.resource_bundles = {
    'TodayExtension' => ['TodayExtension/Assets/*.{png,xib}']
  }

  s.dependency 'AppConfiguration'
  s.dependency 'ComponentKit'
  s.dependency 'Dip'
  s.dependency 'Localization'
  s.dependency 'LocalizationData'
  s.dependency 'Network'
  s.dependency 'PodHelper'
  s.dependency 'RxSwift'
  s.dependency 'Snapshot'
  s.dependency 'SnapshotService'
  s.dependency 'UITableViewPresentation'
  s.dependency 'Utilities'
end
