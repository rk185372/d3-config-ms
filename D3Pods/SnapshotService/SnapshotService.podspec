Pod::Spec.new do |s|
    s.name             = 'SnapshotService'
    s.version          = '0.1.0'
    s.summary          = 'A short description of Snapshot.'
    s.homepage         = 'https://github.com/<GITHUB_USERNAME>/Snapshot'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'David McRae' => 'dmcrae@d3banking.com' }
    s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/Snapshot.git', :tag => s.version.to_s }

    s.ios.deployment_target = '11.0'
    s.watchos.deployment_target = '5.0'
    s.swift_version = '4.2'
    s.static_framework = true
    
    s.source_files = 'SnapshotService/Classes/**/*'
    s.resource_bundles = {
        'SnapshotService' => ['SnapshotService/Assets/**/*.{storyboard,xib,xcassets,jpg,png,json}']
    }

    s.dependency 'Logging'
    s.dependency 'Network'
    s.dependency 'RxSwift'
    s.dependency 'Snapshot'
    s.dependency 'Transactions'
    s.dependency 'Utilities'
end
