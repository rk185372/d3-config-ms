Pod::Spec.new do |s|
  s.name             = 'D3Contacts'
  s.version          = '0.1.0'
  s.summary          = 'A short description of D3Contacts.'
  s.homepage         = 'https://github.com/smith.brandene@gmail.com/D3Contacts'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'smith.brandene@gmail.com' => 'smith.brandene@gmail.com' }
  s.source           = { :git => 'https://github.com/smith.brandene@gmail.com/D3Contacts.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'

  s.source_files = 'D3Contacts/Classes/**/*'
  
  s.dependency 'Dip'
  s.dependency 'DependencyContainerExtension'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'RxRelay'
end
