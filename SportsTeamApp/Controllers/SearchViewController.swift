//
//  SearchViewController.swift
//  SportsTeamApp
//
//  Created by Rodianov on 19.02.2021.
//  Copyright © 2021 Rodionova. All rights reserved.
//

import Foundation
import UIKit

protocol SearchDelegate: AnyObject {
  func getData(withPredicate: NSCompoundPredicate)
}

final class SearchViewController: UIViewController {
  
  var dataManager: CoreDataManager!
  weak var delegate: SearchDelegate?
  
  // MARK: - Private properties  
  private let searchView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .white
    return view
  }()
  
  private let nameTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Name contains:"
    textField.borderStyle = .roundedRect
    return textField
  }()
  
  private let ageTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Age"
    textField.keyboardType = .numberPad
    textField.borderStyle = .roundedRect
    return textField
  }()
  
  private let segmentedControl: UISegmentedControl = {
    let segmentControl = UISegmentedControl(items: [">=", "=", "<="])
    segmentControl.translatesAutoresizingMaskIntoConstraints = false
    segmentControl.selectedSegmentIndex = 0
    return segmentControl
  }()
  
  private let positionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Position:"
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  private lazy var positionPickerLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Select"
    label.textColor = .systemBlue
    label.font = .systemFont(ofSize: 16)
    label.sizeToFit()
    label.addGestureRecognizer(self.tapPositionGesture)
    label.isUserInteractionEnabled = true
    return label
  }()
  
  private lazy var positionPicker: UIPickerView = {
    let pickerView = UIPickerView()
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    pickerView.backgroundColor = .white
    pickerView.delegate = self
    pickerView.dataSource = self
    pickerView.isHidden = true
    pickerView.tag = 1
    return pickerView
  }()
  
  private let teamLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Team:"
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  private lazy var teamPickerLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Select"
    label.textColor = .systemBlue
    label.font = .systemFont(ofSize: 16)
    label.sizeToFit()
    label.addGestureRecognizer(self.tapTeamGesture)
    label.isUserInteractionEnabled = true
    return label
  }()
  
  private lazy var teamPicker: UIPickerView = {
    let pickerView = UIPickerView()
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    pickerView.backgroundColor = .white
    pickerView.delegate = self
    pickerView.dataSource = self
    pickerView.isHidden = true
    pickerView.tag = 2
    return pickerView
  }()
  
  private let startSearchButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Start search", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    button.sizeToFit()
    button.addTarget(self, action: #selector(startSearchButtonPressed), for: .touchUpInside)
    return button
  }()
  
  private let resetButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Reset", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 16)
    button.sizeToFit()
    button.addTarget(self, action: #selector(resetButtonpressed), for: .touchUpInside)
    return button
  }()
  
  private lazy var tapTeamGesture: UITapGestureRecognizer = {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapTeamHandler(gestureRecognizer:)))
    return tap
  }()
  
  private lazy var tapPositionGesture: UITapGestureRecognizer = {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapPositionHandler(gestureRecognizer:)))
    return tap
  }()
  
  private lazy var tapOnView: UITapGestureRecognizer = {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnViewHadler(gestureRecognizer:)))
    return tap
  }()
  
  private lazy var tapOnBackground: UITapGestureRecognizer = {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnBgHandler(gestureRecognizer:)))
    return tap
  }()
  // MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .lightGray
    view.addGestureRecognizer(tapOnBackground)
    searchView.addGestureRecognizer(tapOnView)
    
    setupLayout()
   
  }
}
// MARK: - Button & Gesture Handlers

extension SearchViewController {
  @objc private func startSearchButtonPressed() {
    print("search button pressed")
    let compoundPredicate = makeCompoundPredicate(name: nameTextField.text!,
                                                  age: ageTextField.text!,
                                                  team: teamPickerLabel.text!,
                                                  position: positionPickerLabel.text!)
    
    delegate?.getData(withPredicate: compoundPredicate)
    
    dismiss(animated: true, completion: nil)
  }
  
  @objc private func resetButtonpressed() {
    delegate?.getData(withPredicate: NSCompoundPredicate(andPredicateWithSubpredicates: []))
    dismiss(animated: true, completion: nil)
  }
  
  @objc private func tapTeamHandler(gestureRecognizer: UITapGestureRecognizer) {
    teamPicker.isHidden = false
  }
  
  @objc private func tapPositionHandler(gestureRecognizer: UITapGestureRecognizer) {
    positionPicker.isHidden = false
  }
  
