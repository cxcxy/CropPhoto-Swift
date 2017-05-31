//
//  ViewController.swift
//  CropPhoto-Swift
//
//  Created by 陈旭 on 2017/4/10.
//  Copyright © 2017年 陈旭. All rights reserved.
//
import UIKit
let CX_W = (UIScreen.main.bounds.size.width)
let CX_H = (UIScreen.main.bounds.size.height)
let kMaxRotationAngle: CGFloat = 0.5
let kCropLines: Int = 2
//let kMaxRotationAngle: CGFloat = 0.0
let kMaximumCanvasWidthRatio: CGFloat = 1
let kCropViewCornerLength: CGFloat = 22
let singDegree: CGFloat = 1.0
// 一个刻度代表多少度
let minDegree: Int = -45
//  最小刻度
let maxDegree: Int = 45
// 最大刻度
//#define kInstruction
// 装载图片的View
class PhotoContentView:UIView {
    var imageView: UIImageView!
    var image: UIImage!
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        self.image = image
        self.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(image.size.width), height: CGFloat(image.size.height))
        imageView = UIImageView(frame: bounds)
        imageView.image = self.image
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView!.frame = bounds
    }
    
}
import Foundation
import UIKit
enum CropCornerType : Int {
    case upperLeft
    case upperRight
    case lowerRight
    case lowerLeft
}

class CropCornerView: UIView {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    init(frame: CGRect, type: CropCornerType) {
        super.init(frame: frame)

        self.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: kCropViewCornerLength, height: kCropViewCornerLength)
        backgroundColor = UIColor.clear
        let lineWidth: CGFloat = 2
        let horizontal = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: kCropViewCornerLength, height: lineWidth))
        horizontal.backgroundColor = UIColor.cropLine()
        addSubview(horizontal)
        let vertical = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: lineWidth, height: kCropViewCornerLength))
        vertical.backgroundColor = UIColor.cropLine()
        addSubview(vertical)
        if type == .upperLeft {
            horizontal.center = CGPoint(x: CGFloat(kCropViewCornerLength / 2), y: CGFloat(lineWidth / 2))
            vertical.center = CGPoint(x: CGFloat(lineWidth / 2), y: CGFloat(kCropViewCornerLength / 2))
        }
        else if type == .upperRight {
            horizontal.center = CGPoint(x: CGFloat(kCropViewCornerLength / 2), y: CGFloat(lineWidth / 2))
            vertical.center = CGPoint(x: CGFloat(kCropViewCornerLength - lineWidth / 2), y: CGFloat(kCropViewCornerLength / 2))
        }
        else if type == .lowerRight {
            horizontal.center = CGPoint(x: CGFloat(kCropViewCornerLength / 2), y: CGFloat(kCropViewCornerLength - lineWidth / 2))
            vertical.center = CGPoint(x: CGFloat(kCropViewCornerLength - lineWidth / 2), y: CGFloat(kCropViewCornerLength / 2))
        }
        else if type == .lowerLeft {
            horizontal.center = CGPoint(x: CGFloat(kCropViewCornerLength / 2), y: CGFloat(kCropViewCornerLength - lineWidth / 2))
            vertical.center = CGPoint(x: CGFloat(lineWidth / 2), y: CGFloat(kCropViewCornerLength / 2))
        }
    
    }
}

class PhotoTweakView: UIView,UIScrollViewDelegate,CropViewDelegate {

    private(set) var photoContentOffset = CGPoint.zero

    var isCrop: Bool = false
    // 是否选择的原图  原图就不裁剪
    var isRoat: Bool = false
    // 原图是否旋转  原图就不裁剪
    var sizeImgId: Int = 0

