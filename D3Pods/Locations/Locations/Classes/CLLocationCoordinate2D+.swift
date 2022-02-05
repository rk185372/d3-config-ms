//
//  CLLocationCoordinate2D+.swift
//  Locations
//
//  Created by Chris Carranza on 1/25/18.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Codable {
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (x: CLLocationCoordinate2D, y: CLLocationCoordinate2D) -> Bool {
        return x.latitude == y.latitude && x.longitude == y.longitude
    }
}
