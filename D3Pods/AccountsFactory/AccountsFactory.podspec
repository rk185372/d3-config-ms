# frozen_string_literal: true

Pod::Spec.new do |s|
    s.name = 'AccountsFactory'
    s.version          = '0.1.0'
    s.summary          = 'Common interface to include either web or native accounts'
    s.homepage         = 'https://github.com/watt/AccountsFactory'
    s.author           = { 'watt' => 'awatt@d3banking.com' }
    s.source           = { git: 'https://github.com/watt/AccountsFactory.git', tag: s.version.to_s }

    s.ios.deployment_target = '11.0'
    s.static_framework = true
    
    s.subspec 'Common' do |ss|
        ss.source_files = 'AccountsFactory/Common/**/*'
    end

    s.subspec 'Web' do |ss|
        ss.dependency 'AccountsFactory/Common'
        ss.source_files = 'AccountsFactory/Web/**/*'
    end

    s.subspec 'Native' do |ss|
        ss.dependency 'AccountsFactory/Common'
        ss.source_files = 'AccountsFactory/Native/**/*'
    end

    s.default_subspec = 'Common'

    s.dependency 'AccountsPresentation'
    s.dependency 'Permissions'
    s.dependency 'Utilities'
    s.dependency 'Web'
end
