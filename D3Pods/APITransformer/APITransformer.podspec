Pod::Spec.new do |s|
  s.name             = 'APITransformer'
  s.version          = '0.1.0'
  s.summary          = 'A short description of APITransformer.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ccarranzaD3/APITransformer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ccarranzaD3' => 'ccarranza@d3banking.com' }
  s.source           = { :git => 'https://github.com/ccarranzaD3/APITransformer.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  s.static_framework = true
  
  s.source_files = 'APITransformer/Classes/**/*'

   s.resource_bundles = {
     'APITransformer' => ['APITransformer/Assets/**/*.{storyboard,xib,xcassets,js,png}']
   }
   s.frameworks = 'JavaScriptCore'
   s.dependency 'CompanyAttributes'
   s.dependency 'PodHelper'
   s.dependency 'Localization'
   s.dependency 'Utilities'
end
