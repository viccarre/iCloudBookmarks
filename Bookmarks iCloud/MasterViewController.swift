//
//  MasterViewController.swift
//  Bookmarks iCloud
//
//  Created by Victor Carreño on 2/13/16.
//  Copyright © 2016 Victor Carreño. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController,AddBookMarkDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()

    var query:NSMetadataQuery?
    var bookmarks = NSMutableArray()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        self.loadBookarks()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {

        performSegueWithIdentifier("addBookmark", sender: self)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "addBookmark"{
            let vc = segue.destinationViewController as! AddBookMarkViewController
            vc.delegate = self
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        //fetch bookmark
        let bookmarkDocument = self.bookmarks.objectAtIndex(indexPath.row) as! BookmarkDocument
        cell.textLabel?.text = bookmarkDocument.bookmark!.name
        cell.detailTextLabel?.text = bookmarkDocument.bookmark!.URL
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {

            //Fetch document
            let bookmarkDocument = self.bookmarks.objectAtIndex(indexPath.row) as! BookmarkDocument

            // Delete Document
            do {
                try NSFileManager.defaultManager().removeItemAtURL(bookmarkDocument.fileURL)
            } catch let error as NSError{
                print("An error occurred while trying to delete document. Error %@ with user info %@.", error, error.userInfo);
            }

            // Update Bookmarks
            self.bookmarks.removeObjectAtIndex(indexPath.row)

            // Update Table View
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }


    func loadBookarks(){

        let baseURL = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
        guard baseURL != nil else {
            print("Unable to access iCloud Account")
            print("Open the Settings app and enter your Apple ID into iCloud settings")
            return
        }

        query = NSMetadataQuery()
        query?.predicate = NSPredicate(format: "%K like '*'", NSMetadataItemFSNameKey)
        query?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "metadataQueryDidFinishGathering:",
            name: NSMetadataQueryDidFinishGatheringNotification,
            object: self.query)

        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "UIDocumentUpdated:", name: NSMetadataQueryDidUpdateNotification, object: self.query)
        self.query!.enableUpdates()
        self.query!.startQuery()

    }

    func metadataQueryDidFinishGathering(notification: NSNotification) -> Void{

        print("Notification received")
        let query: NSMetadataQuery = notification.object as! NSMetadataQuery

        self.bookmarks.removeAllObjects()

        if query.resultCount > 0 {

            for obj in query.results as! [NSMetadataItem]{

                let documentURL = obj.valueForAttribute(NSMetadataItemURLKey) as! NSURL
                let bookmark = BookmarkDocument(fileURL: documentURL)

                bookmark.openWithCompletionHandler({(success: Bool) -> Void in
                    if success {

                        print("iCloud file open OK")
                        self.bookmarks.addObject(bookmark)
                        self.tableView.reloadData()

                    } else {
                        print("iCloud file open failed")
                    }
                })

        }

    }

        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: NSMetadataQueryDidFinishGatheringNotification,
            object: query)
    }

    func UIDocumentUpdated(notification: NSNotification) -> Void{

        print("Notification received")
        let query: NSMetadataQuery = notification.object as! NSMetadataQuery

        self.bookmarks.removeAllObjects()

        if query.resultCount > 0 {

            for obj in query.results as! [NSMetadataItem]{

                let documentURL = obj.valueForAttribute(NSMetadataItemURLKey) as! NSURL
                let bookmark = BookmarkDocument(fileURL: documentURL)

                bookmark.openWithCompletionHandler({(success: Bool) -> Void in
                    if success {
                        print("iCloud file open OK")

                    } else {
                        print("iCloud file open failed")
                    }
                })
                
            }
            
        }

    }


    func saveBookmark(bookmark:Bookmark) {

        //savebookmark
        let baseURL = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)

        guard baseURL != nil else {
            print("Unable to access iCloud Account")
            print("Open the Settings app and enter your Apple ID into iCloud settings")
            return
        }

        let bookmarksURL = (baseURL?.URLByAppendingPathComponent("Documents"))! as NSURL
        let bookmarURL = bookmarksURL.URLByAppendingPathComponent(NSString(format: "Bookmark_%@-%f", bookmark.name!, NSDate().timeIntervalSince1970) as String) as NSURL

        let document = BookmarkDocument(fileURL: bookmarURL)
        document.bookmark = bookmark
        print(bookmark.name)
        print(document.bookmark.name)

        //addbookmarks

        self.bookmarks.addObject(document)
        self.tableView.reloadData()

        document.saveToURL(bookmarURL, forSaveOperation: .ForCreating, completionHandler: {(success: Bool) -> Void in
            if success {
                print("iCloud create OK")
            } else {
                print("iCloud create failed")
            }
        })
        
    }

    func addNewBookMark(controller: AddBookMarkViewController, newBookmark: Bookmark) {
        self.saveBookmark(newBookmark)
    }

}

