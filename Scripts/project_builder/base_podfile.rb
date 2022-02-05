# frozen_string_literal: true
require 'zip'
require_relative 'PodfileExtensions'

source 'git@github.com:LodoSoftware/D3CocoaPodSpec.git'
source 'git@github.com:facebook/flipper.git'
source 'https://github.com/CocoaPods/Specs.git'

flipperkit_version = '0.23.1'

$swift_42_pods = ['Alamofire', 'Dip', 'BadgeSwift','SnapKit', 'ReCaptcha']
$swift_5_pods = ['BiometricKeychainAccess', 'RxCocoa', 'RxSwift', 'RxRelay', 'RxSwift-iOS', 'RxCocoa-iOS', 'RxRelay-iOS', 'RxSwift-watchOS', 'RxCocoa-watchOS', 'RxRelay-watchOS', 'RxTest']

def local_pod(name)
    base_spec_name = name.split('/').first
    $swift_5_pods.push(base_spec_name)
    pod name, path: "D3Pods/#{base_spec_name}", inhibit_warnings: false
end

abstract_target 'D3 Banking Shared' do
    platform :ios, '13.0'
    use_frameworks!
    inhibit_all_warnings!

    pod 'Dip', '7.0.1'
    pod 'ReCaptcha', '1.5.0'
    pod 'RxCocoa', '5.1.0'
    pod 'RxSwift', '5.1.0'
    pod 'ScrollableSegmentedControl', '~> 1.3.0'
    pod 'UITableViewPresentation', '1.5.4'
    pod 'Wrap', '2.1.1'
    pod 'Firebase/Crashlytics'
    pod 'MatomoTracker', :git=> 'git@github.com:LodoSoftware/d3-matomo-sdk-ios.git', :commit => '9b52eaea3ecabc35862ca53fab2b06fecedfc729'
    pod "SimpleMarkdownParser", '0.7.1'
    
    local_pod 'D3Accounts'
    local_pod 'AccountsPresentation'
    local_pod 'Analytics'
    local_pod 'APITransformer'
    local_pod 'AppConfiguration'
    local_pod 'Authentication'
    local_pod 'AuthGenericViewController'
    local_pod 'Biometrics'
    local_pod 'Branding'
    local_pod 'CompanyAttributes'
    local_pod 'ComponentKit'
    local_pod 'D3Contacts'
    local_pod 'Dashboard'
    local_pod 'DependencyContainerExtension'
    local_pod 'DeviceInfoService'
    local_pod 'EmailVerification'
    local_pod 'Enablement'
    local_pod 'FirebaseAnalyticsD3'
    local_pod 'FIS'
    local_pod 'EDocs'
    local_pod 'LegalContent'
    local_pod 'Localization'
    local_pod 'LocalizationData'
    local_pod 'LogAnalytics'
    local_pod 'Logging'
    local_pod 'Logout'
    local_pod 'Maintenance'
    local_pod 'Messages'
    local_pod 'Navigation'
    local_pod 'Network'
    local_pod 'Offline'
    local_pod 'OpenLinkManager'
    local_pod 'Permissions'
    local_pod 'MatomoAnalytics'
    local_pod 'PodHelper'
    local_pod 'PostAuthFlow'
    local_pod 'PostAuthFlowController'
    local_pod 'PresenterKit'
    local_pod 'ProfileIconManager'
    local_pod 'RootViewController'
    local_pod 'SecurityQuestions'
    local_pod 'Session'
    local_pod 'SessionExpiration'
    local_pod 'ShimmeringData'
    local_pod 'Snapshot'
    local_pod 'SnapshotPresentation'
    local_pod 'SnapshotService'
    local_pod 'TermsOfService'
    local_pod 'Transactions'
    local_pod 'UserInteraction'
    local_pod 'Utilities'
    local_pod 'ViewPresentable'
    local_pod 'Views'
    local_pod 'OutOfBand'
    local_pod 'QRScanner'

    target 'D3 Banking' do
        external_dependencies

        pod 'AlamofireNetworkActivityIndicator', '2.2.0'
        pod 'GBVersionTracking', '1.3.2'
        pod 'Perform', '2.0.1'
        pod 'SnapKit', '4.2.0'
        pod 'SwiftLint', '0.39.2'
        pod 'TPKeyboardAvoiding', '1.3.1'
        pod 'BadgeSwift', '7.0.0'
        pod 'Sourcery', '0.15.0'

        local_pod 'AppInitialization'
        local_pod 'AuthFlow'
        local_pod 'Locations'
        local_pod 'LocationsPresentation'
        local_pod 'Web'
        local_pod 'InAppRatingApi'
        local_pod 'CardControlApi'
        local_pod 'AuthChallengeNetworkInterceptorApi'
        local_pod 'EnablementNetworkInterceptorApi'

        target 'D3 BankingTests' do
            inherit! :search_paths
            
            pod 'Firebase'
            pod 'RxBlocking', '5.1.0'
            pod 'RxTest', '5.1.0'
            local_pod 'MockData'
        end
    end

    target 'D3 BankingUITests' do
        pod 'MockServer', '1.1.3'
    end

    # Today_Extensions
