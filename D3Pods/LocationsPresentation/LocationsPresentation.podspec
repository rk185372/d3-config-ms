Pod::Spec.new do |s|
  s.name             = 'LocationsPresentation'
  s.version          = '0.1.0'
  s.summary          = 'A short description of LocationsPresentation.'
  s.homepage         = 'https://github.com/brandenesmith/LocationsPresentation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'brandenesmith' => 'bsmith@d3banking.com' }
  s.source           = { :git => 'https://github.com/brandenesmith/LocationsPresentation.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'LocationsPresentation/Classes/**/*'
  s.resource_bundles = {
    'LocationsPresentation' => ['LocationsPresentation/Classes/**/*.{storyboard,xib,xcassets}','LocationsPresentation/Assets/**/*.{storyboard,xib,xcassets}']
  }
  
  s.framework = 'MapKit'

  s.dependency 'Alamofire'
  s.dependency 'Analytics'
  s.dependency 'ComponentKit'
  s.dependency 'Dip'
  s.dependency 'Locations'
  s.dependency 'Logging'
  s.dependency 'Navigation'
  s.dependency 'Network'
  s.dependency 'Perform'
  s.dependency 'Permissions'
  s.dependency 'PodHelper'
  s.dependency 'RxRelay'
  s.dependency 'RxKeyboard'
  s.dependency 'SnapKit'
  s.dependency 'TPKeyboardAvoiding'
  s.dependency 'UITableViewPresentation'
  s.dependency 'Utilities'
  s.dependency 'CompanyAttributes'
end
