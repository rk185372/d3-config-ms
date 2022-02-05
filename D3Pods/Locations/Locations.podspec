# frozen_string_literal: true

Pod::Spec.new do |s|
    s.name             = 'Locations'
    s.version          = '0.1.0'
    s.summary          = 'A short description of Locations.'

    s.homepage         = 'https://github.com/ccarranzaD3/Locations'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
    s.source           = { :git => 'https://github.com/ccarranzaD3/Locations.git', :tag => s.version.to_s }
    s.ios.deployment_target = '11.0'
    s.watchos.deployment_target = '5.0'
    s.swift_version = '4.2'
    s.static_framework = true
    
    s.source_files = 'Locations/Classes/**/*'
    s.resource_bundles = {
        'Locations' => ['Locations/Classes/**/*.{storyboard,xib,xcassets}','Locations/Assets/**/*.{storyboard,xib,xcassets}']
    }

    s.framework = 'MapKit'

    s.dependency 'Logging'
    s.dependency 'Network'
    s.dependency 'RxRelay'
    s.dependency 'RxSwift'
    s.dependency 'Utilities'
end
