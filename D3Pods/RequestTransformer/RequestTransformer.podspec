Pod::Spec.new do |s|
  s.name             = 'RequestTransformer'
  s.version          = '0.1.0'
  s.summary          = 'A short description of RequestTransformer.'
  s.homepage         = 'https://github.com/smith.brandene@gmail.com/RequestTransformer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'smith.brandene@gmail.com' => 'smith.brandene@gmail.com' }
  s.source           = { :git => 'https://github.com/smith.brandene@gmail.com/RequestTransformer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.static_framework = true
  
  s.subspec 'Common' do |ss| 
    ss.source_files = 'RequestTransformer/Classes/**/*'
    ss.dependency 'Dip'
    ss.dependency 'DependencyContainerExtension'
  end
  
  s.subspec 'ShapeSecurity' do |ss|
    ss.source_files = 'RequestTransformer/ShapeSecurity/Classes/**/*'
    ss.vendored_frameworks = 'RequestTransformer/ShapeSecurity/Frameworks/APIGuard.framework'

    ss.resource_bundles = {
      'ShapeSecurity' => ['RequestTransformer/ShapeSecurity/Assets/*.{png,xib,json}']
    }

    ss.dependency 'RequestTransformer/Common'
  end

  s.subspec 'Imperva' do |ss|
    ss.source_files = 'RequestTransformer/Imperva/Classes/**/*'
    ss.vendored_frameworks = 'RequestTransformer/Imperva/Frameworks/distil_protection.framework'

    ss.resource_bundles = {
      'ImpervaBundle' => ['RequestTransformer/Imperva/Assets/**/*.{json}']
    }

      ss.dependency 'RequestTransformer/Common'
  end

  s.subspec 'None' do |ss|
    ss.source_files = 'RequestTransformer/None/Classes/**/*'

    ss.dependency 'RequestTransformer/Common'
  end

  s.dependency 'Alamofire'
  s.dependency 'Logging'
  s.dependency 'PodHelper'
  s.dependency 'Utilities'
end
