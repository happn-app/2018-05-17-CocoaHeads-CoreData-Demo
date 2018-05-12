/*
 * MasterViewController.swift
 * CoreData Pres Demo
 *
 * Created by François Lamboley on 07/05/2018.
 * Copyright © 2018 François Lamboley. All rights reserved.
 */

import UIKit
import CoreData



class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
	
	var detailViewController: DetailViewController? = nil
	var managedObjectContext: NSManagedObjectContext? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = editButtonItem
		
		tableView.fetchedResultsControllerReloadMode = .handler({ [weak self] cell, object, _, _ in
			self?.configureCell(cell, withUser: object as! User)
		})
		tableView.fetchedResultsControllerMoveMode = .move(reloadMode: .standard)
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
		navigationItem.rightBarButtonItem = addButton
		if let split = splitViewController {
			let controllers = split.viewControllers
			detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@objc
	func insertNewObject(_ sender: Any) {
		let context = self.fetchedResultsController.managedObjectContext
		let newUser = User(context: context)
		
		newUser.firstName = ["John", "James", "Robert", "Michael", "William"][Int(arc4random()%5)]
		newUser.lastName = ["Smith", "Johnson", "Jones", "Brown", "Davis"][Int(arc4random()%5)]
		
		let newImage = Image(context: context)
		newImage.dominantColor = UIColor(red: CGFloat(arc4random())/CGFloat(UInt32.max), green: CGFloat(arc4random())/CGFloat(UInt32.max), blue: CGFloat(arc4random())/CGFloat(UInt32.max), alpha: CGFloat(arc4random())/CGFloat(UInt32.max))
		newImage.url = URL(
			string: [
				"https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Cat03.jpg/1200px-Cat03.jpg",
				"https://bayonline.co.nz/wp-content/uploads/2016/10/4-ways-cheer-up-depressed-cat.jpg",
				"https://www.cbc.ca/cbcdocspov/content/images/episodes/lohlala.jpg",
				"https://3b0ad08da0832cf37cf5-435f6e4c96078b01f281ebf62986b022.ssl.cf3.rackcdn.com/articles/content/How-old-is-my-cat-in-human-years_0af22fe2-0f4a-4b24-821f-695be0d18cee.jpg",
				"https://i2-prod.mirror.co.uk/incoming/article11935245.ece/ALTERNATES/s615/SWNS_SELFIE_CATS_011.jpg"
			][Int(arc4random()%5)]
		)
		newUser.addToPhotos(newImage)
		
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
	
	// MARK: - Segues
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			if let indexPath = tableView.indexPathForSelectedRow {
				let object = fetchedResultsController.object(at: indexPath)
				let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
				controller.detailItem = object
				controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}
	
	// MARK: - Table View
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let user = fetchedResultsController.object(at: indexPath)
		configureCell(cell, withUser: user)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let context = fetchedResultsController.managedObjectContext
			context.delete(fetchedResultsController.object(at: indexPath))
			
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	func configureCell(_ cell: UITableViewCell, withUser user: User) {
		cell.textLabel!.text = user.fullName
	}
	
	// MARK: - Fetched results controller
	
	lazy var fetchedResultsController: NSFetchedResultsController<User> = {
		let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
		
		let sortDescriptor = NSSortDescriptor(key: "firstName", ascending: true) /* Sort by firstName */
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
		aFetchedResultsController.delegate = self
		
		do {
			try aFetchedResultsController.performFetch()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
		
		return aFetchedResultsController
	}()
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.fetchedResultsControllerWillChangeContent()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		tableView.fetchedResultsControllerDidChange(section: sectionInfo, atIndex: sectionIndex, forChangeType: type)
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		tableView.fetchedResultsControllerDidChange(object: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.fetchedResultsControllerDidChangeContent()
	}
	
}
