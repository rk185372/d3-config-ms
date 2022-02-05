//
//  WebComponentNavigation.swift
//  Web
//
//  Created by Andrew Watt on 7/2/18.
//

import UIKit
import Permissions

public struct WebComponentNavigation {
    public var title: String
    public var path: String
    public var role: UserRole?
    public var sections: [Section]
    public var items: [Item]
    public var showsUserProfile: Bool
    
    public init(title: String, path: String, role: UserRole?, showsUserProfile: Bool, sections: [Section], items: [Item]) {
        self.title = title
        self.path = path
        self.role = role
        self.sections = sections
        self.items = items
        self.showsUserProfile = showsUserProfile
    }
    
    public struct Section {
        public var title: String
        public var items: [Item]
        
        public init(title: String, items: [Item]) {
            self.title = title
            self.items = items
        }
    }
    
    public struct Item {
        public var title: String
        public var component: String
        public var path: String
        public var role: UserRole?
        public var imageName: String?

        public init(title: String, component: String, path: String, role: UserRole?, imageName: String?) {
            self.title = title
            self.component = component
            self.path = path
            self.role = role
            self.imageName = imageName
        }

        public var image: UIImage? {
            return imageName.flatMap(UIImage.init(named:))
        }

        public var feature: Feature {
            return Feature(path: path)
        }
    }
    
    public var feature: Feature {
        return Feature(path: path)
    }
}
