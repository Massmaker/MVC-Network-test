//
//  PostDetailsViewController.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import UIKit

class PostDetailsViewController: UIViewController {

   @IBOutlet private weak var postTitleLabel:UILabel?
   @IBOutlet private weak var postBodyTextView:UITextView?
   @IBOutlet private weak var postAuthorTextLabel:UILabel?
   @IBOutlet private weak var commentsTable:UITableView?
   
   var commentsManager:CommentsManager?
   var usersManager:UsersManager?
   
   private var commentsModel:CommentsModel?
   
   private var postAuthor:User? {
      didSet {
         if let anAuthor = postAuthor {
            postAuthorTextLabel?.text = "\(anAuthor.username)"
         }
      }
   }
   
   var post:Post? {
      
      didSet {
         if let aPost = post {
            
            if commentsManager == nil {
               commentsManager = CommentsManager(dataLoader: DataLoader.sharedInstance)
            }
            
            commentsManager?.getCommentsFor(aPost.id, completion: {[weak self] (comments) in
               self?.commentsModel?.setNeedsReload()
               self?.commentsModel?.comments = comments
            })
            
            if usersManager == nil {
               usersManager = UsersManager(dataLoader: DataLoader.sharedInstance)
            }
            
            usersManager?.getUserWithId(userId: aPost.userID, completion: {[weak self] (user) in
               self?.postAuthor = user
            })
  
         }
         
      }
   }
   
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      commentsModel = CommentsModel(tableView:commentsTable)
      // Do any additional setup after loading the view.
      
      postTitleLabel?.text = post?.title
      postBodyTextView?.text = post?.body
      
      if let postText = postBodyTextView {
         postText.layer.shadowOpacity = 1.0
         postText.layer.shadowRadius = 3.0
         postText.layer.masksToBounds = false
         postText.layer.cornerRadius = 10.0
         postText.layer.shadowOffset = CGSize.zero
         postText.layer.shadowColor = UIColor.lightGray.cgColor
      }
   }
   
   override func viewWillAppear(_ animated: Bool) {
      guard let post = post else {
         return
      }
      #if DEBUG
      print("Loading Data for post: '\(post.title)'")
      #endif
   }
}
