// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable file_length

protocol StoryboardType {
  static var storyboardName: String { get }
}

extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return LocationsPresentationBundle.storyboard(name: name)
  }
}

struct SceneType<T: Any> {
  let storyboard: StoryboardType.Type
  let identifier: String

  func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

struct InitialSceneType<T: Any> {
  let storyboard: StoryboardType.Type

  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

protocol SegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
enum StoryboardScene {
  enum Locations: StoryboardType {
    static let storyboardName = "Locations"

    static let initialScene = InitialSceneType<LocationsViewController>(storyboard: Locations.self)

    static let locationDetailsViewController = SceneType<LocationDetailsViewController>(storyboard: Locations.self, identifier: "LocationDetailsViewController")

    static let locationsListViewController = SceneType<LocationsListViewController>(storyboard: Locations.self, identifier: "LocationsListViewController")

    static let locationsViewController = SceneType<LocationsViewController>(storyboard: Locations.self, identifier: "LocationsViewController")

    static let searchRadiusPopupViewController = SceneType<SearchRadiusPopupViewController>(storyboard: Locations.self, identifier: "SearchRadiusPopupViewController")

    static let searchResultsViewController = SceneType<SearchResultsViewController>(storyboard: Locations.self, identifier: "SearchResultsViewController")
  }
}

enum StoryboardSegue {
  enum Locations: String, SegueType {
    case locationDetails = "LocationDetails"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
