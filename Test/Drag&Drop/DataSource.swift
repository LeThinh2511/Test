//
//  DataSource.swift
//  Test
//
//  Created by Techchain on 6/26/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import Foundation

/// Wrapper used to shared the reference to an item list
class DataSource<T> {
    var items = [T]()
    
    init() {}
    
    init(items: [T]) {
        self.items = items
    }
    
    var count: Int {
        return items.count
    }
    
    func item(at index: Int) -> T {
        return items[index]
    }
    
    func remove(at index: Int) {
        items.remove(at: index)
    }
    
    func append(_ item: T) {
        items.append(item)
    }
    
    func insert(_ item: T, at index: Int) {
        items.insert(item, at: index)
    }
}

