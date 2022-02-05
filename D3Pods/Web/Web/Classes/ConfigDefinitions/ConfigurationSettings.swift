//
//  ThemeCommonWidgets.swift
//  Web
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 5/17/21.
//

import Foundation

public final class ConfigurationSettings: Decodable {
    public var config: ConfigDefinition?
    
    public init() {
        self.config = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case config
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        config = try? container.decode(ConfigDefinition.self, forKey: .config)
    }
}

public struct ConfigDefinition: Decodable {
    public var common: CommonDefinition?
    
    enum CodingKeys: String, CodingKey {
        case common
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        common = try? container.decodeIfPresent(CommonDefinition.self, forKey: .common)
    }
}

public struct CommonDefinition: Decodable, Equatable {
    public var showAvatars: Bool
    
    enum CodingKeys: String, CodingKey {
        case showAvatars
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showAvatars = try container.decodeIfPresent(Bool.self, forKey: .showAvatars) ?? false
    }
}
