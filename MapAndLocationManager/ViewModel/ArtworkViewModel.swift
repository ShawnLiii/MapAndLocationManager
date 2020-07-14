//
//  ArtworkViewModel.swift
//  MapAndLocationManager
//
//  Created by Shawn Li on 7/7/20.
//

import UIKit

class ArtworkViewModel {
    
    var artworks = [ArtWork]()
    
    init() {
        getArtworksData()
    }
    
    private func getArtworksData() {
        Service.shared.fetchData { (artworks) in
            guard let artWorks = artworks else { return }
            self.artworks = artWorks
        }
    }
    
    func getArtworkImage(url: URL, imageHandler: @escaping (UIImage?)->()) {
        Service.shared.fetchImage(url: url) { (image) in
            imageHandler(image)
        }
    }
}
