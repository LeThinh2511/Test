//
//  Drag&DropViewController.swift
//  Test
//
//  Created by Techchain on 6/24/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class Drag_DropViewController: UIViewController {
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var secondTableView: UITableView!
    
    private var firstDataSource = DataSource<CellType>()
    private var secondDataSource = DataSource<CellType>()
    
    private var dragCellType: CellType?
    private var dragView = UIView()
    private var sourceCenter: CGPoint = .zero
    private var destinationCenter: CGPoint = .zero
    private var sourceIndexHolder: IndexPath?
    private var destinationIndexHolder: IndexPath?
    private var sourcePackage: Package<CellType>?
    private var destinationPackage: Package<CellType>?
    private var packages = [Package<CellType>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstList: [CellType] = [.animal(Animal(name: "dog")),
                           .animal(Animal(name: "cat")),
                           .animal(Animal(name: "chicken")),
                           .animal(Animal(name: "bird"))]
        
        let secondList: [CellType] = [.animal(Animal(name: "fish")),
                            .animal(Animal(name: "crab")),
                            .animal(Animal(name: "shark")),
                            .animal(Animal(name: "human"))]
        firstDataSource.items = firstList
        secondDataSource.items = secondList
        
        packages = [
            Package<CellType>(tableView: firstTableView, dataSource: firstDataSource),
            Package<CellType>(tableView: secondTableView, dataSource: secondDataSource)
        ]
        
        let animalCellID = AnimalCell.id
        let animalNib = UINib(nibName: animalCellID, bundle: nil)
        firstTableView.register(animalNib, forCellReuseIdentifier: animalCellID)
        secondTableView.register(animalNib, forCellReuseIdentifier: animalCellID)
        
        let placeholderCellID = PlaceholderCell.id
        let placeholderNib = UINib(nibName: placeholderCellID, bundle: nil)
        firstTableView.register(placeholderNib, forCellReuseIdentifier: placeholderCellID)
        secondTableView.register(placeholderNib, forCellReuseIdentifier: placeholderCellID)
        
        firstTableView.rowHeight = UITableView.automaticDimension
        firstTableView.estimatedRowHeight = 100
        secondTableView.rowHeight = UITableView.automaticDimension
        secondTableView.estimatedRowHeight = 100
    }
    
    @objc private func didLongPressCell(recognizer: UILongPressGestureRecognizer) {
        guard let cell = recognizer.view as? AnimalCell else { return }
        let pressPoint = recognizer.location(in: view)
        if sourcePackage == nil, let package = getPackage(contains: pressPoint) {
            sourcePackage = package
        }
        let sourceTable = sourcePackage!.tableView
        switch recognizer.state {
        case .began:
            if let indexPath = sourceTable.indexPath(for: cell),
                let snapshot = cell.snapshotView(afterScreenUpdates: false),
                let dragCellType = sourcePackage?.dataSource.item(at: indexPath.row) {
                sourceCenter = cell.center
                snapshot.center = recognizer.location(in: view)
                dragView = snapshot
                view.addSubview(snapshot)
                sourceIndexHolder = indexPath
                self.dragCellType = dragCellType
                replaceCell(at: indexPath, with: .placeHolder, target: .source)
            }
        case .changed:
            guard let destinationPack = getPackage(contains: pressPoint), destinationPack.tableView != sourcePackage?.tableView else {
                return
            }
            self.destinationPackage = destinationPack
            let center = recognizer.location(in: view)
            dragView.center = center
            if destinationPack.tableView.frame.contains(dragView.center) {
                let location = view.convert(center, to: destinationPack.tableView)
                guard let indexPath = getIndexPath(ofCellAt: location, in: destinationPack.tableView) else {
                    return
                }
                if let indexPathHolder = destinationIndexHolder {
                    guard indexPathHolder != indexPath else { return }
                    removeCell(at: indexPathHolder, target: .destination)
                    insert(cellType: .placeHolder, at: indexPath, target: .destination)
                } else {
                    insert(cellType: .placeHolder, at: indexPath, target: .destination)
                }
                destinationIndexHolder = indexPath
            } else if let indexPath = destinationIndexHolder {
                removeCell(at: indexPath, target: .destination)
                destinationIndexHolder = nil
            }
        case .ended, .failed, .possible, .cancelled:
            if let firstIndexPathHolder = sourceIndexHolder, let secondIndexPathHolder = destinationIndexHolder, let dragCellType = dragCellType {
                replaceCell(at: secondIndexPathHolder, with: dragCellType, target: .destination)
                removeCell(at: firstIndexPathHolder, target: .source)
                self.destinationIndexHolder = nil
                self.sourceIndexHolder = nil
                dragView.removeFromSuperview()
                dragView = UIView()
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.dragView.center = self.sourceCenter
                }) { completed in
                    guard let firstIndexPathHolder = self.sourceIndexHolder,
                        let cellType = self.dragCellType else { return }
                    self.replaceCell(at: firstIndexPathHolder, with: cellType, target: .source)
                    self.dragView.removeFromSuperview()
                    self.dragView = UIView()
                    self.destinationIndexHolder = nil
                    self.sourceIndexHolder = nil
                }
            }
        @unknown default:
            break
        }
    }
    
    // MARK: Helper
    func getPackage(contains point: CGPoint) -> Package<CellType>? {
        for package in packages {
            if package.tableView.frame.contains(point) {
                return package
            }
        }
        return nil
    }
    
    func replaceCell(at indexPath: IndexPath, with cellType: CellType, target: Target) {
        switch target {
        case .source:
            sourcePackage?.dataSource.remove(at: indexPath.row)
            sourcePackage?.dataSource.insert(cellType, at: indexPath.row)
            sourcePackage?.tableView.reloadRows(at: [indexPath], with: .none)
        case .destination:
            destinationPackage?.dataSource.remove(at: indexPath.row)
            destinationPackage?.dataSource.insert(cellType, at: indexPath.row)
            destinationPackage?.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func insert(cellType: CellType, at indexPath: IndexPath, target: Target) {
        switch target {
        case .source:
            sourcePackage?.dataSource.insert(cellType, at: indexPath.row)
            sourcePackage?.tableView.insertRows(at: [indexPath], with: .fade)
        case .destination:
            destinationPackage?.dataSource.insert(cellType, at: indexPath.row)
            destinationPackage?.tableView.insertRows(at: [indexPath], with: .fade)
        }
    }
    
    func removeCell(at indexPath: IndexPath, target: Target) {
        switch target {
        case .source:
            sourcePackage?.dataSource.remove(at: indexPath.row)
            sourcePackage?.tableView.deleteRows(at: [indexPath], with: .fade)
        case .destination:
            destinationPackage?.dataSource.remove(at: indexPath.row)
            destinationPackage?.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension Drag_DropViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case firstTableView:
            return firstDataSource.count
        case secondTableView:
            return secondDataSource.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case firstTableView:
            let cellType = firstDataSource.item(at: indexPath.row)
            return getCell(at: indexPath, for: secondTableView, using: cellType)
        case secondTableView:
            let cellType = secondDataSource.item(at: indexPath.row)
            return getCell(at: indexPath, for: secondTableView, using: cellType)
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: TableView Helper
    func getCell(at indexPath: IndexPath, for tableView: UITableView, using cellType: CellType) -> UITableViewCell {
        switch cellType {
        case .animal(let animal):
            let cell = tableView.dequeueReusableCell(withIdentifier: AnimalCell.id, for: indexPath) as! AnimalCell
            cell.config(with: animal)
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPressCell(recognizer:)))
            cell.addGestureRecognizer(longPress)
            return cell
        case .placeHolder:
            let cell = tableView.dequeueReusableCell(withIdentifier: PlaceholderCell.id, for: indexPath) as! PlaceholderCell
            switch dragCellType {
            case .animal(let animal):
                cell.config(with: animal)
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    func getIndexPath(ofCellAt location: CGPoint, in tableView: UITableView) -> IndexPath? {
        let visibleCells = tableView.visibleCells
        for cell in visibleCells {
            if cell.frame.contains(location) {
                return tableView.indexPath(for: cell)
            }
        }
        return nil
    }
}

extension Drag_DropViewController {
    enum CellType {
        case animal(_ animal: Animal)
        case placeHolder
    }
    
    enum Target {
        case source
        case destination
    }
}

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

class Package<T> {
    var tableView: UITableView
    var dataSource: DataSource<T>
    
    init(tableView: UITableView, dataSource: DataSource<T>) {
        self.tableView = tableView
        self.dataSource = dataSource
    }
}
