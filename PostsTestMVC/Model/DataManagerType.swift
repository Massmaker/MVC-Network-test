//
//  DataManagerType.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 04.12.2020.
//

import Foundation

protocol DataManagerType {
   var workerQueue:DispatchQueue {get}
   var dataLoader:DataLoader? {get}
   init(dataLoader:DataLoader?)
}