    var cropView: CropView!
    var image: UIImage!
    var slider: UISlider!
    var resetBtn: UIButton!
    var scrollViewAngle: UIScrollView!
    var bottomView: UIView!
    var bottomBtnsView: UIView!
    var oneBtn: UIButton!
    var twoBtn: UIButton!
    var threeBtn: UIButton!
    var originalSize = CGSize.zero
    var angle: CGFloat = 0.0
    var changeDegree: CGFloat = 0.0
    // scrollView 移动1px对应的改变角度
    var isManualZoomed: Bool = false
    // 手动缩放
    var proportionBtns = [UIButton]()
//    var cropBtn: UIButton!
//    var rotaBtn: UIButton!
    // masks
    var topMask: UIView!
    var leftMask: UIView!
    var bottomMask: UIView!
    var rightMask: UIView!
    var centerView: UIView!
    // 中间指示条
    var scaleMaskView: UIImageView!
    // 透明蒙版
    // constants
    var maximumCanvasSize = CGSize.zero
    var currentCenterY: CGFloat = 0.0
    var originalPoint = CGPoint.zero
    var maxRotationAngle: CGFloat = 0.0
    
    var photoContentView: PhotoContentView!
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    lazy var scrollView: PhotoScrollView = {
        let scrollView = PhotoScrollView()

        scrollView.alwaysBounceVertical             = true
        scrollView.alwaysBounceHorizontal           = true
        scrollView.delegate                         = self
        scrollView.minimumZoomScale                 = 1             // 最小缩放
        scrollView.maximumZoomScale                 = 1             // 最大缩放
        scrollView.showsVerticalScrollIndicator     = false
        scrollView.showsHorizontalScrollIndicator   = false
        scrollView.clipsToBounds                    = false
        scrollView.backgroundColor                  = UIColor.yellow
        scrollView.contentSize = CGSize(width: CGFloat((scrollView.bounds.size.width)), height: CGFloat((scrollView.bounds.size.height)))
        return scrollView
    }()
//    // 装载照片的View
//    lazy var photoContentView: PhotoContentView = {
//       let photoContentView = PhotoContentView.init(frame: self.scrollView.bounds, image: self.image)
//
//        photoContentView.backgroundColor            = UIColor.blue
//        photoContentView.isUserInteractionEnabled   = true
//        
//        return photoContentView
//    }()
    init(frame: CGRect, image: UIImage, maxRotationAngle: CGFloat) {
        super.init(frame: frame)
        self.frame = frame

        self.image = image
 
        self.maxRotationAngle = maxRotationAngle
        // scale the image 画布大小
        maximumCanvasSize = CGSize(width: CGFloat(kMaximumCanvasWidthRatio * self.frame.size.width), height: CGFloat(kMaximumCanvasWidthRatio * self.frame.size.width))
        let scaleX  : CGFloat   = image.size.width / maximumCanvasSize.width
        let scaleY  : CGFloat   = image.size.height / maximumCanvasSize.height
        let scale   : CGFloat   = max(scaleX, scaleY)
        let bounds = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(image.size.width / scale), height: CGFloat(image.size.height / scale))
        originalSize = bounds.size
        currentCenterY = maximumCanvasSize.height / 2 + 10
     
        scrollView.frame = bounds
        scrollView.center = CGPoint(x: CGFloat(self.frame.width / 2), y: currentCenterY)

        addSubview(scrollView)

        photoContentView = PhotoContentView.init(frame: self.scrollView.bounds, image: self.image)
        
        photoContentView.backgroundColor            = UIColor.blue
        photoContentView.isUserInteractionEnabled   = true
        
//        return photoContentView
        scrollView.photoContentView = photoContentView
        scrollView.addSubview(photoContentView)
        
        cropView = CropView(frame: (scrollView.frame))
        // 裁剪图形的View
        cropView.center     = (scrollView.center)

        cropView.delegate   = self
        
        addSubview(cropView)
        // 裁剪边框上下左右的背景颜色
        configMask()
        // 配置底部View
        cofigBottomView()
        
