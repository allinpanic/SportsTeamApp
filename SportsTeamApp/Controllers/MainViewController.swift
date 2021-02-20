//
//  ViewController.swift
//  SportsTeamApp
//
//  Created by Rodianov on 16.09.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  var dataManager = CoreDataManager(modelName: "Team")
  
  // MARK: - Private properties
  private var players: [Player] = []
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
 // MARK: - ViewWillAppear
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetchData()
    
    playerTableView.reloadData()
    
  }
 // MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white
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
// MARK: - TableView Delegate, DataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return players.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "Tablecell", for: indexPath) as? PlayerTableViewCell else {return UITableViewCell()}
    
    cell.player = players[indexPath.row]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      dataManager.delete(object: players[indexPath.row])
      fetchData()
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
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
    players.removeAll()
    fetchData(predicate: selectedpredicate)
    playerTableView.reloadData()
  }
}

extension MainViewController {
  private func fetchData(predicate: NSCompoundPredicate? = nil) {
    let allPlayers = dataManager.fetchData(for: Player.self, predicate: predicate)
    
    switch inPlaySegmentedControl.selectedSegmentIndex {
    case 0:
      players = allPlayers
    case 1:
      players = allPlayers.filter({$0.inPlay})
    case 2:
      players = allPlayers.filter({!$0.inPlay})
    default:
      break
    }
    
    if allPlayers.isEmpty {
      playerTableView.isHidden = true
      emptyStorageLabel.isHidden = false
    } else {
      playerTableView.isHidden = false
      emptyStorageLabel.isHidden = true
    }
  }
}

extension MainViewController: SearchDelegate {
  func getData(withPredicate: NSCompoundPredicate) {
    fetchData(predicate: withPredicate)
    selectedpredicate = withPredicate
    playerTableView.reloadData()
  }
}
