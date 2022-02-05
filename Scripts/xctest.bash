#! /usr/bin bash

# Replace the test function in the bitrise workflow with the
# contents of this script in the event that tests fail with a
# kAXErrorServerNotFound. This will produce logs that are far 
# more verbose and can help with identifiying where the test is failing. 
xcrun simctl erase all

echo "---------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------"
echo "Running Tests"

xcodebuild -scheme "D3 Banking" \
-destination "platform=iOS Simulator,name=iPhone 11 Pro Max,OS=13.0" \
-workspace "D3 Banking.xcworkspace" \
test

# Once you fix the issue you might find it useful 
# to use this pipe following `test` to clean up the 
# logs a little bit.
#| xcpretty
