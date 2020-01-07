//
//  LaunchView.swift
//  DropMusic
//
//  Copyright © 2020 n.yuuya. All rights reserved.
//

import UIKit

class LaunchView: UIView {
    
    //
    // MARK: - Properties.
    //
    
    
    
    //
    // MARK: - Initialize.
    //
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibInit()
    }
    fileprivate func nibInit() {
        guard let view = UINib(nibName: "LaunchView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        self.bounds = view.bounds
        self.addSubview(view)
    }
    
    
    
    //
    // MARK: - Override.
    //
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibInit()
    }
    
}
