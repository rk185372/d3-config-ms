Pod::Spec.new do |s|
  s.name             = 'DeviceDescriptionChallengeNetworkInterceptor'
  s.version          = '0.1.0'
  s.summary          = 'A short description of DeviceDescriptionChallengeNetworkInterceptor.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/dmac81/DeviceDescriptionChallengeNetworkInterceptor'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dmac81' => 'dmcrae@d3banking.com' }
  s.source           = { :git => 'https://github.com/dmac81/DeviceDescriptionChallengeNetworkInterceptor.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'DeviceDescriptionChallengeNetworkInterceptor/Classes/**/*'
  
  s.subspec 'Standard' do |ss|
    ss.source_files = 'DeviceDescriptionChallengeNetworkInterceptor/Standard/Classes/**/*'
    ss.dependency 'Utilities'
    ss.dependency 'CompanyAttributes'
  end
  
  s.subspec 'None' do |ss|
    ss.source_files = 'DeviceDescriptionChallengeNetworkInterceptor/None/Classes/**/*'
  end

  s.dependency 'AuthChallengeNetworkInterceptorApi'
  s.dependency 'RxSwift'
  s.dependency 'DependencyContainerExtension'
end
