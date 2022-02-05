Pod::Spec.new do |s|
  s.name             = 'InAppRatingApi'
  s.version          = '0.1.0'
  s.summary          = 'A short description of InAppRatingApi.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/InAppRatingApi'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/InAppRatingApi.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'

  s.source_files = 'InAppRatingApi/Classes/**/*'
  s.dependency 'RxSwift'
end
