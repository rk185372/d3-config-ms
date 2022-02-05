# frozen_string_literal: true

Pod::Spec.new do |s|
    s.name             = 'Session'
    s.version          = '0.1.0'
    s.summary          = 'Session models and services for d3-next-ios'
    s.homepage         = 'https://github.com/watt/Session'
    s.author           = { 'watt' => 'awatt@d3banking.com' }
    s.source           = { git: 'https://github.com/watt/Session.git', tag: s.version.to_s }

    s.ios.deployment_target = '11.0'
    s.swift_version = '4.2'
    s.static_framework = true
    
    s.source_files = 'Session/Classes/**/*'
    s.resource_bundles = {
        'Session' => ['Session/Assets/**/*.{storyboard,xib,xcassets,jpg,png,json}']
    }

    s.dependency 'RxSwift'
    s.dependency 'RxRelay'

    s.dependency 'EDocs'
    s.dependency 'Network'
    s.dependency 'Permissions'
    s.dependency 'TermsOfService'
    s.dependency 'Utilities'
end
