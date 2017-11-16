//
//  TodayViewController.swift
//  Checkit.Widget
//
//  Created by Onur Celik on 16.11.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var tasks: [TaskModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSKeyedUnarchiver.setClass(TaskModel.self, forClassName: "TaskModel")
        let userDefaults = UserDefaults(suiteName: "group.com.onurcelikeng.CheckIt")
        
        if let data = userDefaults?.object(forKey: "taskListWidget") as? Data {
            if let taskList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [TaskModel] {
                self.tasks = taskList
                //self.tableView.reloadData()
            }
        }
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "tableViewCell")
        cell.textLabel?.text = tasks[indexPath.row].header
        
        return cell
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize = maxSize
            }, completion: nil)
            
        }
        else {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize = CGSize(width: maxSize.width, height: 200)
            })
        }
    }
}
