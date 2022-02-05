//
//  UILabelComponent.swift
//  ComponentKit
//
//  Created by Chris Carranza on 4/30/18.
//

import UIKit
import Dip
import DependencyContainerExtension
import Localization
import Utilities
import RxSwift
import RxRelay

public final class UILabelComponent: UILabel, Stylable, NibInjectable {
    @IBInspectable var style: String?
    @IBInspectable var l10nKey: String?
    
    private var l10nProvider: L10nProvider!
    private var componentStyleProvider: ComponentStyleProvider!
    private var reactiveFontObserver: ReactiveFontObserver!
    private var urlOpener: URLOpener!
    private let bag = DisposeBag()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupObservables()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadComponentsNotification(notification:)),
            name: .reloadComponentsNotification,
            object: nil
        )
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupObservables()
        configureComponent()
    }
    
    @objc public func reloadComponentsNotification(notification: NSNotification) {
        DispatchQueue.main.async {
            self.configureComponent()
            self.setNeedsLayout()
        }
    }
    
    private func configureComponent() {
        if let l10nKey = l10nKey {
            text = l10nProvider.localize(l10nKey, parameterMap: nil)
        }
        
        if let style = style {
            let componentStyle: AnyComponentStyle = componentStyleProvider[style]
            componentStyle.style(component: self)
        }
    }
    
    public func injectDependenciesFrom(_ container: DependencyContainer) throws {
        l10nProvider = try container.resolve()
        componentStyleProvider = try container.resolve()
        urlOpener = try container.resolve()
    }
    
    private func setupObservables() {
        reactiveFontObserver = ReactiveFontObserver(originalFont: font)
        reactiveFontObserver.font.drive(rx.font).disposed(by: bag)
    }
    
    func updateOriginalFont(font: UIFont) {
        reactiveFontObserver.updateOriginalFont(font: font)
    }
    
    private var linksTapRecognizer: UITapGestureRecognizer!
    public var areLinksEnabled: Bool {
        get {
            return linksTapRecognizer != nil
        }
        set {
            if newValue {
                linksTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(linkHitTest))
                addGestureRecognizer(linksTapRecognizer)
            } else {
                removeGestureRecognizer(linksTapRecognizer)
                linksTapRecognizer = nil
            }
        }
    }
    
    @objc private func linkHitTest() {
        guard let attributedText = attributedText else {
            return
        }
        let locationOfTouchInLabel = linksTapRecognizer.location(in: linksTapRecognizer.view)
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSRange(location: 0, length: attributedText.length))
        textStorage.addLayoutManager(layoutManager)
        
        var alignmentOffset: CGFloat!
        switch textAlignment {
        case .left, .natural, .justified:
            alignmentOffset = 0.0
        case .center:
            alignmentOffset = 0.5
        case .right:
            alignmentOffset = 1.0
        @unknown default:
            fatalError()
        }
        
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let xOffset = ((bounds.width - textBoundingBox.width) * alignmentOffset) - textBoundingBox.minX
        let yOffset = ((bounds.height - textBoundingBox.height) * alignmentOffset) - textBoundingBox.minY
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - xOffset,
                                                     y: locationOfTouchInLabel.y - yOffset)

        let characterIndex = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                          in: textContainer,
                                                          fractionOfDistanceBetweenInsertionPoints: nil)
        
        for (_, value) in attributedText.attributes(at: characterIndex, effectiveRange: nil) {
            if let link = value as? URL {
                urlOpener.open(url: link)
                return
            }
        }
    }
}
