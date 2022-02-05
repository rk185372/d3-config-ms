import Foundation
import DependencyContainerExtension
import CardControlApi

public final class CardControlModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register { NoneCardControlManager() as CardControlManager }
        container.register { NoneCardControlPushHandler() as CardControlPushHandler }
    }
}
