//
//  NIbInjectable.swift
//  DependencyContainerExtension
//
//  Created by Chris Carranza on 5/3/18.
//

import Foundation
import Dip
import Aspects

extension DependencyContainer {

    /// Containers that can fulfill dependencies through NibInjection
    public static var nibInjectableContainers: [DependencyContainer] = {
        DependencyContainer.swizzleAwakeFromNib()
        return []
    }()
    
    /// Swizzle awake from nib in order to inject the container if its available
    private static func swizzleAwakeFromNib() {
        let wrappedBlock:@convention(block) (AspectInfo) -> Void = { aspectInfo in
            guard let nibInjectable = aspectInfo.instance() as? NibInjectable else { return }
            
            for container in DependencyContainer.nibInjectableContainers {
                do {
                    try nibInjectable.injectDependenciesFrom(container)
                    return
                } catch { }
            }
        }
        
        try! UIView.aspect_hook(
            #selector(UIView.awakeFromNib), with: [], usingBlock: wrappedBlock
        )
    }
}

/// A protocol that facilitates dependency injection for custom classes
/// in a Nib or Storyboard.
public protocol NibInjectable {
    
    /// This method is called when the base NSObject classes awakeFromNib occurs. A dependency
    /// container is passed in that can be used to resolve dependencies before further
    /// customization.
    ///
    /// - Parameter container: A DependencyContainer
    /// - Throws: `DipError.DefinitionNotFound`, `DipError.AutoInjectionFailed`, `DipError.AmbiguousDefinitions`, `DipError.InvalidType`
    func injectDependenciesFrom(_ container: DependencyContainer) throws
}
