//
//  PlayerTableViewCell.swift
//  SportsTeamApp
//
//  Created by Rodianov on 16.09.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import Foundation
import UIKit

final class PlayerTableViewCell: UITableViewCell {

  var player: Player! {
    didSet {
      guard let imageData = player.image else {return}
      playerImageView.image = UIImage(data: imageData)
      fullNameLabel.text = player.fullName
      numberLabel.text = "\(player.teamNumber)"
      playerInfoView.configureView(player: player)
      //guard let player = player else {return}
      if player.inPlay {
        inPlayLabel.text = "In Play"
      } else {
        inPlayLabel.text = "Bench"
      }
    }
  }
  // MARK: - Private Properties
  
  private var playerImageView: UIImageView! = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  
  private var fullNameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 14, weight: .bold)
    label.text = "player fullname"
    return label
  }()
  
  private let playerInfoView: PlayerInfoView = {
    let view = PlayerInfoView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let numberLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 16, weight: .bold)
    label.textColor = .white
    label.text = "11"
    return label
  }()
  
  private let blueView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 4
    view.backgroundColor = UIColor(named: "teamBlue")
    return view
  }()
  
  private let inPlayLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 14)
    label.textColor = .orange
    label.text = "Bench9999"
    return label
  }()
  
  // MARK: - Inits
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - SetupLayout
extension PlayerTableViewCell {
  private func setupLayout() {
    contentView.addSubview(playerImageView)
    contentView.addSubview(fullNameLabel)
    contentView.addSubview(playerInfoView)
    contentView.addSubview(blueView)
    contentView.addSubview(numberLabel)
    contentView.addSubview(inPlayLabel)
    
    NSLayoutConstraint.activate([
      blueView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      blueView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      blueView.heightAnchor.constraint(equalToConstant: 20),
      blueView.widthAnchor.constraint(equalToConstant: 20),
      
      numberLabel.centerXAnchor.constraint(equalTo: blueView.centerXAnchor),
      numberLabel.centerYAnchor.constraint(equalTo: blueView.centerYAnchor),
      
      fullNameLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 8),
      fullNameLabel.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
      
      inPlayLabel.trailingAnchor.constraint(equalTo: playerInfoView.trailingAnchor),
      inPlayLabel.bottomAnchor.constraint(equalTo: blueView.bottomAnchor),
      
      playerImageView.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 8),
      playerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      playerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      playerImageView.heightAnchor.constraint(equalToConstant: 105),
      playerImageView.widthAnchor.constraint(equalToConstant: 105),
      
      playerInfoView.topAnchor.constraint(equalTo: playerImageView.topAnchor),
      playerInfoView.leadingAnchor.constraint(equalTo: playerImageView.trailingAnchor, constant: 20),
      playerInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
      playerInfoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      playerInfoView.heightAnchor.constraint(equalToConstant: 105)
    ])
  }
}
