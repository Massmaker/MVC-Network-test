//
//  StoragePaths.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation

func documentsURL() -> URL? {
   var docsUrl:URL?
   
   let fileMan = FileManager.default
   
   guard let aUrl = fileMan.urls(for: .documentDirectory,
                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else {
                                    return nil
   }
   
   docsUrl = aUrl
   return docsUrl
}