end

# Watch_App

min_deployment_target = Gem::Version.new '13.0'

post_install do |installer|
    # This turns on whole-module optimization at the Pods *project* level. Each target
    # is enabled by default but Xcode will warn about updating to recommended settings
    # if the project itself does not have whole module enabled.
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = config.name == 'Release' ? '-Owholemodule' : '-Onone'
    end
    # This sets the deployment target to the minimum supported by Xcode for each
    # 3rd-party pod with deployment target that is lower than that.
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "org.cocoapods.${PRODUCT_NAME:rfc1034identifier}.${PLATFORM_NAME}"

            if target.name == 'Locations-watchOS-Locations' or target.name == 'SnapshotService-watchOS-SnapshotService' or target.name == 'Snapshot-watchOS-Snapshot'
                config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2,4'
            end

            if target.name == 'ReCaptcha'
                config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            end

            if target.name == "GCDWebServer"
                config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            end

            if $swift_5_pods.include? target.name
                puts "Changing #{target.name} Swift Version to 5"
                config.build_settings['SWIFT_VERSION'] = '5'
            elsif $swift_42_pods.include? target.name
                puts "Changing #{target.name} Swift Version to 4.2"
                config.build_settings['SWIFT_VERSION'] = '4.2'
            else
                puts "Changing #{target.name} Swift Version to 4.1"
                config.build_settings['SWIFT_VERSION'] = '4.1'
            end
            
            ios_deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
            next unless ios_deployment_target
            version = Gem::Version.new ios_deployment_target
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = min_deployment_target.to_s if version < min_deployment_target
        end
    end

    # Flipper support
    file_name = Dir.glob("*.xcodeproj")[0]
    app_project = Xcodeproj::Project.open(file_name)
    app_project.native_targets.each do |target|
      target.build_configurations.each do |config|
        if (config.build_settings['OTHER_SWIFT_FLAGS'])
          if !(config.build_settings['OTHER_SWIFT_FLAGS'].include? '-DFB_SONARKIT_ENABLED')
            config.build_settings['OTHER_SWIFT_FLAGS'] =  [config.build_settings['OTHER_SWIFT_FLAGS'], '-Xcc', '-DFB_SONARKIT_ENABLED']
          end
        elsif
          config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Xcc', '-DFB_SONARKIT_ENABLED']
        end
        app_project.save
      end
    end
    # Unzip the environment.zip again to override default files in external pods.
    environment_zip = 'environment.zip'
    Zip::File.open(environment_zip) do |zip|
      zip.each do |entry|
        entry.extract(entry.name) do
          true # Replace all duplicates.
        end
      end
    end
end

ENV['COCOAPODS_DISABLE_STATS'] = 'true'
