//
//  MusicPlayerV.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class MusicPlayerView: UIView {
 
    // MARK: - init
    // 初期化.
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    // MARK: - private
    
    // MARK: - public
    // レイアウト.
    public func layout(){
        print("layout")
        self.backgroundColor = UIColor.red
        
        do {
            let button = UIButton()
            button.frame = CGRect(x: 100, y: 100, width: 40, height: 40)
            button.setImage(UIImage(named: "play.png"), for: UIControlState.normal)
            button.addTarget(self, action: #selector(buttonEvent(_:)), for: UIControlEvents.touchUpInside)
            self.addSubview(button)
        }

    }
    
    // MARK: - event
    @objc func buttonEvent(_ sender: UIButton) {
        print("buttonEvent")
    }
    
    
}
