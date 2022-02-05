Pod::Spec.new do |s|
  s.name             = 'Transactions'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Transactions.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/Transactions'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'David McRae' => 'dmcrae@d3banking.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/Transactions.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.watchos.deployment_target = '5.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'Transactions/Classes/**/*'
  s.dependency 'Alamofire'
  s.dependency 'Network'
  s.dependency 'RxSwift'
  s.dependency 'Utilities'
end
