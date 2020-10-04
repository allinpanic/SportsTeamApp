//
//  PlayerViewController.swift
//  SportsTeamApp
//
//  Created by Rodianov on 16.09.2020.
//  Copyright © 2020 Rodionova. All rights reserved.
//

import Foundation
import UIKit

class PlayerViewController: UIViewController {
  
  var dataManager: CoreDataManager!
  
  // MARK: - Private properties
  
  private let teams = ["Manchester United", "Real Madrid", "FC Barcelona", "Chelsea FC", "Arsenal", "Liverpool"]
  private let positions = ["Goalkeeper", "Fullback", "Center Back", "Defending Midfielder", "Winger", "Striker", "Attacking Midfielder", "Forward"]
  
  private var activeTextField: UITextField?
  
  private let playerImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.backgroundColor = .systemGray5
    return imageView
  }()
  
  private let numberTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "№"
    textField.borderStyle = .roundedRect
    textField.keyboardType = .numberPad
    return textField
  }()
  
  private let uploadImageButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Upload image", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 16)
    button.sizeToFit()
    button.addTarget(self, action: #selector(uploadImageButtonPressed), for: .touchUpInside)
    return button
  }()
  
  private lazy var imagePickerController: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    return imagePicker
  }()
  
  private lazy var nameTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Name"
    textField.borderStyle = .roundedRect
    textField.delegate = self
    textField.autocorrectionType = .no
    return textField
  }()
  
  private lazy var nationalityTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Nationality"
    textField.borderStyle = .roundedRect
    textField.delegate = self
    textField.autocorrectionType = .no
    return textField
  }()
  
  private lazy var ageTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Age"
    textField.borderStyle = .roundedRect
    textField.keyboardType = .numberPad
    textField.delegate = self
    return textField
  }()
  
  private let teamLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Team:"
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  private let positionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Position:"
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  private lazy var teamPickerLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Press to select"
    label.textColor = .systemBlue
    label.font = .systemFont(ofSize: 16)
    label.sizeToFit()
    label.addGestureRecognizer(self.tapTeamGesture)
    label.isUserInteractionEnabled = true
    return label
  }()
  
  private lazy var positionPickerLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Press to select"
    label.textColor = .systemBlue
    label.font = .systemFont(ofSize: 16)
    label.sizeToFit()
    label.addGestureRecognizer(self.tapPositionGesture)
    label.isUserInteractionEnabled = true
    return label
  }()
  
  private lazy var teamPickerView: UIPickerView = {
    let pickerView = UIPickerView()
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    pickerView.backgroundColor = .white
    pickerView.delegate = self
    pickerView.dataSource = self
    pickerView.isHidden = true
    pickerView.tag = 1
    return pickerView
  }()
  
  private lazy var positionPickerView: UIPickerView = {
    let pickerView = UIPickerView()
    pickerView.translatesAutoresizingMaskIntoConstraints = false
    pickerView.backgroundColor = .white
    pickerView.delegate = self
    pickerView.dataSource = self
    pickerView.isHidden = true
    pickerView.tag = 2
    return pickerView
  }()
  
  private let saveButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Save", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    button.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
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
  
  private lazy var tapForView: UITapGestureRecognizer = {
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapForViewHadler(gestureRecognizer:)))
    return tap
  }()
  // MARK: - ViewDidLoad
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    view.addGestureRecognizer(tapForView)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(PlayerViewController.keyboardWillShow(notification:)),
                                           name: UIResponder.keyboardWillShowNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  
    
    setupLayout()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
  }
}
// MARK: - Handle keyboard

extension PlayerViewController {
  @objc private func keyboardWillShow(notification: NSNotification) {
    
    guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
    let keyboardFrame = keyboardSize.cgRectValue
    
    var shouldMoveViewUp = false
    
    if let activeTextFiled = activeTextField {
      let textFieldBottom = activeTextFiled.convert(activeTextFiled.bounds, to: self.view).maxY
      
      let keyBoardTop = self.view.frame.height - keyboardFrame.height
      
      if textFieldBottom >= keyBoardTop {
        shouldMoveViewUp = true
      }
    }
    
    if shouldMoveViewUp {
      self.view.frame.origin.y = 0 - keyboardFrame.height
    }
  }
  
  @objc private func keyboardWillHide(notification: NSNotification) {
    self.view.frame.origin.y = 0
  }
  
  @objc private func tapForViewHadler(gestureRecognizer: UITapGestureRecognizer) {
     view.endEditing(true)
   }
}

// MARK: - Button and gesture handlers

extension PlayerViewController {
  @objc private func saveButtonPressed() {
    
    if isAnyFieldEmpty() {
      showAlert()
    } else {
      let context = dataManager.getContext()
      
      let player = dataManager.createObject(from: Player.self)
      player.fullName = nameTextField.text
      player.nationality = nationalityTextField.text
      player.position = positionPickerLabel.text
      player.team = teamPickerLabel.text
      
      guard let image = playerImageView.image,
        let imageData = image.pngData() else {return}
      player.image = imageData
      
      guard let numberString = numberTextField.text,
        let number = Int16(numberString) else {return}
      
      guard let ageString = ageTextField.text,
        let ageNumber = Int16(ageString) else {return}
      
      player.age = ageNumber
      player.teamNumber = number
      
      dataManager.save(context: context)
      
      navigationController?.popViewController(animated: true)
    }
  }
  
