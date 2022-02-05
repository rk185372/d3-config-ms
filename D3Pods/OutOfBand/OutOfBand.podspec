Pod::Spec.new do |s|
  s.name             = 'OutOfBand'
  s.version          = '0.1.0'
  s.summary          = 'A short description of OutOfBand.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Swetha/OutOfBand'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Swetha' => 'NP185148' }
  s.source           = { :git => 'https://github.com/Swetha/OutOfBand.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  s.source_files = 'OutOfBand/Classes/**/*'
  s.resource_bundles = {
     'OutOfBand' => ['OutOfBand/Assets/*.{png,xib}']
   }
  s.dependency 'UITableViewPresentation'
  s.dependency 'PostAuthFlowController'
  s.dependency 'PodHelper'
  s.dependency 'Localization'
  s.dependency 'ComponentKit'
  s.dependency 'Network'
  s.dependency 'Utilities'
  s.dependency 'Logging'
  s.dependency 'Session'
  s.dependency 'RxSwift'
  s.dependency 'RxRelay'
  s.dependency 'Views'
  s.dependency 'UserInteraction'
end
