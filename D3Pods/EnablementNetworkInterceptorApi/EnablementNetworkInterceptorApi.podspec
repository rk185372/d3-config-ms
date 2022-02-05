Pod::Spec.new do |s|
  s.name             = 'EnablementNetworkInterceptorApi'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AuthChallengeNetworkInterceptorApi.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/dmac81/EnablementNetworkInterceptorApi'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dmac81' => 'dmcrae@d3banking.com' }
  s.source           = { :git => 'https://github.com/dmac81/EnablementNetworkInterceptorApi.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'EnablementNetworkInterceptorApi/Classes/**/*'
  s.dependency 'RxSwift'
end
