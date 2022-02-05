target 'D3 Banking WatchKit App Extension' do
    platform :watchos, '6.0'
    use_frameworks!

    pod 'Dip', '7.0.1'
    pod 'RxCocoa', '5.1.0'
    pod 'RxSwift', '5.1.0'

    local_pod 'CompanyAttributes'
    local_pod 'Localization'
    local_pod 'Locations'
    local_pod 'Network'
    local_pod 'Snapshot'
    local_pod 'SnapshotService'
    local_pod 'Transactions'
    local_pod 'Utilities'
end