Pod::Spec.new do |s|
  s.name             = 'mRDC'
  s.version          = '0.1.0'
  s.summary          = 'A short description of mRDC.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/cpflepsen/mRDC'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cpflepsen' => 'cpflepsen@d3banking.com' }
  s.source           = { :git => 'https://github.com/cpflepsen/mRDC.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.static_framework = true

  s.subspec 'Common' do |ss|
    ss.source_files = 'mRDC/Common/Classes/**/*'

    ss.resource_bundles = {
        'mRDC' => [
            'mRDC/Common/Assets/**/*.{storyboard,xib,xcassets}'
        ]
    }
  end

  s.subspec 'MiSnap-Common' do |ss| 
    ss.source_files = 'mRDC/MiSnap-Common/Classes/**/*'

    ss.dependency 'mRDC/Common'

    ss.resource_bundles = {
      'RDCMiSnap-Common' => [
          'mRDC/MiSnap-Common/Assets/**/*.{storyboard,xib,xcassets}'
      ]
  }
  end

  s.subspec 'MiSnap' do |ss|
    ss.source_files = 'mRDC/MiSnap/Classes/**/*'

    ss.dependency 'mRDC/MiSnap-Common'
    ss.dependency 'MiSnap/Standard', '1.4.0'
  end

  s.subspec 'MiSnap-Simulator' do |ss|
    ss.source_files = 'mRDC/MiSnap/Classes/**/*'

    ss.dependency 'mRDC/MiSnap-Common'
    ss.dependency 'MiSnap/Simulator', '1.4.0'
  end

  s.subspec 'MiSnap-TCF' do |ss|
    ss.source_files = 'mRDC/MiSnap-TCF/Classes/**/*'

    ss.dependency 'mRDC/MiSnap-Common'
    ss.dependency 'MiSnap-TCF/Standard', '1.4.0'
  end

  s.subspec 'MiSnap-TCF-Simulator' do |ss|
    ss.source_files = 'mRDC/MiSnap-TCF/Classes/**/*'

    ss.dependency 'mRDC/MiSnap-Common'
    ss.dependency 'MiSnap-TCF/Simulator', '1.4.0'
  end

  s.subspec 'Standard' do |ss|
    ss.source_files = 'mRDC/Standard/Classes/**/*'
    ss.dependency 'mRDC/Common'

    ss.resource_bundles = {
        'RDCStandard' => [
            'mRDC/Standard/Assets/**/*.{storyboard,xib,xcassets}'
        ]
    }
  end

  s.dependency 'AccountsPresentation'
  s.dependency 'Alamofire'
  s.dependency 'Analytics'
  s.dependency 'CompanyAttributes'
  s.dependency 'ComponentKit'
  s.dependency 'Dip'
  s.dependency 'Logging'
  s.dependency 'Network'
  s.dependency 'PodHelper'
  s.dependency 'RxRelay'
  s.dependency 'RxSwift'
  s.dependency 'ScrollableSegmentedControl'
  s.dependency 'Session'
  s.dependency 'UITableViewPresentation'
  s.dependency 'Utilities'
  s.dependency 'Wrap'
  s.dependency 'InAppRatingApi'
  s.dependency 'OpenLinkManager'
end
