//
//  FlickrPhotosViewController.swift
//  FlickrSearch
//
//  Created by Daniel Flax on 4/20/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit

class FlickrPhotosViewController: UICollectionViewController {

	private let reuseIdentifier = "FlickrCell"
	private let sectionInsets = UIEdgeInsets(top: 25.0, left: 10.0, bottom: 25.0, right: 10.0)

	// Data structures
	private var searches = [FlickrSearchResults]()
	private let flickr = Flickr()

	func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {
		return searches[indexPath.section].searchResults[indexPath.row]
	}

}

// MARK: - Extension for Text Field Delegate

extension FlickrPhotosViewController : UITextFieldDelegate {

	func textFieldShouldReturn(textField: UITextField) -> Bool {

		// 1
		let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
		textField.addSubview(activityIndicator)
		activityIndicator.frame = textField.bounds
		activityIndicator.startAnimating()
		flickr.searchFlickrForTerm(textField.text) {
			results, error in

			//2
			activityIndicator.removeFromSuperview()
			if error != nil {
				println("Error searching : \(error)")
			}

			if results != nil {
				//3
				println("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
				self.searches.insert(results!, atIndex: 0)

				//4
				self.collectionView?.reloadData()
			}
		}

		textField.text = nil
		textField.resignFirstResponder()
		return true
	}
}

// MARK: - UICollectionViewDataSource delegate methods
extension FlickrPhotosViewController : UICollectionViewDataSource {

	//1
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return searches.count
	}

	//2
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return searches[section].searchResults.count
	}

	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

		//1
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrPhotoCell

		//2
		let flickrPhoto = photoForIndexPath(indexPath)
		cell.backgroundColor = UIColor.blackColor()

		//3
		cell.imageView.image = flickrPhoto.thumbnail

		return cell
	}
}


// MARK: - UICollectionViewDelegateFlowLayout flow layout
extension FlickrPhotosViewController : UICollectionViewDelegateFlowLayout {

	//1
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

			let flickrPhoto =  photoForIndexPath(indexPath)

			//2
			if var size = flickrPhoto.thumbnail?.size {
				size.width  += 10
				size.height += 10
				return size
			}
			return CGSize(width: 100, height: 100)
	}

	//3
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return sectionInsets
	}

}


