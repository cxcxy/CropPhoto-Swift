//
//  CropView.swift
//  CropPhoto-Swift
//
//  Created by 陈旭 on 2017/4/25.
//  Copyright © 2017年 陈旭. All rights reserved.
//

import UIKit

protocol CropViewDelegate: NSObjectProtocol {
    func cropEnded(_ cropView: CropView)
    
    func cropMoved(_ cropView: CropView)
}
class CropView: UIView {
    /// 上下左右 蒙层
    var upperLeft: CropCornerView!
    var upperRight: CropCornerView!
    var lowerRight: CropCornerView!
    var lowerLeft: CropCornerView!
    
    
    var horizontalCropLines = [Any]()
    var verticalCropLines = [Any]()
    var horizontalGridLines = [Any]()
    var verticalGridLines = [Any]()
    weak var delegate: CropViewDelegate?
    var isCropLinesDismissed: Bool = false
    var isGridLinesDismissed: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.cropLine().cgColor
        layer.borderWidth = 1
        horizontalCropLines = [Any]()
        for _ in 0..<kCropLines { // 水平两条线
            let line = UIView()
            line.backgroundColor = UIColor.cropLine()
            horizontalCropLines.append(line)
            addSubview(line)
        }
        verticalCropLines = [Any]()
        for _ in 0..<kCropLines { // 垂直两条线
            let line = UIView()
            line.backgroundColor = UIColor.cropLine()
            verticalCropLines.append(line)
            addSubview(line)
        }
        isGridLinesDismissed = true
        
        showCropLines()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCropLines(_ animate: Bool) {
        
        showCropLines()
        
        let animationBlock: ((_: Void) -> Void)? = {(_: Void) -> Void in
            self.updateLines(self.horizontalCropLines, horizontal: true)
            self.updateLines(self.verticalCropLines, horizontal: false)
        }
        if animate {
            UIView.animate(withDuration: 0.25, animations: animationBlock!)
        }
        else {
            animationBlock!()
        }
    }
    
    
    func updateGridLines(_ animate: Bool) {
        
        if isGridLinesDismissed {
            showGridLines()
        }
        let animationBlock: ((_: Void) -> Void)? = {(_: Void) -> Void in
            self.updateLines(self.horizontalGridLines, horizontal: true)
            //        [self updateLines:self.verticalGridLines horizontal:NO];
        }
        if animate {
            UIView.animate(withDuration: 0.25, animations: animationBlock!)
        }
        else {
            animationBlock!()
        }
    }
    
    func updateLines(_ lines: [Any], horizontal: Bool) {
        
        for line in lines.enumerated() {
            let lineView : UIView? = line.element as? UIView
            if horizontal {
                lineView?.frame = CGRect(x: CGFloat(0), y: CGFloat(( Int(frame.size.height) / (lines.count + 1)) * (line.offset + 1)), width: CGFloat(frame.size.width), height: CGFloat(1 / UIScreen.main.scale))
                
            }else{
                lineView?.frame = CGRect(x: CGFloat((Int(frame.size.width) / (lines.count + 1)) * (line.offset + 1)), y: CGFloat(0), width: CGFloat(1 / UIScreen.main.scale), height: CGFloat(frame.size.height))
            }
        }
        
    }
    
    func dismissCropLines() {
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.dismissLines(self.horizontalCropLines)
            self.dismissLines(self.verticalCropLines)
        }, completion: {(_ finished: Bool) -> Void in
            //        self.cropLinesDismissed = YES;
        })
    }
    
    func dismissGridLines() {
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.dismissLines(self.horizontalGridLines)
            //        [self dismissLines:self.verticalGridLines];
        }, completion: {(_ finished: Bool) -> Void in
            self.isGridLinesDismissed = true
        })
    }
    
    func dismissLines(_ lines: [Any]) {
        for line in lines.enumerated() {
            let lineView : UIView? = line.element as? UIView
            lineView?.alpha = 0.0
        }
    }
    
    func showCropLines() {
        //    self.cropLinesDismissed = NO;
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.showLines(self.horizontalCropLines)
            self.showLines(self.verticalCropLines)
        })
    }
    
    func showGridLines() {
        isGridLinesDismissed = false
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.showLines(self.horizontalGridLines)
            //        [self showLines:self.verticalGridLines];
        })
    }
    
    func showLines(_ lines: [Any]) {
        
        for line in lines.enumerated() {
            let lineView : UIView? = line.element as? UIView
            lineView?.alpha = 1.0
        }
        
    }
}
