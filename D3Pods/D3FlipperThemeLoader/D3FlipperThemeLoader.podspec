
Pod::Spec.new do |s|
  s.name             = 'D3FlipperThemeLoader'
  s.version          = '0.0.1'
  s.summary          = 'A short description of D3FlipperThemeLoader.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/dmac81/D3FlipperThemeLoader'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dmac81' => 'dmcrae@d3banking.com' }
  s.source           = { :git => 'https://github.com/dmac81/D3FlipperThemeLoader.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.static_framework = true
#  s.swift_version = '5'

  s.subspec 'Standard' do |ss|
    ss.source_files = 'D3FlipperThemeLoader/Standard/Classes/**/*'

    ss.dependency 'FlipperKit'
    ss.dependency 'Utilities'

    ss.pod_target_xcconfig = {
      "OTHER_SWIFT_FLAGS" => ["-Xcc","-DFB_SONARKIT_ENABLED"],
      "OTHER_CFLAGS" => "-DFB_SONARKIT_ENABLED"
    }
  end
  
  s.subspec 'None' do |ss|
    ss.source_files = 'D3FlipperThemeLoader/None/Classes/**/*'
  end
end
