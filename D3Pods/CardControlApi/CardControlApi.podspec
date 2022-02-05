Pod::Spec.new do |s|
  s.name             = 'CardControlApi'
  s.version          = '0.1.0'
  s.summary          = 'D3 CardControlApi Pod'
  s.description      = <<-DESC
D3 CardControlApi Pod
                       DESC

  s.homepage         = 'https://github.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'D3 Banking' => '' }
  s.source           = { :git => 'https://github.com', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true

  s.source_files = 'CardControlApi/Classes/**/*'
  
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
end
