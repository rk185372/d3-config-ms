# d3-next-ios

Next generation

## Requirements
 - Xcode 10.2
 - Ruby 2.4.1+
 - CocoaPods
 - XcodeGen

## Setup

### 1. Gems

You can install Ruby via [rvm][rvm]
```
\curl -sSL https://get.rvm.io | bash -s stable
rvm install "ruby-2.6.5"
rvm use ruby-2.6.5
```

Then install and run bundler to install versioned prerequisite gems.

```sh
gem install bundler
bundle install
```

### 2. Xcodegen

[xcodegen](https://github.com/yonaskolb/XcodeGen) is required so that the project configuration (targets, scheme, etc) can be specified in a YAML file. 
Sample use case: Excluding the apple watch extension from our builds for a specific client.

There are multiple installations options described in the repository page, but we recommend using [Homebrew](https://brew.sh):

```
brew install xcodegen
```

### 3. Jarvis

Next you will need to run Jarvis to download an environment configuration.

[Click here to view Jarvis Setup Instructions][jarvis-instructions].

### 4. CocoaPods

There is no need to manually sync CocoaPods as that is already included in the Scripts used in the previous step.

_When adding a new pod to the podfile, you can add it locally in the standard way and run bundle exec pod install for development, but before you commit you'll need to add it to Scripts/project_builder/base_podfile.rb_

### 5. Web Components

Web components come from jarvis and are validated at build time by the WebComponentBuilder. This tool will generate swift code that the application is relying on to successfully build.
Refer to the [README.md](WebComponentBuilder/README.md) in the WebComponentBuilder directory for further instructions on configuration and modification if needed.

### 6. Adding Theme Styles
It is sometimes necessary to add new styles for components used inside of the app. Adding new theme styles may not cause bitrise builds to fail however, if all steps are not completed, Jarvis may still fail to build with the new theme styles. When adding new theme styles, please refer to the [Theme Styles Document][theme-styles] for detailed instructions on properly adding and modifying theme styles.

## Notes

In order to access D3 specific dependency repositories, you'll need to have an SSH key registered in Github.
For instructions go [here](https://help.github.com/en/articles/connecting-to-github-with-ssh).

Be sure to open the Xcode project with the `.xcworkspace` file, not the `.xcproject`.

## Additional Resources

- [Style Guide][style-guide]
- [Certificate Pinning][cert-pinning]
- [Theme Viewer Doc][Theme-Viewer-doc]


[homebrew]: https://brew.sh/
[rvm]: https://rvm.io/
[jarvis-instructions]: Scripts/JarvisCommands.md
[style-guide]: https://github.com/LodoSoftware/d3-ios-app/blob/develop/docs/style.md
[cert-pinning]: https://github.com/LodoSoftware/d3-ios-app/blob/develop/docs/certificate-pinning.md
[nvm]: https://github.com/creationix/nvm
[npm-token]: https://www.npmjs.com/settings/d3veloper/tokens
[Theme-Viewer-doc]: /Theme-Viewer-doc.md
[theme-styles]: /UpdatingThemeStyles.md
