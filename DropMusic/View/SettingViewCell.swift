//
//  SettingViewCell.swift
//  DropMusic
//
//  Copyright © 2020年 n.yuuya. All rights reserved.
//

import UIKit

class SettingViewCell: UITableViewCell {
    
    //
    // MARK: - Constant.
    //
    static let cellIdentifier = "SettingViewCell"
    static let height: CGFloat = 100.0
    
    
    
    //
    // MARK: - Properties.
    //
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subLabel: UILabel!
    
    
    
    //
    // MARK: - Override.
    //
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    
    //
    // MARK: - Public.
    //
    func set(title: String, sub: String) {
        titleLabel.text = title
        subLabel.text = sub
    }
    
}