        sizeImgId = 1
    
    }
    func configMask()  {
        
        let maskColor = UIColor.mask()
        topMask = UIView()
        topMask.backgroundColor     = maskColor
        addSubview(topMask)
        leftMask = UIView()
        leftMask.backgroundColor    = maskColor
        addSubview(leftMask)
        bottomMask = UIView()
        bottomMask.backgroundColor  = maskColor
        addSubview(bottomMask)
        rightMask = UIView()
        rightMask.backgroundColor   = maskColor
        addSubview(rightMask)
        updateMasks(false)

    }
    lazy var cropBtn: UIButton = {
        let cropBtn = UIButton(type: .custom)
        cropBtn.frame   = CGRect(x: CGFloat(30), y: CGFloat(20), width: CGFloat(30), height: CGFloat(30))
        cropBtn.center  = CGPoint(x: CGFloat(CX_W / 2 + 35), y: CGFloat(35))
        cropBtn.addTarget(self, action: #selector(self.cropBtnTapped), for: .touchUpInside)
        cropBtn.setImage(UIImage(named: "crop-no"), for: .normal)
        cropBtn.setImage(UIImage(named: "crop-yes"), for: .selected)
        return cropBtn
    }()
    lazy var rotaBtn: UIButton = {
        let rotaBtn = UIButton(type: .custom)
        rotaBtn.frame   = CGRect(x: 0, y: 0, width: CGFloat(30), height: CGFloat(30))
        rotaBtn.center  = CGPoint(x: CGFloat(CX_W / 2 - 35), y: CGFloat(35))
        rotaBtn.addTarget(self, action: #selector(self.rotaBtnTapped), for: .touchUpInside)
        rotaBtn.setImage(UIImage(named: "rotating-no"), for: .normal)
        rotaBtn.setImage(UIImage(named: "rotating-yes"), for: .selected)
        rotaBtn.isSelected = true
        return rotaBtn
    }()
    // 配置底部View
    func cofigBottomView()  {
        
        bottomView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.bounds.size.width), height: CGFloat(self.h - 395)))
        bottomView.backgroundColor = UIColor.white
        bottomView.center = CGPoint.init(x: self.bounds.width / 2, y: currentCenterY + (CX_W / 2) + ((bottomView.h) / 2) + 10)

        bottomView.addSubview(cropBtn)
        bottomView.addSubview(rotaBtn)
        addSubview(bottomView)
        configAngleScroll()
        configBottomBtns()
        configCropView(CGSize(width: CGFloat(CX_W), height: CGFloat(CX_W)))
        
    }
    
    // 配置底部比例按钮

    func configBottomBtns() {
        var btnTitleArray: [String] = ["1:1", "3:2", "4:3", "16:9"]
        var btnImgSelected: [String] = ["croponeone-selected", "cropthreetwo-selected", "cropfourthree-selected", "cropnice-selected"]
        var btnImg: [String] = ["croponeone", "cropthreetwo", "cropfourthree", "cropnice"]
        proportionBtns = [UIButton]()
        bottomBtnsView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(CX_W), height: CGFloat(150)))

        bottomBtnsView.center = CGPoint(x: CGFloat(bounds.width / 2), y: CGFloat((bottomView.h) - ((bottomBtnsView.h) / 2) - 5))
        bottomBtnsView.backgroundColor = UIColor.blue
        bottomView.addSubview(bottomBtnsView)
        let _: CGFloat = 40
        let centerPX: Float = Float( CX_W / 5 )
        for i in 0..<btnTitleArray.count {
            let sizeBtn = UIButton(type: .custom)

            sizeBtn.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(50), height: CGFloat(50))
            sizeBtn.center = CGPoint(x: CGFloat(centerPX + (Float(i) * centerPX)), y: CGFloat(((bottomBtnsView.h) / 2)))
            sizeBtn.setTitle(btnTitleArray[i], for: .normal)
            sizeBtn.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(12))
            sizeBtn.titleLabel?.textAlignment = .center
            sizeBtn.setTitleColor(UIColor.resetButton(), for: .normal)
            sizeBtn.setTitleColor(UIColor.resetButtonHighlighted(), for: .selected)
            sizeBtn.addTarget(self, action: #selector(self.resetBtnTapped), for: .touchUpInside)
            sizeBtn.setImage(UIImage(named: btnImg[i]), for: .normal)
            sizeBtn.setImage(UIImage(named: btnImgSelected[i]), for: .selected)
//            sizeBtn.setButtonImageTitleStyle(ButtonImageTitleStyleTop, padding: 5)
            // 加载按钮到视图
            sizeBtn.tag = i
            if i == 0 {
                sizeBtn.isSelected = true
            }
            proportionBtns.append(sizeBtn)
            bottomBtnsView.addSubview(sizeBtn)
        }
        bottomBtnsView.isHidden = true
    }
    // 配置滚动角度的scrollView
    func configAngleScroll() {
        let angleHeight     : CGFloat           = 50
        let lineHeight      : CGFloat           = 36
        let scroollViewWidth: CGFloat           = CX_W - 30
        let allGrid         : Int               = maxDegree - minDegree / Int(singDegree)
        let gridWidth       : CGFloat           = scroollViewWidth / 20
        let contentSizeX    : CGFloat           = gridWidth * CGFloat(allGrid)
        
        changeDegree = CGFloat(maxDegree - minDegree) / contentSizeX
        scrollViewAngle = UIScrollView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(CX_W - 30), height: CGFloat(angleHeight + 20)))
        scrollViewAngle.center = CGPoint(x: CGFloat(bounds.width / 2), y: CGFloat(bounds.height - 65))
        scrollView.alwaysBounceVertical     = true
        scrollView.alwaysBounceHorizontal   = true
        scrollViewAngle.backgroundColor     = UIColor.green
        scrollViewAngle.showsVerticalScrollIndicator    = false
        scrollViewAngle.showsHorizontalScrollIndicator  = false
        scrollViewAngle.tag         = 10000
        scrollViewAngle.delegate    = self
        scrollViewAngle.contentSize = CGSize(width: CGFloat(contentSizeX + scroollViewWidth), height: CGFloat(60))
        for i in 0...allGrid {
            let viewLine = UIView()
            viewLine.frame = CGRect(x: CGFloat(scroollViewWidth / 2 + gridWidth * CGFloat(i)), y: CGFloat(0), width: CGFloat(1), height: CGFloat(lineHeight))
            viewLine.backgroundColor = UIColor.darkGray
            viewLine.center = CGPoint(x: CGFloat(viewLine.center.x), y: CGFloat(angleHeight / 2))
            if i % 5 == 0 {
                let lbDegree = UILabel()
                lbDegree.frame  = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(45), height: CGFloat(10))
                lbDegree.font   = UIFont.systemFont(ofSize: CGFloat(12))
                lbDegree.center = CGPoint(x: CGFloat(viewLine.center.x), y: CGFloat(angleHeight + (lbDegree.h / 2) + 5))
                lbDegree.textAlignment = .center
                lbDegree.text = "\(i - maxDegree)°"
                scrollViewAngle.addSubview(lbDegree)
                viewLine.h = angleHeight
                viewLine.center = CGPoint(x: CGFloat(viewLine.center.x), y: CGFloat((angleHeight / 2) - (angleHeight - lineHeight) / 2))
            }
            scrollViewAngle.addSubview(viewLine)
        }
        // 指定到中间的位置
        scrollViewAngle.setContentOffset(CGPoint(x: CGFloat(((gridWidth * CGFloat(allGrid)) / 2) - 0.5), y: CGFloat(0)), animated: false)
        addSubview(scrollViewAngle)
        scaleMaskView = UIImageView(frame: (scrollViewAngle.frame))
        scaleMaskView.image = UIImage(named: "scaleMask")
        addSubview(scaleMaskView)
        centerView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(2), height: CGFloat((scrollViewAngle.h) - 10)))
        centerView.backgroundColor = UIColor.yellow
        centerView.center = CGPoint(x: CGFloat((scrollViewAngle.center.x)), y: CGFloat((scrollViewAngle.center.y) - ((scrollViewAngle.h) - angleHeight)))
        addSubview(centerView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 10000 {
            let zero: CGFloat = scrollView.contentSize.width / CGFloat(2)
                // 零度位置
            let x: CGFloat = scrollView.contentOffset.x + scrollView.w / 2
            // scrollView滑动角度
            angelValueChanged(changeDegree * (x - zero))

            // 旋转
        }
    }

    // 事件传递 处理底部 scrollView
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if (scrollView.frame.contains(point)) {
            if (bottomView?.frame.contains(point))! {
                for subview: UIView in self.subviews.reversed() {
                    let convertedPoint: CGPoint =  subview.convert(point, from: self)
                    
                    let hitTestView: UIView? = subview.hitTest(convertedPoint, with: event)
                    
                    if hitTestView != nil {
                        return hitTestView!
                    }
                    
                }
            }
            return scrollView
        }
        else {
            //reverseObjectEnumerator 反序数组
            for subview: UIView in self.subviews.reversed() {
                let convertedPoint: CGPoint =  subview.convert(point, from: self)
                
                let hitTestView: UIView? = subview.hitTest(convertedPoint, with: event)
                
                if hitTestView != nil {
                    return hitTestView!
                }
                
            }

        }
        return nil
        
        
    }

    // scrollView 缩放  返回需要zoom的View

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoContentView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {

        isManualZoomed = true
        
    }
    // 正在缩放的代理方法  只要在缩放就执行该方法，所以此方法会在缩放过程中多次调用
