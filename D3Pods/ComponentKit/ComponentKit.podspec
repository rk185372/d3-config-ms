Pod::Spec.new do |s|
  s.name             = 'ComponentKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ComponentKit.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/ComponentKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/ComponentKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'ComponentKit/Classes/**/*'
  s.resource_bundles = {
      'ComponentKit' => [
          'ComponentKit/Assets/**/*.{storyboard,xib,xcassets}'
      ]
  }

  s.dependency 'Dip'
  s.dependency 'Logging'
  s.dependency 'RxRelay'
  s.dependency 'RxSwift'
  s.dependency 'SnapKit'
  s.dependency 'UIColor_Hex_Swift', '4.0.1'
  s.dependency 'M13Checkbox', '3.2.2'
  s.dependency 'DependencyContainerExtension'
  s.dependency 'FIS'
  s.dependency 'Localization'
  s.dependency 'PodHelper'
  s.dependency 'Utilities'
  s.dependency 'TPKeyboardAvoiding'
  s.dependency 'BadgeSwift'
  s.dependency 'OpenLinkManager'
  s.dependency 'JVFloatLabeledTextField'
  s.dependency 'D3Contacts'
  s.dependency 'UITableViewPresentation'
end
