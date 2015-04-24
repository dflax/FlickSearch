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
	private let sectionInsets = UIEdgeInsets(top: 15.0, left: 10.0, bottom: 15.0, right: 10.0)

	// Data structures
	private var searches = [FlickrSearchResults]()
	private let flickr = Flickr()

	// To track whether something is selected
	//1
	var largePhotoIndexPath : NSIndexPath? {
		didSet {
			
			//2
			var indexPaths = [NSIndexPath] ()
			if largePhotoIndexPath != nil {
				indexPaths.append(largePhotoIndexPath!)
			}
			if oldValue != nil {
				indexPaths.append(oldValue!)
			}
			
			//3
			collectionView?.performBatchUpdates( {
				self.collectionView?.reloadItemsAtIndexPaths(indexPaths)
				return
				} )
				{
					completed in
					
					//4
					if self.largePhotoIndexPath != nil {
						self.collectionView?.scrollToItemAtIndexPath(
							self.largePhotoIndexPath!, atScrollPosition: .CenteredVertically, animated: true)
					}
				}
		}
	}

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

		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrPhotoCell
		let flickrPhoto = photoForIndexPath(indexPath)

		//1
		cell.activityIndicator.stopAnimating()

		//2
		if indexPath != largePhotoIndexPath {
			cell.imageView.image = flickrPhoto.thumbnail
			return cell
		}

		//3
		if flickrPhoto.largeImage != nil {
			cell.imageView.image = flickrPhoto.largeImage
			return cell
		}

		//4
		cell.imageView.image = flickrPhoto.thumbnail
		cell.activityIndicator.startAnimating()

		//5
		flickrPhoto.loadLargeImage {
			loadedFlickrPhoto, error in

			//6
			cell.activityIndicator.stopAnimating()

			//7
			if error != nil {
				return
			}

			if loadedFlickrPhoto.largeImage == nil {
				return
			}

			//8
			if indexPath == self.largePhotoIndexPath {
				if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FlickrPhotoCell {
					cell.imageView.image = loadedFlickrPhoto.largeImage
				}
			}
		}

		return cell
	}


}


// MARK: - UICollectionViewDelegateFlowLayout flow layout
extension FlickrPhotosViewController : UICollectionViewDelegateFlowLayout {

	var cellPaddingSize : CGFloat {
		if (UIDevice.currentDevice().model.lowercaseString.rangeOfString("iphone") != nil) {
			return 5.0
		} else {
			return 10.0
		}
	}

	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

		let flickrPhoto = photoForIndexPath(indexPath)

		// New code
		if indexPath == largePhotoIndexPath {
			var size = collectionView.bounds.size

			size.height -= topLayoutGuide.length
			size.height -= (sectionInsets.top + sectionInsets.right)
			size.width  -= (sectionInsets.left + sectionInsets.right)

			return flickrPhoto.sizeToFillWidthOfSize(size)
		}

		// Previous code
		if var size = flickrPhoto.thumbnail?.size {
//			size.width += cellPaddingSize
//			size.height += cellPaddingSize

//			size = CGSize(width: 100.0, height: 50.0)
			return size
		}
		return CGSize(width: 100, height: 100)
	}

	//3
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return sectionInsets
	}

}

// MARK: - Selection methods
extension FlickrPhotosViewController : UICollectionViewDelegate {

	override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		if largePhotoIndexPath == indexPath {
			largePhotoIndexPath = nil
		} else {
			largePhotoIndexPath = indexPath
		}
		return false
	}
}



