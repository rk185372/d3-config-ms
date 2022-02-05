# frozen_string_literal: true

Pod::Spec.new do |s|
    s.name             = 'Web'
    s.version          = '0.1.0'
    s.summary          = 'Web view components for d3-next-ios'
    s.description      = <<-DESC
        Web view components for d3-next-ios.
    DESC
    s.homepage         = 'https://github.com/watt/Web'
    s.author           = { 'watt' => 'awatt@d3banking.com' }
    s.source           = { git: 'https://github.com/watt/Web.git', tag: s.version.to_s }

    s.ios.deployment_target = '11.0'
    s.swift_version = '4.2'
    s.static_framework = true
    
    s.source_files = 'Web/Classes/**/*'
    s.resource_bundles = {
        'Web' => ['Web/Assets/**/*.{storyboard,xib,xcassets,jpg,png,json}']
    }
    s.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }
    
    s.dependency 'Alamofire'
    s.dependency 'RxSwift'
    s.dependency 'SnapKit'
    s.dependency 'UITableViewPresentation'

    s.dependency 'AppInitialization'
    s.dependency 'Biometrics'
    s.dependency 'CardControlApi'
    s.dependency 'ComponentKit'
    s.dependency 'FIS'
    s.dependency 'Logging'
    s.dependency 'Network'
    s.dependency 'Permissions'
    s.dependency 'PodHelper'
    s.dependency 'QRScanner'
    s.dependency 'Session'
    s.dependency 'Utilities'
    s.dependency 'BadgeSwift'
    s.dependency 'Analytics'
    s.dependency 'GCDWebServer'
    s.dependency 'InAppRatingApi'
    s.dependency 'OpenLinkManager'
    s.dependency 'D3Contacts'
end
