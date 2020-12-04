//
//  PostsManager.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation

class PostsManager: DataManagerType {

   private var _isPostsInProcess = false
   
   //MARK: DataManagerType
   var dataLoader:DataLoader?
   
   internal lazy var workerQueue: DispatchQueue = DispatchQueue(label: "Posts.Serving.Queue")
   
   required init(dataLoader:DataLoader?) {
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
      
      workerQueue.async {[unowned self] in
         
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
               
               let success = weakSelf.savePostsToStorage(posts)
               
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
   private func savePostsToStorage(_ posts:[Post]) -> Bool {
      
      guard let postsURL = postsFileURL() else {
         return false
      }
         
      return DocumentsFolderWriter.writeEntity(posts, toURL: postsURL)
   }
   
   /// - Returns: Not empty array or nil
   private func readPostsFromDocumentsFile() -> [Post]? {
      
      guard let postsURL = postsFileURL() else {
         return nil
      }
      
      return DocumentsFolderReader.readDataFromDocuments(for: .posts, at: postsURL)
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
