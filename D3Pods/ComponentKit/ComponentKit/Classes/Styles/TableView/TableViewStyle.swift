//
//  TableViewStyle.swift
//  ComponentKit
//
//  Created by Chris Carranza on 11/14/18.
//

import Foundation

public struct TableViewStyle: ComponentStyle, Decodable, Equatable {
    public let separatorColor: DecodableColor
    public let backgroundColor: DecodableColor?
    
    public func style(component: UITableViewComponent) {
        component.separatorColor = separatorColor.color
        component.backgroundColor = backgroundColor?.color
    }
}
