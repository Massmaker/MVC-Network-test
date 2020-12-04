//
//  CommentsManager.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation

class CommentsManager {
   
   private lazy var commentsQueue = DispatchQueue(label: "Comments.Serving.Queue")
   
   var dataLoader:DataLoader?
   
   convenience init(dataLoader:DataLoader?) {
      self.init()
      self.dataLoader = dataLoader
   }
   
   
   /// - Returns: an array of comments or an empty array in the **completion** block
   func getCommentsFor(_ postId:Int, completion:@escaping (([Comment]) -> ())) {
      
      commentsQueue.async { [weak self]  in
         
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
               
               let saved = weakSelf.saveComments(receivedComments, for: postId)
                  
               #if DEBUG
               print("Comments Saved: '\(saved)'")
               #endif
               
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
      
      guard let commentsFileURL = commentsFileURL(for: postId),
            FileManager.default.fileExists(atPath: commentsFileURL.path) else {
         return nil
      }
      
      do {
         let commentsData = try Data(contentsOf: commentsFileURL)
         let comments = try JSONDecoder().decode([Comment].self, from: commentsData)
         
         if comments.isEmpty {
            return nil
         }
         
         return comments
      }
      catch (let decodeError) {
         #if DEBUG
         print(#function + "Error decoding COMMENTS for POST ID '\(postId)': \(decodeError.localizedDescription)"  )
         #endif
      }
      return nil
   }
   
   @discardableResult
   private func saveComments(_ comments:[Comment], for postId:Int) -> Bool {
      
      guard let commentsFileURL = commentsFileURL(for: postId) else {
         return false
      }
      
      return DocumentsFolderWriter.writeEntity(comments, toURL: commentsFileURL)
   }
}

fileprivate func commentsFileURL(for postId:Int) -> URL? {
   guard let doscURL = documentsURL() else {
      return nil
   }
   
   let postsFileURL = doscURL.appendingPathComponent("Comments-\(postId).bin")
   return postsFileURL
}
