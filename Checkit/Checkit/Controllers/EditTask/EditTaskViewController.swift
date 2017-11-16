//
//  EditTaskViewController.swift
//  Checkit
//
//  Created by Onur Celik on 15.11.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import UIKit

class EditTaskViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {


    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var headerTextField: UITextField!
    let picker = UIDatePicker()
    let pickerView = UIPickerView()
    let toolbar = UIToolbar()
    let statusArray = ["done", "cancel", "postpone", "not done"]
    var indexPath: Int = 0
    var tasks: [TaskModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indexPath = UserDefaults.standard.integer(forKey: "indexPath")
        NSKeyedUnarchiver.setClass(TaskModel.self, forClassName: "TaskModel")
        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
        
        if let data = userDefaults?.object(forKey: "taskListWidget") as? Data {
            if let taskList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [TaskModel] {
                self.tasks = taskList
            }
        }
        
        statusTextField.text = tasks[indexPath].status
        noteTextField.text = tasks[indexPath].note
        headerTextField.text = tasks[indexPath].header
        dateTextField.text = tasks[indexPath].date

        createDatePicker()
        createPickerView()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        tasks.remove(at: indexPath)
        NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
        let data = NSKeyedArchiver.archivedData(withRootObject: tasks)
        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
        userDefaults?.removeObject(forKey: "taskListWidget")
        userDefaults!.set(data, forKey: "taskListWidget")
        userDefaults!.synchronize()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if dateTextField.text != "" && headerTextField.text != "" && noteTextField.text != "" {
            let item = TaskModel(header: headerTextField.text!, note: noteTextField.text!, date: dateTextField.text!, status: statusTextField.text!)
            tasks[indexPath] = item
            
            NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
            let data = NSKeyedArchiver.archivedData(withRootObject: tasks)
            let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
            userDefaults?.removeObject(forKey: "taskListWidget")
            userDefaults!.set(data, forKey: "taskListWidget")
            userDefaults!.synchronize()
            
            dismiss(animated: true, completion: nil)
        }
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
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = picker
        picker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    func createPickerView() {
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.backgroundColor = UIColor.white
        statusTextField.inputView = pickerView
    }
    
    @objc func donePicker () {
        dateTextField.resignFirstResponder()
    }
    
    @objc func cancelPicker () {
        dateTextField.text = ""
        dateTextField.resignFirstResponder()
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusArray[row] as String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        statusTextField.text = statusArray[row]
        pickerView.isHidden = false
        statusTextField.resignFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 120.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
}
