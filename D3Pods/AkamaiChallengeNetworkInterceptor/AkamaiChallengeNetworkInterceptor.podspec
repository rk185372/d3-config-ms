Pod::Spec.new do |s|
  s.name             = 'AkamaiChallengeNetworkInterceptor'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Akamai.'
  s.homepage         = 'https://github.com/smith.brandene@gmail.com/Akamai'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'smith.brandene@gmail.com' => 'smith.brandene@gmail.com' }
  s.source           = { :git => 'https://github.com/smith.brandene@gmail.com/Akamai.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.subspec 'Standard' do |ss|
    ss.source_files = 'AkamaiChallengeNetworkInterceptor/Standard/Classes/**/*'
    ss.dependency 'Akamai', '0.1.1'
  end
  
  s.subspec 'None' do |ss|
    ss.source_files = 'AkamaiChallengeNetworkInterceptor/None/Classes/**/*'
  end

  s.dependency 'AuthChallengeNetworkInterceptorApi'
  s.dependency 'RxSwift'
  s.dependency 'DependencyContainerExtension'
end