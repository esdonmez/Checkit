//
//  TaskViewController.swift
//  Checkit
//
//  Created by Onur Celik on 13.11.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import UIKit
import KCFloatingActionButton
import UserNotifications

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate/*, ExpandableHeaderViewDelegate*/ {
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let picker = UIDatePicker()
    let toolbar = UIToolbar()
    var reordering: Bool = true
    var longPress = UILongPressGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var tasks: [TaskModel] = []
    var filteredTasks = [TaskModel]()
    var searchActive : Bool = false
    var selectedTask: TaskModel = TaskModel(header: "", note: "", date: "", status: "")
    var longPressed: Bool = false
    var date: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTasks()
        
        taskTableView.delegate = self
        taskTableView.dataSource = self
        searchBar.delegate = self

        NSKeyedUnarchiver.setClass(TaskModel.self, forClassName: "TaskModel")
        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
        
        if let data = userDefaults?.object(forKey: "taskListWidget") as? Data {
            if let taskList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [TaskModel] {
                self.tasks = taskList
                //self.tableView.reloadData()
            }
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(TaskViewController.handleLongPress))
        longPress.minimumPressDuration = 1.50;
        taskTableView.addGestureRecognizer(longPress)
        
        self.taskTableView.addSubview(self.refreshControl)
        
        definesPresentationContext = true
        
        let fab = KCFloatingActionButton()
        fab.addItem("Add new task", icon: UIImage(named: "first")!, handler: { item in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "newTaskViewController") as! UINavigationController
            self.present(newViewController, animated: true, completion: nil)
            fab.close()
        })
        fab.addItem("Sort by header", icon: UIImage(named: "first")!, handler: { item in
            self.tasks.sort(by: { $0.header < $1.header })
            self.taskTableView.reloadData()
            fab.close()
        })
        fab.addItem("Sort by date", icon: UIImage(named: "first")!, handler: { item in
            self.tasks.sort(by: { $0.date < $1.date })
            self.taskTableView.reloadData()
            fab.close()
        })
        fab.addItem("Order by status", icon: UIImage(named: "first")!, handler: { item in
            self.tasks.sort(by: { $0.status < $1.status })
            self.taskTableView.reloadData()
            fab.close()
        })
        fab.buttonColor = UIColor.init(red: 254/255, green: 202/255, blue: 11/255, alpha: 1)
        fab.plusColor = UIColor.init(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
        fab.overlayColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
        fab.openAnimationType = KCFABOpenAnimationType.slideLeft

        self.view.addSubview(fab)
    }
    
    func loadTasks() {
        NSKeyedUnarchiver.setClass(TaskModel.self, forClassName: "TaskModel")
        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
        
        if let data = userDefaults?.object(forKey: "taskListWidget") as? Data {
            if let taskList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [TaskModel] {
                self.tasks = taskList
            }
        }
        
        NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
        let data = NSKeyedArchiver.archivedData(withRootObject: tasks)
        let userDefault = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
        userDefault!.set(data, forKey: "taskListWidget")
        userDefault!.synchronize()
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        let touchPoint = longPress.location(in: taskTableView)
        self.longPressed = true
        if taskTableView.indexPathForRow(at: touchPoint) != nil {
            taskTableView.setEditing(true, animated: true)
            reordering = true
        }
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredTasks.count
        }
        
        return tasks.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! TaskTableViewCell
        
        if isFiltering() {
            cell.headerLabel?.text = filteredTasks[indexPath.row].header
            cell.noteLabel?.text = filteredTasks[indexPath.row].note
            cell.dateLabel?.text = filteredTasks[indexPath.row].date
            
            if (filteredTasks[indexPath.row].status == "postpone") {
                cell.colorView.backgroundColor = UIColor.init(red: 222/255, green: 119/255, blue: 49/255, alpha: 1)
            } else if (filteredTasks[indexPath.row].status == "cancel") {
                cell.colorView.backgroundColor = UIColor.init(red: 223/255, green: 36/255, blue: 64/255, alpha: 1)
            } else if (filteredTasks[indexPath.row].status == "done") {
                cell.colorView.backgroundColor = UIColor.init(red: 123/255, green: 191/225, blue: 79/255, alpha: 1)
            } else if (filteredTasks[indexPath.row].status == "not done") {
                cell.colorView.backgroundColor = UIColor.init(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
            }
        } else {
            cell.headerLabel?.text = tasks[indexPath.row].header
            cell.noteLabel?.text = tasks[indexPath.row].note
            cell.dateLabel?.text = tasks[indexPath.row].date
            
            if (tasks[indexPath.row].status == "postpone") {
                cell.colorView.backgroundColor = UIColor.init(red: 222/255, green: 119/255, blue: 49/255, alpha: 1)
            } else if (tasks[indexPath.row].status == "cancel") {
                cell.colorView.backgroundColor = UIColor.init(red: 223/255, green: 36/255, blue: 64/255, alpha: 1)
            } else if (tasks[indexPath.row].status == "done") {
                cell.colorView.backgroundColor = UIColor.init(red: 123/255, green: 191/225, blue: 79/255, alpha: 1)
            } else if (tasks[indexPath.row].status == "not done") {
                cell.colorView.backgroundColor = UIColor.init(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
            }
        }

        cell.backgroundColor = UIColor.init(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
        
        NSKeyedUnarchiver.setClass(TaskModel.self, forClassName: "TaskModel")
        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
        
        if let data = userDefaults?.object(forKey: "taskListWidget") as? Data {
            if let taskList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [TaskModel] {
                self.tasks = taskList
                //self.tableView.reloadData()
            }
        }
        
        for task in tasks {
            if task.date == result {
                self.createNotification()
            }
        }
        
        self.taskTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.longPressed {
            self.longPressed = false
            
            if (taskTableView.isEditing == true) {
                taskTableView.setEditing(false, animated: true)
            }
        } else {
            if isFiltering() {
                var index = 0
                let item = filteredTasks[indexPath.row]
                for task in tasks {
                    if item == task {
                        UserDefaults.standard.set(index, forKey: "indexPath")
                    }
                    index += 1
                }
            } else {
                UserDefaults.standard.set(indexPath.row, forKey: "indexPath")
            }
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "editTaskViewController") as! UINavigationController
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if (tableView.isEditing == false) {
            reordering = false
        } else {
            reordering = true
        }
        
        if (reordering) {
            return .none // set all cells to not have that any control button
        } else {
            return .delete // set all cells to have delete control button
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let done = UITableViewRowAction(style: .normal, title: "Done"){(UITableViewRowAction,NSIndexPath) -> Void in
            if self.isFiltering() {
                let item = self.filteredTasks[indexPath.row]
                
                for task in self.tasks {
                    if task == item {
                        task.status = "done"
                        
                        NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
                        let data = NSKeyedArchiver.archivedData(withRootObject: self.tasks)
                        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
                        userDefaults?.removeObject(forKey: "taskListWidget")
                        userDefaults!.set(data, forKey: "taskListWidget")
                        userDefaults!.synchronize()
                        self.taskTableView.reloadData()
                    }
                }
            } else {
                self.tasks[indexPath.row].status = "done"
                
                NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
                let data = NSKeyedArchiver.archivedData(withRootObject: self.tasks)
                let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
                userDefaults?.removeObject(forKey: "taskListWidget")
                userDefaults!.set(data, forKey: "taskListWidget")
                userDefaults!.synchronize()
                self.taskTableView.reloadData()
            }
        }
        done.backgroundColor = UIColor.init(red: 123/255, green: 191/225, blue: 79/255, alpha: 1)
        
        let cancel = UITableViewRowAction(style: .normal, title: "Cancel"){(UITableViewRowAction,NSIndexPath) -> Void in
            if self.isFiltering() {
                let item = self.filteredTasks[indexPath.row]
                
                for task in self.tasks {
                    if task == item {
                        task.status = "cancel"
                        
                        NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
                        let data = NSKeyedArchiver.archivedData(withRootObject: self.tasks)
                        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
                        userDefaults?.removeObject(forKey: "taskListWidget")
                        userDefaults!.set(data, forKey: "taskListWidget")
                        userDefaults!.synchronize()
                        self.taskTableView.reloadData()
                    }
                }
            } else {
                self.tasks[indexPath.row].status = "cancel"
                NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
                let data = NSKeyedArchiver.archivedData(withRootObject: self.tasks)
                let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
                userDefaults?.removeObject(forKey: "taskListWidget")
                userDefaults!.set(data, forKey: "taskListWidget")
                userDefaults!.synchronize()
                self.taskTableView.reloadData()
            }
        }
        cancel.backgroundColor = UIColor.init(red: 223/255, green: 36/255, blue: 64/255, alpha: 1)
        
        let postpone = UITableViewRowAction(style: .normal, title: "Postpone"){(UITableViewRowAction,NSIndexPath) -> Void in
            if self.isFiltering() {
                let item = self.filteredTasks[indexPath.row]
                
                for task in self.tasks {
                    if task == item {
                        task.status = "postpone"
                        NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
                        let data = NSKeyedArchiver.archivedData(withRootObject: self.tasks)
                        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
                        userDefaults?.removeObject(forKey: "taskListWidget")
                        userDefaults!.set(data, forKey: "taskListWidget")
                        userDefaults!.synchronize()
                        self.taskTableView.reloadData()
                      
                        self.selectedTask = self.tasks[indexPath.row]
                        self.createDatePicker()
                    }
                }
            } else {
                self.tasks[indexPath.row].status = "postpone"
                NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
                let data = NSKeyedArchiver.archivedData(withRootObject: self.tasks)
                let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
                userDefaults?.removeObject(forKey: "taskListWidget")
                userDefaults!.set(data, forKey: "taskListWidget")
                userDefaults!.synchronize()
                self.taskTableView.reloadData()
                
                self.selectedTask = self.tasks[indexPath.row]
                self.createDatePicker()
            }
        }
        postpone.backgroundColor = UIColor.init(red: 222/255, green: 119/255, blue: 49/255, alpha: 1)
        
        return [done, cancel, postpone]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(movedObject, at: destinationIndexPath.row)
        self.taskTableView.reloadData()
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(TaskViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.taskTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func createDatePicker() {
        picker.datePickerMode = .date
        
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
        
        toolbar.frame = CGRect(x: 0, y: view.frame.height - 400, width: view.frame.width, height: 44)
        picker.frame = CGRect(x: 0, y: view.frame.height - 400, width: view.frame.width, height: 400)
        picker.backgroundColor = UIColor.white
        
        taskTableView.addSubview(picker)
        taskTableView.addSubview(toolbar)
        picker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    @objc func donePicker () {
        for task in self.tasks {
            if task == self.selectedTask {
                task.date = date
                print(task.date)
                date = ""
            }
        }
        
        NSKeyedArchiver.setClassName("TaskModel", for: TaskModel.self)
        let data = NSKeyedArchiver.archivedData(withRootObject: self.tasks)
        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
        userDefaults?.removeObject(forKey: "taskListWidget")
        userDefaults!.set(data, forKey: "taskListWidget")
        userDefaults!.synchronize()
        self.taskTableView.reloadData()
        self.selectedTask = TaskModel(header: "", note: "", date: "", status: "")
        picker.removeFromSuperview()
        toolbar.removeFromSuperview()
    }
    
    @objc func cancelPicker () {
        self.selectedTask = TaskModel(header: "", note: "", date: "", status: "")
        picker.removeFromSuperview()
        toolbar.removeFromSuperview()
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        date = dateFormatter.string(from: sender.date)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchBar.text?.isEmpty ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredTasks = tasks.filter({( task : TaskModel) -> Bool in
            return task.header.lowercased().contains(searchText.lowercased())
        })
        
        if(filteredTasks.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.taskTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
    
    func createNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to look at your tasks!"
        content.subtitle = "You have some tasks to do!"
        content.body = "Click to see them now!"
        content.badge = 1
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

