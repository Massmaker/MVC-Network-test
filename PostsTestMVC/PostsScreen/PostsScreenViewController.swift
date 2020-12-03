//
//  ViewController.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import UIKit

class PostsScreenViewController: UIViewController {

   @IBOutlet private weak var postsTable:UITableView?
   
   var postsManager:PostsManager?
   var postsModel:PostsModel?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.

      if postsManager == nil {
         postsManager = PostsManager(dataLoader:DataLoader.sharedInstance)
      }
   }

   override func viewDidAppear(_ animated:Bool) {
      super.viewDidAppear(animated)
      
      postsManager?.getPosts({[weak self] (posts) in
         #if DEBUG
         print("Posts Screen received \(posts.count) POSTs")
         #endif
         
         self?.reloadTableWithPosts(posts)
      })
      
   }
   
   private func reloadTableWithPosts(_ posts:[Post]) {
      if let model = postsModel {
         model.setNeedsReload()
         model.posts = posts
      }
      else {
         if let tableView = postsTable {
            postsModel = PostsModel(tableView:tableView)
            postsModel?.delegate = self
            postsModel?.posts = posts
         }
      }
   }
}

//MARK: - PostsModelDelegate {
extension PostsScreenViewController : PostsModelDelegate {
   func postsModel(_ model: PostsModel, didSelectPost post: Post, at indexPath: IndexPath) {
      let postDetailsScreen = PostDetailsViewController(nibName:"PostDetailsViewController", bundle:nil)
      postDetailsScreen.post = post
      navigationController?.pushViewController(postDetailsScreen, animated: true)
   }
   
   
}

