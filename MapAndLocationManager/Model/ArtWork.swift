//
//  ArtWork.swift
//  MapAndLocationManager
//
//  Created by Shawn Li on 7/6/20.
//

import Foundation

struct ArtWork: Decodable {
    var creator: String?
    var credit: String?
    var date: String?
    var description: String?
    var discipline: String?
    var location: String?
    var imagefile: String?
    var title: String?
    var artloc: ArtLocation?
}

struct ArtLocation: Decodable {
    var type: String?
    var coordinates: [Double]?
}