//
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//            //    self.photoContentView.center = scrollView.center;
//            //    self.photoContentView.center = CGPointMake(CX_W / 2 , 395 / 2 );
//        let x: CGFloat = self.scrollView.frame.origin.x
//        let y: CGFloat = self.scrollView.frame.origin.y
//        let w: CGFloat = self.scrollView.frame.size.width
//        let h: CGFloat = self.scrollView.frame.size.height
//        let c_x: CGFloat = self.scrollView.center.x
//        let c_y: CGFloat = self.scrollView.center.y
////        let contentSize_w: CGFloat = self.scrollView!.contentSize.width
////        let contentSize_h: CGFloat = self.scrollView!.contentSize.height
//        print(String(format: "%.0f-%.0f-%.0f-%.0f", x, y, w, h))
//        print(String(format: "%.0f=%.0f", c_x, c_y))
//        //    if (contentSize_w < CX_W) {
//        ////        self.scrollView.contentSize.width == CX_W;
//        //        [self.scrollView setContentSize:CGSizeMake(CX_W, contentSize_h)];
//        //    }
//        //    
//        //    NSLog(@"%.0f=%.0f",contentSize_w,contentSize_h);
//    }
// MARK: - Crop View Delegate

    func cropMoved(_ cropView: CropView) {
        updateMasks(false)
    }

    func cropEnded(_ cropView: CropView) {
        let newCropBounds = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(cropView.frame.size.width), height: CGFloat(cropView.frame.size.height))
            // calculate the new bounds of scroll view
        let width: CGFloat = fabs(cos(angle)) * newCropBounds.size.width + fabs(sin(angle)) * newCropBounds.size.height
        let height: CGFloat = fabs(sin(angle)) * newCropBounds.size.width + fabs(cos(angle)) * newCropBounds.size.height
            // calculate the zoom area of scroll view
        var scaleFrame: CGRect = cropView.frame
        if scaleFrame.size.width >= (scrollView.bounds.size.width) {
            scaleFrame.size.width = (scrollView.bounds.size.width) - 1
        }
        if scaleFrame.size.height >= (scrollView.bounds.size.height) {
            scaleFrame.size.height = (scrollView.bounds.size.height) - 1
        }
        let contentOffset: CGPoint = scrollView.contentOffset
        let contentOffsetCenter = CGPoint(x: CGFloat(contentOffset.x + (scrollView.bounds.size.width) / 2), y: CGFloat(contentOffset.y + (scrollView.bounds.size.height) / 2))
        var bounds: CGRect = scrollView.bounds
        bounds.size.width = width
        bounds.size.height = height
        scrollView.bounds = CGRect(x: CGFloat(0), y: CGFloat(0), width: width, height: height)
        let newContentOffset = CGPoint(x: CGFloat(contentOffsetCenter.x - (scrollView.bounds.size.width) / 2), y: CGFloat(contentOffsetCenter.y - (scrollView.bounds.size.height) / 2))
        scrollView.contentOffset = newContentOffset
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            // 改变内部cropView的center
            cropView.center = CGPoint(x: CGFloat(self.frame.width / 2), y: CGFloat(self.currentCenterY))
        })
        isManualZoomed = true
        // update masks
        updateMasks(true)
        self.cropView?.dismissCropLines()
        let scaleH: CGFloat = scrollView.bounds.size.height / scrollView.contentSize.height
        let scaleW: CGFloat = scrollView.bounds.size.width / scrollView.contentSize.width
        var scaleM: CGFloat = max(scaleH, scaleW)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            //        if (scaleM > 1) {
            // 改变内部cotentView的frame 大小  根据返回的比例辩护
            scaleM = scaleM * (self.scrollView.zoomScale)
            //        CGRect zooRect = [self viewForZoomingInScrollView:<#(nonnull UIScrollView *)#>]
            self.scrollView.setZoomScale(scaleM, animated: true)
            self.scrollView.minimumZoomScale = (self.scrollView.zoomScaleToBound())
            self.isManualZoomed = false
            //        }
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                self.checkScrollContentOffset()
            })
        })
    }
    //更新上下左右蒙版
    func updateMasks(_ animate: Bool) {
        let animationBlock = {() -> Void in
            
                self.topMask.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat((self.cropView.frame.origin.x) + (self.cropView.frame.size.width)), height: CGFloat((self.cropView.frame.origin.y)))
                self.leftMask.frame = CGRect(x: CGFloat(0), y: CGFloat((self.cropView.frame.origin.y)), width: CGFloat((self.cropView.frame.origin.x)), height: CGFloat(self.frame.size.height - (self.cropView.frame.origin.y)))
                self.bottomMask.frame = CGRect(x: CGFloat((self.cropView.frame.origin.x)), y: CGFloat((self.cropView.frame.origin.y) + (self.cropView.frame.size.height)), width: CGFloat(self.frame.size.width - (self.cropView.frame.origin.x)), height: CGFloat(self.frame.size.height - ((self.cropView.frame.origin.y) + (self.cropView.frame.size.height))))
                self.rightMask.frame = CGRect(x: CGFloat((self.cropView.frame.origin.x) + (self.cropView.frame.size.width)), y: CGFloat(0), width: CGFloat(self.frame.size.width - ((self.cropView.frame.origin.x) + (self.cropView.frame.size.width))), height: CGFloat((self.cropView.frame.origin.y) + (self.cropView.frame.size.height)))
            
        }
        if animate {
            
            UIView.animate(withDuration: 0.25, animations: animationBlock)

        }else {
            
            animationBlock()
            
        }
    }

    func checkScrollContentOffset() {
        scrollView.contentOffset.x = max((scrollView.contentOffset.x), 0)
        scrollView.contentOffset.y = max((scrollView.contentOffset.y), 0)
        if (scrollView.contentSize.height) - (scrollView.contentOffset.y) <= (scrollView.bounds.size.height) {
             scrollView.contentOffset.y = (scrollView.contentSize.height) - (scrollView.bounds.size.height)
        }
        if (scrollView.contentSize.width) - (scrollView.contentOffset.x) <= (scrollView.bounds.size.width) {
            scrollView.contentOffset.x = (scrollView.contentSize.width) - (scrollView.bounds.size.width)
        }
    }

    func clearScrollChanged() {
        isRoat  = true
        angle   = 0
        scrollView.transform = CGAffineTransform.identity
        scrollView.center = CGPoint(x: CGFloat(frame.width / 2), y: currentCenterY)
        scrollView.bounds = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(originalSize.width), height: CGFloat(originalSize.height))
        scrollView.minimumZoomScale = 1
        scrollView.setZoomScale(1, animated: false)
        cropView?.frame = (scrollView.frame)
        cropView?.center = (scrollView.center)
        updateMasks(false)
    }

    func angelValueChanged(_ sender: CGFloat) {

        isRoat = false
        // 旋转
        // update masks
        updateMasks(false)
        // update grids
        cropView?.updateGridLines(false)
        // rotate scroll view
        angle = sender / 100
        scrollView.transform = CGAffineTransform(rotationAngle: angle)
            // position scroll view
        let width: CGFloat  = fabs(cos(angle)) * cropView!.frame.size.width + fabs(sin(angle)) * cropView!.frame.size.height
        let height: CGFloat = fabs(sin(angle)) * cropView!.frame.size.width + fabs(cos(angle)) * cropView!.frame.size.height
        let center: CGPoint = scrollView.center
        let contentOffset: CGPoint = scrollView.contentOffset
        let contentOffsetCenter = CGPoint(x: CGFloat(contentOffset.x + (scrollView.bounds.size.width) / 2), y: CGFloat(contentOffset.y + (scrollView.bounds.size.height) / 2))
        scrollView.bounds = CGRect(x: CGFloat(0), y: CGFloat(0), width: width, height: height)
        let newContentOffset = CGPoint(x: CGFloat(contentOffsetCenter.x - (scrollView.bounds.size.width) / 2), y: CGFloat(contentOffsetCenter.y - (scrollView.bounds.size.height) / 2))
        scrollView.contentOffset = newContentOffset
        scrollView.center = center
            // scale scroll view
        let shouldScale: Bool = scrollView.contentSize.width / scrollView.bounds.size.width <= 1.0 || scrollView.contentSize.height / scrollView.bounds.size.height <= 1.0
        if !isManualZoomed || shouldScale {
            scrollView.setZoomScale((scrollView.zoomScaleToBound()), animated: false)
            scrollView.minimumZoomScale = (scrollView.zoomScaleToBound())
            isManualZoomed = false
        }
        checkScrollContentOffset()
    }

    func sliderTouchEnded(_ sender: Any) {
        cropView?.dismissGridLines()
    }
    
    // 根据不同的size 定制不同的cropView
    func configCropView(_ size: CGSize) {
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            self.cropView.size = size
            self.cropView.center = (self.scrollView.center)
            self.cropMoved(self.cropView)
            self.cropEnded(self.cropView)
            self.cropView.updateCropLines(false)
        })
    }

    func cropBtnTapped(_ sender: UIButton) {
        if sender.isSelected == false {
            // 点击状态
            if rotaBtn.isSelected == true {
                rotaBtn.isSelected = false
            }
            sender.isSelected           = true
            centerView.isHidden         = true
            scaleMaskView.isHidden      = true
            bottomBtnsView.isHidden     = false
            scrollViewAngle.isHidden    = true
        }
    }

    func rotaBtnTapped(_ sender: UIButton) {
        if sender.isSelected == false {
            // 点击状态
            if cropBtn.isSelected == true {
                cropBtn.isSelected = false
            }
            sender.isSelected           = true
            centerView.isHidden         = false
            scaleMaskView.isHidden      = false
            bottomBtnsView.isHidden     = true
            scrollViewAngle.isHidden    = false
        }
    }

    func resetBtnTapped(_ sender: UIButton) {
        var width: CGFloat  = 0
        var height: CGFloat = 0
        switch sender.tag {
            case 0:
                // 1:1
                width = CX_W
                height = width * 1
            case 1:
                // 3:2
                width = CX_W
                height = width * 0.67
            case 2:
                // 4:3
                width = CX_W
                height = width * 0.75
            case 3:
                // 16:9
                width = CX_W
                height = width * 0.56
            case 4:
                //原图
                width = originalSize.width
                height = originalSize.height
            default:
                break
        }

        sizeImgId = sender.tag + 1
        isCrop = false
        for obj in proportionBtns.enumerated() {
            let btn = obj.element
            if btn.tag != sender.tag {
                // 取消其他按钮选中状态
                if btn.isSelected == true {
                    // 点击状态
                    btn.isSelected = false
                }
            }
            else {
                // 改变本身按钮选中状态
                if btn.isSelected == false {
                    btn.isSelected = true
                    self.configCropView(CGSize(width: width, height: height))
                }
            }
        }
    }

    func photoTranslation() -> CGPoint {
        let rect: CGRect? = photoContentView.convert((photoContentView.bounds), to: self)
        let point = CGPoint(x: CGFloat((rect?.origin.x)! + (rect?.size.width)! / 2), y: CGFloat((rect?.origin.y)! + (rect?.size.height)! / 2))
        let zeroPoint = CGPoint(x: CGFloat(frame.width / 2), y: currentCenterY)
        return CGPoint(x: CGFloat(point.x - zeroPoint.x), y: CGFloat(point.y - zeroPoint.y))
    }
}
