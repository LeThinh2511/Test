//
//  Package.swift
//  Test
//
//  Created by Techchain on 6/26/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

/// Using this class to wrap a pair of tableView and its dataSource
class Package<T> {
    var tableView: UITableView
    var dataSource: DataSource<T>
    
    init(tableView: UITableView, dataSource: DataSource<T>) {
        self.tableView = tableView
        self.dataSource = dataSource
    }
}
