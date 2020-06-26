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
        switch recognizer.state {
        case .began:
            handleLongPress(pressPoint: pressPoint, pressCell: cell, in: sourcePackage!)
        case .changed:
            handleDrag(to: pressPoint)
        case .ended:
            handleRelease()
        case .failed, .possible, .cancelled:
            // TODO: Long press and release repeatedly cause bug
            handleRelease()
        @unknown default:
            break
        }
    }
    
    func handleLongPress(pressPoint: CGPoint, pressCell: UITableViewCell, in package: Package<CellType>) {
        // Find pressed cell and take a snapshot to move
        if let indexPath = package.tableView.indexPath(for: pressCell),
            let snapshot = pressCell.snapshotView(afterScreenUpdates: false) {
                let cellType = package.dataSource.item(at: indexPath.row)
            snapshot.center = pressPoint
            dragView = snapshot
            view.addSubview(snapshot)
            // Save drag item's information
            sourceCenter = package.tableView.convert(pressCell.center, to: view)
            sourceIndexHolder = indexPath
            dragCellType = cellType
            // Replace cell by placeholder cell
            replaceCell(at: indexPath, with: .placeHolder, target: .source)
        }
    }
    
    func handleDrag(to point: CGPoint) {
        dragView.center = point
        guard let destinationPackage = getPackage(contains: point), destinationPackage.tableView != sourcePackage?.tableView else {
            // Reset destination's info when drag cell outside previous destination
            if let indexPath = self.destinationIndexHolder {
                removeCell(at: indexPath, target: .destination)
                self.destinationPackage = nil
                self.destinationIndexHolder = nil
            }
            return
        }
        // In case the package which contain current point has found
        self.destinationPackage = destinationPackage
        let desTableView = destinationPackage.tableView
            // Get location in destination tableView(drag point -> cell index -> center point)
        let location = view.convert(point, to: desTableView)
        guard let indexPath = getIndexPath(ofCellAt: location, in: desTableView), let desPoint = desTableView.cellForRow(at: indexPath)?.center else {
            return
        }
            // Insert place holder cell in destination tableView
        if let indexPathHolder = destinationIndexHolder {
            guard indexPathHolder != indexPath else { return }
            removeCell(at: indexPathHolder, target: .destination)
            insert(cellType: .placeHolder, at: indexPath, target: .destination)
        } else {
            insert(cellType: .placeHolder, at: indexPath, target: .destination)
        }
        destinationIndexHolder = indexPath
        destinationCenter = desTableView.convert(desPoint, to: view)
    }
    
    func handleRelease() {
        if let firstIndexPathHolder = sourceIndexHolder, let secondIndexPathHolder = destinationIndexHolder, let dragCellType = dragCellType {
            // Move drag cell to destination tableView
            removeCell(at: firstIndexPathHolder, target: .source)
            UIView.animate(withDuration: 0.5, animations: {
                self.dragView.center = self.destinationCenter
            }) { completed in
                self.replaceCell(at: secondIndexPathHolder, with: dragCellType, target: .destination)
                self.resetState()
            }
        } else {
            // Move drag cell to source tableView
            UIView.animate(withDuration: 0.5, animations: {
                self.dragView.center = self.sourceCenter
            }) { completed in
                guard let firstIndexPathHolder = self.sourceIndexHolder,
                    let cellType = self.dragCellType else { return }
                self.replaceCell(at: firstIndexPathHolder, with: cellType, target: .source)
                self.resetState()
            }
        }
    }
    
    // MARK: Helper
    /// Get the package contains tableView which contains a point in viewController's view
    func getPackage(contains point: CGPoint) -> Package<CellType>? {
        for package in packages {
            if package.tableView.frame.contains(point) {
                return package
            }
        }
        return nil
    }
    
    // Replace a cell by another in a tableView (destination/source tableView)
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
    
    // insert a cell to a target tableView (destination/source tableView)
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
    
    // Remove a cell from a target tableView (destination/source tableView)
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
    
    /// Reset to the original state
    func resetState() {
        dragCellType = nil
        dragView.removeFromSuperview()
        dragView = UIView()
        sourceCenter = .zero
        destinationCenter = .zero
        sourceIndexHolder = nil
        destinationIndexHolder = nil
        sourcePackage = nil
        destinationPackage = nil
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
    
    /// Get cell at a specific point in a tableView
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
    /// Cell Wrapper to use multiple cellType in table view
    enum CellType {
        case animal(_ animal: Animal)
        case placeHolder
    }
    
    enum Target {
        case source
        case destination
    }
}
