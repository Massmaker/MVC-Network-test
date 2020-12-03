//
//  PostsModel.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation
import UIKit

protocol PostsModelDelegate : class {
   func postsModel(_ model:PostsModel, didSelectPost post:Post, at indexPath:IndexPath)
}

class PostsModel: NSObject {
   
   weak var delegate:PostsModelDelegate?
   
   private weak var table:UITableView?
   
   private var _reloadNeeded:Bool = false
   
   var posts:[Post] = [Post]() {
      didSet {
         if _reloadNeeded {
            table?.reloadData()
            _reloadNeeded = false
         }
      }
   }
   
   init(tableView:UITableView) {
      
      super.init()
      
      table = tableView
      
      setNeedsReload()
      
      table?.dataSource = self
      table?.delegate = self
   }
   
   
   func setNeedsReload() {
      _reloadNeeded = true
   }
}

//MARK: - UITableViewDataSource

extension PostsModel:UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "Post Cell", for: indexPath)
       let post = posts[indexPath.row]
       var content = cell.defaultContentConfiguration()
       
       content.text = post.title
       content.secondaryText = post.body
       cell.contentConfiguration = content
       return cell
    }
}

extension PostsModel:UITableViewDelegate {
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      tableView.deselectRow(at: indexPath, animated: true)
      delegate?.postsModel(self, didSelectPost: posts[indexPath.row], at: indexPath)
   }
}
  
