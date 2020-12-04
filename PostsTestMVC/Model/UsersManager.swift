//
//  UsersManager.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation
class UsersManager: DataManagerType {
   
   //MARK: DataManagerType
   var dataLoader:DataLoader?
   
   internal lazy var workerQueue: DispatchQueue = DispatchQueue(label: "Users.Serving.Queue")
   
   required init(dataLoader:DataLoader?) {
      self.dataLoader = dataLoader
   }
   
   //MARK: -
   func getUserWithId(userId:Int, completion:((User?) -> ())? = nil) {
      guard userId > 0 else {
         performOnMainQueue {
            completion?(nil)
         }
         
         return
      }
      
      workerQueue.async {[weak self] in
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
               
               //anyway use the saved-to-disk USER or don`t return result
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
      
      guard let userFileURL = userFileURL(for: userId) else {
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

//MARK: -

fileprivate func userFileURL(for userId:Int) -> URL? {
   
   guard let doscURL = documentsURL() else {
      return nil
   }
   
   let postsFileURL = doscURL.appendingPathComponent("User-\(userId).bin")
   
   return postsFileURL
}
