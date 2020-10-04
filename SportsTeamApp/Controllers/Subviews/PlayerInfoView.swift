//
//  PlayerInfoView.swift
//  SportsTeamApp
//
//  Created by Rodianov on 16.09.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import Foundation
import UIKit

final class PlayerInfoView: UIView {
  
  private let teamLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Team"
    label.font = .systemFont(ofSize: 14, weight: .bold)
    return label
  }()
  
  private let teamNameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12)
    label.text = "Player team"
    return label
  }()
  
  private let nationalityLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Nationality"
    label.font = .systemFont(ofSize: 14, weight: .bold)
    return label
  }()
  
  private let nationalityPlayerLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12)
    label.text = "some nation"
    return label
  }()
  
  private let positionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Position"
    label.font = .systemFont(ofSize: 14, weight: .bold)
    return label
  }()
  
  private let playerPositionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12)
    label.text = "some position"
    return label
  }()
  
  private let ageLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Age"
    label.font = .systemFont(ofSize: 14, weight: .bold)
    return label
  }()
  
  private let agePlayerLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12)
    label.text = "30"
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension PlayerInfoView {
  private func setupLayout() {
    self.backgroundColor = .systemGray5
    
    let subviews = [ teamLabel, teamNameLabel, nationalityLabel, nationalityPlayerLabel, positionLabel, playerPositionLabel, ageLabel, agePlayerLabel]
    subviews.forEach({self.addSubview($0)})
    
    NSLayoutConstraint.activate([
      teamLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
      teamLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
      
      nationalityLabel.topAnchor.constraint(equalTo: teamLabel.bottomAnchor, constant: 8),
      nationalityLabel.leadingAnchor.constraint(equalTo: teamLabel.leadingAnchor),
      
      positionLabel.topAnchor.constraint(equalTo: nationalityLabel.bottomAnchor, constant: 8),
      positionLabel.leadingAnchor.constraint(equalTo: teamLabel.leadingAnchor),
      
      ageLabel.topAnchor.constraint(equalTo: positionLabel.bottomAnchor, constant: 8),
      ageLabel.leadingAnchor.constraint(equalTo: teamLabel.leadingAnchor),
      
      teamNameLabel.centerYAnchor.constraint(equalTo: teamLabel.centerYAnchor),
      teamNameLabel.leadingAnchor.constraint(equalTo: teamLabel.leadingAnchor, constant: 90),
      
      nationalityPlayerLabel.centerYAnchor.constraint(equalTo: nationalityLabel.centerYAnchor),
      nationalityPlayerLabel.leadingAnchor.constraint(equalTo: teamNameLabel.leadingAnchor),
      
      playerPositionLabel.centerYAnchor.constraint(equalTo: positionLabel.centerYAnchor),
      playerPositionLabel.leadingAnchor.constraint(equalTo: teamNameLabel.leadingAnchor),
      
      agePlayerLabel.centerYAnchor.constraint(equalTo: ageLabel.centerYAnchor),
      agePlayerLabel.leadingAnchor.constraint(equalTo: teamNameLabel.leadingAnchor)
    ])
  }
  
  func configureView(player: Player) {
    teamNameLabel.text = player.team
    nationalityPlayerLabel.text = player.nationality
    playerPositionLabel.text = player.position
    agePlayerLabel.text = "\(player.age)"    
  }
}
