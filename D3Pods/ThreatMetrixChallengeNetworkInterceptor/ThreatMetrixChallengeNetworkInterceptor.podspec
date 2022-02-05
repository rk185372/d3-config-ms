Pod::Spec.new do |s|
  s.name             = 'ThreatMetrixChallengeNetworkInterceptor'
  s.version          = '0.2.0'
  s.summary          = 'A short description of ThreatMetrixChallengeNetworkInterceptor.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/smith.brandene@gmail.com/ThreatMetrixChallengeNetworkInterceptor'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'smith.brandene@gmail.com' => 'smith.brandene@gmail.com' }
  s.source           = { :git => 'https://github.com/smith.brandene@gmail.com/ThreatMetrixChallengeNetworkInterceptor.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.static_framework = true

  s.source_files = 'ThreatMetrixChallengeNetworkInterceptor/Classes/**/*'
  
  s.subspec 'Standard' do |ss|
    ss.source_files = 'ThreatMetrixChallengeNetworkInterceptor/Standard/Classes/**/*'
    ss.vendored_frameworks = 'ThreatMetrixChallengeNetworkInterceptor/Standard/Frameworks/TMXProfiling.framework', 'ThreatMetrixChallengeNetworkInterceptor/Standard/Frameworks/TMXProfilingConnections.framework'
    ss.xcconfig = {'OTHER_LDFLAGS' => ['-ObjC','-lz']}
    ss.dependency 'CompanyAttributes'
    ss.script_phase = { :name => 'Strip Architectures', :script => "#!/bin/sh\n\n#  Created by Samin Pour on 18/6/18.\n#  Copyright © 2018 ThreatMetrix. All rights reserved.\n#\n# ThreatMetrix iOS SDK contains multiple architectures, armv7, armv7s, arm64, x86_64. The arm\n# architectures are for devices, x86_64 is for simulators. When preparing application for publishing\n# Xcode removes simulator architectures from your application, but due to a bug / design flaw it\n# doesn't strip these slices from dynamic frameworks.\n#\n# If these architectures are not removed Apple will reject the binary.\n# http://www.openradar.me/radar?id=6409498411401216#ag9zfm9wZW5yYWRhci1ocmRyFAsSB0NvbW1lbnQYgICAuO-k9QgM\n# Possible error  messages in Xcode are\n# 1. “iTunes Store Operation Failed: Unsupported Architectures. The executable YourApp contains unsupported architectures '[(x86_64, i386)]'”\n# 2. “LC_ENCRYPTION_INFO”\n# 3. “Invalid Segment Alignment”\n# 4. “The binary is invalid.”\n# Removing simulator slices will resolve these issues.\n#\n# This script automatically strips unused architectures from ThreatMetrix framework, to use it please\n# add a new \"Run Script Phase\" to the build phase and add the content of this file there.\n#\n# IMPORTANT NOTE: Please make sure to add this script after \"Embed Frameworks\" / \"Copy File(s)\"  phase\n\n\nAPP_PATH=\"${TARGET_BUILD_DIR}/${WRAPPER_NAME}\"\n\nfind \"$APP_PATH\" -name 'TMX*.framework' -type d | while read -r FRAMEWORK; do\n    FRAMEWORK_EXECUTABLE_NAME=$(defaults read \"$FRAMEWORK/Info.plist\" CFBundleExecutable)\n    FRAMEWORK_EXECUTABLE_PATH=\"$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME\"\n\n    EXTRACTED_ARCHS=()\n\n    for ARCH in $ARCHS; do\n        lipo -extract \"$ARCH\" \"$FRAMEWORK_EXECUTABLE_PATH\" -o \"$FRAMEWORK_EXECUTABLE_PATH-$ARCH\"\n        EXTRACTED_ARCHS+=(\"$FRAMEWORK_EXECUTABLE_PATH-$ARCH\")\n    done\n\n    lipo -o \"$FRAMEWORK_EXECUTABLE_PATH-merged\" -create \"${EXTRACTED_ARCHS[@]}\"\n    rm \"${EXTRACTED_ARCHS[@]}\"\n\n    rm \"$FRAMEWORK_EXECUTABLE_PATH\"\n    mv \"$FRAMEWORK_EXECUTABLE_PATH-merged\" \"$FRAMEWORK_EXECUTABLE_PATH\"\n\ndone\n" }
  end
  
  s.subspec 'None' do |ss|
    ss.source_files = 'ThreatMetrixChallengeNetworkInterceptor/None/Classes/**/*'
  end

  s.dependency 'AuthChallengeNetworkInterceptorApi'
  s.dependency 'RxSwift'
  s.dependency 'DependencyContainerExtension'
end
