Pod::Spec.new do |s|
  s.name             = 'UserInteraction'
  s.version          = '0.1.0'
  s.summary          = 'A short description of UserInteraction.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/UserInteraction'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/UserInteraction.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'UserInteraction/Classes/**/*'
  s.dependency 'RxSwift'
  s.dependency 'RxRelay'
end
