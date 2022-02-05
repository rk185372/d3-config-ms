//
//  UIColorDecoding.swift
//  ComponentKit
//
//  Created by Chris Carranza on 5/10/18.
//

import Foundation
import UIColor_Hex_Swift

extension KeyedDecodingContainer {
    public func decode(_ type: UIColor.Type,
                       forKey key: KeyedDecodingContainer.Key) throws -> UIColor {
        let string = try decode(String.self, forKey: key)
        
        do {
            return try UIColor(rgba_throws: string)
        } catch {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: error.localizedDescription
            )
        }
    }
    
    public func decodeIfPresent(_ type: UIColor.Type,
                                forKey key: KeyedDecodingContainer.Key) throws -> UIColor? {
        guard let string = try decodeIfPresent(String.self, forKey: key) else { return nil }
        return try? UIColor(rgba_throws: string)
    }
}

extension UnkeyedDecodingContainer {
    public mutating func decode(_ type: UIColor.Type) throws -> UIColor {
        let string = try decode(String.self)
        
        do {
            return try UIColor(rgba_throws: string)
        } catch {
            throw DecodingError.dataCorruptedError(
                in: self,
                debugDescription: error.localizedDescription
            )
        }
    }
}

extension SingleValueDecodingContainer {
    public func decode(_ type: UIColor.Type) throws -> UIColor {
        let string = try decode(String.self)
        
        do {
            return try UIColor(rgba_throws: string)
        } catch {
            throw DecodingError.dataCorruptedError(
                in: self,
                debugDescription: error.localizedDescription
            )
        }
    }

}
