import Foundation
import StyleValidatorCore
import Commander
import PathKit

func run() {
    command(
        Option<Path>("configPath", default: ".", description: "Path to the configuration file")
    ) { configPath in
        Log.level = .info
        
        let yamlPath = configPath.isDirectory ? configPath + Path(".style-validator.yml") : configPath
        guard yamlPath.exists else {
            Log.error("No configuration file exists at \(yamlPath)")
            exit(1)
        }
        
        do {
            let configuration = try Configuration(path: yamlPath)
            
            let validator = StyleValidator(configuration: configuration)
            
            try validator.validate()
        } catch {
            Log.error(error)
            exit(1)
        }
    }.run()
}

run()
