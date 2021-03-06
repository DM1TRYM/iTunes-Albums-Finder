//
//  ViewController.swift
//  iTunesAPI
//
//  Created by Mikhailov on 25.11.2020.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var albums = [AlbumModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        let indentation = (self.view.bounds.size.width - 300) / 4
        collectionView.contentInset = UIEdgeInsets(top: indentation, left: indentation, bottom: indentation, right: indentation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AlbumDetailVC" {
            if let destinationVC = segue.destination as? AlbumViewController {
                if let album = sender as? AlbumModel {
                    destinationVC.album = album
                    let index = albums.firstIndex(where: { $0 === album })
                    let indexPath = IndexPath(row: index!, section: 0)
                    if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCell {
                        destinationVC.image = cell.albumImage.image
                    }
                }
            }
        }
    }
}

// MARK: - CollectionView methods

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionCell", for: indexPath) as? AlbumCell {
            cell.updateCell(album: albums[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = albums[indexPath.row]
        performSegue(withIdentifier: "AlbumDetailVC", sender: album)
        searchBar.resignFirstResponder()
    }

}

// MARK: - SearchBar methods

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil || searchBar.text != "" {
            DataService.shared.getAlbums(searchRequest: searchBar.text!) { (requestedAlbums) in
                self.albums = requestedAlbums.sorted(by: {$0.collectionName < $1.collectionName})
                DispatchQueue.main.async {
                self.collectionView.reloadData()
                }
            }
        }
        searchBar.resignFirstResponder()
    }
}


