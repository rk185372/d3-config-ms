Pod::Spec.new do |s|
  s.name             = 'FeatureTour'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FeatureTour.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/FeatureTour'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/FeatureTour.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.subspec 'Synovus' do |ss|
    ss.source_files = 'FeatureTour/Synovus/Classes/**/*'
    
    ss.resource_bundles = {
      'FeatureTourSynovus' => ['FeatureTour/Synovus/Assets/*.{storyboard,xib,xcassets,jpg,png}']
    }
  end
  
  s.subspec 'None' do |ss|
    ss.source_files = 'FeatureTour/None/Classes/**/*'
  end
  
  s.dependency 'Utilities'
  s.dependency 'RxSwift'
  s.dependency 'RxRelay'
  s.dependency 'Localization'
  s.dependency 'ComponentKit'
  s.dependency 'Logging'
  s.dependency 'PodHelper'
  s.dependency 'Dip'
  s.dependency 'DependencyContainerExtension'
  s.dependency 'SnapKit'
  s.dependency 'Navigation'
  s.dependency 'CompanyAttributes'
  s.dependency 'Analytics'
end
