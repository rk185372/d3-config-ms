Pod::Spec.new do |s|
  s.name             = 'OpenLinkManager'
  s.version          = '0.1.0'
  s.summary          = 'A short description of OpenLinkManager.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/D3Rcrichlow/OpenLinkManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'D3Rcrichlow' => 'rcrichlow@d3banking.com' }
  s.source           = { :git => 'https://github.com/D3Rcrichlow/OpenLinkManager.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.source_files = 'OpenLinkManager/Classes/**/*'
  
  s.dependency 'Logging'
  s.dependency 'RxRelay'
  s.dependency 'RxSwift'
  s.dependency 'Utilities'
end
