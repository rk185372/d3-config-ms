//
//  Location.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/19/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import MapKit
import Contacts

public struct Location: Equatable {
    public enum LocationType: String, Codable {
        case all = "ALL"
        case atm = "ATM"
        case bank = "BRANCH"
        case unknown = "UNKNOWN"

        public var imageName: String {
            switch self {
            case .atm:
                return "atmIcon"
            default:
                return "bankIcon"
            }
        }
    }
    
    public struct LocationProperty: Equatable {
        public let name: String
        public let value: String
        
        init(raw: RawLocation.RawProperty) {
            self.name = raw.name
            self.value = raw.value
        }
    }
    
    public struct Address: Equatable {
        private static let formatter = CNPostalAddressFormatter()

        public var street: String?
        public var city: String?
        public var state: String?
        public var zip: String?

        public var formattedString: String {
            let address = CNMutablePostalAddress()
            address.street = street ?? ""
            address.city = city ?? ""
            address.state = state ?? ""
            address.postalCode = zip ?? ""
            return Address.formatter.string(from: address)
        }
        
        init(from raw: RawLocation.RawAddress) {
            self.street = raw.line1
            self.city = raw.city
            self.state = raw.state
            self.zip = raw.postalCode
        }
    }

    public var name: String
    public var type: LocationType
    public var address: Address
    public var phoneNumber: String?
    public var hours: [String]
    public var coordinate: CLLocationCoordinate2D
    public var todaysSchedule: String?
    public var distance: String?
    public var properties: [LocationProperty]?

    init?(from raw: RawLocation) {
        guard let coordinate = raw.coordinate else {
            return nil
        }
        self.name = raw.name
        self.type = raw.type
        self.address = Address(from: raw.address)
        self.phoneNumber = raw.phoneNumber
        self.hours = raw.hours
        self.coordinate = coordinate
        self.todaysSchedule = raw.todaysSchedule

        if let distance = raw.distance {
            self.distance = "\(distance) \(raw.unit ?? "MI")"
        }
        
        self.properties = raw.properties?.map({ LocationProperty(raw: $0) })
    }
    
    public func navigationInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
}

struct RawLocation: Decodable {
    struct RawAddress: Decodable {
        var line1: String?
        var city: String?
        var state: String?
        var postalCode: String?
        var latitude: Double?
        var longitude: Double?
    }
    
    struct RawProperty: Decodable {
        let name: String
        let value: String
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case type
        case address
        case phoneNumber
        case hours
        case distance
        case unit
        case todaysSchedule
        case properties
    }

    var id: String
    var name: String
    var type: Location.LocationType
    var address: RawAddress

    var phoneNumber: String?
    var hours: [String]
    var distance: String?
    var unit: String?
    var todaysSchedule: String?
    var properties: [RawProperty]?

    var coordinate: CLLocationCoordinate2D? {
        if let lat = address.latitude, let lon = address.longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(Location.LocationType.self, forKey: .type)
        address = try container.decode(RawAddress.self, forKey: .address)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        hours = try container.decode([String].self, forKey: .hours)
        distance = try container.decodeIfPresent(String.self, forKey: .distance)
        unit = try container.decodeIfPresent(String.self, forKey: .unit)
        todaysSchedule = try container.decodeIfPresent(String.self, forKey: .todaysSchedule)
        
        if let properties = try? container.decode([String: String].self, forKey: .properties) {
            self.properties = properties.map({ (key, value) in RawProperty(name: key, value: value) })
        }
    }
}
