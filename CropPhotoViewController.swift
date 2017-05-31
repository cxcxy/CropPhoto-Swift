//
//  CropPhotoViewController.swift
//  CropPhoto-Swift
//
//  Created by 陈旭 on 2017/4/10.
//  Copyright © 2017年 陈旭. All rights reserved.
//

import UIKit
protocol PhotoTweaksViewControllerDelegate:class {
    
    func photoTweaksController(_ controller: CropPhotoViewController, didFinishWithCroppedImage croppedImage: UIImage)

    func photoTweaksControllerDidCancel(_ controller: CropPhotoViewController)

}
class CropPhotoViewController: UIViewController {

    var image: UIImage?

    var isAutoSaveToLibray: Bool = false

    var maxRotationAngle: CGFloat = 0.0

    weak var delegate: PhotoTweaksViewControllerDelegate?

    var saveButtonTitleColor: UIColor?

    var saveButtonHighlightTitleColor: UIColor?

    var cancelButtonTitleColor: UIColor?

    var cancelButtonHighlightTitleColor: UIColor?
 
    var resetButtonTitleColor: UIColor?
    
    var photoView:PhotoTweakView = PhotoTweakView()
    func setupSubviews() {
        photoView = PhotoTweakView(frame: CGRect(x: CGFloat(0), y: CGFloat(64), width: CGFloat(view.bounds.size.width), height: CGFloat(view.bounds.size.height - 64)), image: image ?? UIImage(), maxRotationAngle: maxRotationAngle)

        photoView.backgroundColor = UIColor.red
        view.addSubview(photoView)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
 

        title = "编辑图片"
        let button = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(60), height: CGFloat(30)))
        //设置按钮标题
        button.setTitle("返回", for: .normal)
        //设置按钮标题颜色
        button.setTitleColor(UIColor.red, for: .normal)
        //设置按钮标题字体
        button.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(12))
        //添加点击事件
        button.addTarget(self, action: #selector(self.cancelBtnTapped), for: .touchUpInside)
        //设置导航栏左按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        let regihtbutton = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(60), height: CGFloat(30)))
        //设置按钮标题
        regihtbutton.setTitle("下一步", for: .normal)
        //设置按钮标题颜色
        regihtbutton.setTitleColor(UIColor.red, for: .normal)
        //设置按钮标题字体
        regihtbutton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(12))
        setupSubviews()
        regihtbutton.addTarget(self, action: #selector(self.saveBtnTapped), for: .touchUpInside)
        //设置导航栏左按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: regihtbutton)

    }
    
    func cancelBtnTapped() {
        delegate?.photoTweaksControllerDidCancel(self)
    }
    
    func saveBtnTapped() {

        var transform = CGAffineTransform.identity
        // translate
        let translation: CGPoint = photoView.photoTranslation()
        transform = transform.translatedBy(x: (translation.x), y: (translation.y))
        // rotate
        transform = transform.rotated(by: photoView.angle)
        // scale
        let t: CGAffineTransform = (photoView.photoContentView.transform)
        let xScale: CGFloat = sqrt((t.a) * (t.a) + (t.c) * (t.c))
        let yScale: CGFloat = sqrt((t.b) * (t.b) + (t.d) * (t.d))
        transform = transform.scaledBy(x: xScale, y: yScale)
        
        let imageRef: CGImage = newTransformedImage(transform, sourceImage: self.image!.cgImage!, sourceSize: self.image!.size, sourceOrientation: self.image!.imageOrientation, outputWidth: self.image!.size.width, cropSize: (photoView.cropView?.frame.size)!, imageViewSize: (photoView.photoContentView.bounds.size))
        let image = UIImage(cgImage: imageRef)
    

//        if isAutoSaveToLibray {
//            var library = ALAssetsLibrary()
//            library.writeImage(toSavedPhotosAlbum: image.cgImage, metadata: nil, completionBlock: {(_ assetURL: URL, _ error: Error?) -> Void in
//                if error == nil {
//                    
//                }
//            })
//        }
        delegate?.photoTweaksController(self, didFinishWithCroppedImage: image)
    }
    
    func newScaledImage(_ source: CGImage, with orientation: UIImageOrientation, to size: CGSize, with quality: CGInterpolationQuality) -> CGImage {
        var srcSize: CGSize = size
        var rotation: CGFloat = 0.0
        switch orientation {
        case .up:
            rotation = 0
        case .down:
            rotation = .pi
        case .left:
            rotation = CGFloat(Double.pi/2)
            srcSize = CGSize(width: CGFloat(size.height), height: CGFloat(size.width))
        case .right:
            rotation = -(CGFloat)(Double.pi/2)
            srcSize = CGSize(width: CGFloat(size.height), height: CGFloat(size.width))
        default:
            break
        }
        
        let rgbColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)

        
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow:             //CGImageGetBitsPerComponent(source),
            0, space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.interpolationQuality = quality
        context?.translateBy(x: size.width / 2, y: size.height / 2)
        context?.rotate(by: rotation)
        context?.draw(source, in: CGRect(x: CGFloat(-srcSize.width / 2), y: CGFloat(-srcSize.height / 2), width: CGFloat(srcSize.width), height: CGFloat(srcSize.height)))

        let resultRef: CGImage = (context?.makeImage())!
  
        
        return resultRef
    }
    
    func newTransformedImage(_ transform: CGAffineTransform, sourceImage: CGImage, sourceSize: CGSize, sourceOrientation: UIImageOrientation, outputWidth: CGFloat, cropSize: CGSize, imageViewSize: CGSize) -> CGImage {
        let source: CGImage = newScaledImage(sourceImage, with: sourceOrientation, to: sourceSize, with: .none)
        let aspect: CGFloat = cropSize.height / cropSize.width
        let outputSize = CGSize(width: outputWidth, height: CGFloat(outputWidth * aspect))
        let context = CGContext(data: nil, width: Int(outputSize.width), height: Int(outputSize.height), bitsPerComponent: source.bitsPerComponent, bytesPerRow: 0, space: source.colorSpace!, bitmapInfo: source.bitmapInfo.rawValue)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(outputSize.width), height: CGFloat(outputSize.height)))
        var uiCoords = CGAffineTransform(scaleX: outputSize.width / cropSize.width, y: outputSize.height / cropSize.height)
        uiCoords = uiCoords.translatedBy(x: cropSize.width / 2.0, y: cropSize.height / 2.0)
        uiCoords = uiCoords.scaledBy(x: 1.0, y: -1.0)
        context?.concatenate(uiCoords)
        context?.concatenate(transform)
        context?.scaleBy(x: 1.0, y: -1.0)
         context?.draw(source, in: CGRect(x: CGFloat(-imageViewSize.width / 2.0), y: CGFloat(-imageViewSize.height / 2.0), width: CGFloat(imageViewSize.width), height: CGFloat(imageViewSize.height)))

        let resultRef: CGImage = context!.makeImage()!

        return resultRef
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