  @objc private func uploadImageButtonPressed() {
    present(imagePickerController, animated: true, completion: nil)
  }
  
  @objc private func tapTeamHandler(gestureRecognizer: UITapGestureRecognizer) {
    teamPickerView.isHidden = false
  }
  
  @objc private func tapPositionHandler(gestureRecognizer: UITapGestureRecognizer) {
    positionPickerView.isHidden = false
  }
}
// MARK: - Picker Delegate, DataSource

extension PlayerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView.tag {
    case 1:
      return teams.count
    case 2:
      return positions.count
    default:
      return 0
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch pickerView.tag {
    case 1:
      return teams[row]
    case 2:
      return positions[row]
    default:
      return "not specified"
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView.tag {
    case 1:
      teamPickerLabel.text = teams[row]
      teamPickerView.isHidden = true
    case 2:
      positionPickerLabel.text = positions[row]
      positionPickerView.isHidden = true
    default:
      print("something went wrong")
    }
    
    self.view.endEditing(true)
  }
}
// MARK: - UIImagePickerControllerDelegate

extension PlayerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      return
    }
    
    playerImageView.image = image
    
    dismiss(animated: true, completion: nil)
  }
}
// MARK: - UITextFieldDelegate

extension PlayerViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    self.activeTextField = textField
  }
  
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    self.activeTextField = nil
  }
}
// MARK: - SetupLayout

extension PlayerViewController {
  private func setupLayout() {
    let subviews = [playerImageView, numberTextField, uploadImageButton, nameTextField, nationalityTextField, ageTextField, teamLabel, positionLabel, teamPickerLabel, positionPickerLabel, saveButton, teamPickerView, positionPickerView]
    
    subviews.forEach({view.addSubview($0)})
    
    NSLayoutConstraint.activate([
      playerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
      playerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      playerImageView.heightAnchor.constraint(equalToConstant: 180),
      playerImageView.widthAnchor.constraint(equalToConstant: 180),
      
      numberTextField.topAnchor.constraint(equalTo: playerImageView.topAnchor, constant: 7),
      numberTextField.trailingAnchor.constraint(equalTo: playerImageView.trailingAnchor, constant: -7),
      numberTextField.heightAnchor.constraint(equalToConstant: 35),
      numberTextField.widthAnchor.constraint(equalToConstant: 35),
      
      uploadImageButton.topAnchor.constraint(equalTo: playerImageView.bottomAnchor, constant: 7),
      uploadImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      nameTextField.topAnchor.constraint(equalTo: uploadImageButton.bottomAnchor, constant: 15),
      nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
      
      nationalityTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 7),
      nationalityTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
      nationalityTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
      
      ageTextField.topAnchor.constraint(equalTo: nationalityTextField.bottomAnchor, constant: 7),
      ageTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
      ageTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
      
      teamLabel.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 15),
      teamLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
      
      teamPickerLabel.topAnchor.constraint(equalTo: teamLabel.topAnchor),
      teamPickerLabel.leadingAnchor.constraint(equalTo: teamLabel.trailingAnchor, constant: 10),
      
      teamPickerView.centerYAnchor.constraint(equalTo: teamLabel.centerYAnchor),
      teamPickerView.leadingAnchor.constraint(equalTo: teamLabel.trailingAnchor, constant: 4),
      
      positionLabel.topAnchor.constraint(equalTo: teamLabel.bottomAnchor, constant: 15),
      positionLabel.leadingAnchor.constraint(equalTo: teamLabel.leadingAnchor),
      
      positionPickerLabel.topAnchor.constraint(equalTo: positionLabel.topAnchor),
      positionPickerLabel.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor, constant: 10),
      
      positionPickerView.centerYAnchor.constraint(equalTo: positionLabel.centerYAnchor),
      positionPickerView.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor, constant: 4),
      
      saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
    ])
  }
  
  func isAnyFieldEmpty() -> Bool {
    guard let numberField = numberTextField.text,
      let ageField = ageTextField.text,
      let nameField = nameTextField.text,
      let nationalityField = nationalityTextField.text else {
        return true
    }
    
    if !numberField.isEmpty,
    !ageField.isEmpty,
    !nameField.isEmpty,
      !nationalityField.isEmpty,
    playerImageView.image != nil,
    teamPickerLabel.text != "Press to select",
      positionPickerLabel.text != "Press to select" {
      return false
    }
    return true
  }
  
  private func showAlert() {
    let alert = UIAlertController(title: "Some of the fields is empty", message: "Please ,fill the field and try again", preferredStyle: .alert)
    
    let action = UIAlertAction(title: "OK", style: .cancel, handler: {
      [weak self] action in
      self?.dismiss(animated: true, completion: nil)
    })
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}
