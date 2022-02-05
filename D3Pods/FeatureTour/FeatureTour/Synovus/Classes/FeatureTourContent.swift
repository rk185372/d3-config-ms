//
//  FeatureTourContent.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/28/19.
//

import Foundation
import Logging
import CompanyAttributes
import Utilities

public final class FeatureTourContent {
    let contentViewControllers: [FeatureTourContentViewController]
    private let companyAttributesHolder: CompanyAttributesHolder
    private let userDefaults: UserDefaults
    
    public var hasContent: Bool {
        return !contentViewControllers.isEmpty
            && !hasSeenFeatureTour
            && companyAttributesHolder.companyAttributes.value?.boolValue(forKey: "mobile.mobileNativeFeatureTutorial.enabled") ?? false
    }
    
    var hasSeenFeatureTour: Bool {
        get {
            return userDefaults.bool(key: KeyStore.hasSeenFeatureTour)
        }
        set {
            userDefaults.set(value: newValue, key: KeyStore.hasSeenFeatureTour)
        }
    }
    
    init(splashViewControllerFactory: SplashViewControllerFactory,
         welcomeViewControllerFactory: WelcomeViewControllerFactory,
         pagingContentViewControllerFactory: PagingContentViewControllerFactory,
         completeViewControllerFactory: CompleteViewControllerFactory,
         webContentViewControllerFactory: WebContentViewControllerFactory,
         companyAttributesHolder: CompanyAttributesHolder,
         userDefaults: UserDefaults,
         screen: UIScreen) {
        self.companyAttributesHolder = companyAttributesHolder
        self.userDefaults = userDefaults
        
        var contentViewControllers: [FeatureTourContentViewController] = []
        
        var baseUrl = URL(fileURLWithPath: Bundle.main.bundlePath + "/featureTour")
        
        let traitCollection = screen.traitCollection
        
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            // This is for anything larger than an iPhone
            baseUrl.appendPathComponent("desktop")
        }
        
        let manager = FileManager.default
        
        do {
            let files = try manager
                .contentsOfDirectory(at: baseUrl, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            let filteredFiles = files.filter { !$0.hasDirectoryPath }.sorted(by: { (first, second) -> Bool in
                return first.lastPathComponent.first! < second.lastPathComponent.first!
            })
            
            if let backgroundImage = UIImage(named: "Splash", in: FeatureTourBundle.bundle, compatibleWith: traitCollection),
                let textImage = UIImage(named: "SplashText", in: FeatureTourBundle.bundle, compatibleWith: traitCollection) {
                contentViewControllers.append(splashViewControllerFactory.create(backgroundImage: backgroundImage, textImage: textImage))
            }
            
            if let welcomeContent = filteredFiles.first {
                contentViewControllers.append(welcomeViewControllerFactory.create(url: welcomeContent))
            }
            
            var pagingViewControllers: [FeatureTourContentViewController] = []
            
            // We drop the first item here because it is the welcome view and is handled separately
            if filteredFiles.count > 1 {
                let pagingViews = filteredFiles
                    .dropFirst()
                    .map { webContentViewControllerFactory.create(url: $0) } as [FeatureTourContentViewController]
                pagingViewControllers += pagingViews
            }
            
            if let backgroundImage = UIImage(named: "Complete", in: FeatureTourBundle.bundle, compatibleWith: traitCollection),
                let logoImage = UIImage(named: "Logo", in: FeatureTourBundle.bundle, compatibleWith: traitCollection),
                let taglineImage = UIImage(named: "Tagline", in: FeatureTourBundle.bundle, compatibleWith: traitCollection) {
                pagingViewControllers.append(
                    completeViewControllerFactory.create(backgroundImage: backgroundImage, logoImage: logoImage, taglineImage: taglineImage)
                )
            }
            
            if !pagingViewControllers.isEmpty {
                contentViewControllers.append(pagingContentViewControllerFactory.create(viewControllers: pagingViewControllers))
            }
        } catch {
            log.error("Error getting Feature Tour contents: \(error)")
        }
        
        self.contentViewControllers = contentViewControllers
    }
}
