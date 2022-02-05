Pod::Spec.new do |s|
  s.name             = 'CardControl'
  s.version          = '1.0.0'
  s.summary          = 'D3 CardControl Pod'
  s.description      = <<-DESC
D3 CardControl Pod
                       DESC

  s.homepage         = 'https://github.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'D3 Banking' => '' }
  s.source           = { :git => 'https://github.com', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true

  s.subspec 'Common' do |ss|
    ss.source_files = 'CardControl/Common/Classes/**/*'
  end

  s.subspec 'None' do |ss|
    ss.dependency 'CardControl/Common'
    ss.source_files = 'CardControl/None/Classes/**/*'
  end

  s.subspec 'OnDot' do |ss|
    ss.source_files = 'CardControl/OnDot/Classes/**/*'
    ss.resource_bundles = {
       'CardControl' => ['CardControl/OnDot/Assets/*.{json}']
    }

    ss.dependency 'OnDot', '1.5.4'
    ss.dependency 'CardControl/Common'
    ss.dependency 'ComponentKit'
    ss.dependency 'Dashboard'
    ss.dependency 'Logging'
    ss.dependency 'Network'
    ss.dependency 'Session'
    ss.dependency 'Utilities'
    ss.dependency 'Views'
  end

  s.dependency 'DependencyContainerExtension'
  s.dependency 'CardControlApi'
  s.dependency 'CompanyAttributes'
  s.dependency 'PodHelper'

end
