Pod::Spec.new do |s|
  s.name             = 'SnapshotPresentation'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SnapshotPresentation.'
  s.homepage         = 'https://github.com/brandenesmith/SnapshotPresentation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/SnapshotPresentation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.watchos.deployment_target = '5.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'SnapshotPresentation/Classes/**/*'
  s.resource_bundles = {
      'SnapshotPresentation' => ['SnapshotPresentation/Assets/**/*.{storyboard,xib,xcassets,jpg,png,json}']
  }

  s.dependency 'RxSwift'
  s.dependency 'RxRelay'
  s.dependency 'UITableViewPresentation'

  s.dependency 'AccountsPresentation'
  s.dependency 'ComponentKit'
  s.dependency 'Localization'
  s.dependency 'Logging'
  s.dependency 'Network'
  s.dependency 'PodHelper'
  s.dependency 'ShimmeringData'
  s.dependency 'Snapshot'
  s.dependency 'SnapshotService'
  s.dependency 'Utilities'
  s.dependency 'Analytics'
end
