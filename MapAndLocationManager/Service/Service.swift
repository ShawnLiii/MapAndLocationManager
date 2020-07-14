//
//  Service.swift
//  MapAndLocationManager
//
//  Created by Shawn Li on 7/6/20.
//

import UIKit

class Service {
    static var `shared` = Service()
    private init() {}
    
    private var api = "https://data.honolulu.gov/resource/yef5-h88r.json"
    
    func fetchData(handler: @escaping ([ArtWork]?)->()) {
        var artWorks = [ArtWork]()
        
        guard let url = URL(string: api) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                artWorks = try JSONDecoder().decode([ArtWork].self, from: data)
//                let artwork = try JSONDecoder().decode(ArtWork.self, from: data)
//                artWorks = Array(arrayLiteral: artwork)
                handler(artWorks)
            } catch {
                print(error)
                handler(nil)
            }
        }
        task.resume()
    }
    
    func fetchImage(url: URL, handler: @escaping (UIImage?) -> ())
    {
        
        let task = URLSession.shared.downloadTask(with: url)
        { (downloadedURL, response, error) in
            if let url = downloadedURL
            {
                DispatchQueue.main.async
                {
                    do
                    {
                        let data = try Data(contentsOf: url)
                        let image = UIImage(data: data)
                        handler(image)
                    }
                    catch
                    {
                        handler(nil)
                        print(error)
                    }
                }
            }
        }
        task.resume()

    }
}
