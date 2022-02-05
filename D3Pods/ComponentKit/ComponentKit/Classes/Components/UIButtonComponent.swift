//
//  UIButtonComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/1/18.
//

import UIKit
import Dip
import DependencyContainerExtension
import Localization
import RxSwift
import RxRelay
import Utilities

public class UIButtonComponent: UIButton, Stylable, NibInjectable {
    /// UIControlState may be the union of several states at once. This enum represents the
    /// the most "important" bit of a button's UIControlState in a mutually-exclusive way.
    public enum ReactiveState {
        case highlighted
        case disabled
        case normal
        
        public init(controlState: UIControl.State) {
            if controlState.contains(.highlighted) {
                self = .highlighted
            } else if controlState.contains(.disabled) {
                self = .disabled
            } else {
                self = .normal
            }
        }
    }
    
    @IBInspectable public var style: String?
    @IBInspectable var l10nKey: String?
    
    private var l10nProvider: L10nProvider!
    private var componentStyleProvider: ComponentStyleProvider!
    
    private var titlesByState: [UIControl.State: String] = [:]
    private var backgroundsByState: [ReactiveState: ComponentBackground] = [:]
    private var borderColorsByState: [ReactiveState: UIColor] = [:]
    private var gradientLayer: CAGradientLayer?
    private lazy var activityIndicatorView = { () -> UIActivityIndicatorView in
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        self.addSubview(view)
        return view
    }()
    
    private lazy var stateRelay: BehaviorRelay<UIControl.State> = {
        return BehaviorRelay(value: self.state)
    }()
    private var isLoadingRelay = BehaviorRelay(value: false)
    
    /// When `true`:
    /// - the button's title is hidden
    /// - a `UIActivityIndicatorView` is shown
    public var isLoading: Bool {
        get {
            return isLoadingRelay.value
        }
        set {
            isLoadingRelay.accept(newValue)
        }
    }
    
    private var _originalCornerRadius: CGFloat = 0
    public var cornerRadius: CGFloat {
        set {
            _originalCornerRadius = newValue
            layer.cornerRadius = min(bounds.size.height / 2, CGFloat(newValue))
        }
        get {
            return layer.cornerRadius
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        startReactiveObservers()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        startReactiveObservers()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    init(l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider) {
        super.init(frame: .zero)
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )

        startReactiveObservers()
    }
    
    private func startReactiveObservers() {
        stateRelay
            .takeUntil(rx.deallocated)
            .map(ReactiveState.init(controlState:))
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] (state) in
                self.applyStyles(forState: state)
            })
            .forever()
        
        isLoadingRelay
            .takeUntil(rx.deallocated)
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] (loading) in
                self.applyBehavior(whenLoading: loading)
            })
            .forever()
    }
    
    private func applyStyles(forState state: ReactiveState) {
        let background = backgroundsByState[state] ?? .none
        let borderColor = borderColorsByState[state]

        switch background {
        case .none:
            backgroundColor = nil
            gradientLayer?.colors = nil
            
        case .solid(let color):
            backgroundColor = color
            gradientLayer?.colors = nil
            
        case .gradient(let gradient):
            let gradientLayer = self.gradientLayer ?? createGradientLayer()
            gradientLayer.colors = gradient.cgColors
            gradientLayer.locations = [0, 1]
        }

        layer.borderColor = borderColor?.cgColor
    }
    
    private func applyBehavior(whenLoading loading: Bool) {
        if loading {
            for state in titlesByState.keys {
                super.setTitle(nil, for: state)
            }
            activityIndicatorView.color = currentTitleColor
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
        } else {
            for (state, title) in titlesByState {
                super.setTitle(title, for: state)
            }
            activityIndicatorView.stopAnimating()
        }
    }
    
    private func createGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        self.layer.insertSublayer(layer, at: 0)
        layer.frame = self.layer.bounds
        gradientLayer = layer
        return layer
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        configureComponent()
    }
    
    @objc public func reloadComponentsNotification(notification: NSNotification) {
        DispatchQueue.main.async {
            self.configureComponent()
            self.setNeedsLayout()
        }
    }
    
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        self.titlesByState[state] = title
        if !isLoading {
            super.setTitle(title, for: state)
        }
    }
    
    public func configureComponent(withStyle buttonStyle: ButtonStyleKey? = nil) {
        var newStyle: ButtonStyle

        // If the user passed in a style we want to use it.
        // If the caller did not pass a value we use the currently stored
        // style or crash if that style is invalid.
        if let buttonStyle = buttonStyle {
            newStyle = componentStyleProvider[buttonStyle.rawValue]
            self.style = buttonStyle.rawValue
        } else {
            newStyle = componentStyleProvider[style!]
        }

        if let l10nKey = l10nKey {
            setTitle(l10nProvider.localize(l10nKey, parameterMap: nil), for: .normal)
        }

        newStyle.style(component: self)
    }
    
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        l10nProvider = try container.resolve()
        componentStyleProvider = try container.resolve()
    }
    
    func setBorderColor(_ color: UIColor?, for state: UIControl.State) {
        borderColorsByState[ReactiveState(controlState: state)] = color
        updateIfState(matchesState: state)
    }
    
    func setBackground(_ background: ComponentBackground, for state: UIControl.State) {
        backgroundsByState[ReactiveState(controlState: state)] = background
        updateIfState(matchesState: state)
    }
    
    private func updateIfState(matchesState controlState: UIControl.State) {
        let currentState = ReactiveState(controlState: state)
        let updatedState = ReactiveState(controlState: controlState)
        if updatedState == currentState {
            applyStyles(forState: currentState)
        }
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == self.layer, let gradientLayer = gradientLayer {
            gradientLayer.frame = layer.bounds
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = _originalCornerRadius
        if isLoading {
            self.activityIndicatorView.center = self.bounds.center
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            if isEnabled != oldValue {
                stateRelay.accept(state)
            }
        }
    }
    
    public override var isHighlighted: Bool {
        didSet {
            if isHighlighted != oldValue {
                stateRelay.accept(state)
            }
        }
    }
}

extension UIControl.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}
