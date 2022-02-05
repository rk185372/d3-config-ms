import Foundation

public final class FlipperInitalizer {
    
    public init(theme: [String: Any]) {
        D3FlipperThemeLoader.self.setupFlipper(withTheme: theme)
    }
}
