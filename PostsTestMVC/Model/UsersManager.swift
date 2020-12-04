//
//  UsersManager.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation
class UsersManager {
   
   private lazy var usersQueue = DispatchQueue(label: "Users.Serving.Queue")
   
   var dataLoader:DataLoader?
   
   convenience init(dataLoader:DataLoader?) {
      self.init()
      self.dataLoader = dataLoader
   }
   
   
   func getUserWithId(userId:Int, completion:((User?) -> ())? = nil) {
      guard userId > 0 else {
         performOnMainQueue {
            completion?(nil)
         }
         
         return
      }
      
      usersQueue.async {[weak self] in
         if let storedUser = self?.loadUserFromStorageBy(userId) {
            performOnMainQueue {
               completion?(storedUser)
            }
            return
         }
       
         //start loading user by Id
         
         guard let loader = self?.dataLoader else {
            completion?(nil)
            return
         }
         
         loader.loadUserWithID(userId) {[weak self] (aUser) in
            if let weakerSelf = self, let user = aUser {
               
               let savedUser = weakerSelf.saveUserToDocuments(user: user)
               
               #if DEBUG
               print("User '\(user.id)' was saved to documents: \(savedUser)")
               #endif
               
               if let user = weakerSelf.loadUserFromStorageBy(userId) {
                  performOnMainQueue {
                     completion?(user) //SUCCESS getUserWith
                  }
               }
               else {
                  performOnMainQueue {
                     completion?(nil)
                  }
               }
               
            }
            else {
               performOnMainQueue {
                  completion?(nil)
               }
            }
         }
      }
   }
   
   private func loadUserFromStorageBy(_ userId:Int) -> User? {
      
      guard let userFileURL = userFileURL(for: userId),
            FileManager.default.fileExists(atPath: userFileURL.path) else {
         return nil
      }
      
      return DocumentsFolderReader.readDataFromDocuments(for: .user, at: userFileURL)
   }
   
   @discardableResult
   private func saveUserToDocuments(user:User) -> Bool {
      
      guard let userFileURL = userFileURL(for: user.id) else {
         return false
      }
      
      return DocumentsFolderWriter.writeEntity(user, toURL: userFileURL)
   }
}

fileprivate func userFileURL(for userId:Int) -> URL? {
   guard let doscURL = documentsURL() else {
      return nil
   }
   
   let postsFileURL = doscURL.appendingPathComponent("User-\(userId).bin")
   return postsFileURL
}
