//
//  DocumentsFolderWriter.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 04.12.2020.
//

import Foundation
class DocumentsFolderWriter {
   
   class func writeEntity<T:Encodable>(_ entity:T, toURL:URL) -> Bool {
      
      var didWrite = false
      
      do {
         let encodedPostsData = try JSONEncoder().encode(entity)
         
         try encodedPostsData.write(to: toURL)
         
         didWrite = true
      }
      catch (let encodeError) {
         #if DEBUG
         print("DocumentsFolderWriter -> Encoding \(entity.self) error: \(encodeError.localizedDescription)")
         #endif
      }
      
      return didWrite
   }
}
