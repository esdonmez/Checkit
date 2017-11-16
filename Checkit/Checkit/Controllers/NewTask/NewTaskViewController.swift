//
//  NewTaskViewController.swift
//  Checkit
//
//  Created by Onur Celik on 13.11.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController {

    @IBOutlet weak var headerTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var dateTimeTextField: UITextField!
    let picker = UIDatePicker()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        createDatePicker()
    }

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if dateTimeTextField.text != "" && headerTextField.text != "" && noteTextField.text != "" {
            let item = TaskModel(header: headerTextField.text!, note: noteTextField.text!, date: dateTimeTextField.text!, status: "not done")
            
            NSKeyedUnarchiver.setClass(TaskModel.self, forClassName: "TaskModel")
            let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
            
            if let data = userDefaults?.object(forKey: "taskListWidget") as? Data {
                if var taskList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [TaskModel] {
                    taskList.append(item)
                    
                    NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
                    let data = NSKeyedArchiver.archivedData(withRootObject: taskList)
                    let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
                    userDefaults?.removeObject(forKey: "taskListWidget")
                    userDefaults!.set(data, forKey: "taskListWidget")
                    userDefaults!.synchronize()
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func createDatePicker() {
        picker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor(red: 189/255, green: 194/255, blue: 201/255, alpha: 1)
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        doneButton.tintColor = UIColor.black
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        cancelButton.tintColor = UIColor.black
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        dateTimeTextField.inputAccessoryView = toolbar
        dateTimeTextField.inputView = picker
        picker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    
    @objc func donePicker () {
        dateTimeTextField.resignFirstResponder()
    }
    
    @objc func cancelPicker () {
        dateTimeTextField.text = ""
        dateTimeTextField.resignFirstResponder()
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateTimeTextField.text = dateFormatter.string(from: sender.date)
    }
}
