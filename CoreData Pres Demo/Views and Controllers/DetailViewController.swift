/*
 * DetailViewController.swift
 * CoreData Pres Demo
 *
 * Created by François Lamboley on 07/05/2018.
 * Copyright © 2018 François Lamboley. All rights reserved.
 */

import UIKit



class DetailViewController: UIViewController {
	
	@IBOutlet weak var imageViewUser: UIImageView!
	
	func configureView() {
		guard let user = detailItem else {return}
		title = user.fullName
		
		guard isViewLoaded else {return}
		imageViewUser.setImage(fromURL: (user.photos?.anyObject() as? Image)?.url)
	}
	
	@IBAction func updateUserName(_ sender: AnyObject) {
		/* On main thread, user is on view context (by contract), so we can modify
		 * the object directly. */
		detailItem?.firstName = ["New John", "New James", "New Robert", "New Michael", "New William"][Int(arc4random()%5)]
		detailItem?.lastName = ["Smith", "Johnson", "Jones", "Brown", "Davis"][Int(arc4random()%5)]
		_ = try? detailItem?.managedObjectContext?.save()
		
		configureView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureView()
	}
	
	var detailItem: User? {
		didSet {
			configureView()
		}
	}
	
}
