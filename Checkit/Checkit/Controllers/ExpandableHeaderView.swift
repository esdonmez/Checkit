//
//  ExpandableHeaderView.swift
//  Checkit
//
//  Created by Onur Celik on 16.11.2017.
//  Copyright © 2017 Onur Celik. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {

    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func customInit(title: String, section: Int, delegate: ExpandableHeaderViewDelegate) {
        self.textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = UIColor.init(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
        self.contentView.backgroundColor = UIColor.init(red: 254/255, green: 202/255, blue: 11/255, alpha: 1)
    }
}
