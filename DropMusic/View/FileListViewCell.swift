//
//  FileListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class FileListViewCell: UITableViewCell {
    var nameLabel: UILabel!
    var icon: UIImageView!
    var progress: UIProgressView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.textAlignment = .left
        contentView.addSubview(nameLabel)
        
        let image = UIImage(named: "icon_cell_question.png")
        icon = UIImageView(image: image)
        contentView.addSubview(icon)
        
        progress = UIProgressView()
        progress.progress = 0.0
        progress.trackTintColor = UIColor.white
        contentView.addSubview(progress)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 50, y: 0, width: frame.width - 55, height: frame.height)
        icon.frame = CGRect(x: 5, y: 5, width: frame.height - 10, height: frame.height - 10)
        progress.frame = CGRect(x: 0, y: frame.height-2.5, width: frame.width, height: frame.height - 5)
    }
}
