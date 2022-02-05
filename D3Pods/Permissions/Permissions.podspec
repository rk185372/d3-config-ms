# frozen_string_literal: true

Pod::Spec.new do |s|
    s.name             = 'Permissions'
    s.version          = '0.1.0'
    s.summary          = 'Permissions'
    s.homepage         = 'https://github.com/watt/Permissions'
    s.author           = { 'watt' => 'awatt@d3banking.com' }
    s.source           = { git: 'https://github.com/watt/Permissions.git', tag: s.version.to_s }

    s.ios.deployment_target = '11.0'
    s.static_framework = true
    
    s.source_files = 'Permissions/Classes/**/*'

    s.dependency 'Utilities'
    s.dependency 'CompanyAttributes'
end
