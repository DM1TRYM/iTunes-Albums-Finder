//
//  iTunesService.swift
//  iTunesAPI
//
//  Created by Mikhailov on 25.11.2020.
//

import Foundation

let BASE_URL = "https://itunes.apple.com/search?entity=album&attribute=albumTerm&offset=0&limit=100&term="
let ALBUM_SONGS_URL = "https://itunes.apple.com/lookup?entity=song&id="

class DataService {
    
    static let shared = DataService()
    
    func getAlbums (searchRequest: String, complition: @escaping ([AlbumModel]) -> ()) {
        
        var albums = [AlbumModel]()
        let searchString = searchRequest.replacingOccurrences(of: " ", with: "+")
        let url = URL(string: "\(BASE_URL)\(searchString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let session = URLSession.shared
        session.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    if let jsonResults = json["results"] as? NSArray {
                        for album in jsonResults {
                            if let albumInfo = album as? [String: AnyObject] {
                                guard let artistName = albumInfo["artistName"] as? String else {return}
                                guard let artworkUrl100 = albumInfo["artworkUrl100"] as? String else {return}
                                guard let collectionId = albumInfo["collectionId"] as? Int else {return}
                                guard let collectionName = albumInfo["collectionName"] as? String else {return}
                                guard let country = albumInfo["country"] as? String else {return}
                                guard let primaryGenreName = albumInfo["primaryGenreName"] as? String else {return}
                                guard let releaseDate = albumInfo["releaseDate"] as? String else {return}
                                let releaseDateFormatted = releaseDate.prefix(4)
                                let albumInstance = AlbumModel(artistName: artistName,
                                                               artworkUrl100: artworkUrl100,
                                                               collectionId: collectionId,
                                                               collectionName: collectionName,
                                                               country: country,
                                                               primaryGenreName:
                                                                primaryGenreName,
                                                               releaseDate: String(releaseDateFormatted))
                                albums.append(albumInstance)
                            }
                        }
                        complition(albums)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func getAlbumTracks (collectionId: Int, complition: @escaping ([Track]) -> ()) {
        var tracks = [Track]()
        let url = URL(string: "\(ALBUM_SONGS_URL)\(collectionId)")
        let session = URLSession.shared
        session.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    if let jsonResults = json["results"] as? NSArray {
                        for song in jsonResults {
                            if jsonResults.index(of: song) != 0 {
                                if let songInfo = song as? [String: AnyObject] {
                                    guard let trackName = songInfo["trackName"] as? String else {return}
                                    guard let trackNumber = songInfo["trackNumber"] as? Int else {return}
                                    let track = Track(trackName: trackName, trackNumber: trackNumber)
                                    tracks.append(track)
                                }
                            }
                        }
                        complition(tracks)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}











