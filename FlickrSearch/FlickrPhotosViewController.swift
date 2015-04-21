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
	private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

	private var searches = [FlickrSearchResults]()
	private let flickr = Flickr()

	func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto {
		return searches[indexPath.section].searchResults[indexPath.row]
	}


}
