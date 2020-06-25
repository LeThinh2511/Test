//
//  Drag&DropViewController.swift
//  Test
//
//  Created by Techchain on 6/24/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class Drag_DropViewController: UIViewController {
    enum CellType {
        case animal(_ animal: Animal)
        case placeHolder
    }
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var secondTableView: UITableView!
    
    private var firstDataSource = [CellType]()
    private var secondDataSource = [CellType]()
    
    private var dragCellType: CellType?
    private var dragView = UIView()
    private var originalCenter: CGPoint = .zero
    private var secondIndexPathHolder: IndexPath?
    private var firstIndexPathHolder: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstDataSource = [.animal(Animal(name: "dog")),
                           .animal(Animal(name: "cat")),
                           .animal(Animal(name: "chicken")),
                           .animal(Animal(name: "bird"))]
        
        secondDataSource = [.animal(Animal(name: "fish")),
                            .animal(Animal(name: "crab")),
                            .animal(Animal(name: "shark")),
                            .animal(Animal(name: "human"))]
        
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
        switch recognizer.state {
        case .began:
            if let indexPath = firstTableView.indexPath(for: cell),
                let snapshot = cell.snapshotView(afterScreenUpdates: false) {
                originalCenter = cell.center
                snapshot.center = recognizer.location(in: view)
                dragView = snapshot
                dragCellType = firstDataSource[indexPath.row]
                view.addSubview(snapshot)
                firstIndexPathHolder = indexPath
                replaceCell(at: indexPath, in: firstTableView, with: .placeHolder)
            }
        case .changed:
            let center = recognizer.location(in: view)
            dragView.center = center
            if secondTableView.frame.contains(dragView.center) {
                let location = view.convert(center, to: secondTableView)
                guard let indexPath = getIndexPath(ofCellAt: location, in: secondTableView) else {
                    return
                }
                if let indexPathHolder = secondIndexPathHolder {
                    guard indexPathHolder != indexPath else { return }
                    removeCell(in: secondTableView, at: indexPathHolder)
                    insert(cellType: .placeHolder, into: secondTableView, at: indexPath)
                } else {
                    insert(cellType: .placeHolder, into: secondTableView, at: indexPath)
                }
                secondIndexPathHolder = indexPath
            } else if let indexPath = secondIndexPathHolder {
                removeCell(in: secondTableView, at: indexPath)
                secondIndexPathHolder = nil
            }
        case .ended:
            if let firstIndexPathHolder = firstIndexPathHolder, let secondIndexPathHolder = secondIndexPathHolder, let dragCellType = dragCellType {
                replaceCell(at: secondIndexPathHolder, in: secondTableView, with: dragCellType)
                removeCell(in: firstTableView, at: firstIndexPathHolder)
                self.secondIndexPathHolder = nil
                self.firstIndexPathHolder = nil
                dragView.removeFromSuperview()
                dragView = UIView()
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.dragView.center = self.originalCenter
                }) { completed in
                    guard let firstIndexPathHolder = self.firstIndexPathHolder,
                        let cellType = self.dragCellType else { return }
                    self.replaceCell(at: firstIndexPathHolder, in: self.firstTableView, with: cellType)
                    self.dragView.removeFromSuperview()
                    self.dragView = UIView()
                    self.secondIndexPathHolder = nil
                    self.firstIndexPathHolder = nil
                }
            }
        default: break
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
            let cellType = firstDataSource[indexPath.row]
            return getCell(at: indexPath, for: secondTableView, using: cellType)
        case secondTableView:
            let cellType = secondDataSource[indexPath.row]
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
    
    func replaceCell(at indexPath: IndexPath, in tableView: UITableView, with cellType: CellType) {
        switch tableView {
        case firstTableView:
            firstDataSource.remove(at: indexPath.row)
            firstDataSource.insert(cellType, at: indexPath.row)
        case secondTableView:
            secondDataSource.remove(at: indexPath.row)
            secondDataSource.insert(cellType, at: indexPath.row)
        default: break
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func insert(cellType: CellType, into tableView: UITableView, at indexPath: IndexPath) {
        switch tableView {
        case firstTableView:
            firstDataSource.insert(cellType, at: indexPath.row)
        case secondTableView:
            secondDataSource.insert(cellType, at: indexPath.row)
        default: break
        }
        tableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func removeCell(in tableView: UITableView, at indexPath: IndexPath) {
        switch tableView {
        case firstTableView:
            firstDataSource.remove(at: indexPath.row)
        case secondTableView:
            secondDataSource.remove(at: indexPath.row)
        default: break
        }
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
