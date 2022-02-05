# frozen_string_literal: true

# Returns a hash of dependencies to be injected into the podfile.
#
# Hash keys are symbols, and values are instances of `PodDependency`.
def jarvis_dependencies
    # These dependencies will override any that have the same key specified
    # in `default_dependencies` in PodfileExtensions.rb
    {
        # Include local pod named 'NewAccountsImplementation' with key :accounts
        accounts: PodDependency.new(name: 'NewAccountsImplementation'),

        # Include a remote pod named 'LibXYZ' with key :xyz
        xyz: PodDependency.new(name: 'LibXYZ', git: 'https://github.com/xyz/libxyz')
    }
end
