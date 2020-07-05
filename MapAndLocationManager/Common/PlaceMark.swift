//
//  PlaceMark.swift
//  MapAndLocationManager
//
//  Created by Shawn Li on 7/3/20.
//

import Foundation
import MapKit

extension CLPlacemark {
    var completeAddress: String? {
        if let name = self.name {
            var address = name
    
            if let street = self.thoroughfare {
                address += ", \(street)"
            }
//            if let locality = self.locality {
//                address += ", \(locality)"
//            }
            if let subLocality = self.subLocality {
                address += ", \(subLocality)"
            }
            if let postalCode = self.postalCode {
                address += ", \(postalCode)"
            }
            if let country = self.country {
                address += ", \(country)"
            }
            return address
        }
        return nil
    }
}
