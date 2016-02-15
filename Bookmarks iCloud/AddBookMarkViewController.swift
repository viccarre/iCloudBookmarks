//
//  AddBookMarkViewController.swift
//  Bookmarks iCloud
//
//  Created by Victor Carreño on 2/14/16.
//  Copyright © 2016 Victor Carreño. All rights reserved.
//

import UIKit

protocol AddBookMarkDelegate{
    func addNewBookMark(controller:AddBookMarkViewController,newBookmark:Bookmark)
}

class AddBookMarkViewController: UIViewController {

    var delegate:AddBookMarkDelegate! = nil

    @IBOutlet var name: UITextField!
    @IBOutlet var url: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func save(sender: AnyObject) {

        let bookmark = Bookmark.init(name: name.text!, URL: url.text!)
        //self.viewController = MasterViewController()
        //self.viewController?.saveBookmark(bookmark)

        delegate!.addNewBookMark(self, newBookmark: bookmark)

        //delegate!.(self, text: colorLabel.text)


        self.dismissViewControllerAnimated(true, completion: nil)

    }

    /*
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

        self.viewController?.bookmarks.addObject(document)
        self.viewController?.tableView.reloadData()

        document.saveToURL(bookmarURL, forSaveOperation: .ForCreating, completionHandler: {(success: Bool) -> Void in
            if success {
                print("iCloud create OK")
            } else {
                print("iCloud create failed")
            }
        })

    }*/



}
