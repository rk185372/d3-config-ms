# frozen_string_literal: true

Pod::Spec.new do |s|
    s.name             = 'Logout'
    s.version          = '0.1.0'
    s.summary          = 'A short description of Logout.'
    s.description      = <<-DESC
        TODO: Add long description of the pod here.
    DESC

    s.homepage         = 'https://github.com/ccarranzaD3/Logout'
    s.license          = { type: 'MIT', file: 'LICENSE' }
    s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
    s.source           = { git: 'https://github.com/ccarranzaD3/Logout.git', tag: s.version.to_s }
    s.ios.deployment_target = '11.0'
    s.swift_version = '4.2'
    s.static_framework = true
    
    s.source_files = 'Logout/Classes/**/*'
    s.resource_bundles = {
        'Logout' => ['Logout/Assets/**/*.{storyboard,xib,xcassets}']
    }

    s.dependency 'RxSwift'

    s.dependency 'ComponentKit'
    s.dependency 'Localization'
    s.dependency 'Navigation'
    s.dependency 'Network'
    s.dependency 'Permissions'
    s.dependency 'PodHelper'
    s.dependency 'Session'
    s.dependency 'Utilities'
end
