//
//  UIViewControllerComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/23/18.
//

import UIKit
import Localization
import Dip
import DependencyContainerExtension
import RxSwift
import RxRelay
import Utilities

/// A class for controlling the navigation bar style
/// on an individual ViewController basis. This should
/// be used in conjunction with a UINavigationController
/// component to acheive the desired transitions between
/// styles.
public final class NavigationStyleItem {
    public var tintColor: UIColor? {
        get {
            return _tintColor.value
        }
        set {
            _tintColor.accept(newValue)
        }
    }
    public var barTintColor: UIColor? {
        get {
            return _barTintColor.value
        }
        set {
            _barTintColor.accept(newValue)
        }
    }
    public var shadowImage: UIImage? {
        get {
            return _shadowImage.value
        }
        set {
            _shadowImage.accept(newValue)
        }
    }
    public var titleColor: UIColor? {
        get {
            return _titleColor.value
        }
        set {
            _titleColor.accept(newValue)
        }
    }
    public var titleFont: UIFont? {
        get {
            return _titleFont.value
        }
        set {
            _titleFont.accept(newValue)
        }
    }
    public var isTranslucent: Bool {
        get {
            return _isTranslucent.value
        }
        set {
            _isTranslucent.accept(newValue)
        }
    }
    
    private let _tintColor: BehaviorRelay<UIColor?> = BehaviorRelay(value: nil)
    private let _barTintColor: BehaviorRelay<UIColor?> = BehaviorRelay(value: nil)
    private let _shadowImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    private let _titleColor: BehaviorRelay<UIColor?> = BehaviorRelay(value: nil)
    private let _titleFont: BehaviorRelay<UIFont?> = BehaviorRelay(value: nil)
    private let _isTranslucent: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    var tintColorObservable: Observable<UIColor?> {
        return _tintColor.asObservable()
    }
    var barTintColorObservable: Observable<UIColor?> {
        return _barTintColor.asObservable()
    }
    var shadowImageObservable: Observable<UIImage?> {
        return _shadowImage.asObservable()
    }
    var titleAttributesObservable: Observable<(UIColor?, UIFont?)> {
        return Observable.combineLatest(_titleColor, _titleFont)
    }
    var isTranslucentObservable: Observable<Bool> {
        return _isTranslucent.asObservable()
    }
    
    public init() {}
    
    private var previousShadowImage: UIImage?
    private var shadowImageShown: Bool = true
    
    /// Hides the navigation bars shadow image
    public func hideShadowImage() {
        guard shadowImageShown else { return }
        shadowImageShown = false
        previousShadowImage = shadowImage
        shadowImage = UIImage()
    }
    
    /// Unhides the navigation bars shadow image
    public func showShadowImage() {
        guard !shadowImageShown else { return }
        shadowImageShown = true
        shadowImage = previousShadowImage
    }
}

open class UIViewControllerComponent: UIViewController, NibInjectable {
    @IBInspectable public var navigationTextStyle: String?
    @IBInspectable public var navigationStyle: String?
    @IBInspectable public var statusBarStyle: String?
    @IBInspectable public var titleL10nKey: String?
    
    public private(set) var l10nProvider: L10nProvider!
    public private(set) var componentStyleProvider: ComponentStyleProvider!

    public let bag = DisposeBag()
    public let cancelables = CancelableBag()
    
    var hasLightText: Bool = false
    
    private let _navigationStyleItem: NavigationStyleItem = NavigationStyleItem()
    public var navigationStyleItem: NavigationStyleItem {
        return childForNavigationStyle?.navigationStyleItem ?? _navigationStyleItem
    }
    open private(set) var childForNavigationStyle: UIViewControllerComponent?
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                nibName: String? = nil,
                bundle: Bundle? = nil) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        super.init(nibName: nibName, bundle: bundle)
    }
    
    @available(*, unavailable)
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialNavigationStyleItem()
        
        if let titleL10nKey = titleL10nKey {
            title = l10nProvider.localize(titleL10nKey, parameterMap: nil)
        }
        
        if let navigationTextStyle = navigationTextStyle {
            let componentStyle: AnyComponentStyle = componentStyleProvider[navigationTextStyle]
            componentStyle.style(component: self)
        }
        
        if let navigationStyle = navigationStyle {
            let componentStyle: AnyComponentStyle = componentStyleProvider[navigationStyle]
            componentStyle.style(component: self)
        }
        
        if let statusBarStyle = statusBarStyle {
            let componentStyle: AnyComponentStyle = componentStyleProvider[statusBarStyle]
            componentStyle.style(component: self)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open func setNeedsNavigationStyleAppearanceUpdate() {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return hasLightText ? .lightContent : .default
    }
    
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        l10nProvider = try container.resolve()
        componentStyleProvider = try container.resolve()
    }
    
    private func setupInitialNavigationStyleItem() {
        if let tintColor = navigationController?.navigationBar.tintColor {
            navigationStyleItem.tintColor = tintColor
        }
        
        if let barTintColor = navigationController?.navigationBar.barTintColor {
            navigationStyleItem.barTintColor = barTintColor
        }
        
        if let shadowImage = navigationController?.navigationBar.shadowImage {
            navigationStyleItem.shadowImage = shadowImage
        }
        
        if let titleFont = navigationController?.navigationBar.titleTextAttributes?[NSAttributedString.Key.font] as? UIFont {
            navigationStyleItem.titleFont = titleFont
        }
        
        if let titleColor = navigationController?.navigationBar.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor {
            navigationStyleItem.titleColor = titleColor
        }
        
        if let isTranslucent = navigationController?.navigationBar.isTranslucent {
            navigationStyleItem.isTranslucent = isTranslucent
        }
    }

    public func beginLoading(fromButton button: UIButtonComponent? = nil) {
        cancelables.cancel()

        let controls = view.descendantViews.compactMap { $0 as? UIControl }

        button?.isLoading = true
        controls.forEach { $0.isEnabled = false }

        cancelables.insert {
            button?.isLoading = false
            controls.forEach { $0.isEnabled = true }
        }
    }
}
