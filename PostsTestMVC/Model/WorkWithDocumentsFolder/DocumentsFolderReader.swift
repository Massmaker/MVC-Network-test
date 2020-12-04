//
//  DocumentsFolderReader.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 04.12.2020.
//

import Foundation

enum DataType {
   case user
   case posts
   case comments
}

class DocumentsFolderReader {
   
   class func readDataFromDocuments<T:Decodable>(for dataType:DataType, at url: URL) -> T? {
      
      guard FileManager.default.fileExists(atPath: url.path) else {
         return nil
      }
      
      var result:T?
      
      do {
         let data = try Data(contentsOf: url)
         
         switch dataType {
         case .posts:
            let posts = try JSONDecoder().decode([Post].self, from: data)
            result = posts.isEmpty ? nil : (posts as? T)
         case .user:
            let user = try JSONDecoder().decode(User.self, from: data)
            result = user as? T
         case .comments:
            let comments = try JSONDecoder().decode([Comment].self, from: data)
            result = comments.isEmpty ? nil : (comments as? T)
         }
      }
      catch (let dataReadingError) {
         #if DEBUG
         print("DocumentsFolderReader -> ERROR decoding \(dataType) from file: \(dataReadingError.localizedDescription)")
         #endif
      }
      
      return result
   }
}
