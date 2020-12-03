//
//  CommentsModel.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation
import UIKit

class CommentsModel:NSObject {
   
   weak var table:UITableView?
   private var _isNeedReload = false
   
   var comments:[Comment] = [Comment]() {
      didSet {
         if _isNeedReload {
            table?.reloadData()
         }
      }
   }
   
   convenience init (tableView:UITableView?) {
      self.init()
      
      table = tableView
      
      let cellNib = UINib(nibName: CommentCell.reuseIdentifier, bundle: nil)
      table?.register(cellNib, forCellReuseIdentifier: CommentCell.reuseIdentifier)
      table?.dataSource = self
   }
   
   func setNeedsReload() {
      _isNeedReload = true
   }
}

extension CommentsModel : UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return comments.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier,
                                               for: indexPath)
      let comment = comments[indexPath.row]
      var content = cell.defaultContentConfiguration()
      
      content.text = comment.body
      content.secondaryText = comment.name
      
      cell.contentConfiguration = content
      return cell
   }
   
   
}
