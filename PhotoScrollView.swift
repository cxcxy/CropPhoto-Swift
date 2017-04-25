//
//  PhotoScrollView.swift
//  CropPhoto-Swift
//
//  Created by 陈旭 on 2017/4/10.
//  Copyright © 2017年 陈旭. All rights reserved.
//

import UIKit

class PhotoScrollView: UIScrollView {

        
        var photoContentView = PhotoContentView()
        
        
        func setContentOffsetY(_ offsetY: CGFloat) {
            var contentOffset: CGPoint = self.contentOffset
            contentOffset.y = offsetY
            self.contentOffset = contentOffset
        }
        
        func setContentOffsetX(_ offsetX: CGFloat) {
            var contentOffset: CGPoint = self.contentOffset
            contentOffset.x = offsetX
            self.contentOffset = contentOffset
        }
        
        func zoomScaleToBound() -> CGFloat {
            let scaleW: CGFloat = bounds.size.width / photoContentView.bounds.size.width
            let scaleH: CGFloat = bounds.size.height / photoContentView.bounds.size.height
            let maxValue =  max(scaleW, scaleH)
            return maxValue
        }
    

}
extension UIColor {
    
    class func cancelButton() -> UIColor {
        return UIColor(red: CGFloat(0.09), green: CGFloat(0.49), blue: CGFloat(1), alpha: CGFloat(1))
    }
    
    class func cancelButtonHighlighted() -> UIColor {
        return UIColor(red: CGFloat(0.11), green: CGFloat(0.17), blue: CGFloat(0.26), alpha: CGFloat(1))
    }
    
    class func saveButton() -> UIColor {
        return UIColor(red: CGFloat(1), green: CGFloat(0.8), blue: CGFloat(0), alpha: CGFloat(1))
    }
    
    class func saveButtonHighlighted() -> UIColor {
        return UIColor(red: CGFloat(0.26), green: CGFloat(0.23), blue: CGFloat(0.13), alpha: CGFloat(1))
    }
    
    class func resetButton() -> UIColor {
        return UIColor(red: CGFloat(128.0 / 255.0), green: CGFloat(128.0 / 255.0), blue: CGFloat(128.0 / 255.0), alpha: CGFloat(1))
    }
    
    class func resetButtonHighlighted() -> UIColor {
        return UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1))
    }
    
    class func mask() -> UIColor {
        return UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(0.8))
    }
    
    class func cropLine() -> UIColor {
        return UIColor(white: CGFloat(1.0), alpha: CGFloat(1.0))
    }
    
    class func gridLine() -> UIColor {
        return UIColor(red: CGFloat(0.52), green: CGFloat(0.48), blue: CGFloat(0.47), alpha: CGFloat(0.8))
    }
    
    class func photoTweakCanvasBackground() -> UIColor {
        return UIColor(white: CGFloat(0.0), alpha: CGFloat(1.0))
    }
}
