//
//  PostsManager.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation

class PostsManager {
   
   var dataLoader:DataLoader?
   
   private static var fileManager = FileManager.default
   private var _isPostsInProcess = false
   private lazy var postsQueue:DispatchQueue = DispatchQueue(label: "Posts.Serving.Queue")
   
   
   convenience init(dataLoader:DataLoader?) {
      self.init()
      self.dataLoader = dataLoader
   }
   
   //MARK: - POSTs
   
   var isRequestingPosts: Bool {
      return _isPostsInProcess
   }
   
   func getPosts(_ completion:@escaping ([Post]) -> ()) {
      
      if _isPostsInProcess {
         
         performOnMainQueue {
            completion([Post]())
         }
         return
      }
      
      _isPostsInProcess = true
      
      postsQueue.async {[unowned self] in
         
         if let storedPosts = readPostsFromDocumentsFile() {
            #if DEBUG
            print("PostsModel -> returning POSTs from Documents file.")
            #endif
            performOnMainQueue {
               completion(storedPosts)
            }
            _isPostsInProcess = false
            return
         }
     
         if let loader = dataLoader {
            
            loader.loadPosts { [weak self]  (postsArray) in
               
               guard let weakSelf = self,
                     let posts = postsArray,
                     !posts.isEmpty else {
                  
                  performOnMainQueue {
                     completion([Post]())
                  }
                  self?._isPostsInProcess = false
                  return
               }
               
               let success = weakSelf.savePosts(posts)
               
               #if DEBUG
               print("PostsModel -> POSTs saved to Documents: \(success)")
               #endif
               
               if let newPosts = weakSelf.readPostsFromDocumentsFile() {
                  performOnMainQueue {
                     completion(newPosts)
                  }
               }
               else {
                  performOnMainQueue {
                     completion([Post]())
                  }
               }
               
               weakSelf._isPostsInProcess = false
               
            }
         }
      }//async end
      
   }
   
   @discardableResult
   private func savePosts(_ posts:[Post]) -> Bool {
      
         guard let postsURL = postsFileURL() else {
            return false
         }
         
         do {
            let encodedPostsData = try JSONEncoder().encode(posts)
            
            try encodedPostsData.write(to: postsURL)
            
            return true
         }
         catch (let encodeError) {
            #if DEBUG
            print("PostsModel -> Encoding POSTs error: \(encodeError.localizedDescription)")
            #endif
            return false
         }
   }
   
   /// - Returns: Not empty array or nil
   private func readPostsFromDocumentsFile() -> [Post]? {
      
      guard let postsURL = postsFileURL() else {
         return nil
      }
      
      guard Self.fileManager.fileExists(atPath: postsURL.path) else {
         return nil
      }
      
      do {
         let data = try Data(contentsOf: postsURL)
         
         let posts = try JSONDecoder().decode([Post].self, from: data)
         
         if posts.isEmpty {
            return nil
         }
         
         return posts
      }
      catch (let dataReadingError) {
         #if DEBUG
         print("PostsModel -> ERROR decoding posts from file: \(dataReadingError.localizedDescription)")
         #endif
         return nil
      }
   }
}

//MARK: -
fileprivate func postsFileURL() -> URL? {
   guard let doscURL = documentsURL() else {
      return nil
   }
   
   let postsFileURL = doscURL.appendingPathComponent("Posts.bin")
   return postsFileURL
}
