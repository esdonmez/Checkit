//
//  Section.swift
//  Checkit
//
//  Created by Onur Celik on 16.11.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import Foundation

struct Section {
    var title: String!
    var expanded: Bool!
    
    init(title: String, expanded: Bool) {
        self.title = title
        self.expanded = expanded
    }
}
