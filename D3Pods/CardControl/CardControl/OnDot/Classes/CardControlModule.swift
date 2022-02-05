import Foundation
import CardControlApi
import DependencyContainerExtension
import ComponentKit
import CardAppMobile
import Utilities
import Network
import CompanyAttributes

public final class CardControlModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        let configuration = CardControlConfiguration()
        let theme: ThemeColors = try! container.resolve()

        let branding = CardControlBranding(
            primaryColor: theme.get(.backgroundPrimary),
            secondaryColor: theme.get(.backgroundSecondary)
        )

        let client: ClientProtocol = try! container.resolve()
        let service = OnDotService(configuration: configuration, client: client)
        container.register(.singleton) {
            OnDotCardControlManager(
                configuration: configuration,
                branding: branding,
                device: $0,
                tokenHandler: $1,
                service: service,
                l10nProvider: $2
            ) as CardControlManager
        }

        container.register(.singleton) {
            OnDotCardControlPushHandler(userSession: $0) as CardControlPushHandler
        }

    }
}
