Pod::Spec.new do |s|
  s.name             = 'AccountsPresentation'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AccountsPresentation.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/AccountsPresentation'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/AccountsPresentation.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'AccountsPresentation/Classes/**/*'
  s.resource_bundles = {
    'AccountsPresentation' => [
      'AccountsPresentation/Classes/**/*.{storyboard,xib,xcassets}',
      'AccountsPresentation/Assets/**/*.{storyboard,xib,xcassets,js}'
    ]
  }
  s.dependency 'D3Accounts'
  s.dependency 'Alamofire'
  s.dependency 'Analytics'
  s.dependency 'Branding'
  s.dependency 'ComponentKit'
  s.dependency 'Dip'
  s.dependency 'InAppRatingApi'
  s.dependency 'Messages'
  s.dependency 'Network'
  s.dependency 'Perform'
  s.dependency 'PodHelper'
  s.dependency 'PresenterKit'
  s.dependency 'ScrollableSegmentedControl'
  s.dependency 'Session'
  s.dependency 'Shimmer'
  s.dependency 'ShimmeringData'
  s.dependency 'TPKeyboardAvoiding'
  s.dependency 'Transactions'
  s.dependency 'UITableViewPresentation'
  s.dependency 'Utilities'
  s.dependency 'ViewPresentable'
  s.dependency 'Views'
  s.dependency 'Web'
end
