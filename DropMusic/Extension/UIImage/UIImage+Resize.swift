//
//  UIImage+Resize.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

//import Foundation
import UIKit

extension UIImage {
    func resizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        let scale = reSize.width / self.size.width
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width*scale, height: self.size.height*scale));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
}
