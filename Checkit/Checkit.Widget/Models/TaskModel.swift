//
//  TaskModel.swift
//  Checkit.Widget
//
//  Created by Onur Celik on 16.11.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import UIKit

class TaskModel: NSObject, NSCoding {
    var header: String
    var note: String
    var date: String
    var status: String
    
    init(header: String, note: String, date: String, status: String) {
        self.header = header
        self.note = note
        self.date = date
        self.status = status
    }
    
    required init(coder decoder: NSCoder) {
        self.header = decoder.decodeObject(forKey: "header") as? String ?? ""
        self.note = decoder.decodeObject(forKey: "note") as? String ?? ""
        self.date = decoder.decodeObject(forKey: "date") as? String ?? ""
        self.status = decoder.decodeObject(forKey: "status") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(header, forKey: "header")
        coder.encode(note, forKey: "note")
        coder.encode(date, forKey: "date")
        coder.encode(status, forKey: "status")
    }
}
