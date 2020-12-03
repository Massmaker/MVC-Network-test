//
//  DataLoader.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation

fileprivate let requestPath = "http://jsonplaceholder.typicode.com/"



class DataLoader {
   
   static var sharedInstance = DataLoader()
   
   private init() {
      
   }
   
   private enum URLEndpoint:String {
      case posts
      case users
      case comments
   }
   
   lazy var tasksInProgress:[Date:URLSessionDataTask] = [Date:URLSessionDataTask]()
   
   private func getURLRequestFor(_ endpoint:URLEndpoint) -> URLRequest? {
     
      guard let aURL = URL(string: requestPath + endpoint.rawValue) else {
         return nil
      }
      
      var request = URLRequest(url: aURL)
      request.setValue("application-json", forHTTPHeaderField: "ACCEPT")
      
      return request
   }
   
   //MARK: - Posts
   func loadPosts(_ completion:(([Post]?)->())? = nil) {
      
      guard let request = getURLRequestFor(.posts) else {
         completion?(nil)
         return
      }
      
      let dateNow = Date()
      #if DEBUG
      print("\(dateNow) - Posts Loading Starts -->")
      #endif
      
      let task = URLSession.shared.dataTask(with: request) {[weak self] (respData, urlResponse, respError) in
         
         #if DEBUG
         print("\(Date()) - Posts Loading Response<--")
         #endif
         
         if let resp = urlResponse as? HTTPURLResponse {
            let code = resp.statusCode
            #if DEBUG
            print("Response posts: \(Date()) - StatusCode:\(code)")
            #endif
         }
         
         var toProceed = true
         
         if let responseError = respError {
            
            toProceed = false
            
            #if DEBUG
            print("Response posts ERROR:\(responseError.localizedDescription)")
            #endif
         }
         
         if !toProceed {
            if let weakSelf = self {
               weakSelf.tasksInProgress[dateNow] = nil
            }
            completion?(nil)
            return
         }
         
         guard let data = respData, !data.isEmpty else {
            completion?(nil)
            if let weakSelf = self {
               weakSelf.tasksInProgress[dateNow] = nil
            }
            return
         }
         
         // decode JSON into Posts array
         do {
            let postObjects = try JSONDecoder().decode([Post].self, from: data)
            #if DEBUG
            print("Posts decoded: \(postObjects.count)")
            #endif
            completion?(postObjects)
         }
         catch (let jsonError) {
            #if DEBUG
            print("Response posts ERROR decoding:\(jsonError.localizedDescription)")
            #endif
            completion?(nil)
         }
         
         if let weakSelf = self {
            weakSelf.tasksInProgress[dateNow] = nil
         }
         
      }
      
      tasksInProgress[dateNow] = task
      
      //begin loading posts
      task.resume()
   }
   
   //MARK: - Comments
   
   func loadCommentsForPost(_ postId:Int, completion:@escaping (([Comment]?) -> ()) ) {
      guard let allCommentsURLRequest = getURLRequestFor(.comments) else {
         completion([Comment]())
         return
      }
      
      var commentsRequest = allCommentsURLRequest
      //commentsRequest.setValue("\(postId)", forHTTPHeaderField: "postId")
      
      if let absString = allCommentsURLRequest.url?.absoluteString {
         let urlWithParam = absString.appending("?postId=\(postId)")
         if let paramURL = URL(string: urlWithParam) {
            commentsRequest.url = paramURL
         }
      }
      
      let dateNow = Date()
      
      let commentsTask = URLSession.shared.dataTask(with: commentsRequest) {[weak self] (commData, commResponse, commError) in
         
         if let response = commResponse as? HTTPURLResponse {
            let code = response.statusCode
            #if DEBUG
            print("loadCommentsForPost '\(postId)' statusCode: \(code)")
            #endif
         }
         
         var toProceed = true
         
         if let error = commError {
            #if DEBUG
            print("loadCommentsForPost '\(postId)' ERROR: \(error.localizedDescription)")
            #endif
            toProceed = false
         }
         
         guard toProceed,
               let data = commData,
               !data.isEmpty else {
            
            completion(nil)
            //clean the requests queue
            self?.tasksInProgress[dateNow] = nil
            return
         }
         
         // decode JSON into Comments array
         do {
            let commentObjects = try JSONDecoder().decode([Comment].self, from: data)
            #if DEBUG
            print("Comments decoded: \(commentObjects.count)")
            #endif
            completion(commentObjects)
         }
         catch (let jsonError) {
            #if DEBUG
            print("Response comments ERROR decoding:\(jsonError.localizedDescription)")
            #endif
            completion(nil)
         }
      
         //clean the requests queue
         self?.tasksInProgress[dateNow] = nil
      }
      
      //store the reques until it finishes for some needs in the future
      tasksInProgress[dateNow] = commentsTask
      
      commentsTask.resume()
   }
   
//   func loadALLComments(completion:([Comment]) -> ()) {
//      guard let allCommentsURL = getURLRequestFor(.comments) else {
//         completion([Comment]())
//         return
//      }
//
//   }
   
   
   //MARK: - Users
   
   func loadUserWithID(_ userId:Int, completion:@escaping ((User?) -> ())) {
      
      guard let userRequest = getURLRequestFor(.users) else {
         completion(nil)
         return
      }
      
      
      var userRequestWithId = userRequest
      
      if let urlString = userRequest.url?.absoluteString {
         let newAddress = urlString.appending("?id=\(userId)")
         if let newURL = URL(string: newAddress) {
            userRequestWithId.url = newURL
         }
      }
      
      //userRequestWithId.setValue("\(userId)", forHTTPHeaderField: "id")
      
      let dateNow = Date()
      
      let userLoadTask = URLSession.shared.dataTask(with: userRequestWithId) {[weak self] (userData, userResponse, userError) in
         
         if let response = userResponse as? HTTPURLResponse {
            let code = response.statusCode
            #if DEBUG
            print("loadUser '\(userId)' statusCode: \(code)")
            #endif
         }
         
         var toProceed = true
         
         if let error = userError {
            #if DEBUG
            print("loadUser '\(userId)' ERROR: \(error.localizedDescription)")
            #endif
            toProceed = false
         }
         
         guard toProceed,
               let data = userData,
               !data.isEmpty else {
            
            completion(nil)
            //clean the requests queue
            self?.tasksInProgress[dateNow] = nil
            return
         }
         
         // decode JSON into Users array
         do {
            let userObjects = try JSONDecoder().decode([User].self, from: data)
            #if DEBUG
            print("Users decoded: \(userObjects.count)")
            #endif
            completion(userObjects.first)
         }
         catch (let jsonError) {
            #if DEBUG
            print("Response Users ERROR decoding:\(jsonError.localizedDescription)")
            #endif
            completion(nil)
         }
      
         //clean the requests queue
         self?.tasksInProgress[dateNow] = nil
      }
      
      tasksInProgress[dateNow] = userLoadTask
      
      userLoadTask.resume()
   }
}
