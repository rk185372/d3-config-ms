Pod::Spec.new do |s|
  s.name             = 'Utilities'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Utilities.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/Utilities'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chris Carranza' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/Utilities.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.static_framework = true

  s.swift_version = '4.2'
  s.watchos.deployment_target = '5.0'
  s.source_files = 'Utilities/Common/**/*'
  s.ios.source_files = 'Utilities/iOS/**/*'
  s.watchos.source_files = 'Utilities/watchOS/**/*'

  s.dependency 'Alamofire'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'Logging'
end
