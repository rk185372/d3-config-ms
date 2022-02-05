Pod::Spec.new do |s|
  s.name             = 'MatomoAnalytics'
  s.version          = '0.1.0'
  s.summary          = 'A short description of MatomoAnalytics.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/MatomoAnalytics'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/MatomoAnalytics.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'MatomoAnalytics/Classes/**/*'
  s.dependency 'MatomoTracker' # Version Set in the Podfile
  s.dependency 'Analytics'
end
