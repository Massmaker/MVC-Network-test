//
//  GlobalFunctions.swift
//  PostsTestMVC
//
//  Created by Ivan Yavorin on 03.12.2020.
//

import Foundation

func performOnMainQueue(_ block:@escaping()->()) {
   DispatchQueue.main.async {
      block()
   }
}
