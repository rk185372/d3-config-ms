# frozen_string_literal: true

# Returns a hash of dependencies to be injected into the podfile.
#
# Hash keys are symbols, and values are instances of `PodDependency`.
def default_dependencies
    # These will be overridden by any dependencies in Jarvis with the same keys.
    {
        accounts: PodDependency.new(name: 'AccountsFactory/Web'),
        buildInfoScreen: PodDependency.new(name: 'BuildInfoScreen/Standard'),
        rdc: PodDependency.new(name: 'mRDC/Standard'),
        featureTour: PodDependency.new(name: 'FeatureTour/None'),
        inAppRating: PodDependency.new(name: 'InAppRating/Standard'),
        themeLoader: PodDependency.new(name: 'D3FlipperThemeLoader/None'),
        threatMetrixChallengeNetworkInterceptor: PodDependency.new(name: 'ThreatMetrixChallengeNetworkInterceptor/None'),
        akamaiChallengeInterceptor: PodDependency.new(name: 'AkamaiChallengeNetworkInterceptor/None'),
        deviceDescriptionChallengeInterceptor: PodDependency.new(name: 'DeviceDescriptionChallengeNetworkInterceptor/None'),
        deviceDescriptionEnablementInterceptor: PodDependency.new(name: 'DeviceDescriptionEnablementNetworkInterceptor/None'),
        requestTransformer: PodDependency.new(name: 'RequestTransformer/None'),
        cardControl: PodDependency.new(name: 'CardControl/None')
    }
end

class PodDependency
    attr_accessor :name
    attr_accessor :git
    attr_accessor :commit

    def initialize(name:, git: nil, commit: nil)
        @name = name
        @git = git
        @commit = commit
    end
end

require_relative 'PodfileExtensionRemote' if File.exist?('PodfileExtensionRemote.rb')

def external_dependencies
    dependencies = default_dependencies
    
    if respond_to?(:jarvis_dependencies, include_all: true)
        dependencies = dependencies.merge!(jarvis_dependencies)
    end
    
    dependencies.values.each do |dependency|
        if dependency.git
            pod dependency.name, git: dependency.git, commit: dependency.commit, inhibit_warnings: true
        else
            local_pod dependency.name
        end
    end
end
