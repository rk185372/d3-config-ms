Pod::Spec.new do |s|
  s.name             = 'BuildInfoScreen'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BuildInfoScreen.'
  s.homepage         = 'https://github.com/brandenesmith/BuildInfoScreen'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/BuildInfoScreen.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.static_framework = true

  s.subspec 'Common' do |ss|
    ss.source_files = 'BuildInfoScreen/Classes/**/*'
  end

  s.subspec 'Standard' do |ss|
    ss.source_files = 'BuildInfoScreen/Standard/Classes/**/*'
  
    ss.resource_bundles = {
      'BuildInfoScreen' => ['BuildInfoScreen/Standard/Assets/**/*.{png,xib}']
    }

    ss.dependency 'BuildInfoScreen/Common'
  end

  s.subspec 'None' do |ss|
    ss.source_files = 'BuildInfoScreen/None/Classes/**/*'
  end

  s.dependency 'ComponentKit'
  s.dependency 'Network'
  s.dependency 'PresenterKit'
  s.dependency 'RxSwift'
  s.dependency 'UITableViewPresentation'
  s.dependency 'Utilities'
  s.dependency 'Web'
end
