//
//  CommentsManager.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation

class CommentsManager: DataManagerType {
   
   //MARK: DataManagerType
   var dataLoader:DataLoader?
   
   internal lazy var workerQueue: DispatchQueue = DispatchQueue(label: "Comments.Serving.Queue")
   
   required init(dataLoader:DataLoader?) {
      self.dataLoader = dataLoader
   }
   
   //MARK: -
   /// - Returns: an array of comments or an empty array in the **completion** block
   func getCommentsFor(_ postId:Int, completion:@escaping (([Comment]) -> ())) {
      
      workerQueue.async { [weak self]  in
         
         // return previously loaded comments for this post
         if let storedComments = self?.loadCommentsFromStorage(for: postId) {
            
            performOnMainQueue {
               completion(storedComments) //success
            }
            return
         }
         
         //otherwise try to load comments and then return them
         guard let loader = self?.dataLoader else {
            performOnMainQueue {
               completion([Comment]())
            }
            return
         }
         
         loader.loadCommentsForPost(postId) { (comments) in
            
            if let receivedComments = comments, !receivedComments.isEmpty {
               
               guard let weakSelf = self else {
                  completion([Comment]())
                  return
               }
               
               let saved = weakSelf.saveCommentsToStorage(receivedComments, for: postId)
                  
               #if DEBUG
               print("Comments Saved: '\(saved)'")
               #endif
               
               //anyway use the saved-to-disk COMMENTs or don`t return result
               if let storedComments = self?.loadCommentsFromStorage(for: postId) {
                  performOnMainQueue {
                     completion(storedComments) //success
                  }
               }
               else {
                  performOnMainQueue {
                     completion([Comment]())
                  }
               }
               
            }
            else {
               //no comments loaded from the API
               performOnMainQueue {
                  completion([Comment]())
               }
            }
         }
      }
   }
   
   /// - Returns: Not empty comments array or nil
   private func loadCommentsFromStorage(for postId:Int) -> [Comment]? {
      
      guard let commentsFileURL = commentsFileURL(for: postId) else {
         return nil
      }
      
      return DocumentsFolderReader.readDataFromDocuments(for: .comments, at: commentsFileURL)
   }
   
   @discardableResult
   private func saveCommentsToStorage(_ comments:[Comment], for postId:Int) -> Bool {
      
      guard let commentsFileURL = commentsFileURL(for: postId) else {
         return false
      }
      
      return DocumentsFolderWriter.writeEntity(comments, toURL: commentsFileURL)
   }
}

//MARK: -

fileprivate func commentsFileURL(for postId:Int) -> URL? {
   
   guard let doscURL = documentsURL() else {
      return nil
   }
   
   let postsFileURL = doscURL.appendingPathComponent("Comments-\(postId).bin")
   
   return postsFileURL
}