  @objc private func tapOnViewHadler(gestureRecognizer: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  @objc private func tapOnBgHandler(gestureRecognizer: UITapGestureRecognizer) {
    dismiss(animated: true, completion: nil)
  }
  
  private func makeCompoundPredicate(name: String, age: String, team: String, position: String) -> NSCompoundPredicate {
    var predicates = [NSPredicate]()
    
    print(name,age,team,position)
    
    if !name.isEmpty {
      let namePredicate = NSPredicate(format: "fullName CONTAINS[cd] '\(name)'")
      predicates.append(namePredicate)
    }
    
    if !age.isEmpty {
      let condition = ageCondition(index: segmentedControl.selectedSegmentIndex)
      let agePredicate = NSPredicate(format: "age \(condition) '\(age)'")
      predicates.append(agePredicate)
    }
    
    if team != "Select"{
      let teamPredicate = NSPredicate(format: "team CONTAINS[cd] '\(team)'")
      print("team predicate: \(team)")
      predicates.append(teamPredicate)
    }
    
    if position != "Select" {
      let positionPredicate = NSPredicate(format: "position CONTAINS[cd] '\(position)'")
      print("position predicate: \(position)")
      predicates.append(positionPredicate)
    }
    
    return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
  }
  
  private func ageCondition(index: Int) -> String {
    var condition: String = ""
    
    switch index {
    case 0: condition = ">="
    case 1: condition = "="
    case 2: condition = "<="
    default: break
    }
    return condition
  }
}
// MARK: - PickerView Delegate DataSourse

extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView.tag {
    case 1:
      return Constants.positions.count
    case 2:
      return Constants.teams.count
    default:
      return 0
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch pickerView.tag {
    case 1:
      return Constants.positions[row]
    case 2:
      return  Constants.teams[row]
    default:
      return "not specified"
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView.tag {
    case 1:
      positionPickerLabel.text = Constants.positions[row]
      positionPicker.isHidden = true      
    case 2:
      teamPickerLabel.text = Constants.teams[row]
      teamPicker.isHidden = true
    default:
      print("something went wrong")
    }
    
    self.view.endEditing(true)
  }
}
// MARK: - SetupLayout

extension SearchViewController {
  private func setupLayout() {
    view.addSubview(searchView)
    
    let subviews = [nameTextField,  ageTextField, segmentedControl, positionLabel, positionPickerLabel, teamLabel, teamPickerLabel, teamPicker,positionPicker, startSearchButton, resetButton]
    
    subviews.forEach({searchView.addSubview($0)})
    
    NSLayoutConstraint.activate([
      searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
      searchView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      searchView.heightAnchor.constraint(equalToConstant: 350),
      searchView.widthAnchor.constraint(equalToConstant: 300),
      
      nameTextField.topAnchor.constraint(equalTo: searchView.topAnchor, constant: 16),
      nameTextField.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 16),
      nameTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: -16),

      ageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
      ageTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
      ageTextField.trailingAnchor.constraint(equalTo: segmentedControl.leadingAnchor, constant: -8),

      segmentedControl.centerYAnchor.constraint(equalTo: ageTextField.centerYAnchor),
      segmentedControl.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
      segmentedControl.widthAnchor.constraint(equalToConstant: 110),

      positionLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 23),
      positionLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),

      positionPickerLabel.topAnchor.constraint(equalTo: positionLabel.topAnchor),
      positionPickerLabel.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor, constant: 10),
      
      positionPicker.centerYAnchor.constraint(equalTo: positionPickerLabel.centerYAnchor),

      teamLabel.topAnchor.constraint(equalTo: positionLabel.bottomAnchor, constant: 23),
      teamLabel.leadingAnchor.constraint(equalTo: positionLabel.leadingAnchor),

      teamPickerLabel.topAnchor.constraint(equalTo: teamLabel.topAnchor),
      teamPickerLabel.leadingAnchor.constraint(equalTo: teamLabel.trailingAnchor, constant: 10),
      
      teamPicker.centerYAnchor.constraint(equalTo: teamPickerLabel.centerYAnchor),

      resetButton.bottomAnchor.constraint(equalTo: searchView.bottomAnchor, constant: -20),
      resetButton.centerXAnchor.constraint(equalTo: searchView.centerXAnchor),

      startSearchButton.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -16),
      startSearchButton.centerXAnchor.constraint(equalTo: searchView.centerXAnchor)
    ])
  }
}
