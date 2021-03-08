//
//  ViewController.swift
//  SportsTeamApp
//
//  Created by Rodianov on 16.09.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import UIKit
import CoreData

final class MainViewController: UIViewController {
  
  var dataManager = CoreDataManager(modelName: "Team")
  var fetchedResultController: NSFetchedResultsController<Player>!
  
  // MARK: - Private properties
  private var selectedpredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [])
  
  private lazy var playerTableView: UITableView = {
    let tableView = UITableView(frame: .zero)
    tableView.backgroundColor = .white
    
    tableView.register(PlayerTableViewCell.self, forCellReuseIdentifier: "Tablecell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()
  
  private let emptyStorageLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.text = """
    Storage is empty
    
    Add new player
    """
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 20)
    label.textColor = .black
    return label
  }()
  
  private lazy var inPlaySegmentedControl: UISegmentedControl = {
    let segmentControl = UISegmentedControl(items: ["All", "In Play", "Bench"])
    segmentControl.translatesAutoresizingMaskIntoConstraints = false
    segmentControl.selectedSegmentIndex = 0
    segmentControl.addTarget(self, action: #selector(inPlaySegmentedControlChanged), for: .valueChanged)
    return segmentControl
  }()
 // MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white
    
    setupLayout()
    
    fetchData()
  }  
}
// MARK: - TableView Delegate, DataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    guard let sections = fetchedResultController.sections else {return 0}
    
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let sections = fetchedResultController.sections else {return nil}
    
    return sections[section].name
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sections = fetchedResultController.sections else {return 0}
    return sections[section].numberOfObjects
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "Tablecell", for: indexPath) as? PlayerTableViewCell else {return UITableViewCell()}
    
    cell.player = fetchedResultController.object(at: indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
      [weak self] (action, view, completion) in
      
      guard let player = self?.fetchedResultController.object(at: indexPath) else {return}
      
      self?.dataManager.delete(object: player)
      
      completion(true)
    }
    
    let editAction = UIContextualAction(style: .normal, title: "Edit") {
      [weak self] (action, view, completion) in
      let playerViewController = PlayerViewController()
      playerViewController.player = self?.fetchedResultController.object(at: indexPath)
      playerViewController.dataManager = self?.dataManager
      
      self?.navigationController?.pushViewController(playerViewController, animated: true)
      completion(true)
    }
    
    var inPlayTitle = ""
    if fetchedResultController.object(at: indexPath).inPlay {
      inPlayTitle = "Bench"
    } else {
      inPlayTitle = "In Play"
    }
    
    let inPlayAction = UIContextualAction(style: .normal, title: inPlayTitle) {
      [weak self] (action, view, completion) in
      guard let isInPlay = self?.fetchedResultController.object(at: indexPath).inPlay else {return}
      guard let context = self?.dataManager.getContext() else {return}
      
      if isInPlay {
        self?.fetchedResultController.object(at: indexPath).setValue(false, forKey: "inPlay")
        self?.dataManager.save(context: context)
        
        action.title = "In Play"
      } else {
        self?.fetchedResultController.object(at: indexPath).setValue(true, forKey: "inPlay")
        self?.dataManager.save(context: context)
        action.title = "Bench"
      }
      completion(true)
    }
    
    editAction.backgroundColor = .orange
    inPlayAction.backgroundColor = .cyan
    
    return UISwipeActionsConfiguration(actions: [deleteAction, editAction, inPlayAction])
  }
}
// MARK: - Button handler

extension MainViewController {
  @objc private func addButtonPressed() {
    let playerViewController = PlayerViewController()
    playerViewController.dataManager = dataManager
    navigationController?.pushViewController(playerViewController, animated: true)
  }
  
  @objc private func searchButtonPressed() {
    let searchViewController = SearchViewController()
    searchViewController.dataManager = dataManager
    searchViewController.delegate = self
    present(searchViewController, animated: true, completion: nil)
  }
  
  @objc private func inPlaySegmentedControlChanged() {
    fetchData(predicate: selectedpredicate)
    playerTableView.reloadData()
  }
}
// MARK: - FetchData

extension MainViewController {
  private func fetchData(predicate: NSCompoundPredicate? = nil) {

    var fetchPredicate: NSCompoundPredicate? = NSCompoundPredicate(andPredicateWithSubpredicates: [])
    let inPlayPredicate = NSPredicate(format: "inPlay == TRUE")
    let benchPredicate = NSPredicate(format: "inPlay == FALSE")
    
    switch inPlaySegmentedControl.selectedSegmentIndex {
    case 0:
      fetchPredicate = predicate
      
    case 1:
      guard let predicate = predicate else {return}
      fetchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, inPlayPredicate])
      
    case 2:
      guard let predicate = predicate else {return}
      fetchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, benchPredicate])
      
    default:
      break
    }
    
    fetchedResultController = dataManager.fetchDataWithController(for: Player.self, sectionNameKeyPath: "position", predicate: fetchPredicate)
    
    fetchedResultController.delegate = self

    checkStorageIsEmpty()
  }
  
  private func checkStorageIsEmpty() {
    guard let allPlayers = fetchedResultController.fetchedObjects else {return}
    
      if allPlayers.isEmpty {
        playerTableView.isHidden = true
        emptyStorageLabel.isHidden = false
      } else {
        playerTableView.isHidden = false
        emptyStorageLabel.isHidden = true
      }
  }
}
// MARK: - SearchDelegate

extension MainViewController: SearchDelegate {
  func getData(withPredicate: NSCompoundPredicate) {
    fetchData(predicate: withPredicate)
    selectedpredicate = withPredicate
    playerTableView.reloadData()
  }
}
// MARK: - FetchedController Delegate

extension MainViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    playerTableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    
    switch type {
    case .delete:
      playerTableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet,
                                     with: .fade)
    case .insert:
      playerTableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet,
                                     with: .fade)
    default:
      return
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
    switch type {
    case .delete:
      guard let indexPath = indexPath else {return}
      playerTableView.deleteRows(at: [indexPath], with: .fade)

    case .insert:
      guard let newIndexPath = newIndexPath else {return}
      playerTableView.insertRows(at: [newIndexPath], with: .fade)
      
    case .update:
      guard let indexPath = indexPath else {return}
      let cell = playerTableView.cellForRow(at: indexPath) as! PlayerTableViewCell
      let player = fetchedResultController.object(at: indexPath)
      cell.player = player

    case .move:
      guard let indexPath = indexPath,
      let newIndexPath = newIndexPath else {return}

      playerTableView.deleteRows(at: [indexPath], with: .fade)
      playerTableView.insertRows(at: [newIndexPath], with: .fade)
      
    default:
      return
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    playerTableView.endUpdates()
  }
}
// MARK: - SetupLayout

extension MainViewController {
  private func setupLayout() {
    view.addSubview(emptyStorageLabel)
    view.addSubview(playerTableView)
    view.addSubview(inPlaySegmentedControl)
    
    
    self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add,
                                                          target: self,
                                                          action: #selector(addButtonPressed)),
                                          animated: true)
    
    self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .search,
                                                         target: self,
                                                         action: #selector(searchButtonPressed)),
                                         animated: true)

    NSLayoutConstraint.activate([
      inPlaySegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      inPlaySegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      inPlaySegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      
      playerTableView.topAnchor.constraint(equalTo: inPlaySegmentedControl.bottomAnchor, constant: 16),
      playerTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      playerTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      playerTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      
      emptyStorageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyStorageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
    ])
  }
}
