//
//  BookmarkDocument.swift
//  Bookmarks iCloud
//
//  Created by Victor Carreño on 2/14/16.
//  Copyright © 2016 Victor Carreño. All rights reserved.
//
let kArchiveKey  = "Bookmark"

import UIKit

class BookmarkDocument: UIDocument {

    var bookmark:Bookmark!

    override func loadFromContents(contents: AnyObject, ofType typeName: String?) throws {

            let unarchiver:NSKeyedUnarchiver = NSKeyedUnarchiver.init(forReadingWithData: contents as! NSData)
            self.bookmark = unarchiver.decodeObjectForKey(kArchiveKey) as! Bookmark
            unarchiver.finishDecoding()
    }


    override func contentsForType(typeName: String) throws -> AnyObject{

        let data:NSMutableData = NSMutableData.init()
        let archiver:NSKeyedArchiver = NSKeyedArchiver.init(forWritingWithMutableData: data)
        archiver.encodeObject(self.bookmark, forKey: kArchiveKey)
        archiver.finishEncoding()

        return data

    }


}
