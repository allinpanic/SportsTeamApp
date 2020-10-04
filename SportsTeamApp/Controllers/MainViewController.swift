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
    
    
    self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add,
                                                          target: self,
                                                          action: #selector(addButtonPressed)),
                                          animated: true)

    NSLayoutConstraint.activate([
      playerTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      playerTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      playerTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      playerTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      
      emptyStorageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyStorageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
    ])
    
  }  
}
// MARK: - TAbleView Delegate, DataSource

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
}

extension MainViewController {
  private func fetchData() {
    players = dataManager.fetchData(from: Player.self)
    
    if players.isEmpty {
      playerTableView.isHidden = true
      emptyStorageLabel.isHidden = false
    } else {
      playerTableView.isHidden = false
      emptyStorageLabel.isHidden = true
    }    
  }
}

