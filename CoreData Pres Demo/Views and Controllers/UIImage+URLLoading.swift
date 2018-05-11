/*
 * UIImage+URLLoading.swift
 * CoreData Pres Demo
 *
 * Created by François Lamboley on 11/05/2018.
 * Copyright © 2018 François Lamboley. All rights reserved.
 */

import UIKit



private var keyURL = "url"
private var keyDataTask = "data task"

extension UIImageView {
	
	/** Cancels the URL request from the latest setImageFromURL (only one loading
	can be done at any given time anyway). Prevents the image to change after
	setImageFromURL has been called. Useful to manually set the image of the
	interface object to another static image. */
	func cancelPreviousLoadingOfImageFromURL() {
		dataTask?.cancel()
		dataTask = nil
		url = nil
	}
	
	/** Sets the image of the interface image from a URL.
	
	Note: You really should call cancelPreviousLoadingOfImageFromURL before
	manually setting the image of an interface image whose setImageFromURL has
	been called to avoid having the image being changed when the URL finishes to
	load. */
	func setImage(fromURL imageURL: URL?) {
		assert(Thread.isMainThread)
		guard imageURL != url else {return}
		cancelPreviousLoadingOfImageFromURL()
		
		guard let imageURL = imageURL else {image = nil; return}
		
		let t = URLSession.shared.dataTask(with: imageURL, completionHandler: { [weak self] data, _, _ -> Void in
			DispatchQueue.main.async {
				guard let strongSelf = self, strongSelf.url == imageURL else {return}
				strongSelf.image = data.flatMap{ UIImage(data: $0) }
				strongSelf.dataTask = nil
				strongSelf.url = nil
			}
		})
		
		url = imageURL
		dataTask = t
		t.resume()
	}
	
	private var dataTask: URLSessionDataTask? {
		get {return objc_getAssociatedObject(self, &keyDataTask) as? URLSessionDataTask}
		set {objc_setAssociatedObject(self, &keyDataTask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
	}
	
	private var url: URL? {
		get {return objc_getAssociatedObject(self, &keyURL) as? URL}
		set {objc_setAssociatedObject(self, &keyURL, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
	}
	
}
