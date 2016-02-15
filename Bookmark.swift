//
//  Bookmark.swift
//  Bookmarks iCloud
//
//  Created by Victor Carreño on 2/13/16.
//  Copyright © 2016 Victor Carreño. All rights reserved.
//
let kBookmarkName = "Bookmark Name"
let kBookmarkURL  = "Bookmark URL"

import UIKit

class Bookmark: NSObject, NSCoding {

    var name: String?
    var URL: String?

    override init() {}

    init(name:String, URL:String){
            self.name = name
            self.URL = URL
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: kBookmarkName)
        aCoder.encodeObject(self.URL, forKey: kBookmarkURL)

    }

    required init(coder aDecoder: NSCoder) {

        if let nameDecoded = aDecoder.decodeObjectForKey(kBookmarkName) as? String{
            self.name = nameDecoded
        }

        if let urlDecoded = aDecoder.decodeObjectForKey(kBookmarkURL) as? String{
            self.URL = urlDecoded
        }

    }


}
