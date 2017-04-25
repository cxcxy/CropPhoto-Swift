//
//  ViewController.swift
//  CropPhoto-Swift
//
//  Created by 陈旭 on 2017/4/10.
//  Copyright © 2017年 陈旭. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,PhotoTweaksViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let a = max(1, 2)
        print(a)
    
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
    }
    //选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        //查看info对象
        print(info)
        
        //显示的图片
        let image:UIImage!
//        if editSwitch.isOn {
//            //获取编辑后的图片
//            image = info[UIImagePickerControllerEditedImage] as! UIImage
//        }else{
//            //获取选择的原图
            image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            let a = image.CGImage!.width
//        }
        //图片控制器退出
//        picker.dismiss(animated: true, completion: {
//            () -> Void in
//        })

        
        let photoTweaksViewController = CropPhotoViewController()
        photoTweaksViewController.delegate = self
//        photoTweaksViewController?.autoSaveToLibray = false
        
        photoTweaksViewController.image = image
        picker.pushViewController(photoTweaksViewController, animated: true)
        
    }
    func photoTweaksController(_ controller: CropPhotoViewController, didFinishWithCroppedImage croppedImage: UIImage){
        imageView.image = croppedImage
       _ = controller.navigationController?.popViewController(animated: true)
    }
  
    
    func photoTweaksControllerDidCancel(_ controller: CropPhotoViewController){
    _ = controller.navigationController?.popViewController(animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

