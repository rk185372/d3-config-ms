# StyleValidator

This tool validates that the iOS project doesn't use a style that isn't defined in a style template. It does this by parsing .xib and .storyboard files in the given directory and compares it to a template file. This runs as a run script build phase. Its configuration is the [.style-validator.yml](../.style-validator.yml) file located at the root of the iOS project.

## Editing Project

To edit the project in xcode you need to run `swift generate-xcodeproj` to generate the xcodeproj file. The project is built in Swift 4.2 and uses the swift package manager.

To install dependencies run `swift package update`. If dependencies or targets have been added or changed run `swift generate-xcodeproj` to recreate the project file.

The included make file is the easiest way to produce the packaged executable.

Run `make release` to build a release version of the tool and it will be moved into the root directory of the StyleValidator.

