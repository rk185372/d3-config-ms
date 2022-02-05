Pod::Spec.new do |s|
  s.name             = 'FirebaseAnalyticsD3'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FirebaseAnalyticsD3.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/FirebaseAnalyticsD3'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/FirebaseAnalyticsD3.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'FirebaseAnalyticsD3/Classes/**/*'
  s.dependency 'Analytics'
  s.dependency 'Firebase/Core'
  s.static_framework = true
end
