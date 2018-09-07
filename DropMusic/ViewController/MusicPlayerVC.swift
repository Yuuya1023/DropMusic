//
//  MusicPlayerViewControlloer.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class MusicPlayerViewControlloer: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.view.backgroundColor = UIColor.red
        
        let rect = CGRect(x: 0,
                          y: 0,
                          width: self.view.frame.size.width,
                          height: self.view.frame.size.height
        )
        var playerView = MusicPlayerView(frame:rect)
        self.view.addSubview(playerView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
