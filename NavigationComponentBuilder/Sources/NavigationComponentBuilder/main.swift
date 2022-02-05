import Commander
import Foundation
import NavigationComponentBuilderCore
import PathKit
import Yams

func run() {
    command(
        Option<Path>("configPath", default: ".", description: "Path to the config")
    ) { configPath in
        let yamlPath = configPath.isDirectory
            ? configPath + Path(".navigation-builder.yml")
            : configPath

        guard yamlPath.exists else {
            Log.error("The configuration path: \(yamlPath) does not exist")
            exit(1)
        }

        let navBuilder = NavigationComponentBuilder(
            configuration: try Configuration(configurationPath: yamlPath)
        )

        do {
            try navBuilder.build()
        } catch {
            Log.error(error)
            exit(1)
        }
    }.run()
}

run()
